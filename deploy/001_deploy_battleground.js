require('dotenvrc');
const { deployments, hardhatArguments } = require("hardhat");
const POLYMORPHS_CONTRACT_ADDRESS = "0x6323c145f03b894c0461dd507d13A32d43d962fD";

module.exports = async function () {
  if (
    hardhatArguments.network === "ganache" ||
    hardhatArguments.network === "hardhat" ||
    hardhatArguments.network === "rinkeby" ||
    hardhatArguments.network === "ropsten"
  ) {
    const namedAccounts = await hre.getNamedAccounts();
    const Battleground = await deployments.getOrNull("PolymorphBattleground");
    const Polymorphs = await deployments.getOrNull("PolymorphWithGeneChanger");
    const { log } = deployments;
    const POLYMORPHS_CONTRACT_ADDRESS = process.env.POLYMORPHS_CONTRACT_ADDRESS;
    const DAO_ADDRESS = process.env.DAO_ADDRESS;
    const UNISWAP_SWAP_ROUTER_ADDRESS = process.env.UNISWAP_SWAP_ROUTER_ADDRESS;
    const LINK_ADDRESS = process.env.LINK_ADDRESS;
    const WETH_ADDRESS = process.env.WETH_ADDRESS;
    const DAO_FEE_BPS = process.env.DAO_FEE_BPS;
    const OPERATIONAL_FEE_BPS = process.env.OPERATIONAL_FEE_BPS;
    const LINK_COST = process.env.LINK_COST;
    const START_ROUND_INCETIVE = process.env.START_ROUND_INCETIVE;
    const END_ROUND_INCETIVE = process.env.END_ROUND_INCETIVE;
    const VRF_COORDINATOR_ADDRESS = process.env.VRF_COORDINATOR_ADDRESS;

    if (!Battleground) {

      const polymorphBattlegroundDeployment = await deployments.deploy("PolymorphBattleground", {
        from: namedAccounts.deployer,
        args: [
          POLYMORPHS_CONTRACT_ADDRESS,
          DAO_ADDRESS,
          UNISWAP_SWAP_ROUTER_ADDRESS,
          LINK_ADDRESS,
          WETH_ADDRESS,
          DAO_FEE_BPS,
          OPERATIONAL_FEE_BPS,
          LINK_COST,
          START_ROUND_INCETIVE,
          END_ROUND_INCETIVE,
          VRF_COORDINATOR_ADDRESS,
        ]
      });

      console.log("PolymorphBattleground deployed to:", polymorphBattlegroundDeployment.address);

    } else {
      log("PolymorphBattleground already deployed");
    }

    if (!Polymorphs) {

      const polymorphsDeployment = await deployments.deploy("PolymorphWithGeneChanger", {
        from: namedAccounts.deployer,
        args: [],
      });

      console.log("Polymorphs deployed to:", polymorphsDeployment.address);

    } else {
      log("Polymorphs already deployed");
    }

  }
};

module.exports.tags = ["PolymorphBattleground"];