// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {OFTAdapter} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTAdapter.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RdatOFTAdapter
 * @notice OFT Adapter for existing RDAT token on Vana Mainnet
 * @dev This contract wraps the existing RDAT ERC-20 token to make it omnichain-compatible
 *
 * The adapter allows the existing RDAT token at 0xC1aC75130533c7F93BDa67f6645De65C9DEE9a3A
 * to be bridged to other chains using LayerZero V2.
 *
 * Key features:
 * - Locks tokens on Vana when bridging out
 * - Unlocks tokens when bridging back from other chains
 * - Maintains 1:1 backing with locked tokens
 */
contract RdatOFTAdapter is OFTAdapter {
    /**
     * @notice Constructor for RdatOFTAdapter
     * @param _rdatToken The address of the existing RDAT token on Vana (0xC1aC75130533c7F93BDa67f6645De65C9DEE9a3A)
     * @param _endpoint The LayerZero endpoint address on Vana
     * @param _owner The owner address (should be multisig: 0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF)
     */
    constructor(
        address _rdatToken,
        address _endpoint,
        address _owner
    ) OFTAdapter(_rdatToken, _endpoint, _owner) Ownable(_owner) {}
}