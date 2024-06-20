async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    const SimpleDex = await ethers.getContractFactory("SimpleDex");
    const simpleDex = await SimpleDex.deploy();
  
    console.log("SimpleDex deployed to:", simpleDex.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });