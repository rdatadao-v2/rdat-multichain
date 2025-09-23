import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  const { deploy } = deployments
  const { deployer, owner } = await getNamedAccounts()

  console.log(`Deploying RdatOFTAdapter on ${network.name}...`)
  console.log(`Deployer: ${deployer}`)
  console.log(`Owner: ${owner}`)

  // Get configuration from environment
  const rdatToken = process.env.RDAT_TOKEN_ADDRESS
  const endpoint = process.env.VANA_ENDPOINT

  if (!rdatToken || !endpoint) {
    throw new Error('Missing required environment variables: RDAT_TOKEN_ADDRESS or VANA_ENDPOINT')
  }

  // Deploy RdatOFTAdapter
  const deployment = await deploy('RdatOFTAdapter', {
    from: deployer,
    args: [
      rdatToken, // Existing RDAT token address
      endpoint,  // LayerZero endpoint on Vana
      owner || deployer // Owner (multisig or deployer)
    ],
    log: true,
    waitConfirmations: network.live ? 5 : 1,
    skipIfAlreadyDeployed: true,
  })

  console.log(`RdatOFTAdapter deployed at: ${deployment.address}`)

  // Verify contract if on live network
  if (network.live && process.env.VANASCAN_API_KEY) {
    console.log('Verifying contract on Vanascan...')
    try {
      await hre.run('verify:verify', {
        address: deployment.address,
        constructorArguments: [rdatToken, endpoint, owner || deployer],
      })
      console.log('Contract verified successfully')
    } catch (error) {
      console.error('Verification failed:', error)
    }
  }
}

export default func
func.tags = ['RdatOFTAdapter', 'vana']
func.dependencies = []