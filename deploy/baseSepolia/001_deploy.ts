import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, get } = deployments;
  const { deployer, stableReceiver } = await getNamedAccounts();
  await deploy("USDC", {
    contract: "FiatTokenV2",
    from: deployer,
    log: true,
    skipIfAlreadyDeployed: true,
  });

  await deploy("BaseReceiver", {
    contract: "BaseReceiver",
    from: deployer,
    log: true,
    skipIfAlreadyDeployed: true,
    args: [stableReceiver, (await get("USDC")).address],
  });

  await hre.run("verify:verify", {
    address: (await get("USDC")).address,
    constructorArguments: [],
  });

  await hre.run("verify:verify", {
    address: (await get("BaseReceiver")).address,
    constructorArguments: [stableReceiver, (await get("USDC")).address],
  });
};
export default func;
