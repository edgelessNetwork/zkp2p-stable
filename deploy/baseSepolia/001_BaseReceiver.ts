import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, execute, get } = deployments;
  const { deployer, stableReceiver, USDC } = await getNamedAccounts();

  await deploy("BaseReceiver", {
    contract: "BaseReceiver",
    from: deployer,
    log: true,
    skipIfAlreadyDeployed: true,
  });

  await execute(
    "BaseReceiver",
    {
      from: deployer,
      log: true,
    },
    "initialize",
    deployer,
    stableReceiver,
    USDC,
  );

  await hre.run("verify:verify", {
    address: (await get("BaseReceiver")).address,
    constructorArguments:[],
  });
};
export default func;
