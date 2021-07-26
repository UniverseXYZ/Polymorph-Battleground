const { expect } = require('chai');
const { waffle, ethers } = require('hardhat');
const { loadFixture } = waffle;
const POLYMORPHS_CONTRACT_ADDRESS = "0x094e0c66bEc52a737e580fbba50ECb66a4CF74B2";

describe("PolymorphBattleground", function () {
  const deployContracts = async () => {
    const PolymorphsContract = await ethers.getContractFactory("PolymorphWithGeneChanger");
    const polymorphsContract = await PolymorphsContract.deploy();
    await polymorphsContract.deployed();

    const PolymorphBattleground = await ethers.getContractFactory("PolymorphBattleground");
    const polymorphBattleground = await PolymorphBattleground.deploy(polymorphsContract.address);
    await polymorphBattleground.deployed();
    return { polymorphBattleground, polymorphsContract };
  };

  it("Should deploy PolymorphBattleground", async function () {
    const { polymorphBattleground } = await loadFixture(deployContracts);
    expect(ethers.utils.isAddress(polymorphBattleground.address)).to.be.true;
  });

  it("Should deploy PolymorphsContract", async function () {
    const { polymorphsContract } = await loadFixture(deployContracts);
    expect(ethers.utils.isAddress(polymorphsContract.address)).to.be.true;
  });

  it("Should enter Battle Pool properly", async function () {
    const { polymorphBattleground, polymorphsContract } = await loadFixture(deployContracts);
    const [signer] = await ethers.getSigners();
    await polymorphsContract.mint(signer.address, 2);
    await polymorphBattleground.enterBattle(2, 1, {value: ethers.utils.parseEther("1")});
    const battleEntitiy = await polymorphBattleground.battlePool(2);
    const battlePoolLength = await polymorphBattleground.battlePoolLength();
    expect(battleEntitiy.registered).to.be.true;
    expect(battleEntitiy.id === 2);
    expect(battleEntitiy.skillType === 1);
    expect(battlePoolLength.toString() === "1");
  });


  it("Should not override existing battleEntity in the Battle Pool", async function () {
    const { polymorphBattleground, polymorphsContract } = await loadFixture(deployContracts);
    const [signer] = await ethers.getSigners();
    await polymorphsContract.mint(signer.address, 2);
    await polymorphBattleground.enterBattle(2, 1, {value: ethers.utils.parseEther("1")});
    const battleEntitiy = await polymorphBattleground.battlePool(2);
    const battlePoolLength = await polymorphBattleground.battlePoolLength();
    expect(battleEntitiy.registered).to.be.true;
    expect(battleEntitiy.id === 2);
    expect(battleEntitiy.skillType === 1);
    expect(battlePoolLength.toString() === "1");

    await expect(polymorphBattleground.enterBattle(2, 2, {value: ethers.utils.parseEther("1")})).revertedWith(
      'Your polymorph has already been registered for the battle que !'
    );
  });

  it("Should calculate stats", async function () {
    const { polymorphBattleground } = await loadFixture(deployContracts);
    const attackTx = await polymorphBattleground.getStatsPoints(2);
    expect(attackTx.toString() === "35");
  });

});
