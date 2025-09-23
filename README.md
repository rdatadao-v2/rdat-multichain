# RDAT Multichain Bridge

RDAT token deployed across multiple chains using LayerZero V2 OFT (Omnichain Fungible Token) standard.

## 📊 Status: ✅ **BRIDGE OPERATIONAL**

RDAT is successfully deployed and operational across **Vana**, **Base**, and **Solana** networks with LayerZero V2 infrastructure.

## 🌐 Networks & Contracts

### Vana Mainnet (Canonical)
- **Contract**: OFT Adapter `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58`
- **Type**: Wraps existing RDAT token
- **Explorer**: [Vanascan](https://vanascan.io/address/0xd546C45872eeA596155EAEAe9B8495f02ca4fc58)

### Base Mainnet
- **Contract**: OFT `0x77D2713972af12F1E3EF39b5395bfD65C862367C`
- **Type**: Mints/burns RDAT representations
- **Explorer**: [Basescan](https://basescan.org/address/0x77D2713972af12F1E3EF39b5395bfD65C862367C)

### Solana Mainnet
- **Program**: `BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f`
- **SPL Mint**: `HVGrNMrX2uNsFhdvS73BgvGzHVb7VwPHYQwgteC7WR8y`
- **Type**: SPL token integration with LayerZero
- **Explorer**: [Solana Explorer](https://explorer.solana.com/address/BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f)

## 🌉 Bridge Status

- ✅ **Vana ↔ Base**: Fully operational (bidirectional)
- ✅ **Vana → Solana**: Configured and operational
- ⏳ **Solana → Vana**: Available when needed

## 📖 Documentation

**All documentation is organized in the `docs/` folder:**

### 👥 **For Users**
- **[📖 Documentation Hub](./docs/README.md)** - Start here for everything
- **[🚀 Quick Start Guide](./docs/guides/QUICK_START.md)** - Get started with RDAT multichain
- **[🌉 User Bridging Guide](./docs/guides/USER_BRIDGING_GUIDE.md)** - How to bridge RDAT between chains

### 👨‍💻 **For Developers**
- **[🛠️ Frontend Integration Guide](./docs/guides/FRONTEND_INTEGRATION_GUIDE.md)** - Build custom bridge UI with burn mechanism
- **[🏗️ Architecture Overview](./docs/architecture/ARCHITECTURE.md)** - Technical system architecture
- **[📋 Deployment Results](./docs/deployment/DEPLOYMENT_RESULTS.md)** - All contract addresses and verification

### 🏢 **For Project Teams**
- **[📊 Project Summary](./docs/reference/PROJECT_SUMMARY.md)** - Complete project overview
- **[🎯 Final Status](./docs/reference/FINAL_STATUS.md)** - Current implementation status
- **[💰 CoinMarketCap Guide](./docs/guides/COINMARKETCAP_LISTING_GUIDE.md)** - Exchange listing requirements
- **[⭐ Stargate Submission Guide](./docs/guides/STARGATE_SUBMISSION_GUIDE.md)** - Stargate Finance integration

## 🏗️ Repository Structure

```
rdat-multichain/
├── 📁 contracts/              # Foundry smart contracts (Vana & Base)
├── 📁 solana-oft/             # Anchor Solana program
├── 📁 docs/                   # 📚 Organized documentation
│   ├── 📁 guides/             #   User & developer guides
│   ├── 📁 deployment/         #   Deployment documentation
│   ├── 📁 architecture/       #   Technical architecture
│   └── 📁 reference/          #   Project reference materials
├── 📄 README.md               # This overview
└── 📄 CLAUDE.md               # Claude Code configuration
```

## ⚡ Key Features

- **🌉 Cross-Chain Bridge**: Seamless RDAT transfers via LayerZero V2
- **🔥 Deflationary Burn**: Optional 0.01% burn fee on custom bridge UI
- **🔒 Multisig Security**: Secure ownership across all chains
- **📊 Full Monitoring**: LayerZero Scan integration
- **🚀 Production Ready**: All contracts deployed and operational
- **📱 Mobile Support**: MetaMask + Phantom wallet integration

## 🛠️ Development

### EVM Contracts (Vana & Base)
```bash
cd contracts
forge build                    # Build contracts
forge test                     # Run tests
forge script DeployWrapper     # Deploy burn wrapper
```

### Solana Program
```bash
cd solana-oft/oft-solana
anchor build                   # Build program
anchor test                    # Run tests
anchor deploy                  # Deploy to mainnet
```

## 📞 Support & Resources

- **📖 Complete Documentation**: [./docs/README.md](./docs/README.md)
- **🔍 LayerZero Scan**: [Track transactions](https://layerzeroscan.com)
- **💬 LayerZero Discord**: [#dev-support](https://discord.gg/layerzero)
- **🐛 GitHub Issues**: [Report problems](https://github.com/rdatadao-v2/rdat-multichain/issues)

## 🎉 What's Next?

1. **🏦 Exchange Listings**: DEX liquidity → CoinMarketCap → CEX listings
2. **⭐ Stargate Integration**: Submit for Stargate Finance UI listing
3. **🎨 Custom Bridge UI**: Deploy deflationary burn mechanism
4. **🔄 Bidirectional Solana**: Complete Solana ↔ Vana configuration

---

**🚀 The bridge is live and ready for cross-chain RDAT transfers!**

*Last updated: September 23, 2025*
*🤖 Built with [Claude Code](https://claude.ai/code)*