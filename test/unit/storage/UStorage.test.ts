import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockUStorage, MockUStorage__factory } from '../../../types/generated'

const { ethers } = HRE

const SLOT = ethers.utils.keccak256(Buffer.from('equilibria.root.UStorage.testSlot'))

describe('UStorage', () => {
  let user: SignerWithAddress
  let value: SignerWithAddress
  let uStorage: MockUStorage

  beforeEach(async () => {
    ;[user, value] = await ethers.getSigners()
    uStorage = await new MockUStorage__factory(user).deploy()
  })

  describe('#store(bool)', async () => {
    it('sets value', async () => {
      await uStorage.storeBool(SLOT, true)
      expect(await uStorage.readBool(SLOT)).to.equal(true)
    })
  })

  describe('#store(uint256)', async () => {
    it('sets value', async () => {
      await uStorage.storeUint256(SLOT, ethers.utils.parseEther('1'))
      expect(await uStorage.readUint256(SLOT)).to.equal(ethers.utils.parseEther('1'))
    })
  })

  describe('#store(int256)', async () => {
    it('sets value', async () => {
      await uStorage.storeInt256(SLOT, ethers.utils.parseEther('-1'))
      expect(await uStorage.readInt256(SLOT)).to.equal(ethers.utils.parseEther('-1'))
    })
  })

  describe('#store(address)', async () => {
    it('sets value', async () => {
      await uStorage.storeAddress(SLOT, value.address)
      expect(await uStorage.readAddress(SLOT)).to.equal(value.address)
    })
  })

  describe('#store(bytes)', async () => {
    it('sets value', async () => {
      await uStorage.storeBytes32(SLOT, SLOT)
      expect(await uStorage.readBytes32(SLOT)).to.equal(SLOT)
    })
  })
})
