// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {OFT} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RdatOFT
 * @notice Omnichain Fungible Token for RDAT on satellite chains
 * @dev This contract represents RDAT on Base and other satellite chains
 *
 * The OFT mints tokens when receiving from Vana (canonical chain) and
 * burns tokens when sending back to Vana. This maintains the total supply
 * across all chains.
 *
 * Key features:
 * - Mints on receive from canonical chain
 * - Burns on send to canonical chain
 * - Maintains supply consistency across chains
 */
contract RdatOFT is OFT {
    /**
     * @notice Constructor for RdatOFT
     * @param _endpoint The LayerZero endpoint address on this chain
     * @param _owner The owner address (should be chain-specific multisig)
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _endpoint,
        address _owner
    ) OFT(_name, _symbol, _endpoint, _owner) Ownable(_owner) {}
}