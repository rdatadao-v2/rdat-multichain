# RDAT Solana OFT Implementation

## Overview

This directory contains the Solana implementation of the RDAT Omnichain Fungible Token (OFT) using LayerZero V2. The program enables cross-chain transfers of RDAT tokens between Solana and EVM chains (Vana, Base).

## Deployment Information

### Mainnet Deployment
- **Program ID**: `BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f`
- **Network**: Solana Mainnet-Beta
- **Status**: ✅ Deployed (September 23, 2025)
- **Explorer**: [View on Solana Explorer](https://explorer.solana.com/address/BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f)

### Program Details
- **Size**: 557,168 bytes (557KB)
- **Authority**: `FFMX53TNrX3fRNXC6uGDZEis9NZpTbEV2d53dcwt4rGM`
- **Rent**: 3.88 SOL (rent-exempt)
- **Framework**: Anchor 0.29.0
- **LayerZero**: V2 Solana SDK

## Architecture

```
Solana OFT Program
├── SPL Token Integration
├── LayerZero V2 Messaging
└── Cross-chain Bridge
    ├── To Vana (Hub) - Pending Configuration
    └── To Base - Via Vana Hub
```

## Build Instructions

### Prerequisites
- Rust 1.75.0
- Anchor 0.29.0
- Solana CLI 1.17.31
- Docker (for builds)
- Node.js >= 18.16.0

### Building the Program

```bash
# Using Docker (recommended to avoid dependency issues)
anchor build -v -e OFT_ID=BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f

# Build artifacts will be in:
# - target/verifiable/oft.so (program binary)
# - target/idl/oft.json (IDL)
```

## Configuration

### Environment Setup
Create a `.env` file based on `.env.example`:

```env
# Solana Configuration
SOLANA_PRIVATE_KEY=<base58-private-key>
SOLANA_KEYPAIR_PATH=./keypair.json
RPC_URL_SOLANA=https://api.mainnet-beta.solana.com

# LayerZero Configuration
SOLANA_EID=30168
VANA_EID=30330
BASE_EID=30184

# Program Configuration
OFT_PROGRAM_ID=BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f
```

### Peer Configuration

To connect with other chains:

```bash
# Set Vana as peer (hub chain)
pnpm hardhat lz:oft:solana:set-peer \
  --eid 30168 \
  --peer-eid 30330 \
  --peer-address 0xd546C45872eeA596155EAEAe9B8495f02ca4fc58
```

## Program Instructions

### Key Instructions
- `init_oft` - Initialize OFT configuration
- `send` - Send tokens cross-chain
- `lz_receive` - Receive tokens from other chains
- `set_peer_config` - Configure trusted peers
- `quote_oft` - Get bridging fee quote

### Security Features
- Pausable functionality
- Rate limiting support
- Owner-only admin functions
- Peer validation

## Testing

```bash
# Run Anchor tests
anchor test

# Run specific test suites
cargo test -p oft
```

## Deployment Process

### 1. Deploy Program
```bash
solana program deploy \
  --program-id target/deploy/oft-keypair.json \
  target/verifiable/oft.so \
  -u mainnet-beta \
  --keypair keypair.json
```

### 2. Initialize OFT Store
```bash
pnpm hardhat lz:oft:solana:create \
  --eid 30168 \
  --program-id BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f
```

### 3. Configure Peers
Set up trusted connections with other chains (Vana, Base)

## Troubleshooting

### Common Issues

1. **ahash dependency error during build**
   - Solution: Use Docker build with Anchor 0.29.0
   - The Docker image includes the correct Rust toolchain

2. **Insufficient funds for deployment**
   - Required: ~3.88 SOL for program deployment
   - Additional: ~0.1 SOL for account creation and transactions

3. **Program upgrade authority**
   - Current authority: Deployer wallet
   - Transfer to multisig for production

## Network Information

### Chain IDs (EIDs)
- Solana: 30168
- Vana: 30330
- Base: 30184

### Contract Addresses
- Vana OFT Adapter: `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58`
- Base OFT: `0x77D2713972af12F1E3EF39b5395bfD65C862367C`

## Resources

- [LayerZero V2 Docs](https://docs.layerzero.network/v2)
- [Anchor Framework](https://www.anchor-lang.com/)
- [Solana Web3.js](https://solana-labs.github.io/solana-web3.js/)
- [RDAT Multichain Docs](../README.md)

## Support

For issues or questions:
- GitHub Issues: [rdatadao-v2/rdat-multichain](https://github.com/rdatadao-v2/rdat-multichain)
- LayerZero Discord: [LayerZero Community](https://discord.gg/layerzero)

---

🤖 Generated with [Claude Code](https://claude.ai/code)