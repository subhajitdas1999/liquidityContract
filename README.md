# liquidityContract 
This contract uses the router and factory contract of uniswap v2 (rinkeby network)

User need to approve the token amounts to this contract before calling the addLiquidity function.

after adding the liquidity user will get some LP tokens ,which will get stored in the contract , user can check it by calling the 

the liquidityOf function (ex liquidityOf(userAddress,poolAddress), user will get the pool address in event, emitted during addLiquidity func call).

User can remove liquidity by calling the removeLiquidity func along with two token address.

# Contract Addresses
All the contract is deployed at Rinkeby network

tokenA is deployed at (0x1E97446647d94d36e987e5b353Ec66Dd53B476aB)
tokenB is deployed at (0xC52329f1e51E09D9a2B5da6426D9f946D6b16079)

ERC 20 token contract is verified. [etherscan link](https://rinkeby.etherscan.io/address/0x1E97446647d94d36e987e5b353Ec66Dd53B476aB#code)

MyLiquidity is deployed at (0xf333956F26aA3549E265e3a5C02E265aF21F1D71)
MyLiquidity contract is verified .[etherscan link](https://rinkeby.etherscan.io/address/0xf333956F26aA3549E265e3a5C02E265aF21F1D71#code)


# To run tests

we have forked the rinkeby network .For details see hardhat.config.js

to run the tests, first enter the all the necessary env details to a .env files (for details see .env.example files)

then from root directory run,

 -npx hardhat test
