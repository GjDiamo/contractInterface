pragma solidity 0.4.24;

library strings {
    struct slice {
        uint _len;
        uint _ptr;
    }
    function memcpy(uint dest, uint src, uint len) private pure {
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }
    function toSlice(string memory self) internal pure returns (slice memory) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }
    function len(bytes32 self) internal pure returns (uint) {
        uint ret;
        if (self == 0)
            return 0;
        if (self & 0xffffffffffffffffffffffffffffffff == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (self & 0xffffffffffffffff == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (self & 0xffffffff == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (self & 0xffff == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (self & 0xff == 0) {
            ret += 1;
        }
        return 32 - ret;
    }
    function toSliceB32(bytes32 self) internal pure returns (slice memory ret) {
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, self)
            mstore(add(ret, 0x20), ptr)
        }
        ret._len = len(self);
    }
    function copy(slice memory self) internal pure returns (slice memory) {
        return slice(self._len, self._ptr);
    }
    function toString(slice memory self) internal pure returns (string memory) {
        string memory ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }
    function len(slice memory self) internal pure returns (uint l) {
        uint ptr = self._ptr - 31;
        uint end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }
    function empty(slice memory self) internal pure returns (bool) {
        return self._len == 0;
    }
    function compare(slice memory self, slice memory other) internal pure returns (int) {
        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;
        uint selfptr = self._ptr;
        uint otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                uint256 mask = uint256(-1); // 0xffff...
                if(shortest < 32) {
                    mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                }
                uint256 diff = (a & mask) - (b & mask);
                if (diff != 0)
                    return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }
    function equals(slice memory self, slice memory other) internal pure returns (bool) {
        return compare(self, other) == 0;
    }
    function nextRune(slice memory self, slice memory rune) internal pure returns (slice memory) {
        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }
        uint l;
        uint b;
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
        if (b < 0x80) {
            l = 1;
        } else if(b < 0xE0) {
            l = 2;
        } else if(b < 0xF0) {
            l = 3;
        } else {
            l = 4;
        }
        if (l > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }
        self._ptr += l;
        self._len -= l;
        rune._len = l;
        return rune;
    }
    function nextRune(slice memory self) internal pure returns (slice memory ret) {
        nextRune(self, ret);
    }
    function ord(slice memory self) internal pure returns (uint ret) {
        if (self._len == 0) {
            return 0;
        }
        uint word;
        uint length;
        uint divisor = 2 ** 248;
        assembly { word:= mload(mload(add(self, 32))) }
        uint b = word / divisor;
        if (b < 0x80) {
            ret = b;
            length = 1;
        } else if(b < 0xE0) {
            ret = b & 0x1F;
            length = 2;
        } else if(b < 0xF0) {
            ret = b & 0x0F;
            length = 3;
        } else {
            ret = b & 0x07;
            length = 4;
        }
        if (length > self._len) {
            return 0;
        }
        for (uint i = 1; i < length; i++) {
            divisor = divisor / 256;
            b = (word / divisor) & 0xFF;
            if (b & 0xC0 != 0x80) {
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }
        return ret;
    }
    function keccak(slice memory self) internal pure returns (bytes32 ret) {
        assembly {
            ret := keccak256(mload(add(self, 32)), mload(self))
        }
    }
    function startsWith(slice memory self, slice memory needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }
        if (self._ptr == needle._ptr) {
            return true;
        }
        bool equal;
        assembly {
            let length := mload(needle)
            let selfptr := mload(add(self, 0x20))
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }
        return equal;
    }
    function beyond(slice memory self, slice memory needle) internal pure returns (slice memory) {
        if (self._len < needle._len) {
            return self;
        }
        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let selfptr := mload(add(self, 0x20))
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }
        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }
        return self;
    }
    function endsWith(slice memory self, slice memory needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        uint selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }

        return equal;
    }
    function until(slice memory self, slice memory needle) internal pure returns (slice memory) {
        if (self._len < needle._len) {
            return self;
        }
        uint selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }
        if (equal) {
            self._len -= needle._len;
        }
        return self;
    }
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr = selfptr;
        uint idx;
        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }
                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }
                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr;
            } else {
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }
                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr;
        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }
                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }
                while (ptrdata != needledata) {
                    if (ptr <= selfptr)
                        return selfptr;
                    ptr--;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr + needlelen;
            } else {
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }
    function find(slice memory self, slice memory needle) internal pure returns (slice memory) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }
    function rfind(slice memory self, slice memory needle) internal pure returns (slice memory) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
    }
    function split(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }
    function split(slice memory self, slice memory needle) internal pure returns (slice memory token) {
        split(self, needle, token);
    }
    function rsplit(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }
    function rsplit(slice memory self, slice memory needle) internal pure returns (slice memory token) {
        rsplit(self, needle, token);
    }
   function count(slice memory self, slice memory needle) internal pure returns (uint cnt) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }
    function contains(slice memory self, slice memory needle) internal pure returns (bool) {
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }
    function concat(slice memory self, slice memory other) internal pure returns (string memory) {
        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }
    function join(slice memory self, slice[] memory parts) internal pure returns (string memory) {
        if (parts.length == 0)
            return "";
        uint length = self._len * (parts.length - 1);
        for(uint i = 0; i < parts.length; i++)
            length += parts[i]._len;

        string memory ret = new string(length);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        for(i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }
        return ret;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC721 {
    function implementsERC721() public pure returns (bool);         //是否是erc721
    function totalSupply() public view returns (uint256 total);     //总供应量
    function balanceOf(address _owner) public view returns (uint256 balance);   //余额
    function ownerOf(uint256 _tokenId) public view returns (address owner);     //所有者
    // function approve(address _to, uint256 _tokenId) public returns (bool);      //批准
    // function transferFrom(address _from, address _to, uint256 _tokenId) public returns (bool);  //from转移给to
    function transfer(address _to, uint256 _tokenId) public returns (bool);                     //转移给to
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);          //转移事件
    // event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);   //批准事件

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);
}

