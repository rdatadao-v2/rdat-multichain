# RDAT Multichain Execution Plan

## Summary
Deploy RDAT as an omnichain token using LayerZero v2 OFT (Omnichain Fungible Token) standard.
- **Canonical Chain**: Vana Mainnet (existing RDAT token at `0xC1aC75130533c7F93BDa67f6645De65C9DEE9a3A`)
- **Satellite Chains**: Base Mainnet, Solana Mainnet

## Key Information Discovered

### 1. Existing RDAT Token on Vana
- **Contract Address**: `0xC1aC75130533c7F93BDa67f6645De65C9DEE9a3A`
- **Type**: Upgradeable ERC-20 (RDATUpgradeable.sol)
- **Total Supply**: 100M RDAT
- **Features**: UUPS upgradeable, pausable, burnable, permit functionality

### 2. Validated Chain Configurations

#### Vana Mainnet (Canonical)
- **EID**: 30330 ✅ (Confirmed in LayerZero docs)
- **EndpointV2**: `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa` (Need to verify)
- **Contract Type**: OFTAdapter (wraps existing RDAT)

#### Base Mainnet (Satellite)
- **EID**: 30184 ✅ (Confirmed)
- **EndpointV2**: `0x1a44076050125825900e736c501f859c50fE728c` ✅ (Confirmed)
- **Contract Type**: OFT (mints/burns representations)

#### Solana Mainnet (Satellite)
- **EID**: 30168 ✅ (Confirmed in plan)
- **Contract Type**: Solana OFT Program

## Design Decisions Required

### 1. **Vana Endpoint Verification** ❓
The endpoint address `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa` needs verification. Most chains use `0x1a44076050125825900e736c501f859c50fE728c`. We need to:
- Deploy a test contract to verify the correct endpoint
- Or check with Vana documentation/team

### 2. **Multisig Configuration** ❓
Who should own the OFT contracts?
- **Recommendation**: Use existing multisigs from rdatadao-contracts
  - Vana: `0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF`
  - Base: `0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A`

### 3. **DVN (Decentralized Verifier Network) Setup** ❓
- Use LayerZero Labs DVN (simplest, recommended for start)
- Or configure custom DVN quorum (more complex, better decentralization)

### 4. **Gas/Execution Limits** ❓
- EVM to EVM: 80,000 gas (standard)
- EVM to Solana: 200,000 gas + 2,500,000 lamports value
- Need to test and optimize

## Implementation Steps

### Phase 1: Project Setup ✅
```bash
# 1. Create .gitignore for rdatadao-contracts
echo "rdatadao-contracts/" >> .gitignore

# 2. Scaffold LayerZero OFT project
npx create-lz-oapp@latest --example oft

# 3. Install dependencies
npm install
```

### Phase 2: Contract Development

#### 2.1 Vana OFTAdapter Contract
```solidity
// contracts/RdatOFTAdapter.sol
contract RdatOFTAdapter is OFTAdapter {
    constructor(
        address _rdatToken,    // 0xC1aC75130533c7F93BDa67f6645De65C9DEE9a3A
        address _endpoint,     // Verify: 0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa
        address _owner         // 0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF
    ) OFTAdapter(_rdatToken, _endpoint, _owner) {}
}
```

#### 2.2 Base OFT Contract
```solidity
// contracts/RdatOFT.sol
contract RdatOFT is OFT {
    constructor(
        string memory _name,   // "RDAT"
        string memory _symbol, // "RDAT"
        address _endpoint,     // 0x1a44076050125825900e736c501f859c50fE728c
        address _owner         // 0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A
    ) OFT(_name, _symbol, _endpoint, _owner) {}
}
```

#### 2.3 Solana OFT Program
- Use scaffolded Solana program
- Configure SPL token metadata

### Phase 3: Configuration

#### 3.1 LayerZero Config (layerzero.config.ts)
```typescript
const config = {
  contracts: [
    { eid: 30330, contractName: 'RdatOFTAdapter' }, // Vana
    { eid: 30184, contractName: 'RdatOFT' },       // Base
    { eid: 30168, address: '<SOLANA_OFT>' }        // Solana
  ],
  connections: [
    // Vana <-> Base
    {
      from: 30330,
      to: 30184,
      config: {
        sendLibrary: "SendUln302",
        receiveLibrary: "ReceiveUln302",
        sendConfig: {
          ulnConfig: {
            confirmations: 15,
            requiredDVNs: ["LayerZero Labs"],
            optionalDVNs: [],
            optionalDVNThreshold: 0
          }
        }
      }
    },
    // Similar for other pairs...
  ]
}
```

### Phase 4: Deployment Scripts

#### 4.1 Deploy Sequence
1. **Deploy Vana OFTAdapter**
   ```bash
   npx hardhat deploy --network vana --tags RdatOFTAdapter
   ```

2. **Deploy Base OFT**
   ```bash
   npx hardhat deploy --network base --tags RdatOFT
   ```

3. **Deploy Solana OFT**
   ```bash
   anchor deploy --provider.cluster mainnet
   ```

### Phase 5: Wiring & Configuration

#### 5.1 Set Peers (Critical!)
```javascript
// scripts/wire.ts
await vanaAdapter.setPeer(30184, baseOFTAddress);    // Vana trusts Base
await baseOFT.setPeer(30330, vanaAdapterAddress);    // Base trusts Vana
await vanaAdapter.setPeer(30168, solanaOFTAddress);  // Vana trusts Solana
// Set Solana peer via CLI/SDK
```

#### 5.2 Configure DVNs & Executors
```javascript
await configureDVN(vanaAdapter, ["LayerZero Labs"]);
await configureExecutor(vanaAdapter, executorAddress);
```

### Phase 6: Testing

#### 6.1 Unit Tests
- Test OFTAdapter wrapping functionality
- Test OFT minting/burning
- Test peer configuration

#### 6.2 Integration Tests (Testnet First!)
1. Deploy to testnets (Vana Moksha, Base Sepolia)
2. Bridge small amounts
3. Verify total supply consistency

#### 6.3 Security Checks
- Audit peer configurations
- Verify multisig ownership
- Check gas limits and options

### Phase 7: Mainnet Deployment

#### 7.1 Pre-deployment Checklist
- [ ] Contracts audited
- [ ] Multisigs configured
- [ ] Endpoints verified
- [ ] Gas estimates optimized
- [ ] Emergency pause functionality tested

#### 7.2 Deployment Order
1. Deploy all contracts
2. Wire all peers
3. Configure DVNs/Executors
4. Transfer ownership to multisigs
5. Small test transfer
6. Monitor for 24 hours
7. Announce to community

## Risk Mitigation

### Critical Risks
1. **Wrong Endpoint Address**: Could brick the deployment
   - **Mitigation**: Deploy test contract first to verify

2. **Peer Misconfiguration**: Messages won't route
   - **Mitigation**: Double-check all setPeer calls

3. **Supply Inconsistency**: Token duplication/loss
   - **Mitigation**: Implement supply tracking, monitoring

4. **Bridge Exploit**: Loss of funds
   - **Mitigation**: Audit, use established DVNs, rate limiting

## Open Questions for Team

1. **Vana Endpoint**: Is `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa` correct?
2. **Multisig Signers**: Who are the signers? Threshold?
3. **Launch Timeline**: When to deploy? Phased or all at once?
4. **Liquidity**: How to bootstrap liquidity on Base/Solana?
5. **Rate Limits**: Should we implement daily bridge limits initially?

## Next Steps

1. ✅ Validate Vana endpoint address
2. ⬜ Scaffold project with LayerZero CLI
3. ⬜ Implement contracts
4. ⬜ Deploy to testnets
5. ⬜ Test thoroughly
6. ⬜ Audit
7. ⬜ Deploy to mainnet

## Resources
- LayerZero Docs: https://docs.layerzero.network/v2
- OFT Guide: https://docs.layerzero.network/v2/developers/evm/oft/quickstart
- Solana OFT: https://docs.layerzero.network/v2/developers/solana/oft/quickstart
- Existing RDAT: `/Users/nissan/code/rdatadao-contracts/`