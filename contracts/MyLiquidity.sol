// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Interface/IUniswapV2Router02.sol";
import "./Interface/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title A DEX like contract
/// @author Subhajit Das
/// @notice contract helps user to create liquidity pool, add liquidity to the pool, removes liquiidty, swap tokens
/// @dev this contract uses the router and factory contract of UniSwapV2 and calls the functions from this contract
/// @custom:experimental This is an experimental contract.

contract MyLiquidity {
    /// @dev UniswapV2Router02 contract on sepolia network
    address public router = 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008;
    /// @dev UniswapV2Factory contract on sepolia network
    address public factory = 0x7E0987E5b3a30e3f2828572Bb659A548460a3003;

    /// @notice strore the lp tokens of a user
    /// @dev this contract holds all the liquidity of all user
    /// @dev msg.sender and pair address(pool) to the lp token
    /// @return liquidity of a user in a pool
    mapping(address => mapping(address => uint256)) public liquidityOf;

    /// @notice To add liquidity in pool
    /// @notice before calling this func user need to approve the tokenAmounts to this contract from tokenA and tokenB
    /// @dev after adding liquidity user gets some LP tokens , which is stored in this contract
    /// @dev user can check it by calling the liquidityOf func with userAddress,pool address
    /// @param tokenA first token Address
    /// @param tokenB second token Address
    /// @param amountA first token Amount
    /// @param amountB second token Amount
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB
    ) external {
        require(
            address(0) != tokenA && address(0) != tokenB,
            "Token address cannot be zero address"
        );
        require(
            amountA >= 10000 && amountB >= 10000,
            "both token amount should be greater than or equal 10000"
        );

        /// @dev transfer all the tokens to this contract
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        /// @dev approve the router contract
        IERC20(tokenA).approve(router, amountA);
        IERC20(tokenB).approve(router, amountB);

        /// @dev call the function addLiquidity in router contract
        (
            uint256 TokenAamount,
            uint256 TokenBamountB,
            uint256 LPToken
        ) = IUniswapV2Router02(router).addLiquidity(
                tokenA,
                tokenB,
                amountA,
                amountB,
                1,
                1,
                address(this),
                block.timestamp
            );

        /// @dev get the pair address(pool)
        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);

        /// @dev this contract address holds all the lp tokens
        /// @dev check it with IERC(pair).balanceOf(address(this))

        /// @dev add the liquidity to the collection
        liquidityOf[msg.sender][pair] += LPToken;

        /// @dev emit the event
        emit AddedLiquidity(TokenAamount, TokenBamountB, LPToken, pair);
    }

    /// @notice call this function to remove the liquidity you had provided
    /// @dev this func reverts if caller doesn't have any liquidity to the pool
    /// @dev this func sends the tokens to the caller address
    /// @param tokenA first token address
    /// @param tokenB second token address
    function removeLiquidity(address tokenA, address tokenB) external {
        require(
            address(0) != tokenA && address(0) != tokenB,
            "Token address cannot be zero address"
        );

        /// @dev get the liquidity pool (pair)
        address pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);

        require(
            liquidityOf[msg.sender][pair] > 0,
            "you don't have any liquidity to the pool"
        );

        /// @dev get the sender liquidity
        uint256 senderLiquidity = liquidityOf[msg.sender][pair];

        /// @dev update the liquidity of the user
        liquidityOf[msg.sender][pair] = 0;

        /// @dev this contracts holds all the liquidity , so contract should approve senders all liquidity to the router contract
        /// @dev approve so that it can send the lp tokens to the pool address and burn it
        IERC20(pair).approve(router, senderLiquidity);

        /// @dev call the remove liquidity function
        /// @dev 1,1 = Token A minimum , Token B minimum
        (uint256 TokenAamount, uint256 TokenBamount) = IUniswapV2Router02(
            router
        ).removeLiquidity(
                tokenA,
                tokenB,
                senderLiquidity,
                1,
                1,
                msg.sender,
                block.timestamp
            );

        /// @dev emit the event
        emit RemovedLiquidity(TokenAamount, TokenBamount, pair);
    }

    /// @notice call the function to swap tokens (ex. tokenA -> tokenB)
    /// @notice caller need to approve the token amount (amount user want to swap) to the contract
    /// @dev after swapping the token ,caller will get the desired tokens to his address
    /// @param fromToken the address of the token user is ready to swap
    /// @param toToken the address of the token user wants to get
    /// @param tokenAmountForSwap the amount of token user wants to swap to get the toToken
    function swapTokens(
        address fromToken,
        address toToken,
        uint256 tokenAmountForSwap
    ) external {
        address pair = IUniswapV2Factory(factory).getPair(fromToken, toToken);

        /// @dev if pool is not exist,revert
        require(pair != address(0), "Pool is not exist");
        /// @dev transfer the tokens from sender address to contract address
        IERC20(fromToken).transferFrom(
            msg.sender,
            address(this),
            tokenAmountForSwap
        );

        /// @dev approve this token for the router contract
        IERC20(fromToken).approve(router, tokenAmountForSwap);

        /// @dev path of swapping the token
        address[] memory path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;
        /// @dev get the token amount , user will get after the swapping
        uint256 tokenAmountOut = IUniswapV2Router02(router).getAmountsOut(
            tokenAmountForSwap,
            path
        )[1];
        /// @dev swap the tokns
        IUniswapV2Router02(router).swapExactTokensForTokens(
            tokenAmountForSwap,
            tokenAmountOut,
            path,
            msg.sender,
            block.timestamp
        );
        /// @dev emit the event
        emit TokenSwapped(tokenAmountOut, msg.sender);
    }

    function getAmountsOut(
        address tokenA,
        address tokenB,
        uint256 tokenAmountForSwap
    ) external view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;

        uint256 tokenAmountOut = IUniswapV2Router02(router).getAmountsOut(
            tokenAmountForSwap,
            path
        )[1];

        return tokenAmountOut;
    }

    /* all events */
    event AddedLiquidity(
        uint256 amountA,
        uint256 amountB,
        uint256 LPToken,
        address PoolAddress
    );
    event RemovedLiquidity(
        uint256 amountA,
        uint256 amountB,
        address PoolAddress
    );
    event TokenSwapped(uint256 TokenAmountOut, address tokenReciever);
}
