'use strict'

const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("SimpleDex Contract", function () {
  async function deploymentFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    // Triển khai TokenA và TokenB
    const TokenA = await ethers.getContractFactory("MockERC20");
    const tokenA = await TokenA.deploy("Token A", "TKA");

    const TokenB = await ethers.getContractFactory("MockERC20");
    const tokenB = await TokenB.deploy("Token B", "TKB");

    // Triển khai SimpleDex
    const SimpleDex = await ethers.getContractFactory("SimpleDex");
    const simpleDex = await SimpleDex.deploy();

    return { tokenA, tokenB, simpleDex, owner, addr1, addr2 };
  }
  

  describe("#addLiquidity()", function () {
    it("should add liquidity successfully", async function () {
      const { tokenA, tokenB, simpleDex, owner, addr1, addr2 } = await loadFixture(deploymentFixture);

      await tokenA.transferFrom(owner.address, addr1.address, 500000)
      console.log('1')
      const balance = await tokenA.balanceOf(addr1.address)
      console.log(balance)

      
      await simpleDex.addLiquidity(tokenA.target, tokenB.target, 500000, 250000, owner.address);

      // Kiểm tra kết quả
      const lpTokenAddress = await simpleDex.lptokens(tokenA.address, tokenB.address);
      expect(lpTokenAddress).to.not.equal(ethers.constants.AddressZero);

      const liquidityToken = await ethers.getContractAt("LiquidityToken", lpTokenAddress);
      const liquidityBalance = await liquidityToken.balanceOf(owner.address);
      expect(liquidityBalance).to.be.gt(0);
    });

    // it("should revert if one of the amounts is zero", async function () {
    //   const amountADesired = ethers.utils.parseUnits("0", 18);
    //   const amountBDesired = ethers.utils.parseUnits("500000", 18);

    //   await expect(simpleDex.addLiquidity(tokenA.address, tokenB.address, amountADesired, amountBDesired, owner.address))
    //     .to.be.revertedWith("either amount is zero");
    // });

    // it("should revert if token addresses are the same", async function () {
    //   const amountADesired = ethers.utils.parseUnits("500000", 18);
    //   const amountBDesired = ethers.utils.parseUnits("500000", 18);

    //   await expect(simpleDex.addLiquidity(tokenA.address, tokenA.address, amountADesired, amountBDesired, owner.address))
    //     .to.be.revertedWith("both tokens are same address");
    // });
  });
});
