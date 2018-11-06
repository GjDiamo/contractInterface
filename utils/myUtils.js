//导出的是一个封装了web3内容的方法
module.exports={
    getWeb3:()=>{
        let Web3=require("web3");
        // const web3 = new Web3(Web3.givenProvider || 'http://127.0.0.1:8545');//连接私有链(本地)
        const web3=new Web3(Web3.givenProvider ||"https://rinkeby.infura.io/v3/1c0501c9704f4d99b4b9acb30534d60d");//这个是以太坊网络测试网络
        //主网
        return web3

    },
    success:(data)=>{
        responseData={
            code:0,
            status:"success",
            data:data
        }
        return responseData
    },
    fail:(msg)=>{
        responseData={
            code:1,
            status: 'fail',
            msg:msg
        }
    },
}