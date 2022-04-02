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

  describe('#write(bool)', async () => {
    it('sets value', async () => {
      await uStorage['write(bytes32,bool)'](SLOT, true)
      expect(await uStorage.readBool(SLOT)).to.equal(true)
    })
  })

  describe('#write(uint256)', async () => {
    it('sets value', async () => {
      await uStorage['write(bytes32,uint256)'](SLOT, ethers.utils.parseEther('1'))
      expect(await uStorage.readUint256(SLOT)).to.equal(ethers.utils.parseEther('1'))
    })
  })

  describe('#write(int256)', async () => {
    it('sets value', async () => {
      await uStorage['write(bytes32,int256)'](SLOT, ethers.utils.parseEther('-1'))
      expect(await uStorage.readInt256(SLOT)).to.equal(ethers.utils.parseEther('-1'))
    })
  })

  describe('#write(address)', async () => {
    it('sets value', async () => {
      await uStorage['write(bytes32,address)'](SLOT, value.address)
      expect(await uStorage.readAddress(SLOT)).to.equal(value.address)
    })
  })

  describe('#write(bytes)', async () => {
    it('sets value', async () => {
      await uStorage['write(bytes32,bytes32)'](SLOT, SLOT)
      expect(await uStorage.readBytes32(SLOT)).to.equal(SLOT)
    })
  })

  describe('#write(UFixed18)', async () => {
    it('sets value', async () => {
      await uStorage.writeUFixed18(SLOT, ethers.utils.parseEther('1'))
      expect(await uStorage.readUFixed18(SLOT)).to.equal(ethers.utils.parseEther('1'))
    })
  })

  describe('#write(Fixed18)', async () => {
    it('sets value', async () => {
      await uStorage.writeFixed18(SLOT, ethers.utils.parseEther('-1'))
      expect(await uStorage.readFixed18(SLOT)).to.equal(ethers.utils.parseEther('-1'))
    })
  })
})
