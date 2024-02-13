import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, execute, get } = deployments;
  const { deployer, stableMinter } = await getNamedAccounts();

  await deploy("EthereumMinter", {
    contract: "EthereumMinter",
    from: deployer,
    log: true,
    skipIfAlreadyDeployed: true,
  });

  await execute(
    "EthereumMinter",
    { from: deployer },
    "initialize",
    deployer,
    (await get("USDC")).address,
    stableMinter,
  );

  await hre.run("verify:verify", {
    address: (await get("EthereumMinter")).address,
    constructorArguments: [],
  });
};
export default func;
