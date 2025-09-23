# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a multichain deployment of the RDAT token using LayerZero v2's Omnichain Fungible Token (OFT) standard. The token is canonical on Vana Mainnet and has satellite deployments on Base Mainnet and Solana Mainnet.

## Key Chain Information

- **Vana Mainnet** (Canonical Chain)
  - EID: 30330
  - EndpointV2: `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa`
  - Contract Type: OFTAdapter (wraps existing RDAT ERC-20)

- **Base Mainnet** (Satellite)
  - EID: 30184
  - EndpointV2: `0x1a44076050125825900e736c501f859c50fE728c`
  - Contract Type: OFT (mints/burns RDAT representations)

- **Solana Mainnet** (Satellite)
  - EID: 30168
  - Contract Type: Solana OFT program (SPL-compatible)

## Development Commands

### Initial Setup
```bash
# Scaffold EVM contracts and configuration
npx create-lz-oapp@latest --example oft

# Scaffold Solana OFT (if needed)
LZ_ENABLE_SOLANA_OFT_EXAMPLE=1 npx create-lz-oapp@latest
```

### Deployment Workflow
1. Deploy `RdatOFTAdapter` on Vana (wraps existing RDAT token)
2. Deploy `RdatOFT` on Base (mints/burns representations)
3. Deploy Solana OFT program on Solana
4. Wire trusted peers using `setPeer()` calls bidirectionally
5. Configure DVNs (Decentralized Verification Networks) and Executors
6. Run configuration scripts to complete setup

## Architecture Notes

### Contract Types
- **OFTAdapter**: Used on Vana to wrap the existing RDAT ERC-20 token
- **OFT**: Used on Base for minting/burning RDAT representations
- **Solana OFT**: SPL-compatible program for Solana deployment

### Cross-Chain Communication
- All cross-chain references use EIDs (Endpoint IDs), not traditional chain IDs
- Each contract must explicitly trust its peers via `setPeer()` configuration
- Messages include gas/compute parameters configured via LayerZero Options

### Key Implementation Details
- When bridging tokens, use `IOFT.SendParam` structure with destination EID
- Always set `minAmountLD` to handle potential slippage
- Configure appropriate gas limits: ~80,000 for EVM, ~200,000 for Solana
- Total supply consistency must be maintained across all chains

## Important LayerZero v2 References
- Chain IDs/EIDs: https://docs.layerzero.network/v2/developers/evm/chain-ids
- OFT Overview: https://docs.layerzero.network/v2/developers/evm/oft/overview
- Solana OFT: https://docs.layerzero.network/v2/developers/solana/oft/quickstart
- Configuration: https://docs.layerzero.network/v2/developers/oapp/configuration