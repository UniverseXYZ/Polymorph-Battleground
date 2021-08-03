const { expect, assert } = require('chai');
const { waffle, ethers } = require('hardhat');
const { loadFixture } = waffle;

// Rinkeby configuration
// const POLYMORPHS_CONTRACT_ADDRESS = "0x0650E5F57F42834896fB288923bdF43Fa68F3c56";
// const DAO_ADDRESS = "0x67b93852482113375666a310ac292D61dDD4bbb9";
// const UNISWAP_V3_ROUTER = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
// const LINK_ADDRESS = "0xc7ad46e0b8a400bb3c915120d284aafba8fc4735";
// const WETH_ADDRESS = "0xc778417e063141139fce010982780140aa0cd5ab";
// const DAO_FEE_BPS = 1000;
// const OPERATIONAL_FEEBPS = 1000;
// const RNG_CHAINLINK_COST = "100000000000000000";
// const POOLS = ["1000000000000000", "2000000000000000", "3000000000000000"];


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
});
