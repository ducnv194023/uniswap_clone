async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    const LPT = await ethers.getContractFactory("LiquidityToken");
    const lpt = await LPT.deploy();
  
    console.log("LPT deployed to:", lpt.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });