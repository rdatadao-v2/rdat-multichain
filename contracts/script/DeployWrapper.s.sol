// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {RDATBridgeWrapper} from "../src/RDATBridgeWrapper.sol";

contract DeployWrapper is Script {
    // Configuration for each network
    struct NetworkConfig {
        address oftAdapter;
        address rdatToken;
        uint256 minAmount;
        uint256 maxAmount;
    }

    function run() external {
        // Get network config
        NetworkConfig memory config = getNetworkConfig();

        // Get deployer private key
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying RDATBridgeWrapper...");
        console.log("Deployer:", deployer);
        console.log("OFT Adapter:", config.oftAdapter);
        console.log("RDAT Token:", config.rdatToken);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy wrapper
        RDATBridgeWrapper wrapper = new RDATBridgeWrapper(
            config.oftAdapter,
            config.rdatToken,
            config.minAmount,
            config.maxAmount
        );

        console.log("RDATBridgeWrapper deployed at:", address(wrapper));
        console.log("Burn fee:", wrapper.BURN_FEE_BPS(), "bps (0.01%)");
        console.log("Min bridge amount:", config.minAmount);
        console.log("Max bridge amount:", config.maxAmount);

        vm.stopBroadcast();

        // Verify deployment
        console.log("\n=== Deployment Summary ===");
        console.log("Wrapper Address:", address(wrapper));
        console.log("Owner:", wrapper.owner());
        console.log("Total Burned:", wrapper.totalBurned());
        console.log("\n=== Next Steps ===");
        console.log("1. Transfer ownership to multisig");
        console.log("2. Update frontend to use wrapper");
        console.log("3. Test bridge with small amount");
    }

    function getNetworkConfig() internal view returns (NetworkConfig memory) {
        uint256 chainId = block.chainid;

        // Vana Mainnet
        if (chainId == 1480) {
            return NetworkConfig({
                oftAdapter: 0xd546C45872eeA596155EAEAe9B8495f02ca4fc58,
                rdatToken: 0x2c1CB448cAf3579B2374EFe20068Ea97F72A996E,
                minAmount: 1e18,        // 1 RDAT minimum
                maxAmount: 1000000e18   // 1M RDAT maximum
            });
        }

        // Base Mainnet
        if (chainId == 8453) {
            return NetworkConfig({
                oftAdapter: 0x77D2713972af12F1E3EF39b5395bfD65C862367C,
                rdatToken: 0x77D2713972af12F1E3EF39b5395bfD65C862367C, // OFT is the token itself
                minAmount: 1e18,        // 1 RDAT minimum
                maxAmount: 1000000e18   // 1M RDAT maximum
            });
        }

        // Local/Fork testing
        if (chainId == 31337) {
            console.log("Using local test configuration");
            return NetworkConfig({
                oftAdapter: address(0x1234567890123456789012345678901234567890),
                rdatToken: address(0x0987654321098765432109876543210987654321),
                minAmount: 1e18,
                maxAmount: 1000000e18
            });
        }

        revert("Unsupported chain");
    }
}