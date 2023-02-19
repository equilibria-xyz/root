import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockAccumulator6, MockAccumulator6__factory } from '../../../types/generated'

const { ethers } = HRE

describe('Accumulator6', () => {
  let user: SignerWithAddress
  let accumulator6: MockAccumulator6

  const value = async (mockAccumulator: MockAccumulator6) => {
    return (await mockAccumulator.accumulator())._value
  }

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    accumulator6 = await new MockAccumulator6__factory(user).deploy()
  })

  describe('#increment', async () => {
    it('increments (no rounding)', async () => {
      await accumulator6.increment(utils.parseUnits('2', 6), utils.parseUnits('1', 6))
      expect(await value(accumulator6)).to.equal(utils.parseUnits('2', 6))

      await accumulator6.increment(utils.parseUnits('-3', 6), utils.parseUnits('1', 6))
      expect(await value(accumulator6)).to.equal(utils.parseUnits('-1', 6))
    })

    it('increments (rounds down)', async () => {
      await accumulator6.increment(1, utils.parseUnits('2', 6))
      expect(await value(accumulator6)).to.equal(0)

      await accumulator6.increment(-1, utils.parseUnits('2', 6))
      expect(await value(accumulator6)).to.equal(-1)
    })
  })

  describe('#decrement', async () => {
    it('decrements (no rounding)', async () => {
      await accumulator6.decrement(utils.parseUnits('2', 6), utils.parseUnits('1', 6))
      expect(await value(accumulator6)).to.equal(utils.parseUnits('-2', 6))

      await accumulator6.decrement(utils.parseUnits('-3', 6), utils.parseUnits('1', 6))
      expect(await value(accumulator6)).to.equal(utils.parseUnits('1', 6))
    })

    it('decrements (rounds down)', async () => {
      await accumulator6.decrement(-1, utils.parseUnits('2', 6))
      expect(await value(accumulator6)).to.equal(0)

      await accumulator6.decrement(1, utils.parseUnits('2', 6))
      expect(await value(accumulator6)).to.equal(-1)
    })
  })

  describe('#accumulated', async () => {
    it('returns accumulated (no rounding)', async () => {
      const from = await accumulator6.accumulator()
      await accumulator6.increment(utils.parseUnits('2', 6), utils.parseUnits('5', 6))
      expect(await accumulator6.accumulated(from, utils.parseUnits('5', 6))).to.equal(utils.parseUnits('2', 6))
    })

    it('returns positive accumulated (rounds down)', async () => {
      const from = await accumulator6.accumulator()
      await accumulator6.increment(1, utils.parseUnits('1', 6))
      expect(await accumulator6.accumulated(from, 1)).to.equal(0)
    })

    it('returns negative accumulated (rounds down)', async () => {
      const from = await accumulator6.accumulator()
      await accumulator6.decrement(1, utils.parseUnits('1', 6))
      expect(await accumulator6.accumulated(from, utils.parseUnits('1', 6).add(1))).to.equal(-2)
    })
  })
})
