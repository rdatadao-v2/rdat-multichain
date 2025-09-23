// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IOFTAdapter {
    struct SendParam {
        uint32 dstEid;
        bytes32 to;
        uint256 amountLD;
        uint256 minAmountLD;
        bytes extraOptions;
        bytes composeMsg;
        bytes oftCmd;
    }

    struct MessagingFee {
        uint256 nativeFee;
        uint256 lzTokenFee;
    }

    struct MessagingReceipt {
        bytes32 guid;
        uint64 nonce;
        MessagingFee fee;
    }

    function send(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory);

    function quoteSend(
        SendParam calldata _sendParam,
        bool _payInLzToken
    ) external view returns (MessagingFee memory);
}

/**
 * @title TestBridge
 * @notice Script to test bridging RDAT from Vana to Base after deployment
 * @dev Run with: forge script script/TestBridge.s.sol --rpc-url https://rpc.vana.org --broadcast
 */
contract TestBridge is Script {
    // Addresses
    address constant RDAT_TOKEN = 0xC1aC75130533c7F93BDa67f6645De65C9DEE9a3A;

    // LayerZero EIDs
    uint32 constant BASE_EID = 30184;

    // Test amount: 0.001 RDAT
    uint256 constant TEST_AMOUNT = 0.001 ether;

    function run() external {
        // Get addresses from environment
        address vanaAdapter = vm.envAddress("VANA_ADAPTER_ADDRESS");
        require(vanaAdapter != address(0), "VANA_ADAPTER_ADDRESS not set");

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("=== RDAT Bridge Test ===");
        console.log("");
        console.log("Test Amount:", TEST_AMOUNT / 10**18, "RDAT");
        console.log("From:", deployer);
        console.log("To Chain: Base (EID:", BASE_EID, ")");
        console.log("");

        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Check RDAT balance
        IERC20 rdat = IERC20(RDAT_TOKEN);
        uint256 balance = rdat.balanceOf(deployer);
        console.log("[1] Current RDAT balance:", balance / 10**18, "RDAT");
        require(balance >= TEST_AMOUNT, "Insufficient RDAT balance");

        // Step 2: Approve adapter
        console.log("");
        console.log("[2] Approving adapter to spend RDAT...");
        rdat.approve(vanaAdapter, TEST_AMOUNT);
        console.log("    Approved:", TEST_AMOUNT / 10**18, "RDAT");

        // Step 3: Prepare send parameters
        IOFTAdapter adapter = IOFTAdapter(vanaAdapter);
        IOFTAdapter.SendParam memory sendParam = IOFTAdapter.SendParam({
            dstEid: BASE_EID,
            to: bytes32(uint256(uint160(deployer))), // Send to same address on Base
            amountLD: TEST_AMOUNT,
            minAmountLD: TEST_AMOUNT,
            extraOptions: bytes(""),
            composeMsg: bytes(""),
            oftCmd: bytes("")
        });

        // Step 4: Quote the bridge fee
        console.log("");
        console.log("[3] Getting bridge quote...");
        IOFTAdapter.MessagingFee memory fee = adapter.quoteSend(sendParam, false);
        console.log("    Required fee:", fee.nativeFee, "wei");
        console.log("    In VANA:", fee.nativeFee / 10**18, "VANA");

        // Check deployer has enough VANA for gas
        uint256 vanaBalance = deployer.balance;
        console.log("    Current VANA balance:", vanaBalance / 10**18, "VANA");
        require(vanaBalance >= fee.nativeFee, "Insufficient VANA for bridge fee");

        // Step 5: Execute bridge
        console.log("");
        console.log("[4] Executing bridge transaction...");
        IOFTAdapter.MessagingReceipt memory receipt = adapter.send{value: fee.nativeFee}(
            sendParam,
            IOFTAdapter.MessagingFee(fee.nativeFee, 0),
            deployer // refund address
        );

        console.log("    [OK] Bridge transaction sent!");
        console.log("    Message GUID:", vm.toString(receipt.guid));
        console.log("    Nonce:", receipt.nonce);

        vm.stopBroadcast();

        console.log("");
        console.log("=== Bridge Test Complete ===");
        console.log("");
        console.log("Next steps:");
        console.log("1. Monitor LayerZero Scanner: https://layerzeroscan.com/");
        console.log("2. Check Base for received RDAT");
        console.log("3. Try bridging back from Base to Vana");
    }
}