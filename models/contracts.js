//标准导出以太坊智能合约的方式
 const web3=require("../utils/myUtils").getWeb3();
 module.exports={
     getContract:()=>{
         let ABI=[
             {
                 "constant": false,
                 "inputs": [
                     {
                         "name": "_to",
                         "type": "address"
                     },
                     {
                         "name": "_tokenId",
                         "type": "uint256"
                     }
                 ],
                 "name": "approve",
                 "outputs": [],
                 "payable": false,
                 "stateMutability": "nonpayable",
                 "type": "function"
             },
             {
                 "constant": true,
                 "inputs": [],
                 "name": "totalSupply",
                 "outputs": [
                     {
                         "name": "_totalSupply",
                         "type": "uint256"
                     }
                 ],
                 "payable": false,
                 "stateMutability": "view",
                 "type": "function"
             },
             {
                 "constant": false,
                 "inputs": [
                     {
                         "name": "_from",
                         "type": "address"
                     },
                     {
                         "name": "_to",
                         "type": "address"
                     },
                     {
                         "name": "_tokenId",
                         "type": "uint256"
                     }
                 ],
                 "name": "transferFrom",
                 "outputs": [],
                 "payable": false,
                 "stateMutability": "nonpayable",
                 "type": "function"
             },
             {
                 "constant": false,
                 "inputs": [
                     {
                         "name": "_newCEO",
                         "type": "address"
                     }
                 ],
                 "name": "setCEO",
                 "outputs": [],
                 "payable": false,
                 "stateMutability": "nonpayable",
                 "type": "function"
             },
             {
                 "constant": false,
                 "inputs": [],
                 "name": "unpause",
                 "outputs": [],
                 "payable": false,
                 "stateMutability": "nonpayable",
                 "type": "function"
             },
             {
                 "constant": true,
                 "inputs": [
                     {
                         "name": "_tokenId",
                         "type": "uint256"
                     }
                 ],
                 "name": "ownerOf",
                 "outputs": [
                     {
                         "name": "_owner",
                         "type": "address"
                     }
                 ],
                 "payable": false,
                 "stateMutability": "view",
                 "type": "function"
             },
             {
                 "constant": true,
                 "inputs": [
                     {
                         "name": "_tokenId",
                         "type": "uint256"
                     }
                 ],
                 "name": "tokenMetadata",
                 "outputs": [
                     {
                         "components": [
                             {
                                 "name": "location",
                                 "type": "string"
                             },
                             {
                                 "name": "price",
                                 "type": "uint256"
                             }
                         ],
                         "name": "",
                         "type": "tuple"
                     }
                 ],
                 "payable": false,
                 "stateMutability": "view",
                 "type": "function"
             },
             {
                 "constant": true,
                 "inputs": [
                     {
                         "name": "_owner",
                         "type": "address"
                     }
                 ],
                 "name": "balanceOf",
                 "outputs": [
                     {
                         "name": "_balance",
                         "type": "uint256"
                     }
                 ],
                 "payable": false,
                 "stateMutability": "view",
                 "type": "function"
             },
             {
                 "constant": false,
                 "inputs": [],
                 "name": "pause",
                 "outputs": [],
                 "payable": false,
                 "stateMutability": "nonpayable",
                 "type": "function"
             },
             {
                 "constant": false,
                 "inputs": [
                     {
                         "name": "_tokenId",
                         "type": "uint256"
                     }
                 ],
                 "name": "destroyParkingSpace",
                 "outputs": [],
                 "payable": false,
                 "stateMutability": "nonpayable",
                 "type": "function"
             },
             {
                 "constant": false,
                 "inputs": [
                     {
                         "name": "_to",
                         "type": "address"
                     },
                     {
                         "name": "_tokenId",
                         "type": "uint256"
                     }
                 ],
                 "name": "transfer",
                 "outputs": [],
                 "payable": false,
                 "stateMutability": "nonpayable",
                 "type": "function"
             },
             {
                 "constant": false,
                 "inputs": [
                     {
                         "name": "_tokenId",
                         "type": "uint256"
                     },
                     {
                         "name": "_location",
                         "type": "string"
                     },
                     {
                         "name": "_price",
                         "type": "uint256"
                     }
                 ],
                 "name": "mint",
                 "outputs": [],
                 "payable": false,
                 "stateMutability": "nonpayable",
                 "type": "function"
             },
             {
                 "constant": true,
                 "inputs": [],
                 "name": "getCEOAddress",
                 "outputs": [
                     {
                         "name": "",
                         "type": "address"
                     }
                 ],
                 "payable": false,
                 "stateMutability": "view",
                 "type": "function"
             },
             {
                 "constant": false,
                 "inputs": [
                     {
                         "name": "_owner",
                         "type": "address"
                     },
                     {
                         "name": "_tokenId",
                         "type": "uint256"
                     },
                     {
                         "name": "_location",
                         "type": "string"
                     },
                     {
                         "name": "_price",
                         "type": "uint256"
                     }
                 ],
                 "name": "mintWithMetadata",
                 "outputs": [],
                 "payable": false,
                 "stateMutability": "nonpayable",
                 "type": "function"
             },
             {
                 "anonymous": false,
                 "inputs": [
                     {
                         "indexed": true,
                         "name": "_to",
                         "type": "address"
                     },
                     {
                         "indexed": true,
                         "name": "_tokenId",
                         "type": "uint256"
                     }
                 ],
                 "name": "Minted",
                 "type": "event"
             },
             {
                 "anonymous": false,
                 "inputs": [
                     {
                         "indexed": true,
                         "name": "_from",
                         "type": "address"
                     },
                     {
                         "indexed": true,
                         "name": "_to",
                         "type": "address"
                     },
                     {
                         "indexed": false,
                         "name": "_tokenId",
                         "type": "uint256"
                     }
                 ],
                 "name": "Transfer",
                 "type": "event"
             },
             {
                 "anonymous": false,
                 "inputs": [
                     {
                         "indexed": true,
                         "name": "_owner",
                         "type": "address"
                     },
                     {
                         "indexed": true,
                         "name": "_approved",
                         "type": "address"
                     },
                     {
                         "indexed": false,
                         "name": "_tokenId",
                         "type": "uint256"
                     }
                 ],
                 "name": "Approval",
                 "type": "event"
             },
             {
                 "anonymous": false,
                 "inputs": [
                     {
                         "indexed": true,
                         "name": "_to",
                         "type": "address"
                     },
                     {
                         "indexed": true,
                         "name": "_tokenId",
                         "type": "uint256"
                     }
                 ],
                 "name": "destroy",
                 "type": "event"
             }
         ]
         let contractAddress='0x11f2a42ae346b8f2ee9d584bad904e09b8f731c1';//ERC721 ParkingSpace 合约'
         let myContract=new web3.eth.Contract(ABI,contractAddress);
         return myContract
     },
 }