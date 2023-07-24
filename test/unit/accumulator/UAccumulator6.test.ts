import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockUAccumulator6, MockUAccumulator6__factory } from '../../../types/generated'

const { ethers } = HRE

describe('Accumulator6', () => {
  let user: SignerWithAddress
  let accumulator6: MockUAccumulator6

  const value = async (mockAccumulator: MockUAccumulator6) => {
    return (await mockAccumulator.accumulator())._value
  }

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    accumulator6 = await new MockUAccumulator6__factory(user).deploy()
  })

  describe('#increment', async () => {
    it('increments (no rounding)', async () => {
      await accumulator6.increment(utils.parseUnits('2', 6), utils.parseUnits('1', 6))
      expect(await value(accumulator6)).to.equal(utils.parseUnits('2', 6))
    })

    it('increments (rounds down)', async () => {
      await accumulator6.increment(1, utils.parseUnits('2', 6))
      expect(await value(accumulator6)).to.equal(0)
    })
  })

  describe('#accumulated', async () => {
    it('returns accumulated (no rounding)', async () => {
      const from = await accumulator6.accumulator()
      await accumulator6.increment(utils.parseUnits('2', 6), utils.parseUnits('5', 6))
      expect(await accumulator6.accumulated(from, utils.parseUnits('5', 6))).to.equal(utils.parseUnits('2', 6))
    })

    it('returns accumulated (rounds down)', async () => {
      const from = await accumulator6.accumulator()
      await accumulator6.increment(1, utils.parseUnits('1', 6))
      expect(await accumulator6.accumulated(from, 1)).to.equal(0)
    })
  })
})
