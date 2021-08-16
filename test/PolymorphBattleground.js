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
  [2, 1, 1, 50, 1, 100],
  [2, 2, 1, 50, 1, 50],
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
  [3, 1, 1, 50, 1, 100],
  [3, 2, 1, 50, 1, 50],
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
  [4, 1, 1, 50, 1, 100],
  [4, 2, 1, 100, 1, 100],
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
  [4, 24, 1, 50, 1, 50]
];

const ITEMS2 = [
  [5, 0, 1, 100, 1, 50],
  [5, 1, 1, 50, 1, 100],
  [5, 2, 1, 100, 1, 50],
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
  [6, 1, 1, 50, 1, 100],
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
  [7, 1, 1, 100, 1, 50],
  [7, 2, 1, 150, 1, 100],
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
  [8, 1, 1, 100, 1, 50],
  [8, 2, 1, 150, 1, 100],
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

// Initializer functions, could be overwriten in need
const deployContracts = async () => {
  const [vrfCoordinator, dao] = await ethers.getSigners();

  const PolymorphsContract = await ethers.getContractFactory("PolymorphWithGeneChanger");
  const polymorphsContract = await PolymorphsContract.deploy();
  await polymorphsContract.deployed();

  const ADDRESSES = [
    polymorphsContract.address,
    UNISWAP_V3_ROUTER,
    LINK_ADDRESS,
    WETH_ADDRESS,
    vrfCoordinator.address
  ];

  const PolymorphBattleground = await ethers.getContractFactory("PolymorphBattleground");
  const polymorphBattleground = await PolymorphBattleground.deploy(
    ADDRESSES,
    dao.address,
    DAO_FEE_BPS,
    OPERATIONAL_FEEBPS,
    RNG_CHAINLINK_COST,
    START_ROUND_INCETIVE,
    END_ROUND_INCETIVE,
    );
  await polymorphBattleground.deployed();

  // Init items
  await polymorphBattleground.connect(dao).initItems(ITEMS1);
  await polymorphBattleground.connect(dao).initItems(ITEMS2);

  return { polymorphBattleground, polymorphsContract };
};

const mintPolymorphs = async (owners) => {
  // Mint polymorphs
  const mintAndEnterPromises = owners.map(async (participant, index) => {
    const polymorphId = index + 1;
    const transactionMint = await polymorphsContract.mint(participant.address,polymorphId);
    await transactionMint.wait();
    const transactionEnter = await polymorphBattleground.connect(participant).enterBattle(polymorphId, 1, {value: ethers.utils.parseEther("1")});
    await transactionEnter.wait();
  });

  await Promise.all(mintAndEnterPromises);
}

let polymorphBattleground, polymorphsContract, signers, participants;

describe("Test of constructor()", function() {
  beforeEach(async function() {
    // Deploy contracts
    const contracts = await loadFixture(deployContracts);
    polymorphBattleground = contracts.polymorphBattleground;
    polymorphsContract = contracts.polymorphsContract;
  });

  it("All passed variables are cached into the contract", async function () {
  const [vrfCoordinator, dao] = await ethers.getSigners();

    const polymorphContractAddress = await polymorphBattleground.polymorphsContractAddress();
    expect(polymorphContractAddress.toString()).to.be.eq(polymorphsContract.address.toString());

    const daoAddress = await polymorphBattleground.daoAddress();
    expect(daoAddress.toString()).to.be.eq(dao.address);

    const router = await polymorphBattleground.uniswapV3Router();
    expect(router).to.be.eq(UNISWAP_V3_ROUTER);

    const linkAddress = await polymorphBattleground.linkAddress();
    expect(linkAddress).to.be.eq(LINK_ADDRESS);

    const wethAddress = await polymorphBattleground.wethAddress();
    expect(wethAddress.toLowerCase()).to.be.eq(WETH_ADDRESS.toLowerCase());

    const daoFeeBps = await polymorphBattleground.daoFeeBps();
    expect(daoFeeBps).to.be.eq(DAO_FEE_BPS);

    const operationalFeeBps = await polymorphBattleground.operationalFeeBps();
    expect(operationalFeeBps).to.be.eq(OPERATIONAL_FEEBPS);

    const rngChainlinkCost = await polymorphBattleground.rngChainlinkCost();
    expect(rngChainlinkCost).to.be.eq(RNG_CHAINLINK_COST);

    const startRoundIncetive = await polymorphBattleground.startRoundIncetive();
    expect(startRoundIncetive).to.be.eq(START_ROUND_INCETIVE);

    const finishRoundIncetive = await polymorphBattleground.finishRoundIncetive();
    expect(finishRoundIncetive).to.be.eq(END_ROUND_INCETIVE);
  });
});

describe("Tests for enterBattle() method: ", function () {
  beforeEach(async function() {
    // Deploy contracts
    const contracts = await loadFixture(deployContracts);
    polymorphBattleground = contracts.polymorphBattleground;
    polymorphsContract = contracts.polymorphsContract;

    //  Get signers
    signers = await hre.ethers.getSigners();

    participants = [];
    const participantsCount = await polymorphBattleground.maxPoolSize();
    for (let i = 0; i < participantsCount.toNumber(); i++) {
      participants.push(signers[i]);
    };
  });

  it("User cannot enter the battle if not enough ETH amount is sent", async function () {
    const signer = signers[0]
    await polymorphsContract.mint(signer.address, 2);
    await expect(polymorphBattleground.enterBattle(2, 1)).revertedWith('Not enough ETH amount sent to enter the pool !');
  });

  it("User cannot enter the battle pool with the same polymorph twice", async function () {
    const signer = signers[0]
    await polymorphsContract.mint(signer.address, 2);
    await polymorphBattleground.enterBattle(2, 1, {value: ethers.utils.parseEther("1")});
    await expect(polymorphBattleground.enterBattle(2, 1, {value: ethers.utils.parseEther("1")})).revertedWith('You have already registered for the current battle pool');
  });

  it("User should be the owner of the polymorph", async function () {
    const signer = signers[0];
    const signer1 = signers[1];
    await polymorphsContract.mint(signer.address, 2);
    await expect(polymorphBattleground.connect(signer1).enterBattle(2, 1, {value: ethers.utils.parseEther("1")})).revertedWith('ou must be the owner of the polymorph');
  });

  it("User balance gets updated after entering a battle pool", async function () {
    const signer = signers[0];
    await polymorphsContract.mint(signer.address, 2);
    const userBalanceBefore = await polymorphBattleground.playerBalances(signer.address);
    await polymorphBattleground.enterBattle(2, 1, {value: ethers.utils.parseEther("1")});
    const userBalanceAfter = await polymorphBattleground.playerBalances(signer.address);
    await expect(parseInt(userBalanceBefore.toString())).to.be.lessThan(parseInt(userBalanceAfter.toString()));
  });

  it("User joins the next battlePool if the current one is full", async function () {
    // Fill the battle pool
    await mintPolymorphs(participants);

    const signer = signers[0];
    const polymorphId = 222;
    const battlePoolIindexBefore = await polymorphBattleground.battlePoolIndex();

    await polymorphsContract.mint(signer.address, polymorphId);
    await polymorphBattleground.enterBattle(polymorphId, 1, {value: ethers.utils.parseEther("1")});

    const battlePoolIindexAfter = await polymorphBattleground.battlePoolIndex();
    await expect(battlePoolIindexBefore.toNumber()).to.be.lessThan(battlePoolIindexAfter.toNumber());

    const entitiyId = await polymorphBattleground.battlePools(battlePoolIindexAfter, 0);
    await expect(polymorphId).to.be.eq(entitiyId.toNumber());

    const entitiy = await polymorphBattleground.entities(battlePoolIindexAfter.toNumber(), entitiyId.toNumber());
    await expect(polymorphId).to.be.eq(entitiy.id.toNumber());
  });

  it("battleEntity is created if user joins the pool", async function () {
    // Fill the battle pool
    const signer = signers[0];
    const polymorphId = 222;

    await polymorphsContract.mint(signer.address, polymorphId);
    await polymorphBattleground.enterBattle(polymorphId, 1, {value: ethers.utils.parseEther("1")});

    const battlePoolIindex = await polymorphBattleground.battlePoolIndex();

    const entitiy = await polymorphBattleground.entities(battlePoolIindex.toNumber(), polymorphId);
    await expect(polymorphId).to.be.eq(entitiy.id.toNumber());
  });

  it("entitiyId is put into the pool upon joining it", async function () {
    // Fill the battle pool
    const signer = signers[0];
    const polymorphId = 222;

    await polymorphsContract.mint(signer.address, polymorphId);
    await polymorphBattleground.enterBattle(polymorphId, 1, {value: ethers.utils.parseEther("1")});

    const battlePoolIindex = await polymorphBattleground.battlePoolIndex();

    const entitiyId = await polymorphBattleground.battlePools(battlePoolIindex, 0);
    await expect(polymorphId).to.be.eq(entitiyId.toNumber());
  });

  it("user participatedBattlePoolIndex is getting updated after join", async function () {
    // First enter and fill the pool so that if enters the next pool we can check the index again
    await mintPolymorphs(participants);

    // Fill the battle pool
    const signer = signers[0];
    const polymorphId = 222;

    const participatedIndex = await polymorphBattleground.participatedBattlePoolIndex(signer.address);

    await polymorphsContract.connect(signer).mint(signer.address, polymorphId);
    await polymorphBattleground.connect(signer).enterBattle(polymorphId, 1, {value: ethers.utils.parseEther("1")});

    const participatedIndexAfter = await polymorphBattleground.participatedBattlePoolIndex(signer.address);

    await expect(participatedIndex.toNumber()).to.be.lessThan(participatedIndexAfter.toNumber());

  });

  it("Should calculate stats based on Gene", async function () {
    const gene = await polymorphsContract.geneOf(1);
    const [min, max] = await polymorphBattleground.getStats(gene.toString(), 0);

    assert(min.toNumber() != 0, "Min stats should not be 0 !");
    assert(max.toString() != 0, "Max stats should not be 0 !");
  });

  it("Should enter the battle", async function () {
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

  // TODO:: use coverage hardhat
  // TODO:: Write tests for RandomConsumberNumber.sol => https://github.com/alexroan/truffle-tests-tutorial
});

describe("Test of finishRound() method", function() {
  beforeEach(async function() {
    // Deploy contracts
    const contracts = await loadFixture(deployContracts);
    polymorphBattleground = contracts.polymorphBattleground;
    polymorphsContract = contracts.polymorphsContract;

    //  Get signers
    signers = await hre.ethers.getSigners();

    participants = [];
    const participantsCount = await polymorphBattleground.maxPoolSize();
    for (let i = 0; i < participantsCount.toNumber(); i++) {
      participants.push(signers[i]);
    };
  });

  it("Entering without the needed players in the pool", async function () {
    const randomNumber = ethers.BigNumber.from("8238110493506368787129191924534665123803515722583333737448633436947264152644");
    const requestId = "0x0000000000000000000000000000000000000000000000000000000000000000";

    // Fulfill randomness
    const vrfCoordinator = signers[0];
    await polymorphBattleground.connect(vrfCoordinator).rawFulfillRandomness(requestId, randomNumber);

    await expect(polymorphBattleground.finishRound()).revertedWith('Not enough polymorphs into the Battle Pool !');
  });

  it("Entering without randomNumber", async function () {
    // Mint polymorphs
    await mintPolymorphs(participants);
    await expect(polymorphBattleground.finishRound()).revertedWith('Random Number is 0, please request a random number or wait for its fulfilment !');
  });

  it("Testing expand() function", async function () {
    const randomNumber = ethers.BigNumber.from("8238110493506368787129191924534665123803515722583333737448633436947264152644");
    const desiredCount = 2;
    const randoms = await polymorphBattleground.expand(randomNumber, desiredCount);
    expect(randoms.length).to.be.eq(desiredCount);
  });

  it("Starting fight with odd number of participants, transfers one into the next battle pool", async function () {
    await mintPolymorphs(participants.slice(0, (participants.length / 2) - 1));

    // Fulfill randomness
    const randomNumber = ethers.BigNumber.from("8238110493506368787129191924534665123803515722583333737448633436947264152644");
    const requestId = "0x0000000000000000000000000000000000000000000000000000000000000000";
    const vrfCoordinator = signers[0];
    await polymorphBattleground.connect(vrfCoordinator).rawFulfillRandomness(requestId, randomNumber);

    await polymorphBattleground.finishRound();
    const roundIndex = await polymorphBattleground.roundIndex();
    // It has transfered the odd entity into the next pool
    await expect(polymorphBattleground.battlePools(roundIndex,0)).to.not.be.reverted;
  });

  it("Starting fight with even number of participants, dont transfer polymorph into the next battle pool", async function () {
    await mintPolymorphs(participants);

    // Fulfill randomness
    const randomNumber = ethers.BigNumber.from("8238110493506368787129191924534665123803515722583333737448633436947264152644");
    const requestId = "0x0000000000000000000000000000000000000000000000000000000000000000";
    const vrfCoordinator = signers[0];
    await polymorphBattleground.connect(vrfCoordinator).rawFulfillRandomness(requestId, randomNumber);

    await polymorphBattleground.finishRound();
    const roundIndex = await polymorphBattleground.roundIndex();
    // It has not transfered the an entity into the next pool, all fight have been done
    await expect(polymorphBattleground.battlePools(roundIndex,0)).to.be.reverted;
  });

  it("randomNumber gets reset after the battle", async function () {
    await mintPolymorphs(participants);

    // Fulfill randomness
    const randomNumber = ethers.BigNumber.from("8238110493506368787129191924534665123803515722583333737448633436947264152644");
    const requestId = "0x0000000000000000000000000000000000000000000000000000000000000000";
    const vrfCoordinator = signers[0];
    await polymorphBattleground.connect(vrfCoordinator).rawFulfillRandomness(requestId, randomNumber);

    const vrfRandomNumberBefore = await polymorphBattleground.randomNumber();
    expect(vrfRandomNumberBefore.toString()).to.not.be.eq("0");

    await polymorphBattleground.finishRound();

    const vrfRandomNumberAfter = await polymorphBattleground.randomNumber();
    expect(vrfRandomNumberAfter.toString()).to.be.eq("0");
  });

  it("roundIndex gets incremented after the battle", async function () {
    await mintPolymorphs(participants);

    // Fulfill randomness
    const randomNumber = ethers.BigNumber.from("8238110493506368787129191924534665123803515722583333737448633436947264152644");
    const requestId = "0x0000000000000000000000000000000000000000000000000000000000000000";
    const vrfCoordinator = signers[0];
    await polymorphBattleground.connect(vrfCoordinator).rawFulfillRandomness(requestId, randomNumber);

    const roundIndex = await polymorphBattleground.roundIndex();
    expect(roundIndex.toString()).to.be.eq("0");

    await polymorphBattleground.finishRound();

    const roundIndexAfter = await polymorphBattleground.roundIndex();
    const expectedRound= roundIndex.toNumber() + 1;
    expect(roundIndexAfter.toString()).to.be.eq(expectedRound.toString());
  });

  it("swapAndPopEntity() removes entity from the pool", async function () {
    await mintPolymorphs(participants);

    const roundIndex = 0;
    const index = 0;
    const entityIdBefore = await polymorphBattleground.battlePools(roundIndex,index);
    await polymorphBattleground.swapAndPopEntity(index);
    const entityIdAfter = await polymorphBattleground.battlePools(roundIndex,index);
    expect(entityIdBefore.toString()).to.not.be.eq(entityIdAfter.toString());
  });
});

describe("Test of claimRewards()", function() {
  beforeEach(async function() {
    // Deploy contracts
    const contracts = await loadFixture(deployContracts);
    polymorphBattleground = contracts.polymorphBattleground;
    polymorphsContract = contracts.polymorphsContract;

    //  Get signers
    signers = await hre.ethers.getSigners();

    participants = [];
    const participantsCount = await polymorphBattleground.maxPoolSize();
    for (let i = 0; i < participantsCount.toNumber(); i++) {
      participants.push(signers[i]);
    };
  });

  it("player cannot claim rewards if its featured to fight in upcomming round", async function () {
    const signer = signers[0];
    await polymorphsContract.mint(signer.address, 2);
    await polymorphBattleground.enterBattle(2, 1, {value: ethers.utils.parseEther("1")});
    await expect(polymorphBattleground.connect(signer).claimRewards()).revertedWith('You have joined pool which is still in execution or has not been started yet !');
  });

  it("player cannot claim if has no balance", async function () {
    const signer = signers[0];
    await expect(polymorphBattleground.connect(signer).claimRewards()).revertedWith('User Balance is zero');
  });

  it("player balance gets reset after claim", async function () {
    const signer = signers[0];
    await mintPolymorphs(participants);

    // Fulfill randomness
    const randomNumber = ethers.BigNumber.from("8238110493506368787129191924534665123803515722583333737448633436947264152644");
    const requestId = "0x0000000000000000000000000000000000000000000000000000000000000000";
    const vrfCoordinator = signers[0];
    await polymorphBattleground.connect(vrfCoordinator).rawFulfillRandomness(requestId, randomNumber);

    await polymorphBattleground.finishRound();
    await expect(polymorphBattleground.connect(signer).claimRewards()).revertedWith('User Balance is zero');
  });
});

describe("Test of saveRandomNumber()", function() {
  beforeEach(async function() {
    // Deploy contracts
    const contracts = await loadFixture(deployContracts);
    polymorphBattleground = contracts.polymorphBattleground;
    polymorphsContract = contracts.polymorphsContract;

    //  Get signers
    signers = await hre.ethers.getSigners();

    participants = [];
    const participantsCount = await polymorphBattleground.maxPoolSize();
    for (let i = 0; i < participantsCount.toNumber(); i++) {
      participants.push(signers[i]);
    };
  });

  it("saves the random number", async function () {
    await mintPolymorphs(participants);

  // Fulfill randomness
    const randomNumber = ethers.BigNumber.from("8238110493506368787129191924534665123803515722583333737448633436947264152644");
    const requestId = "0x0000000000000000000000000000000000000000000000000000000000000000";
    const vrfCoordinator = signers[0];
    await polymorphBattleground.connect(vrfCoordinator).rawFulfillRandomness(requestId, randomNumber);

    const savedRandomNumber = await polymorphBattleground.randomNumber();
    expect(savedRandomNumber.toString()).to.not.eq("0");
  });
});

describe("Test of setStartRoundIncentive() and setFinishRoundIncentive()", function() {
  beforeEach(async function() {
    // Deploy contracts
    const contracts = await loadFixture(deployContracts);
    polymorphBattleground = contracts.polymorphBattleground;
    polymorphsContract = contracts.polymorphsContract;

    //  Get signers
    signers = await hre.ethers.getSigners();

    participants = [];
    const participantsCount = await polymorphBattleground.maxPoolSize();
    for (let i = 0; i < participantsCount.toNumber(); i++) {
      participants.push(signers[i]);
    };
  });

  it("Only DAO can call setStartRoundIncentive", async function () {
    await expect(polymorphBattleground.setStartRoundIncentive("10")).revertedWith('Not called from the dao');
  });

  it("Only DAO can call setFinishRoundIncentive", async function () {
    await expect(polymorphBattleground.setFinishRoundIncentive("10")).revertedWith('Not called from the dao');
  });

  it("changes startRoundIncentive amount", async function () {
    const [vrfCoordinator, dao] = await ethers.getSigners();

    const incentive = await polymorphBattleground.startRoundIncetive();
    await polymorphBattleground.connect(dao).setStartRoundIncentive("10");
    const incentiveAfter = await polymorphBattleground.startRoundIncetive();
    expect(incentive.toNumber()).to.not.be.eq(incentiveAfter.toNumber());
  });

  it("changes finishRoundIncentive amount", async function () {
    const [vrfCoordinator, dao] = await ethers.getSigners();

    const incentive = await polymorphBattleground.finishRoundIncetive();
    await polymorphBattleground.connect(dao).setFinishRoundIncentive("10");
    const incentiveAfter = await polymorphBattleground.finishRoundIncetive();
    expect(incentive.toString()).to.not.be.eq(incentiveAfter.toString());
  });
});