import { expect } from 'chai'
import { ethers } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { EndpointId } from '@layerzerolabs/lz-definitions'

describe('RDAT OFT Tests', () => {
  let owner: SignerWithAddress
  let user1: SignerWithAddress
  let user2: SignerWithAddress

  const VANA_EID = 30330 as EndpointId
  const BASE_EID = 30184 as EndpointId

  beforeEach(async () => {
    [owner, user1, user2] = await ethers.getSigners()
  })

  describe('RdatOFTAdapter', () => {
    it('Should deploy RdatOFTAdapter with correct parameters', async () => {
      // Mock addresses for testing
      const mockToken = user1.address // Using user1 address as mock token
      const mockEndpoint = user2.address // Using user2 address as mock endpoint

      const RdatOFTAdapter = await ethers.getContractFactory('RdatOFTAdapter')
      const adapter = await RdatOFTAdapter.deploy(
        mockToken,
        mockEndpoint,
        owner.address
      )
      await adapter.deployed()

      // Verify deployment
      expect(adapter.address).to.be.properAddress
      expect(await adapter.owner()).to.equal(owner.address)
      expect(await adapter.token()).to.equal(mockToken)
    })

    it('Should allow owner to set peers', async () => {
      const mockToken = user1.address
      const mockEndpoint = user2.address

      const RdatOFTAdapter = await ethers.getContractFactory('RdatOFTAdapter')
      const adapter = await RdatOFTAdapter.deploy(
        mockToken,
        mockEndpoint,
        owner.address
      )
      await adapter.deployed()

      // Set peer for Base
      const basePeer = ethers.utils.hexZeroPad(user1.address, 32)
      await adapter.setPeer(BASE_EID, basePeer)

      // Verify peer is set
      const storedPeer = await adapter.peers(BASE_EID)
      expect(storedPeer).to.equal(basePeer)
    })

    it('Should not allow non-owner to set peers', async () => {
      const mockToken = user1.address
      const mockEndpoint = user2.address

      const RdatOFTAdapter = await ethers.getContractFactory('RdatOFTAdapter')
      const adapter = await RdatOFTAdapter.deploy(
        mockToken,
        mockEndpoint,
        owner.address
      )
      await adapter.deployed()

      // Try to set peer as non-owner
      const basePeer = ethers.utils.hexZeroPad(user1.address, 32)
      await expect(
        adapter.connect(user1).setPeer(BASE_EID, basePeer)
      ).to.be.revertedWith('Ownable: caller is not the owner')
    })
  })

  describe('RdatOFT', () => {
    it('Should deploy RdatOFT with correct parameters', async () => {
      const mockEndpoint = user2.address

      const RdatOFT = await ethers.getContractFactory('RdatOFT')
      const oft = await RdatOFT.deploy(
        'RDAT',
        'RDAT',
        mockEndpoint,
        owner.address
      )
      await oft.deployed()

      // Verify deployment
      expect(oft.address).to.be.properAddress
      expect(await oft.owner()).to.equal(owner.address)
      expect(await oft.name()).to.equal('RDAT')
      expect(await oft.symbol()).to.equal('RDAT')
      expect(await oft.decimals()).to.equal(18)
    })

    it('Should allow owner to set peers', async () => {
      const mockEndpoint = user2.address

      const RdatOFT = await ethers.getContractFactory('RdatOFT')
      const oft = await RdatOFT.deploy(
        'RDAT',
        'RDAT',
        mockEndpoint,
        owner.address
      )
      await oft.deployed()

      // Set peer for Vana
      const vanaPeer = ethers.utils.hexZeroPad(user1.address, 32)
      await oft.setPeer(VANA_EID, vanaPeer)

      // Verify peer is set
      const storedPeer = await oft.peers(VANA_EID)
      expect(storedPeer).to.equal(vanaPeer)
    })

    it('Should have zero initial supply', async () => {
      const mockEndpoint = user2.address

      const RdatOFT = await ethers.getContractFactory('RdatOFT')
      const oft = await RdatOFT.deploy(
        'RDAT',
        'RDAT',
        mockEndpoint,
        owner.address
      )
      await oft.deployed()

      // Check initial supply is zero (will be minted on bridge)
      expect(await oft.totalSupply()).to.equal(0)
    })
  })

  describe('Peer Configuration', () => {
    it('Should correctly wire bidirectional peers', async () => {
      const mockToken = user1.address
      const mockEndpoint = user2.address

      // Deploy both contracts
      const RdatOFTAdapter = await ethers.getContractFactory('RdatOFTAdapter')
      const adapter = await RdatOFTAdapter.deploy(
        mockToken,
        mockEndpoint,
        owner.address
      )
      await adapter.deployed()

      const RdatOFT = await ethers.getContractFactory('RdatOFT')
      const oft = await RdatOFT.deploy(
        'RDAT',
        'RDAT',
        mockEndpoint,
        owner.address
      )
      await oft.deployed()

      // Wire peers bidirectionally
      const adapterBytes32 = ethers.utils.hexZeroPad(adapter.address, 32)
      const oftBytes32 = ethers.utils.hexZeroPad(oft.address, 32)

      await adapter.setPeer(BASE_EID, oftBytes32)
      await oft.setPeer(VANA_EID, adapterBytes32)

      // Verify both directions
      expect(await adapter.peers(BASE_EID)).to.equal(oftBytes32)
      expect(await oft.peers(VANA_EID)).to.equal(adapterBytes32)
    })
  })
})