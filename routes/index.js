const express = require('express');
const router = express.Router();
const contractInfor=require('../controllers/contractInfor')
//获取账户余额；
router.get('/getBalance', function(req, res, next) {
    contractInfor.getBalance(req, res, next)
});
//获取CEO账户地址；
router.get('/getCeoAddress', function(req, res, next) {
    contractInfor.getCeo(req, res, next)
});
// 代币总额；
router.get('/getTotalSupply', function(req, res, next) {
   contractInfor.getTotal(req,res,next)
});
// 获取合约状态
router.get('/getActive', function(req, res, next) {
    contractInfor.getActive(req,res,next)
});
//获取指定账户所拥有的财产个数；
router.get('/getBalanceByAccounts/:accounts', function(req, res, next) {
   contractInfor.getBalanceByAccounts(req,res,next)
});
//获取指定账户所拥有的具体车位财产；
 router.get('/getParkingSpaceOfByAccount/:accounts', function(req, res, next) {
   contractInfor.getParkingSpaceOfByAccount(req,res,next)
 });

//获取指定ID的data信息；
router.get('/getDataByTokenId/:tokenID', function(req, res, next) {
    contractInfor.getDataByTokenId(req,res,next)
});
//获取指定ID的地理位置
router.get('/getLocationByTokenId/:tokenID', function(req, res, next) {
    contractInfor.getLocationByTokenId(req,res,next)
});
//获取指定ID的URL
router.get('/getUrlByTokenId/:tokenID', function(req, res, next) {
    contractInfor.getUrlByTokenId(req,res,next)
});
//获取指定ID的归属地址
router.get('/getAddressByTokenId/:tokenID', function(req, res, next) {
    contractInfor.getAddressByTokenId(req,res,next)
});
module.exports = router;
