# RDAT Multichain Rollout with LayerZero v2

We are deploying RDAT as an omnichain token using **LayerZero v2**.  
Canonical chain = **Vana**. Satellites = **Base Mainnet**, **Solana Mainnet**.

This doc includes context, code samples, repo scaffold layout, and direct references to LayerZero v2 docs.

---

## 1. Confirm Chain Support & EIDs

Every supported chain has a unique **EID** (Endpoint ID).  
LayerZero v2 does **not** use legacy `chainId`s; all cross-chain references are by **EID**.

- **Vana Mainnet**  
  - **EID:** `30330`  
  - **EndpointV2:** `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa`  
  - Docs: https://docs.layerzero.network/v2/developers/evm/chain-ids

- **Base Mainnet**  
  - **EID:** `30184`  
  - **EndpointV2:** `0x1a44076050125825900e736c501f859c50fE728c`  
  - Docs: https://docs.layerzero.network/v2/developers/evm/chain-ids

- **Solana Mainnet**  
  - **EID:** `30168`  
  - Has its own ULN & Executor programs.  
  - Docs: https://docs.layerzero.network/v2/developers/solana/chain-ids

Background on EIDs: https://docs.layerzero.network/v2/developers/evm/endpoints

---

## 2. Choose OFT Contract Type

- **Vana (canonical RDAT):** Deploy `OFTAdapter` wrapping your ERC-20.  
  Docs: https://docs.layerzero.network/v2/developers/evm/oft/overview

- **Base (EVM satellite):** Deploy `OFT.sol` that mints/burns RDAT representations.  
  Docs: https://docs.layerzero.network/v2/developers/evm/oft/overview

- **Solana:** Deploy Solana OFT program (SPL-compatible).  
  Docs: https://docs.layerzero.network/v2/developers/solana/oft/quickstart

---

## 3. Scaffold with Official CLI

Scaffold contracts, config, and scripts for deployment + wiring.

**EVM:**
```bash
npx create-lz-oapp@latest --example oft
```

**Solana:**
```bash
LZ_ENABLE_SOLANA_OFT_EXAMPLE=1 npx create-lz-oapp@latest
```

Docs: https://docs.layerzero.network/v2/developers/oapp/quickstart

---

## 4. Deploy Contracts

### On Vana (canonical)
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OFTAdapter} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTAdapter.sol";

/// @title RdatOFTAdapter
/// @notice Wraps the existing RDAT ERC20 on Vana.
contract RdatOFTAdapter is OFTAdapter {
    constructor(
        address _rdatToken,    // existing RDAT ERC-20
        address _endpoint,     // EndpointV2 on Vana
        address _owner         // multisig recommended
    ) OFTAdapter(_rdatToken, _endpoint, _owner) {}
}
```

### On Base (satellite)
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OFT} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol";

/// @title RdatOFT
/// @notice Mints/burns RDAT on Base.
contract RdatOFT is OFT {
    constructor(
        address _endpoint,   // EndpointV2 on Base
        address _owner
    ) OFT(_endpoint, _owner) {}
}
```

### On Solana
Use the scaffolded Solana OFT program.  
Docs: https://docs.layerzero.network/v2/developers/solana/oft/quickstart

---

## 5. Wire Trusted Peers

Every contract must trust its peers:

```solidity
// On Vana adapter, trust Base OFT
setPeer(30184, bytes32(uint256(uint160(baseOFT))));

// On Base OFT, trust Vana adapter
setPeer(30330, bytes32(uint256(uint160(vanaAdapter))));

// On Vana adapter, trust Solana OFT
setPeer(30168, bytes32(uint256(uint160(solanaOFT))));

// On Solana OFT, trust Vana adapter (via Solana instruction)
```

Docs: https://docs.layerzero.network/v2/developers/oapp/configuration

---

## 6. Configure Security & Execution

- **DVNs:** Configure quorum.  
  Docs: https://docs.layerzero.network/v2/developers/technology/uln

- **Executors:** Configure gas providers.  
  Docs: https://docs.layerzero.network/v2/developers/technology/executor

- **Options:** Pass gas/compute params per message.  
  Docs: https://docs.layerzero.network/v2/developers/oapp/options

---

## 7. Example `layerzero.config.ts`

