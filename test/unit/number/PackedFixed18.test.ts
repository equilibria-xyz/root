import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockPackedFixed18, MockPackedFixed18__factory } from '../../../types/generated'

const { ethers } = HRE

describe('PackedFixed18', () => {
  let user: SignerWithAddress
  let packedFixed18: MockPackedFixed18

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    packedFixed18 = await new MockPackedFixed18__factory(user).deploy()
  })

  describe('#MAX', async () => {
    it('returns max', async () => {
      expect(await packedFixed18.MAX()).to.equal(ethers.BigNumber.from(2).pow(127).sub(1))
    })
  })

  describe('#MIN', async () => {
    it('returns min', async () => {
      expect(await packedFixed18.MIN()).to.equal(ethers.BigNumber.from(2).pow(127).mul(-1))
    })
  })

  describe('#unpack', async () => {
    it('creates new', async () => {
      expect(await packedFixed18.unpack(utils.parseEther('10'))).to.equal(utils.parseEther('10'))
    })
  })
})
