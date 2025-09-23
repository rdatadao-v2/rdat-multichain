# Multisig Setup Instructions for RDAT Bridge

## 1️⃣ Vana Multisig Transaction

### Safe Wallet Details
- **Safe Address**: `0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF`
- **Network**: Vana Mainnet (Chain ID: 1480)
- **Safe Interface**: Use Gnosis Safe interface or alternative

### Transaction Details for Safe UI

**To Address (Contract):**
```
0xd546C45872eeA596155EAEAe9B8495f02ca4fc58
```

**ABI (Copy this entire JSON):**
```json
[
  {
    "inputs": [
      {"internalType": "uint32", "name": "_eid", "type": "uint32"},
      {"internalType": "bytes32", "name": "_peer", "type": "bytes32"}
    ],
    "name": "setPeer",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]
```

**Function**: `setPeer`

**Parameters:**
- `_eid (uint32)`: `30184`
- `_peer (bytes32)`: `0x00000000000000000000000077D2713972af12F1E3EF39b5395bfD65C862367C`

### Alternative: Raw Transaction Data
If your Safe interface supports raw data input:
```
0x3400288b0000000000000000000000000000000000000000000000000000000000007668000000000000000000000000000077d2713972af12f1e3ef39b5395bfd65c862367c
```

---

## 2️⃣ Base Multisig Transaction

### Safe Wallet Details
- **Safe Address**: `0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A`
- **Network**: Base Mainnet (Chain ID: 8453)
- **Safe Interface**: https://app.safe.global/

### Transaction Details for Safe UI

**To Address (Contract):**
```
0x77D2713972af12F1E3EF39b5395bfD65C862367C
```

**ABI (Copy this entire JSON):**
```json
[
  {
    "inputs": [
      {"internalType": "uint32", "name": "_eid", "type": "uint32"},
      {"internalType": "bytes32", "name": "_peer", "type": "bytes32"}
    ],
    "name": "setPeer",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]
```

**Function**: `setPeer`

**Parameters:**
- `_eid (uint32)`: `30330`
- `_peer (bytes32)`: `0x000000000000000000000000d546C45872eeA596155EAEAe9B8495f02ca4fc58`

### Alternative: Raw Transaction Data
If your Safe interface supports raw data input:
```
0x3400288b000000000000000000000000000000000000000000000000000000000000767a000000000000000000000000d546c45872eea596155eaeae9b8495f02ca4fc58
```

---

## 📋 Step-by-Step Instructions

### For Vana Multisig:
1. Go to your Safe wallet interface for Vana
2. Connect with address `0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF`
3. Click "New Transaction" → "Contract Interaction"
4. Paste the **To Address**: `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58`
5. Paste the ABI and select `setPeer` function
6. Enter the parameters:
   - _eid: `30184`
   - _peer: `0x00000000000000000000000077D2713972af12F1E3EF39b5395bfD65C862367C`
7. Review and submit transaction
8. Get required signatures from other multisig owners

### For Base Multisig:
1. Go to https://app.safe.global/
2. Connect with address `0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A`
3. Click "New Transaction" → "Contract Interaction"
4. Paste the **To Address**: `0x77D2713972af12F1E3EF39b5395bfD65C862367C`
5. Paste the ABI and select `setPeer` function
6. Enter the parameters:
   - _eid: `30330`
   - _peer: `0x000000000000000000000000d546C45872eeA596155EAEAe9B8495f02ca4fc58`
7. Review and submit transaction
8. Get required signatures from other multisig owners

---

## ✅ Verification After Execution

After both transactions are executed, verify the configuration:

### Check Vana → Base connection:
```bash
cast call 0xd546C45872eeA596155EAEAe9B8495f02ca4fc58 \
  "peers(uint32)" 30184 \
  --rpc-url https://rpc.vana.org
# Should return: 0x00000000000000000000000077d2713972af12f1e3ef39b5395bfd65c862367c
```

### Check Base → Vana connection:
```bash
cast call 0x77D2713972af12F1E3EF39b5395bfD65C862367C \
  "peers(uint32)" 30330 \
  --rpc-url https://mainnet.base.org
# Should return: 0x000000000000000000000000d546c45872eea596155eaeae9b8495f02ca4fc58
```

---

## 🔍 What These Transactions Do

- **setPeer** establishes trust between the two contracts
- Vana adapter (0xd546...) will trust Base OFT (0x77D2...) messages from LayerZero
- Base OFT (0x77D2...) will trust Vana adapter (0xd546...) messages from LayerZero
- This enables bidirectional token bridging between chains

## 📞 Support

If you encounter any issues:
1. Verify you're on the correct network
2. Ensure you're using the right multisig address
3. Check that the contract addresses match those above
4. The peer address must be bytes32 (padded with zeros)

## Contract Addresses Summary

| Contract | Address | Chain | Multisig Owner |
|----------|---------|-------|----------------|
| Vana OFT Adapter | `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58` | Vana | `0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF` |
| Base RDAT OFT | `0x77D2713972af12F1E3EF39b5395bfD65C862367C` | Base | `0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A` |