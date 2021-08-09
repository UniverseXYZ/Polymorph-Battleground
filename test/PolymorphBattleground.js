const { expect, assert } = require('chai');
const { waffle, ethers } = require('hardhat');
const { loadFixture } = waffle;

// Rinkeby configuration
const POLYMORPHS_CONTRACT_ADDRESS = "0x0650E5F57F42834896fB288923bdF43Fa68F3c56";
const DAO_ADDRESS = "0x67b93852482113375666a310ac292D61dDD4bbb9";
const UNISWAP_V3_ROUTER = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
const LINK_ADDRESS = "0x01BE23585060835E02B77ef475b0Cc51aA1e0709";
const WETH_ADDRESS = "0xc778417e063141139fce010982780140aa0cd5ab";
const DAO_FEE_BPS = 1000;
const OPERATIONAL_FEEBPS = 1000;
const RNG_CHAINLINK_COST = "100000000000000000";
const WAGER = "100000000000000000"; // 0.1
const START_ROUND_INCETIVE = "5000000000000000"; // 0,005 ETH
const END_ROUND_INCETIVE = "10000000000000000"; // 0.01
const ITEMS1 = [
  [0, 0, 1, 100, 1, 100],
  [0, 1, 1, 100, 1, 100],
  [0, 2, 1, 100, 1, 100],
  [0, 3, 1, 100, 1, 100],
  [0, 4, 1, 100, 1, 100],
  [0, 5, 1, 100, 1, 100],
  [0, 6, 1, 100, 1, 100],
  [0, 7, 1, 100, 1, 100],
  [0, 8, 1, 100, 1, 100],
  [0, 9, 1, 100, 1, 100],
  [0, 10, 1, 100, 1, 100],
  [1, 0, 0, 0, 0, 0],
  [1, 1, 0, 0, 0, 0],
  [1, 2, 0, 0, 0, 0],
  [1, 3, 0, 0, 0, 0],
  [1, 4, 0, 0, 0, 0],
  [1, 5, 0, 0, 0, 0],
  [1, 6, 0, 0, 0, 0],
  [1, 7, 0, 0, 0, 0],
  [1, 8, 0, 0, 0, 0],
  [1, 9, 0, 0, 0, 0],
  [1, 10, 0, 0, 0, 0],
  [1, 11, 0, 0, 0, 0],
  [2, 0, 1, 100, 1, 50],
  [2, 1, 2, 5, 2, 5],
  [2, 2, 2, 5, 2, 5],
  [2, 3, 1, 100, 1, 100],
  [2, 4, 1, 50, 1, 50],
  [2, 5, 1, 150, 1, 100],
  [2, 6, 1, 50, 1, 50],
  [2, 7, 1, 100, 1, 50],
  [2, 8, 1, 100, 1, 100],
  [2, 9, 1, 50, 1, 100],
  [2, 10, 1, 100, 1, 50],
  [2, 11, 1, 50, 1, 50],
  [2, 12, 1, 50, 1, 150],
  [2, 13, 1, 50, 1, 50],
  [2, 14, 1, 50, 1, 50],
  [2, 15, 1, 150, 1, 150],
  [2, 16, 1, 50, 1, 50],
  [2, 17, 1, 50, 1, 100],
  [2, 18, 1, 50, 1, 50],
  [2, 19, 1, 100, 1, 100],
  [2, 20, 1, 50, 1, 50],
  [2, 21, 1, 100, 1, 150],
  [2, 22, 1, 100, 1, 100],
  [2, 23, 1, 50, 1, 50],
  [2, 24, 1, 100, 1, 100],
  [2, 25, 1, 50, 1, 50],
  [2, 26, 1, 100, 1, 100],
  [2, 27, 1, 100, 1, 100],
  [2, 28, 1, 100, 1, 100],
  [2, 29, 1, 50, 1, 50],
  [2, 30, 1, 150, 1, 150],
  [2, 31, 1, 50, 1, 50],
  [2, 32, 1, 50, 1, 50],
  [3, 0, 1, 100, 1, 50],
  [3, 1, 2, 5, 2, 5],
  [3, 2, 2, 5, 2, 5],
  [3, 3, 1, 100, 1, 100],
  [3, 4, 1, 50, 1, 50],
  [3, 5, 1, 150, 1, 100],
  [3, 6, 1, 150, 1, 100],
  [3, 7, 1, 50, 1, 100],
  [3, 8, 1, 50, 1, 50],
  [3, 9, 1, 100, 1, 150],
  [3, 10, 1, 50, 1, 50],
  [3, 11, 1, 150, 1, 150],
  [3, 12, 1, 50, 1, 100],
  [3, 13, 1, 150, 1, 150],
  [3, 14, 1, 50, 1, 100],
  [3, 15, 1, 150, 1, 150],
  [3, 16, 1, 100, 1, 150],
  [3, 17, 1, 50, 1, 100],
  [3, 18, 1, 50, 1, 50],
  [3, 19, 1, 50, 1, 50],
  [3, 20, 1, 100, 1, 150],
  [3, 21, 1, 100, 1, 50],
  [3, 22, 1, 100, 1, 150],
  [3, 23, 1, 100, 1, 150],
  [3, 24, 1, 100, 1, 150],
  [3, 25, 1, 50, 1, 50],
  [3, 26, 1, 50, 1, 100],
  [3, 27, 1, 50, 1, 100],
  [3, 28, 1, 100, 1, 50],
  [3, 29, 1, 150, 1, 150],
  [3, 30, 1, 100, 1, 50],
  [3, 31, 1, 50, 1, 100],
  [3, 32, 1, 50, 1, 50],
  [3, 33, 1, 100, 1, 150],
  [4, 0, 1, 100, 1, 50],
  [4, 1, 1, 50, 1, 50],
  [4, 2, 1, 50, 1, 50],
  [4, 3, 1, 50, 1, 50],
  [4, 4, 1, 50, 1, 50],
  [4, 5, 1, 100, 1, 100],
  [4, 6, 1, 50, 1, 50],
  [4, 7, 1, 100, 1, 100],
  [4, 8, 1, 100, 1, 150],
  [4, 9, 1, 50, 1, 50],
  [4, 10, 1, 150, 1, 150],
  [4, 11, 1, 150, 1, 150],
  [4, 12, 1, 50, 1, 50],
  [4, 13, 1, 100, 1, 100],
  [4, 14, 1, 50, 1, 50],
  [4, 15, 1, 150, 1, 150],
  [4, 16, 1, 100, 1, 100],
  [4, 17, 1, 50, 1, 50],
  [4, 18, 1, 50, 1, 50],
  [4, 19, 1, 100, 1, 100],
  [4, 20, 1, 100, 1, 100],
  [4, 21, 1, 50, 1, 50],
  [4, 22, 1, 50, 1, 50],
  [4, 23, 1, 50, 1, 50],
  [4, 24, 1, 50, 1, 50],
];

