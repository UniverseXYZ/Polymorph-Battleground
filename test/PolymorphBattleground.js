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

  const FEES = [
    WAGER,
    DAO_FEE_BPS,
    OPERATIONAL_FEEBPS,
    RNG_CHAINLINK_COST,
    START_ROUND_INCETIVE,
    END_ROUND_INCETIVE
  ];

  const PolymorphBattleground = await ethers.getContractFactory("PolymorphBattleground");
  const polymorphBattleground = await PolymorphBattleground.deploy(
    ADDRESSES,
    FEES,
    dao.address
    );
  await polymorphBattleground.deployed();

  // Init items
  await polymorphBattleground.connect(dao).initItems(CHARACTER_ITEMS);
  await polymorphBattleground.connect(dao).initItems(BACKGROUND_ITEMS);
  await polymorphBattleground.connect(dao).initItems(PANTS_ITEMS);
  await polymorphBattleground.connect(dao).initItems(TORSO_ITEMS);
  await polymorphBattleground.connect(dao).initItems(FOOTWEAR_ITEMS);
  await polymorphBattleground.connect(dao).initItems(EYEWEAR_ITEMS);
  await polymorphBattleground.connect(dao).initItems(HEAD_ITEMS);
  await polymorphBattleground.connect(dao).initItems(WEAPON_RIGHT_ITEMS);
  await polymorphBattleground.connect(dao).initItems(WEAPON_LEFT_ITEMS);

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

  it("User cannot enter the battle pool with wrong Battle stance !", async function () {
    const signer = signers[0];
    await polymorphsContract.mint(signer.address, 2);
    await expect(polymorphBattleground.enterBattle(2, 2, {value: ethers.utils.parseEther("1")})).revertedWith('Plase select an existing battle stance !');
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