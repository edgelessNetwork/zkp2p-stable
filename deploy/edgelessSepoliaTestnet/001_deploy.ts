import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, execute, get } = deployments;
  const { deployer, stableMinter, USDLR } = await getNamedAccounts();

  await deploy("EdgelessMinter", {
    contract: "EdgelessMinter",
    from: deployer,
    log: true,
    skipIfAlreadyDeployed: true,
  });

  await execute("EdgelessMinter", { from: deployer }, "initialize", deployer, USDLR, stableMinter);

  await hre.run("verify:verify", {
    address: (await get("EdgelessMinter")).address,
    constructorArguments: [],
  });
};
export default func;
