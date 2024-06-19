async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    const Mock = await ethers.getContractFactory("MockERC20");
    const mock = await Mock.deploy("Test", "TET");
    console.log(mock)
    console.log('mock')

    console.log("Mock deployed to:", mock.target);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });