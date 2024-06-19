require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: 'https://sepolia.infura.io/v3/a283529c05ac4c538b4bf7cb808f8233',
      accounts: ['9d6ce0bd4ac821420057d270fe1d748a93a5f2e849bcf8f9d482b31258f84209'],
    },
  },
};
