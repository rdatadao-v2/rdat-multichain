import { EndpointId } from '@layerzerolabs/lz-definitions'
import { ExecutorOptionType } from '@layerzerolabs/lz-v2-utilities'
import { generateConnectionsConfig } from '@layerzerolabs/metadata-tools'
import { OAppEnforcedOption, OmniPointHardhat } from '@layerzerolabs/toolbox-hardhat'

// Vana OFT Adapter - wraps existing RDAT token
const vanaContract: OmniPointHardhat = {
    eid: EndpointId.VANA_V2_MAINNET, // 30330
    address: '0xd546C45872eeA596155EAEAe9B8495f02ca4fc58',
}

// Solana OFT Store - mints/burns RDAT representations
const solanaContract: OmniPointHardhat = {
    eid: EndpointId.SOLANA_V2_MAINNET, // 30168
    address: 'FkVGPvVoE3oYoz6EDuJ3ZP2D9aSgM5HHuxk3jf9ckU35', // OFT Store address from deployment
}

// EVM (Vana) enforced options
const EVM_ENFORCED_OPTIONS: OAppEnforcedOption[] = [
    {
        msgType: 1,
        optionType: ExecutorOptionType.LZ_RECEIVE,
        gas: 150000, // Increased gas for Vana
        value: 0,
    },
]

const CU_LIMIT = 300000 // Compute Unit limit for Solana lz_receive
const SPL_TOKEN_ACCOUNT_RENT_VALUE = 2039280 // Rent for SPL token account

// Solana enforced options
const SOLANA_ENFORCED_OPTIONS: OAppEnforcedOption[] = [
    {
        msgType: 1,
        optionType: ExecutorOptionType.LZ_RECEIVE,
        gas: CU_LIMIT,
        value: SPL_TOKEN_ACCOUNT_RENT_VALUE,
    },
]

export default async function () {
    // Bidirectional connection between Vana and Solana
    const connections = await generateConnectionsConfig([
        [
            vanaContract,           // Chain A: Vana
            solanaContract,          // Chain B: Solana
            [['LayerZero Labs'], []], // DVN configuration
            [15, 32],               // Confirmations: Vana->Solana: 15, Solana->Vana: 32
            [SOLANA_ENFORCED_OPTIONS, EVM_ENFORCED_OPTIONS], // Options
        ],
    ])

    return {
        contracts: [{ contract: vanaContract }, { contract: solanaContract }],
        connections,
    }
}