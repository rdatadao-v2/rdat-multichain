import { ethers } from 'hardhat'
import { EndpointId } from '@layerzerolabs/lz-definitions'
import * as dotenv from 'dotenv'

dotenv.config()

// Chain EIDs
const VANA_EID = 30330 as EndpointId
const BASE_EID = 30184 as EndpointId
const SOLANA_EID = 30168 as EndpointId

async function main() {
  const [deployer] = await ethers.getSigners()
  console.log('Wiring contracts with account:', deployer.address)

  // Get deployment addresses (these should be saved after deployment)
  const vanaAdapterAddress = process.env.VANA_ADAPTER_ADDRESS
  const baseOFTAddress = process.env.BASE_OFT_ADDRESS
  const solanaOFTAddress = process.env.SOLANA_OFT_ADDRESS

  if (!vanaAdapterAddress || !baseOFTAddress) {
    throw new Error('Missing contract addresses. Please set VANA_ADAPTER_ADDRESS and BASE_OFT_ADDRESS in .env')
  }

  // Get contract instances
  const RdatOFTAdapter = await ethers.getContractFactory('RdatOFTAdapter')
  const RdatOFT = await ethers.getContractFactory('RdatOFT')

  const vanaAdapter = RdatOFTAdapter.attach(vanaAdapterAddress)
  const baseOFT = RdatOFT.attach(baseOFTAddress)

  console.log('Setting peers...')

  // Convert addresses to bytes32 for LayerZero
  const vanaAdapterBytes32 = ethers.utils.hexZeroPad(vanaAdapterAddress, 32)
  const baseOFTBytes32 = ethers.utils.hexZeroPad(baseOFTAddress, 32)

  // Wire Vana -> Base
  console.log(`Setting peer on Vana Adapter for Base (EID: ${BASE_EID})...`)
  let tx = await vanaAdapter.setPeer(BASE_EID, baseOFTBytes32)
  await tx.wait()
  console.log('✅ Vana -> Base peer set')

  // Wire Base -> Vana
  console.log(`Setting peer on Base OFT for Vana (EID: ${VANA_EID})...`)
  tx = await baseOFT.setPeer(VANA_EID, vanaAdapterBytes32)
  await tx.wait()
  console.log('✅ Base -> Vana peer set')

  // If Solana address is provided, wire it too
  if (solanaOFTAddress) {
    const solanaOFTBytes32 = ethers.utils.hexZeroPad(solanaOFTAddress, 32)

    console.log(`Setting peer on Vana Adapter for Solana (EID: ${SOLANA_EID})...`)
    tx = await vanaAdapter.setPeer(SOLANA_EID, solanaOFTBytes32)
    await tx.wait()
    console.log('✅ Vana -> Solana peer set')
  }

  console.log('\\n🎉 All peers have been successfully wired!')

  // Verify the peers are set correctly
  console.log('\\nVerifying peer configuration...')

  const basePeerOnVana = await vanaAdapter.peers(BASE_EID)
  console.log(`Vana sees Base peer as: ${basePeerOnVana}`)

  const vanaPeerOnBase = await baseOFT.peers(VANA_EID)
  console.log(`Base sees Vana peer as: ${vanaPeerOnBase}`)

  if (solanaOFTAddress) {
    const solanaPeerOnVana = await vanaAdapter.peers(SOLANA_EID)
    console.log(`Vana sees Solana peer as: ${solanaPeerOnVana}`)
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })