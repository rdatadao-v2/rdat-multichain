import { ethers } from 'hardhat'
import * as dotenv from 'dotenv'

dotenv.config()

/**
 * Script to verify the correct LayerZero endpoint address on Vana
 * This should be run before deployment to confirm the endpoint
 */
async function main() {
  console.log('Verifying LayerZero Endpoint on Vana Mainnet...\n')

  const [signer] = await ethers.getSigners()
  console.log('Using account:', signer.address)

  // Potential endpoint addresses to check
  const endpoints = [
    {
      name: 'Common V2 Endpoint',
      address: '0x1a44076050125825900e736c501f859c50fE728c'
    },
    {
      name: 'Vana Specific Endpoint (from PLAN.md)',
      address: '0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa'
    }
  ]

  // Minimal ABI to check if contract exists and has expected functions
  const endpointABI = [
    'function eid() view returns (uint32)',
    'function isSupportedEid(uint32) view returns (bool)',
    'function defaultSendLibrary(uint32) view returns (address)',
    'function defaultReceiveLibrary(uint32) view returns (address)'
  ]

  for (const endpoint of endpoints) {
    console.log(`\nChecking ${endpoint.name}: ${endpoint.address}`)
    console.log('-'.repeat(60))

    try {
      // Check if contract exists
      const provider = ethers.provider
      const code = await provider.getCode(endpoint.address)

      if (code === '0x') {
        console.log('❌ No contract deployed at this address')
        continue
      }

      console.log('✅ Contract found at address')

      // Try to interact with the endpoint
      const endpointContract = new ethers.Contract(
        endpoint.address,
        endpointABI,
        signer
      )

      // Try to get the EID of this endpoint
      try {
        const eid = await endpointContract.eid()
        console.log(`✅ Endpoint EID: ${eid}`)

        if (eid.toString() === '30330') {
          console.log('✅ EID matches Vana Mainnet (30330)')
        } else {
          console.log(`⚠️  EID is ${eid}, expected 30330 for Vana`)
        }
      } catch (e) {
        console.log('❌ Could not read EID - may not be a LayerZero endpoint')
      }

      // Check if it supports Base (30184)
      try {
        const supportsBase = await endpointContract.isSupportedEid(30184)
        console.log(`Base support (30184): ${supportsBase ? '✅ Yes' : '❌ No'}`)
      } catch (e) {
        console.log('Could not check Base support')
      }

      // Check if it supports Solana (30168)
      try {
        const supportsSolana = await endpointContract.isSupportedEid(30168)
        console.log(`Solana support (30168): ${supportsSolana ? '✅ Yes' : '❌ No'}`)
      } catch (e) {
        console.log('Could not check Solana support')
      }

      // Try to get default libraries
      try {
        const sendLib = await endpointContract.defaultSendLibrary(30184)
        if (sendLib !== ethers.constants.AddressZero) {
          console.log(`✅ Default send library for Base: ${sendLib}`)
        }
      } catch (e) {
        // Silent fail - not critical
      }

      console.log(`\n🎯 LIKELY CORRECT ENDPOINT: ${endpoint.address}`)

    } catch (error) {
      console.log(`❌ Error checking endpoint: ${error.message}`)
    }
  }

  console.log('\n' + '='.repeat(60))
  console.log('RECOMMENDATION:')
  console.log('1. Use the endpoint that has a contract deployed and returns EID 30330')
  console.log('2. If neither works, contact LayerZero or Vana team for correct endpoint')
  console.log('3. Update VANA_ENDPOINT in .env with the correct address before deployment')
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })