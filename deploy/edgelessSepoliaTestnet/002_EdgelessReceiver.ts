import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, execute, get } = deployments;
  const { deployer, stableMinter, USDLR } = await getNamedAccounts();

  await deploy("EdgelessReceiver", {
    contract: "EdgelessReceiver",
    from: deployer,
    log: true,
    skipIfAlreadyDeployed: true,
  });

  await execute("EdgelessReceiver", { from: deployer }, "initialize", deployer, stableMinter, USDLR);

  await hre.run("verify:verify", {
    address: (await get("EdgelessReceiver")).address,
    constructorArguments: [],
  });
};
export default func;
