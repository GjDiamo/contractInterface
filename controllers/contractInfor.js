//能够显示余额，但是在前端页面获取不到数据
const web3 = require('../utils/myUtils').getWeb3();
const myContract=require("../models/newContract").getContract();
module.exports={
    //获取指定账户余额
     getBalance:(req,res,next)=>{
        web3.eth.getBalance('0x61602D1a1cd1ea8B665218E75E95aF7Dec992a28').then(function (balance) {
         //进行币种的格式转换
        const Balance= web3.utils.fromWei(balance,'ether');
        console.log(Balance)
            //传给前端
         res.send(Balance)
     })
    },
    //获取Ceo账户
    getCeo:(req,res,next)=>{
        (async ()=>{
            //声明变量并且赋值
            const CEO=  await myContract.methods.getCeoAddress().call();
            //打印结果
            console.log(CEO)
            //传给前端
            res.send(CEO)
        })(next)
    },
    //获取合约状态
    getActive:(req,res,next)=>{
        (async ()=>{
            //声明变量并且赋值
            const active=await myContract.methods.getpaused().call();
            //打印结果
            console.log(active)
            //返回前端
            res.send(active)
        }) (next)
},
    //获取合约内部代币总额
    getTotal:(req,res,next)=>{
        (async ()=>{
            //声明变量并且赋值
            const TotalSupply=await myContract.methods.totalSupply().call();
            //打印结果
            console.log(TotalSupply)
            //传给前端
            res.send(TotalSupply)
        })(next)
    },
     //带有参数的get请求
    // 获取指定账户的代币数目
    getBalanceByAccounts:(req,res,next)=>{
            (async ()=>{
                //创建变量并赋值
                const balance=  await myContract.methods.balanceOf(req.params.accounts).call();
                //打印结果
                console.log(balance)
                //输出结果
                res.send(balance)
            })(next)
    },
    // 获取指定账户的具体代币
    getParkingSpaceOfByAccount:(req,res,next)=>{
        (async ()=>{
            //创建变量并赋值
            const balanceList=  await myContract.methods.parkingSpaceOf(req.params.accounts).call();
            //打印结果
            console.log(balanceList)
            //输出结果
            res.send(balanceList)
        })(next)
    },
    //获取data全部内容
    getDataByTokenId:(req,res,next)=>{
        (async ()=>{
            //创建变量并赋值
            const data=  await myContract.methods.referencedMetadata(req.params.tokenID).call();
            //打印结果
            console.log(data)
            //输出结果
            res.send(data)
        })(next)
    },
    //获取指定ID的地理位置
    getLocationByTokenId:(req,res,next)=>{
        (async ()=>{
            //创建变量并赋值
            const data=  await myContract.methods.referencedMetadata(req.params.tokenID).call();
            //打印结果
            console.log(data.location)
            //输出结果
            res.send(data.location)
        })(next)
    },
    //获取指定ID的归属地址
    getAddressByTokenId:(req,res,next)=>{
        (async ()=>{
            //创建变量并赋值
            const Address=  await myContract.methods.ownerOf(req.params.tokenID).call();
            //打印结果
            console.log(Address)
            //输出结果
            res.send(Address)
        })(next)
    },
}
