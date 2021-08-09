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

    const gene = await polymorphsContract.geneOf(1);
    const [min, max] = await battleStatsCalculator.getStats(gene.toString(), 0);

    assert(min.toNumber() != 0, "Min stats should not be 0 !");
    assert(max.toString() != 0, "Max stats should not be 0 !");
  });

  it("Should enter the battle", async function () {
    const { polymorphBattleground, polymorphsContract } = await loadFixture(deployContracts);

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
    const { polymorphBattleground, polymorphsContract } = await loadFixture(deployContracts);

    const [signer] = await ethers.getSigners();
    // Every signer starts with 1000 ETH
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
