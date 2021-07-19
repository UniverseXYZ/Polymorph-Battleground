const { expect } = require('chai');
const { waffle, ethers } = require('hardhat');
const { loadFixture } = waffle;

describe("PolymorphBattleground", function () {
  it("Should deploy PolymorphBattleground", async function () {
    const PolymorphBattleground = await ethers.getContractFactory("PolymorphBattleground");
    const polymorphBattleground = await PolymorphBattleground.deploy();
    await polymorphBattleground.deployed();

    expect(ethers.utils.isAddress(polymorphBattleground.address)).to.be.true;

  });
});
