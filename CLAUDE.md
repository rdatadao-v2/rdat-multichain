# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RDAT multichain bridge implementation using LayerZero V2 OFT (Omnichain Fungible Token) standard across Vana, Base, and Solana networks.

## Build Commands

### EVM Contracts (Foundry)
```bash
cd contracts
forge build                           # Build contracts
forge test                           # Run all tests
forge test --match-test testName -vvv # Run single test with verbose output
forge script script/DeployWrapper.s.sol --rpc-url vana --broadcast  # Deploy to Vana
forge verify-contract ADDRESS src/RDATBridgeWrapper.sol:RDATBridgeWrapper --chain vana  # Verify contract
```

### Solana Program (Anchor)
```bash
cd solana-oft/oft-solana
anchor build                         # Build program (use Docker if local fails)
anchor test                          # Run tests
anchor deploy --provider.cluster mainnet  # Deploy to mainnet
npx jest test/anchor                 # Run JavaScript tests
```

### Configuration & Deployment
```bash
# Deploy enforced options configuration (requires multisig)
cd solana-oft/oft-solana
npx hardhat lz:oapp:config:set --network vana
```

## Architecture

### Contract Deployment Model
```
Vana (Canonical)        Base (Satellite)         Solana (Satellite)
     ↓                        ↓                         ↓
OFT Adapter              OFT Contract             OFT Program
(wraps RDAT)            (mints/burns)            (SPL token)
     ↓                        ↓                         ↓
0xd546C4...fc58         0x77D27...367C           BQWFM5...ax4f
```

### Cross-Chain Message Flow
1. **Lock & Mint**: User locks RDAT on Vana → LayerZero message → Mint on destination
2. **Burn & Unlock**: User burns on satellite → LayerZero message → Unlock on Vana
3. **Message verification**: DVNs validate cross-chain messages
4. **Execution**: Executors deliver messages to destination chains

### Key Contracts

#### Vana OFT Adapter
- Wraps existing RDAT ERC20 token at `0x2c1CB448cAf3579B2374EFe20068Ea97F72A996E`
- Manages lock/unlock for cross-chain transfers
- Deployed at `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58`

#### Base OFT
- Mints/burns RDAT representations
- No underlying token - OFT is the token itself
- Deployed at `0x77D2713972af12F1E3EF39b5395bfD65C862367C`

#### Solana OFT Program
- Program ID: `BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f`
- SPL Mint: `HVGrNMrX2uNsFhdvS73BgvGzHVb7VwPHYQwgteC7WR8y`
- Uses PDAs for OFT Store and escrow accounts

#### Burn Fee Wrapper (Optional)
- Implements 0.01% burn fee on bridges
- Burns to `0x000000000000000000000000000000000000dEaD`
- Located in `contracts/src/RDATBridgeWrapper.sol`

### LayerZero Configuration

#### Endpoint IDs (EIDs)
- Vana: 30330
- Base: 30184
- Solana: 30168

#### Enforced Options
- EVM chains: 1,000,000 gas (Arbitrum-compatible)
- Solana: 300,000 compute units + 2,039,280 lamports rent

#### Peer Connections
Peers must be bidirectionally configured via multisig:
- Vana ↔ Base: Operational
- Vana → Solana: Configured
- Solana → Vana: Pending

## Critical Implementation Details

### When Bridging Tokens
- Use `SendParam` struct with destination EID (not chain ID)
- Set `minAmountLD` for slippage protection (typically 99% of amount)
- Include LayerZero fee in native token (VANA/ETH/SOL)
- Monitor via LayerZero Scan for transaction status

### Decimal Handling
- Vana/Base: 18 decimals
- Solana: 9 decimals local, 6 shared decimals for bridging
- LayerZero handles decimal conversion automatically

### Security Model
- All contracts owned by multisigs
- Vana multisig: `0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF`
- Base multisig: `0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A`
- Solana authority transfer pending to multisig

## Deployed Addresses

### Vana Mainnet
- RDAT Token: `0x2c1CB448cAf3579B2374EFe20068Ea97F72A996E`
- OFT Adapter: `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58`
- LayerZero Endpoint: `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa`

### Base Mainnet
- OFT Contract: `0x77D2713972af12F1E3EF39b5395bfD65C862367C`
- LayerZero Endpoint: `0x1a44076050125825900e736c501f859c50fE728c`

### Solana Mainnet
- Program: `BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f`
- SPL Mint: `HVGrNMrX2uNsFhdvS73BgvGzHVb7VwPHYQwgteC7WR8y`
- OFT Store: `FkVGPvVoE3oYoz6EDuJ3ZP2D9aSgM5HHuxk3jf9ckU35`

## Documentation Structure
- `docs/guides/` - User and developer guides
- `docs/deployment/` - Deployment records and process
- `docs/architecture/` - Technical architecture details
- `docs/reference/` - Project reference and planning