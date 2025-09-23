import { EndpointId } from '@layerzerolabs/lz-definitions'
import { ExecutorOptionType } from '@layerzerolabs/lz-v2-utilities'
import type { OAppOmniGraphHardhat, OmniPointHardhat } from '@layerzerolabs/toolbox-hardhat'

// Define the endpoint IDs for each chain
const VANA_EID = 30330 as EndpointId
const BASE_EID = 30184 as EndpointId
const SOLANA_EID = 30168 as EndpointId

// Define contract configurations for each chain
const vanaAdapter: OmniPointHardhat = {
  eid: VANA_EID,
  contractName: 'RdatOFTAdapter',
}

const baseOFT: OmniPointHardhat = {
  eid: BASE_EID,
  contractName: 'RdatOFT',
}

// Solana configuration (address will be added after deployment)
// const solanaOFT: OmniPointHardhat = {
//   eid: SOLANA_EID,
//   address: '<SOLANA_OFT_ADDRESS>',
// }

// Configuration for the OApp graph
const config: OAppOmniGraphHardhat = {
  contracts: [
    {
      contract: vanaAdapter,
    },
    {
      contract: baseOFT,
    },
  ],
  connections: [
    {
      from: vanaAdapter,
      to: baseOFT,
      config: {
        sendLibrary: 'SendUln302',
        receiveLibraryConfig: {
          receiveLibrary: 'ReceiveUln302',
          gracePeriod: 0,
        },
        // Send config from Vana to Base
        sendConfig: {
          ulnConfig: {
            confirmations: 15, // Vana block confirmations
            requiredDVNs: [
              // Using LayerZero Labs DVN (recommended for start)
              // These addresses need to be verified for each chain
            ],
            optionalDVNs: [],
            optionalDVNThreshold: 0,
          },
          executorConfig: {
            maxMessageSize: 10000,
            executorAddress: '', // Will be set by LayerZero
          },
        },
        // Receive config on Vana from Base
        receiveConfig: {
          ulnConfig: {
            confirmations: 5, // Base block confirmations
            requiredDVNs: [],
            optionalDVNs: [],
            optionalDVNThreshold: 0,
          },
        },
        // Enforced options for different message types
        enforcedOptions: [
          {
            msgType: 1, // SEND message type
            optionType: ExecutorOptionType.LZ_RECEIVE,
            gas: 200000, // Gas for receive on destination
            value: 0,
          },
          {
            msgType: 2, // SEND_AND_COMPOSE message type
            optionType: ExecutorOptionType.LZ_RECEIVE,
            gas: 300000,
            value: 0,
          },
        ],
      },
    },
    {
      from: baseOFT,
      to: vanaAdapter,
      config: {
        sendLibrary: 'SendUln302',
        receiveLibraryConfig: {
          receiveLibrary: 'ReceiveUln302',
          gracePeriod: 0,
        },
        // Send config from Base to Vana
        sendConfig: {
          ulnConfig: {
            confirmations: 5, // Base block confirmations
            requiredDVNs: [],
            optionalDVNs: [],
            optionalDVNThreshold: 0,
          },
          executorConfig: {
            maxMessageSize: 10000,
            executorAddress: '',
          },
        },
        // Receive config on Base from Vana
        receiveConfig: {
          ulnConfig: {
            confirmations: 15, // Vana block confirmations
            requiredDVNs: [],
            optionalDVNs: [],
            optionalDVNThreshold: 0,
          },
        },
        enforcedOptions: [
          {
            msgType: 1,
            optionType: ExecutorOptionType.LZ_RECEIVE,
            gas: 200000,
            value: 0,
          },
          {
            msgType: 2,
            optionType: ExecutorOptionType.LZ_RECEIVE,
            gas: 300000,
            value: 0,
          },
        ],
      },
    },
  ],
}

export default config