const ITEMS2 = [
  [5, 0, 1, 100, 1, 50],
  [5, 1, 2, 5, 2, 5],
  [5, 2, 2, 5, 2, 5],
  [5, 3, 1, 100, 1, 50],
  [5, 4, 1, 50, 1, 100],
  [5, 5, 1, 50, 1, 100],
  [5, 6, 1, 50, 1, 100],
  [5, 7, 1, 50, 1, 100],
  [5, 8, 1, 50, 1, 100],
  [5, 9, 1, 50, 1, 100],
  [5, 10, 1, 50, 1, 100],
  [5, 11, 1, 50, 1, 100],
  [5, 12, 1, 50, 1, 100],
  [6, 0, 1, 100, 1, 50],
  [6, 1, 2, 5, 2, 5],
  [6, 2, 1, 100, 1, 100],
  [6, 3, 1, 50, 1, 50],
  [6, 4, 1, 50, 1, 50],
  [6, 5, 1, 150, 1, 100],
  [6, 6, 1, 50, 1, 50],
  [6, 7, 1, 50, 1, 50],
  [6, 8, 1, 50, 1, 50],
  [6, 9, 1, 50, 1, 50],
  [6, 10, 1, 50, 1, 50],
  [6, 11, 1, 50, 1, 50],
  [6, 12, 1, 50, 1, 50],
  [6, 13, 1, 150, 1, 150],
  [6, 14, 1, 150, 1, 150],
  [6, 15, 1, 50, 1, 50],
  [6, 16, 1, 100, 1, 150],
  [6, 17, 1, 150, 1, 150],
  [6, 18, 1, 50, 1, 50],
  [6, 19, 1, 100, 1, 150],
  [6, 20, 1, 50, 1, 50],
  [6, 21, 1, 50, 1, 50],
  [6, 22, 1, 50, 1, 50],
  [6, 23, 1, 100, 1, 150],
  [6, 24, 1, 100, 1, 150],
  [6, 25, 1, 100, 1, 150],
  [6, 26, 1, 50, 1, 50],
  [6, 27, 1, 50, 1, 50],
  [6, 28, 1, 50, 1, 50],
  [6, 29, 1, 50, 1, 50],
  [6, 30, 1, 50, 1, 50],
  [7, 0, 1, 50, 1, 50],
  [7, 1, 2, 5, 2, 5],
  [7, 2, 2, 5, 2, 5],
  [7, 3, 1, 50, 1, 50],
  [7, 4, 1, 50, 1, 50],
  [7, 5, 1, 150, 1, 50],
  [7, 6, 1, 200, 1, 50],
  [7, 7, 1, 150, 1, 50],
  [7, 8, 1, 250, 1, 250],
  [7, 9, 1, 100, 1, 50],
  [7, 10, 1, 150, 1, 50],
  [7, 11, 1, 250, 1, 50],
  [7, 12, 1, 50, 1, 250],
  [7, 13, 1, 250, 1, 250],
  [7, 14, 1, 250, 1, 250],
  [7, 15, 1, 250, 1, 250],
  [7, 16, 1, 50, 1, 50],
  [7, 17, 1, 200, 1, 50],
  [7, 18, 1, 150, 1, 50],
  [7, 19, 1, 100, 1, 50],
  [7, 20, 1, 250, 1, 250],
  [7, 21, 1, 250, 1, 50],
  [7, 22, 1, 100, 1, 50],
  [7, 23, 1, 150, 1, 50],
  [7, 24, 1, 200, 1, 100],
  [7, 25, 1, 250, 1, 250],
  [7, 26, 1, 250, 1, 250],
  [7, 27, 1, 50, 1, 250],
  [7, 28, 1, 150, 1, 100],
  [7, 29, 1, 100, 1, 50],
  [7, 30, 1, 150, 1, 50],
  [7, 31, 1, 100, 1, 50],
  [8, 0, 1, 50, 1, 50],
  [8, 1, 2, 5, 2, 5],
  [8, 2, 2, 5, 2, 5],
  [8, 3, 1, 50, 1, 50],
  [8, 4, 1, 50, 1, 50],
  [8, 5, 1, 150, 1, 50],
  [8, 6, 1, 200, 1, 50],
  [8, 7, 1, 150, 1, 50],
  [8, 8, 1, 250, 1, 250],
  [8, 9, 1, 100, 1, 50],
  [8, 10, 1, 150, 1, 50],
  [8, 11, 1, 250, 1, 50],
  [8, 12, 1, 50, 1, 250],
  [8, 13, 1, 250, 1, 250],
  [8, 14, 1, 250, 1, 250],
  [8, 15, 1, 250, 1, 250],
  [8, 16, 1, 50, 1, 50],
  [8, 17, 1, 200, 1, 50],
  [8, 18, 1, 150, 1, 50],
  [8, 19, 1, 100, 1, 50],
  [8, 20, 1, 250, 1, 250],
  [8, 21, 1, 250, 1, 50],
  [8, 22, 1, 100, 1, 50],
  [8, 23, 1, 150, 1, 50],
  [8, 24, 1, 200, 1, 100],
  [8, 25, 1, 250, 1, 250],
  [8, 26, 1, 250, 1, 250],
  [8, 27, 1, 50, 1, 250],
  [8, 28, 1, 150, 1, 100],
  [8, 29, 1, 100, 1, 50],
  [8, 30, 1, 150, 1, 50],
  [8, 31, 1, 100, 1, 50]
];

