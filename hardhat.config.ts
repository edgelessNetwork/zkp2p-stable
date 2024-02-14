import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-ethers";
import "hardhat-deploy";
import "hardhat-contract-sizer";
import "@nomicfoundation/hardhat-verify";

import dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.23",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1,
      },
    },
  },
  networks: {
    hardhat: {
      deploy: ["./deploy/hardhat/"],
    },
    sepolia: {
      deploy: ["./deploy/sepolia/"],
      url: "https://rpc.sepolia.org	",
      chainId: 11155111,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY!],
    },
    baseSepolia: {
      deploy: ["./deploy/baseSepolia/"],
      url: "https://sepolia.base.org",
      chainId: 84532,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY!],
    },
    edgelessSepoliaTestnet: {
      deploy: ["./deploy/edgelessSepoliaTestnet/"],
      url: "https://edgeless-testnet.rpc.caldera.xyz/http",
      chainId: 202,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY!],
      verify: {
        etherscan: {
          apiUrl: "https://edgeless-testnet.explorer.caldera.xyz/",
        },
      },
    },
  },
  namedAccounts: {
    deployer: {
      sepolia: "0x08C6fBA53BF2Ae19DBdC330E258B510c1C148e44",
      baseSepolia: "0x08C6fBA53BF2Ae19DBdC330E258B510c1C148e44",
      edgelessSepoliaTestnet: "0x08C6fBA53BF2Ae19DBdC330E258B510c1C148e44",
    },
    stableReceiver: {
      baseSepolia: "0x6FAc84fB0cdF5BCC40300dBd3b47d3d918eEEE04",
    },
    stableMinter: {
      sepolia: "0xAF6905711dA0Aec3513290DE42BA45143392a362",
      baseSepolia: "0xAF6905711dA0Aec3513290DE42BA45143392a362",
      edgelessSepoliaTestnet: "0xAF6905711dA0Aec3513290DE42BA45143392a362",
    },
    USDLR: {
      edgelessSepoliaTestnet: "0x1aFeB1d0c8EfA4D6b58b937949ffB55366b8D616",
    },
    USDC: {
      baseSepolia: "0x036CbD53842c5426634e7929541eC2318f3dCF7e",
      sepolia: "0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238",
    },
  },
  paths: {
    sources: "./src",
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.SEPOLIA_API_KEY!,
      baseSepolia: process.env.BASESCAN_API_KEY!,
      edgelessSepoliaTestnet: "You can enter any api key here, it doesn't matter ",
    },
    customChains: [
      {
        network: "edgelessSepoliaTestnet",
        chainId: 202,
        urls: {
          apiURL: "https://edgeless-testnet.explorer.caldera.xyz/api/",
          browserURL: "https://edgeless-testnet.explorer.caldera.xyz/",
        },
      },
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org/",
        },
      },
    ],
  },
};

export default config;
