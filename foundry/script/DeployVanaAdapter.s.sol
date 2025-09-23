// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {RdatOFTAdapter} from "../src/RdatOFTAdapter.sol";

contract DeployVanaAdapter is Script {
    // Vana Mainnet Configuration
    address constant RDAT_TOKEN = 0x2c1CB448cAf3579B2374EFe20068Ea97F72A996E;
    address constant VANA_ENDPOINT = 0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa;
    address constant VANA_MULTISIG = 0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy RdatOFTAdapter
        RdatOFTAdapter adapter = new RdatOFTAdapter(
            RDAT_TOKEN,
            VANA_ENDPOINT,
            VANA_MULTISIG
        );

        console.log("Deployed RdatOFTAdapter to:", address(adapter));
        console.log("RDAT Token:", RDAT_TOKEN);
        console.log("Vana Endpoint:", VANA_ENDPOINT);
        console.log("Owner (Multisig):", VANA_MULTISIG);

        vm.stopBroadcast();
    }
}