contract parkingSpaceBase  is ERC721 {
    using SafeMath for uint256; // afeMath方法可用于类型“unit256”

     using strings for *;

    address ceoAddress = msg.sender;

    // 管理协议是否被暂定，暂停时大多数行动都会被阻塞
    bool paused = false;

    // 车位的结构体
    struct ParkingSpace{
        string location; // 位置
        string URL; // 资源链接
    }

    // ------------- 变量

    uint256 public totalSupply;

    // 基本的引用
    mapping(uint256 => address) private tokenIdToOwner;   //  车位ID => 拥有者地址
    mapping(address => uint256[]) private listOfOwnerTokens;  //  账号地址 => Tokens
    mapping(uint256 => uint256) private tokenIndexInOwnerArray;  //  Token ID => 数组里面的索引
    // 批准的映射
    // mapping(uint256 => address) private approvedAddressToTransferTokenId; //  拥有者地址 => Token ID
    // 车位数据信息
    mapping(uint256 => ParkingSpace) public referencedMetadata;  //  车位ID => 参数

    // ------------- 事件

    event Minted(address indexed _to, uint256 indexed _tokenId);

    // event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    // event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    event destroy(address indexed _to, uint256 indexed _tokenId);

    // ------------- Modifier

    // token不存在的检查
    modifier onlyNonexistentToken(uint256 _tokenId) {
        require(tokenIdToOwner[_tokenId] == address(0));
        _;
    }
    // token存在的检查
    modifier onlyExtantToken(uint256 _tokenId) {
        require(ownerOf(_tokenId) != address(0));
        _;
    }
    // CEO权限检查
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// @dev 提供没有被暂停的状态检查
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev 提供被暂停的状态检查
    modifier whenPaused {
        require(paused);
        _;
    }

    // ------------- (视图)函数

    function getpaused() public view returns (bool){
        return paused;
    }

    function getCEOAddress() public view returns (address){
        return ceoAddress;
    }

    // @dev 返回当前标记为_tokenID所有者的地址。
    function ownerOf(uint256 _tokenId) public view returns (address)
    {
        return tokenIdToOwner[_tokenId];
    }

    // @dev 获取本合同所持有的令牌的总供应量。
    function totalSupply() public view returns (uint256 )
    {
        return totalSupply;
    }

    // @dev 返回当前地址拥有的令牌数量
    function balanceOf(address _owner) public view returns (uint256 )
    {
        return listOfOwnerTokens[_owner].length;
    }

    function tokenMetadata(uint _tokenId) public view returns (string)
    {
        return referencedMetadata[_tokenId].location.toSlice().concat( referencedMetadata[_tokenId].URL.toSlice());
    }

    // @dev 返回当前地址拥有的令牌列表
    function parkingSpaceOf(address _owner) public view returns (uint256[])
    {
        return listOfOwnerTokens[_owner];
    }

    // ------------- (核心) 函数

    // 让当前CEO指派一名新的CEO
    function setCEO(address _newCEO) public onlyCEO returns (bool){
        require(_newCEO != address(0));

        ceoAddress = _newCEO;

        return true;
    }

    /// @dev CEO 能够启动暂停操作，用以应对潜在的bug和缺陷，以降低损失
    function pause() public onlyCEO whenNotPaused returns (bool) {
        paused = true;
        return true;

    }

    /// @dev 只有CEO能够取消暂停状态
    function unpause() public onlyCEO whenPaused returns (bool) {
        paused = false;
        return true;
    }

    // @dev CEO可以创建一个令牌并将其交给CEO
    function mint(uint256 _tokenId, string _location, string _URL) public onlyNonexistentToken(_tokenId) onlyCEO whenNotPaused returns (bool)
    {
        _setTokenOwner(_tokenId, ceoAddress);
        _addTokenToOwnersList(ceoAddress, _tokenId);

        totalSupply = totalSupply.add(1);

        _insertTokenMetadata(_tokenId, _location, _URL);
        emit Minted(ceoAddress, _tokenId);
        return true;
    }

    // @dev CEO可以创建一个令牌并将其交给所有者
    // @notice 根据用例，只应该使用其中一个函数(Mint、mintWithMetadata)
    function mintWithMetadata(address _owner, uint256 _tokenId, string _location, string _URL ) public onlyNonexistentToken(_tokenId) onlyCEO whenNotPaused returns (bool)
    {
        _setTokenOwner(_tokenId, _owner);
        _addTokenToOwnersList(_owner, _tokenId);

        totalSupply = totalSupply.add(1);

        _insertTokenMetadata(_tokenId, _location, _URL);
        emit Minted(_owner, _tokenId);
        return true;
    }


/*    function approve(address _to, uint256 _tokenId) public onlyExtantToken(_tokenId) whenNotPaused returns (bool)
    {
        require(ownerOf(_tokenId) == msg.sender);
        require(_to != address(0));

        _clearApprovalAndTransfer(msg.sender, _to, _tokenId);

        emit Approval(msg.sender, _to, _tokenId);

        return true;
    }*/

    // @dev 将ID为_tokenId的NFT的所有权分配给_to
    function transfer(address _to, uint256 _tokenId) public onlyExtantToken(_tokenId) whenNotPaused returns (bool)
    {
        require(ownerOf(_tokenId) == msg.sender);
        require(_to != address(0));
        require(_to != msg.sender);

        _clearApprovalAndTransfer(msg.sender, _to, _tokenId);

        emit Transfer(msg.sender, _to, _tokenId);

        return true;
    }


/*    // @dev 将令牌从_from传递到_to
    // @notice 地址_from是不必要的
    function transferFrom(address _from, address _to, uint256 _tokenId) public onlyExtantToken(_tokenId) whenNotPaused returns (bool)
    {
        require(approvedAddressToTransferTokenId[_tokenId] == msg.sender);
        require(ownerOf(_tokenId) == _from);
        require(_to != address(0));

        _clearApprovalAndTransfer(_from, _to, _tokenId);

        // emit Approval(_from, 0, _tokenId);
        emit Transfer(_from, _to, _tokenId);

        return true;
    }*/

    // 销毁令牌
    function destroyParkingSpace(uint256 _tokenId) public onlyExtantToken(_tokenId) whenNotPaused returns (bool)
    {
        require(ownerOf(_tokenId) == msg.sender);
        /*_clearTokenApproval(_tokenId);
        _removeTokenFromOwnersList(msg.sender, _tokenId);*/

        delete tokenIdToOwner[_tokenId];
        delete listOfOwnerTokens[msg.sender];
        // delete approvedAddressToTransferTokenId[_tokenId];
        delete referencedMetadata[_tokenId];
        totalSupply--;

        emit destroy(msg.sender, _tokenId);
        return true;
    }


    // ---------------------------- 内部,辅助函数

    function _setTokenOwner(uint256 _tokenId, address _owner) internal
    {
        tokenIdToOwner[_tokenId] = _owner;
    }

    function _addTokenToOwnersList(address _owner, uint256 _tokenId) internal
    {
        listOfOwnerTokens[_owner].push(_tokenId);
        tokenIndexInOwnerArray[_tokenId] = listOfOwnerTokens[_owner].length - 1;
    }

    function _clearApprovalAndTransfer(address _from, address _to, uint256 _tokenId) internal
    {
        // _clearTokenApproval(_tokenId);
        _removeTokenFromOwnersList(_from, _tokenId);
        _setTokenOwner(_tokenId, _to);
        _addTokenToOwnersList(_to, _tokenId);
    }

    function _removeTokenFromOwnersList(address _owner, uint256 _tokenId) internal
    {
        uint256 length = listOfOwnerTokens[_owner].length; // 所有者令牌长度
        uint256 index = tokenIndexInOwnerArray[_tokenId]; // 有者数组中令牌的索引
        uint256 swapToken = listOfOwnerTokens[_owner][length - 1]; // 数组中的最后一个令牌

        listOfOwnerTokens[_owner][index] = swapToken; // 最后一个标记被推到被转移的那个标记的位置
        tokenIndexInOwnerArray[swapToken] = index; // 更新我们移动的令牌的索引

        delete listOfOwnerTokens[_owner][length - 1]; // 把箱子搬开，我们倒空了
        listOfOwnerTokens[_owner].length--; // 缩短数组的长度
    }

/*    function _clearTokenApproval(uint256 _tokenId) internal
    {
        approvedAddressToTransferTokenId[_tokenId] = address(0);
    }*/

    function _insertTokenMetadata(uint256 _tokenId, string _location, string _URL) internal
    {
        ParkingSpace memory ps = ParkingSpace(
            _location,
            _URL
        );
        referencedMetadata[_tokenId] =  ps;
    }
}


contract MyparkingSpace is parkingSpaceBase {
    string public constant name = " MyparkingSpace";
    string public constant symbol = "MPS";

    function implementsERC721() public pure returns (bool)
    {
        return true;
    }

    function() public payable {
        revert();
    }
}