require('dotenvrc');
const { deployments, hardhatArguments } = require("hardhat");

module.exports = async function () {
  if (
    hardhatArguments.network === "ganache" ||
    hardhatArguments.network === "hardhat" ||
    hardhatArguments.network === "rinkeby" ||
    hardhatArguments.network === "ropsten"
  ) {
    const namedAccounts = await hre.getNamedAccounts();
    const Battleground = await deployments.getOrNull("PolymorphBattleground");
    const { log } = deployments;

    if (!Battleground) {

      const polymorphBattlegroundDeployment = await deployments.deploy("PolymorphBattleground", {
        from: namedAccounts.deployer,
        args: [process.env.POLYMORPHS_CONTRACT_ADDRESS],
      });

      console.log("PolymorphBattleground deployed to:", polymorphBattlegroundDeployment.address);

    } else {
      log("PolymorphBattleground already deployed");
    }

  }
};

module.exports.tags = ["PolymorphBattleground"];