import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";
import "@layerzerolabs/toolbox-hardhat";
import "hardhat-deploy";
import "hardhat-deploy-ethers";
import "hardhat-gas-reporter";
import "solidity-coverage";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.22",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]
  },
  networks: {
    // Vana Mainnet
    vana: {
      url: process.env.VANA_RPC_URL || "https://rpc.vana.org",
      chainId: 1480,
      accounts: process.env.DEPLOYER_PRIVATE_KEY ? [process.env.DEPLOYER_PRIVATE_KEY] : [],
      gasPrice: "auto"
    },
    // Base Mainnet
    base: {
      url: process.env.BASE_RPC_URL || "https://mainnet.base.org",
      chainId: 8453,
      accounts: process.env.DEPLOYER_PRIVATE_KEY ? [process.env.DEPLOYER_PRIVATE_KEY] : [],
      gasPrice: "auto"
    },
    hardhat: {
      chainId: 1337
    }
  },
  namedAccounts: {
    deployer: {
      default: 0
    },
    owner: {
      vana: process.env.VANA_MULTISIG_ADDRESS || "",
      base: process.env.BASE_MULTISIG_ADDRESS || ""
    }
  },
  etherscan: {
    apiKey: {
      base: process.env.BASESCAN_API_KEY || "",
      vana: process.env.VANASCAN_API_KEY || ""
    },
    customChains: [
      {
        network: "vana",
        chainId: 1480,
        urls: {
          apiURL: "https://api.vanascan.io/api",
          browserURL: "https://vanascan.io"
        }
      }
    ]
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS === "true",
    currency: "USD"
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
    deployments: "./deployments"
  }
};

export default config;