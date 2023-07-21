import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockStorage, MockStorage__factory } from '../../../types/generated'

const { ethers } = HRE

const SLOT = ethers.utils.keccak256(Buffer.from('equilibria.root.Storage.testSlot'))

describe('Storage', () => {
  let user: SignerWithAddress
  let value: SignerWithAddress
  let storage: MockStorage

  beforeEach(async () => {
    ;[user, value] = await ethers.getSigners()
    storage = await new MockStorage__factory(user).deploy()
  })

  describe('#store(bool)', async () => {
    it('sets value', async () => {
      await storage.storeBool(SLOT, true)
      expect(await storage.readBool(SLOT)).to.equal(true)
    })
  })

  describe('#store(uint256)', async () => {
    it('sets value', async () => {
      await storage.storeUint256(SLOT, ethers.utils.parseEther('1'))
      expect(await storage.readUint256(SLOT)).to.equal(ethers.utils.parseEther('1'))
    })
  })

  describe('#store(int256)', async () => {
    it('sets value', async () => {
      await storage.storeInt256(SLOT, ethers.utils.parseEther('-1'))
      expect(await storage.readInt256(SLOT)).to.equal(ethers.utils.parseEther('-1'))
    })
  })

  describe('#store(address)', async () => {
    it('sets value', async () => {
      await storage.storeAddress(SLOT, value.address)
      expect(await storage.readAddress(SLOT)).to.equal(value.address)
    })
  })

  describe('#store(bytes)', async () => {
    it('sets value', async () => {
      await storage.storeBytes32(SLOT, SLOT)
      expect(await storage.readBytes32(SLOT)).to.equal(SLOT)
    })
  })
})