describe("PolymorphBattleground", function () {
  const deployContracts = async () => {
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
      WAGER,
      START_ROUND_INCETIVE,
      END_ROUND_INCETIVE
      );
    await polymorphBattleground.deployed();

    const BattleStatsCalculator = await ethers.getContractFactory("BattleStatsCalculator");
    const battleStatsCalculator = await BattleStatsCalculator.deploy();
    await battleStatsCalculator.deployed();

    return { polymorphBattleground, polymorphsContract, battleStatsCalculator };
  };

  it("Should calculate stats based on Gene", async function () {
    const { battleStatsCalculator, polymorphsContract } = await loadFixture(deployContracts);

    battleStatsCalculator.initItems(ITEMS1);
    battleStatsCalculator.initItems(ITEMS2);
    const gene = await polymorphsContract.geneOf(1);
    const [min, max] = await battleStatsCalculator.getStats(gene.toString(), 0);

    assert(min.toNumber() != 0, "Min stats should not be 0 !");
    assert(max.toString() != 0, "Max stats should not be 0 !");
  });

  it("Should enter the battle", async function () {
    const { polymorphBattleground, polymorphsContract, battleStatsCalculator } = await loadFixture(deployContracts);

    battleStatsCalculator.initItems(ITEMS1);
    battleStatsCalculator.initItems(ITEMS2);
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

  it("Should refund if overpay for entering a battle", async function () {
    const { polymorphBattleground, polymorphsContract, battleStatsCalculator } = await loadFixture(deployContracts);

    const [signer] = await ethers.getSigners();
    // Every signer starts with 1000 ETH
    battleStatsCalculator.initItems(ITEMS1);
    battleStatsCalculator.initItems(ITEMS2);
    const sentEthAmount = 10;
    const amountBefore = await signer.getBalance();
    const parsedBalanceBefore = await ethers.utils.formatEther(amountBefore);
    const expectedAmountWithoutRefund = parseInt(parsedBalanceBefore) - sentEthAmount;

    await polymorphsContract.mint(signer.address, 2);
    await polymorphBattleground.enterBattle(2, 1, {value: ethers.utils.parseEther("10")});

    const amountAfter = await signer.getBalance();
    const parsedBalanceAfter = await ethers.utils.formatEther(amountAfter);
    const parsedBalanceAfterInt = parseInt(parsedBalanceAfter);

    const comparison = expectedAmountWithoutRefund < parsedBalanceAfterInt;
    expect(comparison).to.be.true;
  });

  it("Should Calculate Fees", async function () {
    const { polymorphBattleground } = await loadFixture(deployContracts);
    const poolLength = 2;
    const fees = await polymorphBattleground.getFeesAmount(WAGER, RNG_CHAINLINK_COST, poolLength, START_ROUND_INCETIVE, END_ROUND_INCETIVE);
    // daoFee = 100000000000000, operationalFee = 50000000000000000, startRoundIncentiveFee = 10000000000000000, endRoundIncentiveFee = 20000000000000000
    // TOTAL = 80100000000000000
    expect(fees.toString() === "80100000000000000"); // 0,0801 ETH
  });

  // TODO:: Write tests for RandomConsumberNumber.sol => https://github.com/alexroan/truffle-tests-tutorial
});
