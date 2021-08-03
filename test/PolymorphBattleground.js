const { expect, assert } = require('chai');
const { waffle, ethers } = require('hardhat');
const { loadFixture } = waffle;

// Rinkeby configuration
const POLYMORPHS_CONTRACT_ADDRESS = "0x0650E5F57F42834896fB288923bdF43Fa68F3c56";
const DAO_ADDRESS = "0x67b93852482113375666a310ac292D61dDD4bbb9";
const UNISWAP_V3_ROUTER = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
const LINK_ADDRESS = "0xc7ad46e0b8a400bb3c915120d284aafba8fc4735";
const WETH_ADDRESS = "0xc778417e063141139fce010982780140aa0cd5ab";
const DAO_FEE_BPS = 1000;
const OPERATIONAL_FEEBPS = 1000;
const RNG_CHAINLINK_COST = "100000000000000000";
const WAGER = "1000000000000000";


describe("PolymorphBattleground", function () {
  it("Should calculate stats based on Gene", async function () {
    const BattleStatsCalculator = await ethers.getContractFactory("BattleStatsCalculator");
    const battleStatsCalculator = await BattleStatsCalculator.deploy();
    await battleStatsCalculator.deployed();

    const PolymorphWithGeneChanger = await ethers.getContractFactory("PolymorphWithGeneChanger");
    const polymorphWithGeneChanger = await PolymorphWithGeneChanger.deploy();
    await polymorphWithGeneChanger.deployed();

    const gene = await polymorphWithGeneChanger.geneOf(1);
    const [min, max] = await battleStatsCalculator.getStats(gene.toString(), 0);

    assert(min.toNumber() != 0, "Min stats should not be 0 !");
    assert(max.toString() != 0, "Max stats should not be 0 !");
  });

  it("Should enter the battle", async function () {
    const PolymorphsContract = await ethers.getContractFactory("PolymorphWithGeneChanger");
    const polymorphsContract = await PolymorphsContract.deploy();
    await polymorphsContract.deployed();

    const PolymorphBattleground = await ethers.getContractFactory("PolymorphBattleground");
    const polymorphBattleground = await PolymorphBattleground.deploy(
      polymorphsContract.address,
      DAO_ADDRESS,
      UNISWAP_V3_ROUTER,
      LINK_ADDRESS,
      WETH_ADDRESS,
      DAO_FEE_BPS,
      OPERATIONAL_FEEBPS,
      RNG_CHAINLINK_COST,
      WAGER
      );
    await polymorphBattleground.deployed();

    const [signer] = await ethers.getSigners();
    await polymorphsContract.mint(signer.address, 2);
    await polymorphBattleground.enterBattle(2, 1, {value: ethers.utils.parseEther("1")});
    const entity = await polymorphBattleground.entities(0, 2)
    const battlePoolEntityId = await polymorphBattleground.battlePools(0, 0);
    expect(entity.id === 2);
    expect(entity.skillType === 1);
    expect(entity.statsMin.toNumber() != 0, "Entity Min stats should not be 0 !");
    expect(entity.statsMax.toNumber() != 0, "Entity Max stats should not be 0 !");
    expect(battlePoolEntityId.toNumber() === entity.id);
  });
});
