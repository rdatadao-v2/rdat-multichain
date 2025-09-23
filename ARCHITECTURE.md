# RDAT Multichain Architecture

## System Overview

```mermaid
graph TB
    subgraph "Users"
        U1[Vana Users]
        U2[Base Users]
    end

    subgraph "Vana Mainnet"
        VT[\"RDAT Token<br/>(Original)<br/>0x2c1CB4...A996E\"]
        VA[\"OFT Adapter<br/>0xd546C4...c4fc58\"]
        VE[\"LayerZero Endpoint<br/>0xcb566e...1aaAa\"]
        VM[\"Multisig<br/>0xe4F7Ec...9D5bCcDF\"]

        VT -.->|locks/unlocks| VA
        VA <-->|messages| VE
        VM -->|owns| VA
    end

    subgraph "LayerZero Network"
        LZ[LayerZero Protocol]
        DVN[DVN Validators]
        EX[Executors]

        LZ --> DVN
        LZ --> EX
    end

    subgraph "Base Mainnet"
        BO[\"RDAT OFT<br/>0x77D271...62367C\"]
        BE[\"LayerZero Endpoint<br/>0x1a4407...728c\"]
        BM[\"Multisig<br/>0x90013583...4B9A\"]

        BO <-->|messages| BE
        BM -->|owns| BO
    end

    U1 -->|interacts| VT
    U1 -->|bridges| VA
    U2 -->|holds| BO

    VE <-.->|EID: 30330| LZ
    BE <-.->|EID: 30184| LZ

    style VT fill:#e3f2fd
    style BO fill:#e8f5e9
    style VA fill:#fff3e0
    style VM fill:#ffcdd2
    style BM fill:#ffcdd2
    style LZ fill:#f3e5f5
```

## Contract Interactions

```mermaid
sequenceDiagram
    box Vana Network
    participant User as User
    participant Token as RDAT Token
    participant Adapter as OFT Adapter
    participant VEndpoint as Vana Endpoint
    end

    box LayerZero
    participant LZ as LayerZero Protocol
    participant DVN as DVN Validators
    end

    box Base Network
    participant BEndpoint as Base Endpoint
    participant OFT as RDAT OFT
    participant Recipient as Recipient
    end

    Note over User,Recipient: Bridge from Vana to Base

    User->>Token: approve(adapter, amount)
    Token-->>User: Approval confirmed

    User->>Adapter: send(params, fee)
    Adapter->>Token: transferFrom(user, adapter, amount)
    Token-->>Adapter: Tokens locked

    Adapter->>VEndpoint: send(message)
    VEndpoint->>LZ: Route message

    LZ->>DVN: Validate
    DVN-->>LZ: Confirmed

    LZ->>BEndpoint: Deliver message
    BEndpoint->>OFT: lzReceive(message)
    OFT->>Recipient: mint(amount)

    Note over Recipient: Tokens received on Base
```

## Security Architecture

```mermaid
graph TB
    subgraph "Access Control"
        MS1[Vana Multisig<br/>3-of-5]
        MS2[Base Multisig<br/>3-of-5]
    end

    subgraph "Contract Ownership"
        OW1[Adapter Owner]
        OW2[OFT Owner]
    end

    subgraph "Critical Functions"
        F1[setPeer]
        F2[setDelegate]
        F3[setConfig]
    end

    subgraph "Validation"
        V1[DVN Network]
        V2[Message Verification]
        V3[Amount Checks]
    end

    MS1 -->|controls| OW1
    MS2 -->|controls| OW2

    OW1 -->|can call| F1
    OW1 -->|can call| F2
    OW2 -->|can call| F1
    OW2 -->|can call| F3

    F1 -->|verified by| V1
    F2 -->|verified by| V2
    F3 -->|verified by| V3

    style MS1 fill:#ffcdd2
    style MS2 fill:#ffcdd2
    style V1 fill:#c8e6c9
    style V2 fill:#c8e6c9
    style V3 fill:#c8e6c9
```

## Token Flow States

```mermaid
stateDiagram-v2
    [*] --> VanaWallet: Initial RDAT

    state "Vana Side" as VS {
        VanaWallet --> Approved: User approves
        Approved --> Locked: Bridge initiated
        Locked --> AdapterHolds: Tokens locked
    }

    state "In Transit" as IT {
        AdapterHolds --> MessageSent: LZ message
        MessageSent --> Validating: DVN validation
        Validating --> Confirmed: Consensus reached
    }

    state "Base Side" as BS {
        Confirmed --> Minting: Message received
        Minting --> BaseWallet: Tokens minted
        BaseWallet --> Burning: Return bridge
    }

    BS --> IT: Return journey
    IT --> VS: Unlock tokens
    Locked --> VanaWallet: Tokens released

    note right of IT: 1-3 minutes
    note left of VS: Supply constant
```

## Key Components

### 1. Token Contracts
- **RDAT Token (Vana)**: Original token with 100M supply
- **OFT Adapter (Vana)**: Locks/unlocks original tokens
- **RDAT OFT (Base)**: Mints/burns representations

### 2. LayerZero Infrastructure
- **Endpoints**: Handle cross-chain messaging
- **DVN**: Decentralized verification network
- **Executors**: Process message delivery

### 3. Security
- **Multisig Control**: All admin functions
- **Peer Trust**: Explicit contract pairing
- **No Upgradability**: Immutable contracts

## Deployment Information

| Component | Address | Network | EID |
|-----------|---------|---------|-----|
| RDAT Token | `0x2c1CB448cAf3579B2374EFe20068Ea97F72A996E` | Vana | - |
| OFT Adapter | `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58` | Vana | 30330 |
| RDAT OFT | `0x77D2713972af12F1E3EF39b5395bfD65C862367C` | Base | 30184 |
| Vana Endpoint | `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa` | Vana | - |
| Base Endpoint | `0x1a44076050125825900e736c501f859c50fE728c` | Base | - |

## Gas Optimization

```mermaid
graph LR
    subgraph "Gas Costs"
        A[Approval<br/>~45k gas]
        B[Bridge Send<br/>~200k gas]
        C[LZ Fee<br/>~0.001 native]
    end

    subgraph "Optimizations"
        D[Batch Approvals]
        E[Optimal Gas Limits]
        F[Message Compression]
    end

    A --> D
    B --> E
    C --> F

    style A fill:#ffebee
    style B fill:#ffebee
    style C fill:#ffebee
    style D fill:#e8f5e9
    style E fill:#e8f5e9
    style F fill:#e8f5e9
```

---

*This document provides a complete technical overview of the RDAT multichain architecture.*