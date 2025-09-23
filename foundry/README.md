# RDAT Multichain - Foundry Implementation

This directory contains the Foundry-based implementation of the RDAT omnichain token using LayerZero V2.

## Overview

The RDAT multichain deployment uses LayerZero V2 OFT (Omnichain Fungible Token) standard to enable seamless token transfers between:

- **Vana Mainnet** (Canonical chain with existing RDAT token)
- **Base Mainnet** (Satellite chain)
- **Solana Mainnet** (Future implementation)

## Architecture

- **RdatOFTAdapter.sol**: Wraps the existing RDAT token on Vana Mainnet
- **RdatOFT.sol**: Mints/burns RDAT representations on satellite chains

## Setup

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- Private key with sufficient funds on target networks

### Installation

```bash
# Install dependencies
forge install

# Compile contracts
forge build
```

## Configuration

### Environment Variables

Create a `.env` file in this directory:

```bash
# Deployment
DEPLOYER_PRIVATE_KEY=0x...

# Contract Addresses (set after deployment)
VANA_ADAPTER_ADDRESS=
BASE_OFT_ADDRESS=

# API Keys for verification
VANASCAN_API_KEY=
BASESCAN_API_KEY=
```

### Network Configuration

The `foundry.toml` file includes configurations for:
- **Vana Mainnet**: Chain ID 1480
- **Base Mainnet**: Chain ID 8453

## Deployment

### 1. Deploy Vana OFT Adapter

```bash
forge script script/DeployVanaAdapter.s.sol --rpc-url https://rpc.vana.org --broadcast --verify
```

### 2. Deploy Base OFT

```bash
forge script script/DeployBaseOFT.s.sol --rpc-url https://mainnet.base.org --broadcast --verify
```

### 3. Wire Contracts Together

Update your `.env` with the deployed contract addresses, then:

```bash
forge script script/WireContracts.s.sol --rpc-url https://rpc.vana.org --broadcast
forge script script/WireContracts.s.sol --rpc-url https://mainnet.base.org --broadcast
```

## Key Addresses

### Vana Mainnet
- **Existing RDAT Token**: `0xC1aC75130533c7F93BDa67f6645De65C9DEE9a3A`
- **LayerZero Endpoint**: `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa`
- **Multisig Owner**: `0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF`

### Base Mainnet
- **LayerZero Endpoint**: `0x1a44076050125825900e736c501f859c50fE728c`
- **Multisig Owner**: `0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A`

### LayerZero Endpoint IDs
- **Vana**: 30330
- **Base**: 30184

## Security Considerations

1. **Ownership Transfer**: After deployment, ownership should be transferred to multisig addresses
2. **Peer Verification**: Double-check all setPeer calls are correct and bidirectional
3. **Gas Limits**: Monitor and optimize gas settings for cross-chain messages
4. **Rate Limiting**: Consider implementing bridge limits for initial launch

## Testing

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vv

# Run specific test
forge test --match-test testDeployment -vv
```

## Verification

After deployment, verify contracts on block explorers:

```bash
# Verify Vana contract
forge verify-contract <ADAPTER_ADDRESS> src/RdatOFTAdapter.sol:RdatOFTAdapter \
  --chain-id 1480 \
  --constructor-args $(cast abi-encode "constructor(address,address,address)" \
    0xC1aC75130533c7F93BDa67f6645De65C9DEE9a3A \
    0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa \
    0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF)

# Verify Base contract
forge verify-contract <OFT_ADDRESS> src/RdatOFT.sol:RdatOFT \
  --chain-id 8453 \
  --constructor-args $(cast abi-encode "constructor(string,string,address,address)" \
    "RDAT" "RDAT" \
    0x1a44076050125825900e736c501f859c50fE728c \
    0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A)
```

## Monitoring

- **LayerZero Scanner**: https://layerzeroscan.com/
- **Vana Explorer**: https://vanascan.io/
- **Base Explorer**: https://basescan.org/

## Advantages of Foundry

1. **Performance**: 10x faster compilation and testing
2. **Security**: Better tooling for audit and security analysis
3. **Simplicity**: No complex JavaScript dependency management
4. **Industry Standard**: Preferred by most new DeFi projects in 2025
5. **Native Solidity**: Write tests in Solidity instead of JavaScript

## Migration from Hardhat

This Foundry implementation replaces the earlier Hardhat version while maintaining:
- ✅ Same contract logic and security
- ✅ Same deployment addresses and configuration
- ✅ Compatible with existing LayerZero infrastructure
- ✅ Improved developer experience and performance
