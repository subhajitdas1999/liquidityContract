// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Interface/IUniswapV2Router02.sol";
import "./Interface/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract MyLiquidity{
    // UniswapV2Router02 contract on Rinkeby network
    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    //UniswapV2Factory contract on rinkeby network
    address public factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    //strore the lp tokens of a user
    // this contract holds all the liquidity of all user
    //mapp msg.sender and pair address(pool) to the lp token
    mapping(address => mapping(address => uint)) public liquidityOf;

    //to add liquidity . need to approve this contract from tokenA and tokenB
    function addLiquidity(address tokenA,address tokenB,uint amountA,uint amountB) external{
        require(address(0)!=tokenA && address(0)!=tokenB,"Token address cannot be zero address");
        require(amountA>=10000 && amountB>=10000,"both token amount should be greater than or equal 10000");

        //transfer all the tokens to this contract
        IERC20(tokenA).transferFrom(msg.sender,address(this),amountA);
        IERC20(tokenB).transferFrom(msg.sender,address(this),amountB);
    
        //approve the router contract
        IERC20(tokenA).approve(router,amountA);
        IERC20(tokenB).approve(router,amountB);

        //call the function addLiquidity in router contract
        (uint TokenAamount,uint TokenBamountB,uint LPToken)=IUniswapV2Router02(router).addLiquidity(tokenA,tokenB,amountA,amountB,1,1,address(this),block.timestamp);
        
        //get the pair address(pool)
        address pair = IUniswapV2Factory(factory).getPair(tokenA,tokenB);

        // this contract address holds all the lp tokens
        //check it with IERC(pair).balanceOf(address(this))

        //add the liquidity to the collection
        liquidityOf[msg.sender][pair] += LPToken ;

        //emit the event
        emit AddedLiquidity(TokenAamount,TokenBamountB,LPToken,pair);

    }

    function removeLiquidity(address tokenA,address tokenB) external {
        require(address(0)!=tokenA && address(0)!=tokenB,"Token address cannot be zero address");

        //get the liquidity pool (pair)
        address pair  = IUniswapV2Factory(factory).getPair(tokenA,tokenB);

        require(liquidityOf[msg.sender][pair] > 0 ,"you don't have any liquidity to the pool");

        //sender liquidity
        uint senderLiquidity = liquidityOf[msg.sender][pair];

        //update the liquidity of the user
        liquidityOf[msg.sender][pair] = 0;

        //this contracts holds all the liquidity , so contract should approve senders all liquidity to the router contract
        //approve so that it can send the lp tokens to the pool address and burn it
        IERC20(pair).approve(router,senderLiquidity);

        //call the remove liquidity function
        //1,1 = Token A minimum , Token B minimum
        (uint TokenAamount,uint TokenBamount)=IUniswapV2Router02(router).removeLiquidity(tokenA,tokenB,senderLiquidity,1,1,address(this),block.timestamp);
      
       
        //send back the tokens to the user
        IERC20(tokenA).transfer(msg.sender,TokenAamount);
        IERC20(tokenB).transfer(msg.sender,TokenBamount);
        
        //emit the event
        emit RemovedLiquidity (TokenAamount,TokenBamount,pair);
    }

    /* all events */
    event AddedLiquidity(uint amountA,uint amountB,uint LPToken,address PoolAddress);
    event RemovedLiquidity(uint amountA,uint amountB,address PoolAddress);
}