# RDAT Multichain - LayerZero V2 OFT Implementation

This repository contains the omnichain implementation of RDAT token using LayerZero V2's Omnichain Fungible Token (OFT) standard.

## Overview

RDAT is being deployed as an omnichain token across multiple chains:
- **Canonical Chain**: Vana Mainnet (existing RDAT at `0xC1aC75130533c7F93BDa67f6645De65C9DEE9a3A`)
- **Satellite Chains**: Base Mainnet, Solana Mainnet

## Architecture

- **Vana**: Uses `OFTAdapter` to wrap the existing RDAT ERC-20 token
- **Base**: Uses `OFT` contract that mints/burns RDAT representations
- **Solana**: Uses Solana OFT Program (SPL-compatible)

## Setup

1. **Install dependencies**:
```bash
pnpm install
```

2. **Configure environment**:
```bash
cp .env.example .env
# Edit .env with your private keys and configurations
```

3. **Compile contracts**:
```bash
pnpm compile
```

## Deployment

### 1. Pre-Deployment Setup

```bash
# Verify the Vana endpoint address (CRITICAL!)
pnpm verify-endpoint

# Create Solana wallet (if deploying to Solana)
./scripts/create-solana-wallet.sh
```

### 2. Deploy to Mainnet

```bash
# Deploy to Vana mainnet
pnpm deploy:vana

# Deploy to Base mainnet
pnpm deploy:base
```

### 3. Wire the Contracts

After deployment, save the contract addresses in `.env`:
```
VANA_ADAPTER_ADDRESS=0x...
BASE_OFT_ADDRESS=0x...
```

Then wire the peers:
```bash
pnpm wire
```

### 4. Test Bridge

```bash
pnpm bridge-test
```

## Configuration

### Chain Information

| Chain | EID | Endpoint Address |
|-------|-----|------------------|
| Vana Mainnet | 30330 | `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa` (needs verification) |
| Base Mainnet | 30184 | `0x1a44076050125825900e736c501f859c50fE728c` |
| Solana Mainnet | 30168 | N/A |

### Multisig Addresses

- **Vana**: `0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF`
- **Base**: `0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A`

## Testing

```bash
# Run all tests
pnpm test

# Run with coverage
pnpm hardhat coverage

# Run specific test
pnpm hardhat test test/RdatOFT.test.ts
```

## Security Considerations

1. **Peer Configuration**: Ensure peers are set correctly and bidirectionally
2. **Ownership**: Transfer ownership to multisigs after deployment
3. **Gas Limits**: Configure appropriate gas limits for cross-chain messages
4. **DVN Configuration**: Use LayerZero Labs DVN initially, consider custom DVN setup later
5. **Rate Limiting**: Consider implementing daily bridge limits initially

## Verification

After deployment, verify contracts on block explorers:

```bash
# Verify on Vanascan
pnpm hardhat verify --network vana <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>

# Verify on Basescan
pnpm hardhat verify --network base <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>
```

## Monitoring

Track cross-chain messages at:
- https://layerzeroscan.com/

## Resources

- [LayerZero V2 Documentation](https://docs.layerzero.network/v2)
- [OFT Quickstart Guide](https://docs.layerzero.network/v2/developers/evm/oft/quickstart)
- [Solana OFT Guide](https://docs.layerzero.network/v2/developers/solana/oft/quickstart)

## License

MIT