```ts
import { ExecutorOptionType } from '@layerzerolabs/lz-v2-utilities';
import { OAppEnforcedOption, OmniPointHardhat } from '@layerzerolabs/toolbox-hardhat';

const VANA_EID = 30330;
const BASE_EID = 30184;
const SOL_EID  = 30168;

export const vanaAdapter: OmniPointHardhat = {
  eid: VANA_EID,
  contractName: 'RdatOFTAdapter',
};

export const baseOFT: OmniPointHardhat = {
  eid: BASE_EID,
  contractName: 'RdatOFT',
};

export const solanaOFT: OmniPointHardhat = {
  eid: SOL_EID,
  address: '<YOUR_SOLANA_OFT_STORE_ADDRESS>',
};

const EVM_OPTIONS: OAppEnforcedOption[] = [
  { msgType: 1, optionType: ExecutorOptionType.LZ_RECEIVE, gas: 80_000, value: 0 },
];

const SOL_OPTIONS: OAppEnforcedOption[] = [
  { msgType: 1, optionType: ExecutorOptionType.LZ_RECEIVE, gas: 200_000, value: 2_500_000 },
];

export default async function () {
  const connections = [
    [vanaAdapter, baseOFT,   [['LayerZero Labs'], []], [1,1], [EVM_OPTIONS, EVM_OPTIONS]],
    [vanaAdapter, solanaOFT, [['LayerZero Labs'], []], [1,1], [SOL_OPTIONS, EVM_OPTIONS]],
  ];
  return { contracts: [{ contract: vanaAdapter }, { contract: baseOFT }, { contract: solanaOFT }], connections };
}
```

Docs: https://docs.layerzero.network/v2/developers/oapp/configuration

---

## 8. Sending RDAT

### EVM
```solidity
import {IOFT} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";

function bridgeToBase(address vanaAdapter, uint32 baseEid, address to, uint256 amt) external payable {
    IOFT.SendParam memory p = IOFT.SendParam({
        dstEid: baseEid,
        to: bytes32(uint256(uint160(to))),
        amountLD: amt,
        minAmountLD: amt,
        extraOptions: bytes(""),
        composeMsg: bytes(""),
        oftCmd: bytes("")
    });

    IOFT(vanaAdapter).send{value: msg.value}(
        p,
        IOFT.PayParam({nativeFee: msg.value, lzTokenFee: 0}),
        address(0)
    );
}
```

### Solana
```ts
import { OftClient } from "@layerzerolabs/oft-v2-solana-sdk";

const client = new OftClient(connection, wallet);
await client.send({
  dstEid: 30330,              // Vana EID
  to: "<recipient_bytes32>",  // convert to bytes32
  amount: 100_000_000,        // RDAT in local decimals
});
```

Docs:  
- EVM: https://docs.layerzero.network/v2/developers/evm/oft/overview  
- Solana: https://docs.layerzero.network/v2/developers/solana/oft/quickstart

---

## 9. Repo Scaffold Layout

A recommended repo structure:

```
rdat-omnichain/
├── contracts/
│   ├── RdatOFTAdapter.sol   # on Vana
│   ├── RdatOFT.sol          # on Base
│   └── (solana program)     # generated by CLI
├── config/
│   └── layerzero.config.ts
├── scripts/
│   ├── deploy-vana.ts
│   ├── deploy-base.ts
│   ├── deploy-solana.ts
│   ├── wire.ts              # runs setPeer across EIDs
│   └── send-test.ts         # bridges a test amount
├── test/
│   └── OFT.test.ts
├── package.json
└── README.md
```

- **`contracts/`** → Solidity + Solana OFT contracts.  
- **`config/`** → `layerzero.config.ts` for wiring.  
- **`scripts/`** → deployment, wiring, bridging test flows.  
- **`test/`** → integration tests with Hardhat/Foundry.  

---

## 10. Rollout Checklist

1. Verify Vana, Base, Solana EIDs + Endpoints.  
2. Deploy `RdatOFTAdapter` on Vana.  
3. Deploy `RdatOFT` on Base.  
4. Deploy Solana OFT program.  
5. Wire peers (setPeer both ways).  
6. Configure DVNs + Executor + options.  
7. Run `wire.ts` to auto-configure.  
8. Run `send-test.ts` to bridge a small RDAT.  
9. Confirm total supply consistency across chains.

---

## References

- EVM Chain IDs: https://docs.layerzero.network/v2/developers/evm/chain-ids  
- Solana Chain IDs: https://docs.layerzero.network/v2/developers/solana/chain-ids  
- Endpoints: https://docs.layerzero.network/v2/developers/evm/endpoints  
- OFT Overview: https://docs.layerzero.network/v2/developers/evm/oft/overview  
- Solana OFT Quickstart: https://docs.layerzero.network/v2/developers/solana/oft/quickstart  
- OApp Quickstart: https://docs.layerzero.network/v2/developers/oapp/quickstart  
- OApp Config: https://docs.layerzero.network/v2/developers/oapp/configuration  
- DVNs: https://docs.layerzero.network/v2/developers/technology/uln  
- Executors: https://docs.layerzero.network/v2/developers/technology/executor  
- Options: https://docs.layerzero.network/v2/developers/oapp/options  
- Transfer API: https://docs.layerzero.network/v2/developers/oapp/transfer-api  

---
