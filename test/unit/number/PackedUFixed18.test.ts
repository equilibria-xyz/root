import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockPackedUFixed18, MockPackedUFixed18__factory } from '../../../types/generated'

const { ethers } = HRE

describe('PackedUFixed18', () => {
  let user: SignerWithAddress
  let packedUFixed18: MockPackedUFixed18

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    packedUFixed18 = await new MockPackedUFixed18__factory(user).deploy()
  })

  describe('#MAX', async () => {
    it('returns max', async () => {
      expect(await packedUFixed18.MAX()).to.equal(ethers.BigNumber.from(2).pow(128).sub(1))
    })
  })

  describe('#unpack', async () => {
    it('creates new', async () => {
      expect(await packedUFixed18.unpack(utils.parseEther('10'))).to.equal(utils.parseEther('10'))
    })
  })
})
