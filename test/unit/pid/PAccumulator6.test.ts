import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { BigNumber, utils } from 'ethers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockPAccumulator6, MockPAccumulator6__factory } from '../../../types/generated'

const { ethers } = HRE

const K = utils.parseUnits('100', 6)
const VALUE = utils.parseUnits('10', 6)
const SKEW = utils.parseUnits('10', 6)
const FROM_TIMESTAMP = 1626156000
const TO_TIMESTAMP = 1626159000
const NEW_SKEW = SKEW.mul(2)
const YEAR_IN_SECONDS = 31536000
const NOTIONAL = utils.parseUnits('500', 6)

const CONTROLLER = {
  k: K,
  max: utils.parseUnits('10000', 6),
}

const CONTROLLER_HALF_CAPPED = {
  k: K,
  max: VALUE.add(
    SKEW.mul(TO_TIMESTAMP - FROM_TIMESTAMP)
      .mul(1e6)
      .div(2)
      .div(K),
  ),
}
const CONTROLLER_COMPLETELY_CAPPED = {
  k: K,
  max: VALUE,
}

const ACCUMULATOR = {
  _value: VALUE,
  _skew: SKEW,
}

// Calculates the uncapped accumulation from FROM_TIMESTAMP to `toTimestamp` given `newValue.
function accumulationUncapped(newValue: BigNumber, interceptTimestamp: number): BigNumber {
  return VALUE.add(newValue)
    .mul(interceptTimestamp - FROM_TIMESTAMP)
    .mul(NOTIONAL)
    .div(YEAR_IN_SECONDS)
    .div(2)
    .div(1e6)
}

function accumulationCapped(newValue: BigNumber, interceptTimestamp: number): BigNumber {
  return newValue
    .mul(TO_TIMESTAMP - interceptTimestamp)
    .mul(NOTIONAL)
    .div(YEAR_IN_SECONDS)
    .div(1e6)
}

describe('PAccumulator6', () => {
  let user: SignerWithAddress
  let pAccumulator6: MockPAccumulator6

  async function accumulate(
    controller: typeof CONTROLLER,
    skew: BigNumber,
    fromTimestamp: number,
    toTimestamp: number,
    notional: BigNumber,
  ): Promise<BigNumber> {
    const accumulated = await pAccumulator6.callStatic.accumulate(
      controller,
      skew,
      fromTimestamp,
      toTimestamp,
      notional,
    )
    await pAccumulator6.accumulate(controller, skew, fromTimestamp, toTimestamp, notional)
    return accumulated
  }

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    pAccumulator6 = await new MockPAccumulator6__factory(user).deploy(ACCUMULATOR)
  })

  describe('#accumulate', async () => {
    it('accumulates correctly (all uncapped)', async () => {
      const accumulated = await accumulate(CONTROLLER, NEW_SKEW, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL)

      const newValue = VALUE.add(
        SKEW.mul(TO_TIMESTAMP - FROM_TIMESTAMP)
          .div(CONTROLLER.k)
          .mul(1e6),
      )
      // All of the accumulation is in the uncapped rate
      expect(accumulated).to.equal(accumulationUncapped(newValue, TO_TIMESTAMP))
      expect((await pAccumulator6.accumulator())._value).to.equal(newValue)
      expect((await pAccumulator6.accumulator())._skew).to.equal(NEW_SKEW)
    })

    it('accumulates correctly (all capped)', async () => {
      const accumulated = await accumulate(
        CONTROLLER_COMPLETELY_CAPPED,
        NEW_SKEW,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
        NOTIONAL,
      )

      // All of the accumulation is in the capped rate
      expect(accumulated).to.equal(accumulationCapped(VALUE, FROM_TIMESTAMP))
      // Accumulator value should be unchanged
      expect((await pAccumulator6.accumulator())._value).to.equal(VALUE)
      expect((await pAccumulator6.accumulator())._skew).to.equal(NEW_SKEW)
    })

    it('accumulates correctly (half capped)', async () => {
      const accumulated = await accumulate(CONTROLLER_HALF_CAPPED, NEW_SKEW, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL)
      const halfwayTimestamp = FROM_TIMESTAMP + (TO_TIMESTAMP - FROM_TIMESTAMP) / 2

      // Half of the accumulation is in the uncapped rate, half in the capped rate
      expect(accumulated).to.equal(
        accumulationUncapped(CONTROLLER_HALF_CAPPED.max, halfwayTimestamp).add(
          accumulationCapped(CONTROLLER_HALF_CAPPED.max, halfwayTimestamp),
        ),
      )
      expect((await pAccumulator6.accumulator())._value).to.equal(CONTROLLER_HALF_CAPPED.max)
      expect((await pAccumulator6.accumulator())._skew).to.equal(NEW_SKEW)
    })

    it('no accumulation (0 notional)', async () => {
      expect(await accumulate(CONTROLLER, NEW_SKEW, FROM_TIMESTAMP, TO_TIMESTAMP, BigNumber.from(0))).to.equal(0)
      expect((await pAccumulator6.accumulator())._value).to.equal(
        VALUE.add(
          SKEW.mul(TO_TIMESTAMP - FROM_TIMESTAMP)
            .div(CONTROLLER.k)
            .mul(10e5),
        ),
      )
      expect((await pAccumulator6.accumulator())._skew).to.equal(NEW_SKEW)
    })

    it('no accumulation (no time passed)', async () => {
      expect(await accumulate(CONTROLLER, NEW_SKEW, FROM_TIMESTAMP, FROM_TIMESTAMP, NOTIONAL)).to.equal(0)
      expect((await pAccumulator6.accumulator())._value).to.equal(VALUE)
      expect((await pAccumulator6.accumulator())._skew).to.equal(NEW_SKEW)
    })

    it('fromTimestamp must be before toTimestamp', async () => {
      await expect(pAccumulator6.accumulate(CONTROLLER, SKEW, TO_TIMESTAMP, FROM_TIMESTAMP, NOTIONAL)).to.be.reverted
    })
  })
})
