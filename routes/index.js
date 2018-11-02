const express = require('express');
const router = express.Router();
const contractInfor=require('../controllers/contractInfor')
//获取账户余额(ok)
router.get('/getBalance', function(req, res, next) {
    contractInfor.getBalance(req, res, next)
});
//获取CEO账户地址(ok)
router.get('/getCeoAddress', function(req, res, next) {
    contractInfor.getCeo(req, res, next)
});
// 代币总额
router.get('/getTotalSupply', function(req, res, next) {
   contractInfor.getTotal(req,res,next)
});
//获取指定账户所拥有的财产(ok)
router.get('/getBalanceByAccounts/:accounts', function(req, res, next) {
   contractInfor.getBalanceByAccounts(req,res,next)
});
module.exports = router;
