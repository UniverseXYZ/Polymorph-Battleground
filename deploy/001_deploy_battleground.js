require('dotenvrc');
const { deployments, hardhatArguments } = require("hardhat");

module.exports = async function () {
  if (
    hardhatArguments.network === "ganache" ||
    hardhatArguments.network === "hardhat" ||
    hardhatArguments.network === "rinkeby" ||
    hardhatArguments.network === "ropsten"
  ) {
    const Battleground = await deployments.getOrNull("PolymorphBattleground");
    const POLYMORPHS_CONTRACT_ADDRESS = process.env.POLYMORPHS_CONTRACT_ADDRESS;
    const UNISWAP_V3_ROUTER = process.env.UNISWAP_SWAP_ROUTER_ADDRESS;
    const LINK_ADDRESS = process.env.LINK_ADDRESS;
    const WETH_ADDRESS = process.env.WETH_ADDRESS;
    const VRF_COORDINATOR_ADDRESS = process.env.VRF_COORDINATOR_ADDRESS;
    const DAO_ADDRESS = process.env.DAO_ADDRESS;
    const WAGER = process.env.WAGER; // 0.1
    const DAO_FEE_BPS = process.env.DAO_FEE_BPS;
    const OPERATIONAL_FEE_BPS = process.env.OPERATIONAL_FEE_BPS;
    const RNG_CHAINLINK_COST = process.env.RNG_CHAINLINK_COST;
    const START_ROUND_INCETIVE = process.env.START_ROUND_INCETIVE;
    const END_ROUND_INCETIVE = process.env.END_ROUND_INCETIVE;

    // const POLYMORPHS_CONTRACT_ADDRESS = "0x0650E5F57F42834896fB288923bdF43Fa68F3c56";
    // const UNISWAP_V3_ROUTER = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
    // const LINK_ADDRESS = "0x01BE23585060835E02B77ef475b0Cc51aA1e0709";
    // const WETH_ADDRESS = "0xc778417e063141139fce010982780140aa0cd5ab";
    // const VRF_COORDINATOR_ADDRESS = "0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B";
    // const DAO_ADDRESS = "0x5012A9a26866Bd7897a71Dd4fb7a65e6FFDD18f2"; // TODO:: Put actual DAO address
    // const WAGER = "100000000000000000"; // 0.1
    // const DAO_FEE_BPS = 1000;
    // const OPERATIONAL_FEE_BPS = 1000;
    // const RNG_CHAINLINK_COST = "100000000000000000";
    // const START_ROUND_INCETIVE = "5000000000000000"; // 0,005 ETH
    // const END_ROUND_INCETIVE = "10000000000000000"; // 0.01

    const CHARACTER_ITEMS = [
      {genePos: 0, itemIndex: 0, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 0, itemIndex: 1, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 0, itemIndex: 2, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 0, itemIndex: 3, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 0, itemIndex: 4, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 0, itemIndex: 5, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 0, itemIndex: 6, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 0, itemIndex: 7, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 0, itemIndex: 8, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 0, itemIndex: 9, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 0, itemIndex: 10, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
    ];

    const BACKGROUND_ITEMS = [
      {genePos: 1, itemIndex: 0, aMin: 0, aMax: 0, dMin: 0, dMax: 0},
      {genePos: 1, itemIndex: 1, aMin: 0, aMax: 0, dMin: 0, dMax: 0},
      {genePos: 1, itemIndex: 2, aMin: 0, aMax: 0, dMin: 0, dMax: 0},
      {genePos: 1, itemIndex: 3, aMin: 0, aMax: 0, dMin: 0, dMax: 0},
      {genePos: 1, itemIndex: 4, aMin: 0, aMax: 0, dMin: 0, dMax: 0},
      {genePos: 1, itemIndex: 5, aMin: 0, aMax: 0, dMin: 0, dMax: 0},
      {genePos: 1, itemIndex: 6, aMin: 0, aMax: 0, dMin: 0, dMax: 0},
      {genePos: 1, itemIndex: 7, aMin: 0, aMax: 0, dMin: 0, dMax: 0},
      {genePos: 1, itemIndex: 8, aMin: 0, aMax: 0, dMin: 0, dMax: 0},
      {genePos: 1, itemIndex: 9, aMin: 0, aMax: 0, dMin: 0, dMax: 0},
      {genePos: 1, itemIndex: 10, aMin: 0, aMax: 0, dMin: 0, dMax: 0},
      {genePos: 1, itemIndex: 11, aMin: 0, aMax: 0, dMin: 0, dMax: 0},
    ];

    const PANTS_ITEMS = [
      {genePos: 2, itemIndex: 0, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 1, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 2, itemIndex: 2, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 3, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 2, itemIndex: 4, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 5, aMin: 1, aMax: 150, dMin: 1, dMax: 100},
      {genePos: 2, itemIndex: 6, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 7, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 8, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 2, itemIndex: 9, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 2, itemIndex: 10, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 11, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 12, aMin: 1, aMax: 50, dMin: 1, dMax: 150},
      {genePos: 2, itemIndex: 13, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 14, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 15, aMin: 1, aMax: 150, dMin: 1, dMax: 150},
      {genePos: 2, itemIndex: 16, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 17, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 2, itemIndex: 18, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 19, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 2, itemIndex: 20, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 21, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 2, itemIndex: 22, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 2, itemIndex: 23, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 24, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 2, itemIndex: 25, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 26, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 2, itemIndex: 27, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 2, itemIndex: 28, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 2, itemIndex: 29, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 30, aMin: 1, aMax: 150, dMin: 1, dMax: 150},
      {genePos: 2, itemIndex: 31, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 2, itemIndex: 32, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
    ];

    const TORSO_ITEMS = [
      {genePos: 3, itemIndex: 0, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 3, itemIndex: 1, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 3, itemIndex: 2, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 3, itemIndex: 3, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 3, itemIndex: 4, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 3, itemIndex: 5, aMin: 1, aMax: 150, dMin: 1, dMax: 100},
      {genePos: 3, itemIndex: 6, aMin: 1, aMax: 150, dMin: 1, dMax: 100},
      {genePos: 3, itemIndex: 7, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 3, itemIndex: 8, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 3, itemIndex: 9, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 3, itemIndex: 10, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 3, itemIndex: 11, aMin: 1, aMax: 150, dMin: 1, dMax: 150},
      {genePos: 3, itemIndex: 12, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 3, itemIndex: 13, aMin: 1, aMax: 150, dMin: 1, dMax: 150},
      {genePos: 3, itemIndex: 14, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 3, itemIndex: 15, aMin: 1, aMax: 150, dMin: 1, dMax: 150},
      {genePos: 3, itemIndex: 16, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 3, itemIndex: 17, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 3, itemIndex: 18, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 3, itemIndex: 19, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 3, itemIndex: 20, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 3, itemIndex: 21, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 3, itemIndex: 22, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 3, itemIndex: 23, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 3, itemIndex: 24, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 3, itemIndex: 25, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 3, itemIndex: 26, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 3, itemIndex: 27, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 3, itemIndex: 28, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 3, itemIndex: 29, aMin: 1, aMax: 150, dMin: 1, dMax: 150},
      {genePos: 3, itemIndex: 30, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 3, itemIndex: 31, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 3, itemIndex: 32, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 3, itemIndex: 33, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
    ];

    const FOOTWEAR_ITEMS = [
      {genePos: 4, itemIndex: 0, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 4, itemIndex: 1, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 4, itemIndex: 2, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 4, itemIndex: 3, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 4, itemIndex: 4, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 4, itemIndex: 5, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 4, itemIndex: 6, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 4, itemIndex: 7, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 4, itemIndex: 8, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 4, itemIndex: 9, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 4, itemIndex: 10, aMin: 1, aMax: 150, dMin: 1, dMax: 150},
      {genePos: 4, itemIndex: 11, aMin: 1, aMax: 150, dMin: 1, dMax: 150},
      {genePos: 4, itemIndex: 12, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 4, itemIndex: 13, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 4, itemIndex: 14, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 4, itemIndex: 15, aMin: 1, aMax: 150, dMin: 1, dMax: 150},
      {genePos: 4, itemIndex: 16, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 4, itemIndex: 17, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 4, itemIndex: 18, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 4, itemIndex: 19, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 4, itemIndex: 20, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 4, itemIndex: 21, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 4, itemIndex: 22, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 4, itemIndex: 23, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 4, itemIndex: 24, aMin: 1, aMax: 50, dMin: 1, dMax: 50}
    ];

    const EYEWEAR_ITEMS = [
      {genePos: 5, itemIndex: 0, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 5, itemIndex: 1, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 5, itemIndex: 2, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 5, itemIndex: 3, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 5, itemIndex: 4, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 5, itemIndex: 5, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 5, itemIndex: 6, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 5, itemIndex: 7, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 5, itemIndex: 8, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 5, itemIndex: 9, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 5, itemIndex: 10, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 5, itemIndex: 11, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 5, itemIndex: 12, aMin: 1, aMax: 50, dMin: 1, dMax: 100}
    ];

    const HEAD_ITEMS = [
      {genePos: 6, itemIndex: 0, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 1, aMin: 1, aMax: 50, dMin: 1, dMax: 100},
      {genePos: 6, itemIndex: 2, aMin: 1, aMax: 100, dMin: 1, dMax: 100},
      {genePos: 6, itemIndex: 3, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 4, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 5, aMin: 1, aMax: 150, dMin: 1, dMax: 100},
      {genePos: 6, itemIndex: 6, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 7, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 8, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 9, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 10, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 11, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 12, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 13, aMin: 1, aMax: 150, dMin: 1, dMax: 150},
      {genePos: 6, itemIndex: 14, aMin: 1, aMax: 150, dMin: 1, dMax: 150},
      {genePos: 6, itemIndex: 15, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 16, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 6, itemIndex: 17, aMin: 1, aMax: 150, dMin: 1, dMax: 150},
      {genePos: 6, itemIndex: 18, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 19, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 6, itemIndex: 20, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 21, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 22, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 23, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 6, itemIndex: 24, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 6, itemIndex: 25, aMin: 1, aMax: 100, dMin: 1, dMax: 150},
      {genePos: 6, itemIndex: 26, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 27, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 28, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 29, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 6, itemIndex: 30, aMin: 1, aMax: 50, dMin: 1, dMax: 50}
    ];

    const WEAPON_RIGHT_ITEMS = [
      {genePos: 7, itemIndex: 0, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 1, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 2, aMin: 1, aMax: 150, dMin: 1, dMax: 100},
      {genePos: 7, itemIndex: 3, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 4, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 5, aMin: 1, aMax: 150, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 6, aMin: 1, aMax: 200, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 7, aMin: 1, aMax: 150, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 8, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 7, itemIndex: 9, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 10, aMin: 1, aMax: 150, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 11, aMin: 1, aMax: 250, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 12, aMin: 1, aMax: 50, dMin: 1, dMax: 250},
      {genePos: 7, itemIndex: 13, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 7, itemIndex: 14, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 7, itemIndex: 15, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 7, itemIndex: 16, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 17, aMin: 1, aMax: 200, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 18, aMin: 1, aMax: 150, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 19, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 20, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 7, itemIndex: 21, aMin: 1, aMax: 250, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 22, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 23, aMin: 1, aMax: 150, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 24, aMin: 1, aMax: 200, dMin: 1, dMax: 100},
      {genePos: 7, itemIndex: 25, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 7, itemIndex: 26, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 7, itemIndex: 27, aMin: 1, aMax: 50, dMin: 1, dMax: 250},
      {genePos: 7, itemIndex: 28, aMin: 1, aMax: 150, dMin: 1, dMax: 100},
      {genePos: 7, itemIndex: 29, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 30, aMin: 1, aMax: 150, dMin: 1, dMax: 50},
      {genePos: 7, itemIndex: 31, aMin: 1, aMax: 100, dMin: 1, dMax: 50}
    ];

    const WEAPON_LEFT_ITEMS =[
      {genePos: 8, itemIndex: 0, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 1, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 2, aMin: 1, aMax: 150, dMin: 1, dMax: 100},
      {genePos: 8, itemIndex: 3, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 4, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 5, aMin: 1, aMax: 150, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 6, aMin: 1, aMax: 200, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 7, aMin: 1, aMax: 150, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 8, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 8, itemIndex: 9, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 10, aMin: 1, aMax: 150, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 11, aMin: 1, aMax: 250, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 12, aMin: 1, aMax: 50, dMin: 1, dMax: 250},
      {genePos: 8, itemIndex: 13, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 8, itemIndex: 14, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 8, itemIndex: 15, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 8, itemIndex: 16, aMin: 1, aMax: 50, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 17, aMin: 1, aMax: 200, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 18, aMin: 1, aMax: 150, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 19, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 20, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 8, itemIndex: 21, aMin: 1, aMax: 250, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 22, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 23, aMin: 1, aMax: 150, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 24, aMin: 1, aMax: 200, dMin: 1, dMax: 100},
      {genePos: 8, itemIndex: 25, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 8, itemIndex: 26, aMin: 1, aMax: 250, dMin: 1, dMax: 250},
      {genePos: 8, itemIndex: 27, aMin: 1, aMax: 50, dMin: 1, dMax: 250},
      {genePos: 8, itemIndex: 28, aMin: 1, aMax: 150, dMin: 1, dMax: 100},
      {genePos: 8, itemIndex: 29, aMin: 1, aMax: 100, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 30, aMin: 1, aMax: 150, dMin: 1, dMax: 50},
      {genePos: 8, itemIndex: 31, aMin: 1, aMax: 100, dMin: 1, dMax: 50}
    ];

    if (!Battleground) {
      const ADDRESSES = [
        POLYMORPHS_CONTRACT_ADDRESS,
        UNISWAP_V3_ROUTER,
        LINK_ADDRESS,
        WETH_ADDRESS,
        VRF_COORDINATOR_ADDRESS
      ];

      const FEES = [
        WAGER,
        DAO_FEE_BPS,
        OPERATIONAL_FEE_BPS,
        RNG_CHAINLINK_COST,
        START_ROUND_INCETIVE,
        END_ROUND_INCETIVE
      ];

      const PolymorphBattleground = await ethers.getContractFactory("PolymorphBattleground");
      const polymorphBattleground = await PolymorphBattleground.deploy(
        ADDRESSES,
        FEES,
        DAO_ADDRESS
      );
    await polymorphBattleground.deployed();

    // Init items
    await polymorphBattleground.initItems(CHARACTER_ITEMS);
    await polymorphBattleground.initItems(BACKGROUND_ITEMS);
    await polymorphBattleground.initItems(PANTS_ITEMS);
    await polymorphBattleground.initItems(TORSO_ITEMS);
    await polymorphBattleground.initItems(FOOTWEAR_ITEMS);
    await polymorphBattleground.initItems(EYEWEAR_ITEMS);
    await polymorphBattleground.initItems(HEAD_ITEMS);
    await polymorphBattleground.initItems(WEAPON_RIGHT_ITEMS);
    await polymorphBattleground.initItems(WEAPON_LEFT_ITEMS);

    console.log("PolymorphBattleground deployed to:", polymorphBattleground.address);

    } else {
      console.log("PolymorphBattleground already deployed");
    }
  }
};

module.exports.tags = ["PolymorphBattleground"];