async function main() {
    const [deployer] = await ethers.getSigners();
    // both token decimal is 0 and initial supply is 100 million
    const initialSupply = 100000000;

    MyLiquidity = await ethers.getContractFactory("MyLiquidity");
    Token = await ethers.getContractFactory("MyERC20Token");
    myLiquidity = await MyLiquidity.deploy();
    tokenA = await Token.deploy("MyTokenA", "MTA", initialSupply);
    tokenB = await Token.deploy("MyTokenB", "MTB", initialSupply);

   
    console.log("Deploying contracts with the account:", deployer.address);  
    console.log("Account balance:", (await deployer.getBalance()).toString());
    console.log("liquidity contract address:", myLiquidity.address);
    console.log("TokenA address:", tokenA.address);
    console.log("TokenB address:", tokenB.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });