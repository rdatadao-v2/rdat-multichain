// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {RdatOFTAdapter} from "../src/RdatOFTAdapter.sol";
import {RdatOFT} from "../src/RdatOFT.sol";

contract WireContracts is Script {
    // LayerZero Endpoint IDs
    uint32 constant VANA_EID = 30330;
    uint32 constant BASE_EID = 30184;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        // Get deployed contract addresses from environment
        address vanaAdapter = vm.envAddress("VANA_ADAPTER_ADDRESS");
        address baseOFT = vm.envAddress("BASE_OFT_ADDRESS");

        require(vanaAdapter != address(0), "VANA_ADAPTER_ADDRESS not set");
        require(baseOFT != address(0), "BASE_OFT_ADDRESS not set");

        vm.startBroadcast(deployerPrivateKey);

        console.log("Setting up peer connections...");
        console.log("Vana Adapter:", vanaAdapter);
        console.log("Base OFT:", baseOFT);

        // Convert addresses to bytes32 for setPeer
        bytes32 vanaAdapterBytes32 = bytes32(uint256(uint160(vanaAdapter)));
        bytes32 baseOFTBytes32 = bytes32(uint256(uint160(baseOFT)));

        // Set Vana Adapter peer to Base OFT
        RdatOFTAdapter(vanaAdapter).setPeer(BASE_EID, baseOFTBytes32);
        console.log("Set Vana Adapter peer to Base OFT");

        // Set Base OFT peer to Vana Adapter
        RdatOFT(baseOFT).setPeer(VANA_EID, vanaAdapterBytes32);
        console.log("Set Base OFT peer to Vana Adapter");

        console.log("Peer connections established successfully!");

        vm.stopBroadcast();
    }
}