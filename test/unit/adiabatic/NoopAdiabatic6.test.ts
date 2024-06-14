import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockNoopAdiabatic6, MockNoopAdiabatic6__factory } from '../../../types/generated'
import { parseUnits } from 'ethers/lib/utils'

const { ethers } = HRE

describe('NoopAdiabatic6', () => {
  let user: SignerWithAddress
  let linearAdiabatic: MockNoopAdiabatic6

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    linearAdiabatic = await new MockNoopAdiabatic6__factory(user).deploy()
  })

  describe('#linear', async () => {
    it('returns correct fee with positive latest', async () => {
      const fee = await await linearAdiabatic.linear(
        {
          linearFee: parseUnits('0.3', 6),
          proportionalFee: parseUnits('0.2', 6),
          scale: parseUnits('100', 6),
        },
        parseUnits('10', 6),
        parseUnits('123', 6),
      )

      // |change| * price * |change| / scale * proportionalFee
      // 10 * 123 * 0.1 = 24.6
      expect(fee).to.equal(parseUnits('369', 6))
    })
  })

  describe('#proportional', async () => {
    it('returns correct fee with positive latest', async () => {
      const fee = await await linearAdiabatic.proportional(
        {
          linearFee: parseUnits('0.1', 6),
          proportionalFee: parseUnits('0.2', 6),
          scale: parseUnits('100', 6),
        },
        parseUnits('10', 6),
        parseUnits('123', 6),
      )

      // |change| * price * |change| / scale * proportionalFee
      // 10 * 123 * 10 / 100 * 0.2 = 24.6
      expect(fee).to.equal(parseUnits('24.6', 6))
    })
  })
})
