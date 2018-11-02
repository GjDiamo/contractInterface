const express = require('express');
const router = express.Router();
const web3 = require('../utils/myUtils').getWeb3();
const myContract=require("../models/newContract").getContract();
const contractInfor=require('../controllers/contractInfor')
//获取账户余额(ok)
router.get('/getBalance', function(req, res, next) {
    contractInfor.getBalance(req, res, next)
    /* web3.eth.getBalance('0x61602D1a1cd1ea8B665218E75E95aF7Dec992a28').then(function (balance) {
          //进行币种的格式转换
         const B=web3.utils.fromWei(balance,'ether');
          //输出结果
          res.send(B)
      })*/
});
//获取CEO账户地址(ok)
router.get('/getCeoAddress', function(req, res, next) {
    (async ()=>{
        //创建变量并赋值
        const CEO=  await myContract.methods.getCeoAddress().call();
        //输出结果
        console.log(CEO.toString)
        res.send(CEO)
    })(next)
});
// 代币总额(ok)
router.get('/getTotalSupply', function(req, res, next) {
    (async ()=>{
        //创建变量并赋值
        const TotalSupply=  await myContract.methods.totalSupply().call();
        //打印结果
        console.log(TotalSupply)
        //输出结果
        res.send(TotalSupply.toString())
    })(next)
});
//带有传入参数的接口说明
//获取指定账户所拥有的财产(ok)
router.get('/getBalanceByAccounts/:accounts', function(req, res, next) {
    (async ()=>{
        //创建变量并赋值
        const balance=  await myContract.methods.balanceOf(req.params.accounts).call();
        //打印结果
        console.log(balance)
        //输出结果
        res.send(balance)
    })(next)
});
module.exports = router;
