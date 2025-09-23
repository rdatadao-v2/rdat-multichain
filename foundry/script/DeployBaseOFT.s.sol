// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {RdatOFT} from "../src/RdatOFT.sol";

contract DeployBaseOFT is Script {
    // Base Mainnet Configuration
    address constant BASE_ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;
    address constant BASE_MULTISIG = 0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy RdatOFT
        RdatOFT oft = new RdatOFT(
            "RDAT",
            "RDAT",
            BASE_ENDPOINT,
            BASE_MULTISIG
        );

        console.log("Deployed RdatOFT to:", address(oft));
        console.log("Token Name: RDAT");
        console.log("Token Symbol: RDAT");
        console.log("Base Endpoint:", BASE_ENDPOINT);
        console.log("Owner (Multisig):", BASE_MULTISIG);

        vm.stopBroadcast();
    }
}