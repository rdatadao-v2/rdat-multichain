// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {RdatOFTAdapter} from "../src/RdatOFTAdapter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ForkTest
 * @notice Tests the deployment and basic functionality on forked mainnet
 * @dev Run with: forge test --fork-url https://rpc.vana.org -vvv
 */
contract ForkTest is Test {
    // Vana Configuration
    address constant RDAT_TOKEN = 0xC1aC75130533c7F93BDa67f6645De65C9DEE9a3A;
    address constant VANA_ENDPOINT = 0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa;
    address constant VANA_MULTISIG = 0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF;

    uint32 constant BASE_EID = 30184;

    RdatOFTAdapter adapter;
    IERC20 rdatToken;

    function setUp() public {
        // Fork Vana mainnet
        string memory VANA_RPC = vm.envOr("VANA_RPC_URL", string("https://rpc.vana.org"));
        vm.createSelectFork(VANA_RPC);

        // Setup token interface
        rdatToken = IERC20(RDAT_TOKEN);
    }

    function test_VanaEndpointExists() public {
        assertTrue(VANA_ENDPOINT.code.length > 0, "Vana endpoint should have code");
        console.log("[OK] Vana endpoint verified at:", VANA_ENDPOINT);
    }

    function test_RDATTokenExists() public {
        assertTrue(RDAT_TOKEN.code.length > 0, "RDAT token should have code");

        // Check token properties
        uint256 totalSupply = rdatToken.totalSupply();
        assertEq(totalSupply, 100_000_000 * 10**18, "Total supply should be 100M");

        console.log("[OK] RDAT token verified");
        console.log("  Total Supply:", totalSupply / 10**18, "RDAT");
    }

    function test_DeployAdapter() public {
        // Deploy the adapter
        adapter = new RdatOFTAdapter(
            RDAT_TOKEN,
            VANA_ENDPOINT,
            VANA_MULTISIG
        );

        // Verify deployment
        assertTrue(address(adapter) != address(0), "Adapter should be deployed");
        assertEq(adapter.owner(), VANA_MULTISIG, "Owner should be multisig");
        assertEq(address(adapter.token()), RDAT_TOKEN, "Should wrap RDAT token");

        console.log("[OK] OFT Adapter deployed successfully");
        console.log("  Address:", address(adapter));
        console.log("  Wrapped token:", address(adapter.token()));
        console.log("  Owner:", adapter.owner());
    }

    function test_SetPeer() public {
        // Deploy adapter
        adapter = new RdatOFTAdapter(
            RDAT_TOKEN,
            VANA_ENDPOINT,
            address(this) // Use test contract as owner for testing
        );

        // Mock Base OFT address
        address mockBaseOFT = address(0x1234567890123456789012345678901234567890);
        bytes32 baseOFTBytes32 = bytes32(uint256(uint160(mockBaseOFT)));

        // Set peer
        adapter.setPeer(BASE_EID, baseOFTBytes32);

        // Verify peer was set
        bytes32 setPeer = adapter.peers(BASE_EID);
        assertEq(setPeer, baseOFTBytes32, "Peer should be set correctly");

        console.log("[OK] Peer configuration successful");
        console.log("  Base EID:", BASE_EID);
        console.log("  Base OFT (mock):", mockBaseOFT);
    }

    function test_TransferOwnership() public {
        // Deploy adapter with test contract as owner
        adapter = new RdatOFTAdapter(
            RDAT_TOKEN,
            VANA_ENDPOINT,
            address(this)
        );

        // Transfer ownership to multisig
        adapter.transferOwnership(VANA_MULTISIG);

        // Note: OFT contracts use single-step ownership transfer
        assertEq(adapter.owner(), VANA_MULTISIG, "Ownership should be transferred");

        console.log("[OK] Ownership transfer successful");
        console.log("  New owner:", VANA_MULTISIG);
    }

    function test_GasEstimation() public {
        uint256 gasBefore = gasleft();

        // Deploy adapter
        adapter = new RdatOFTAdapter(
            RDAT_TOKEN,
            VANA_ENDPOINT,
            VANA_MULTISIG
        );

        uint256 gasUsed = gasBefore - gasleft();

        console.log("Gas usage estimates:");
        console.log("  Adapter deployment: ~", gasUsed, "gas");
        console.log("  Estimated cost at 30 gwei:", (gasUsed * 30) / 10**9, "VANA");
    }
}