import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { BigNumber, utils } from 'ethers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockPController6, MockPController6__factory } from '../../../types/generated'

const { ethers } = HRE

const CONTROLLER = {
  k: utils.parseUnits('10', 6),
  max: utils.parseUnits('10000', 6),
}

const CONTROLLER_LOW_MAX = {
  k: utils.parseUnits('10', 6),
  max: utils.parseUnits('1000', 6),
}

// max is below VALUE
const CONTROLLER_VERY_LOW_MAX = {
  k: utils.parseUnits('10', 6),
  max: utils.parseUnits('100', 6),
}

const VALUE = utils.parseUnits('500', 6)
const SKEW = utils.parseUnits('100', 6)
const FROM_TIMESTAMP = 0
const TO_TIMESTAMP = 100
const FROM_TIMESTAMP_UFIXED6 = utils.parseUnits(FROM_TIMESTAMP.toString(), 6)
const TO_TIMESTAMP_UFIXED6 = utils.parseUnits(TO_TIMESTAMP.toString(), 6)

function computeNewValue(value: BigNumber, skew: BigNumber, k: BigNumber): BigNumber {
  // newValue = value + (toTimestamp - fromTimestamp) * skew / k
  return value.add(
    skew
      .mul(TO_TIMESTAMP - FROM_TIMESTAMP)
      .mul(1e6)
      .div(k),
  )
}

describe('PController6', () => {
  let user: SignerWithAddress
  let pController6: MockPController6

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    pController6 = await new MockPController6__factory(user).deploy()
  })

  describe('#compute', async () => {
    it('computes new value, capped value, and intercept timestamp correctly', async () => {
      const [newValue, interceptTimestamp] = await pController6.compute(
        CONTROLLER,
        VALUE,
        SKEW,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(computeNewValue(VALUE, SKEW, CONTROLLER.k))
      // Value will be max after TO_TIMESTAMP, so interceptTimestamp is clamped to TO_TIMESTAMP
      expect(interceptTimestamp).to.equal(TO_TIMESTAMP_UFIXED6)
    })

    it('computes new value, capped value, and intercept timestamp correctly (negative starting value)', async () => {
      const negativeValue = VALUE.mul(-1)
      const [newValue, interceptTimestamp] = await pController6.compute(
        CONTROLLER,
        negativeValue,
        SKEW,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(computeNewValue(negativeValue, SKEW, CONTROLLER.k))
      // Value will be max after TO_TIMESTAMP, so interceptTimestamp is clamped to TO_TIMESTAMP
      expect(interceptTimestamp).to.equal(TO_TIMESTAMP_UFIXED6)
    })

    it('clamps to max if newValue is too large', async () => {
      const [newValue, interceptTimestamp] = await pController6.compute(
        CONTROLLER_LOW_MAX,
        VALUE,
        SKEW,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      // Value is clamped to max
      expect(newValue).to.equal(CONTROLLER_LOW_MAX.max)
      // Reaches max at the halfway point
      expect(interceptTimestamp).to.equal(TO_TIMESTAMP_UFIXED6.sub(FROM_TIMESTAMP_UFIXED6).div(2))
    })

    it('clamps to max if newValue is too large (negative newValue)', async () => {
      const [newValue, interceptTimestamp] = await pController6.compute(
        CONTROLLER_LOW_MAX,
        VALUE.mul(-1),
        utils.parseUnits('300', 6),
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      // Value is clamped to max
      expect(newValue).to.equal(CONTROLLER_LOW_MAX.max)
      // Reaches max at the halfway point
      expect(interceptTimestamp).to.equal(TO_TIMESTAMP_UFIXED6.sub(FROM_TIMESTAMP_UFIXED6).div(2))
    })

    it('negative range', async () => {
      const negativeSkew = SKEW.mul(-1)
      const [newValue, interceptTimestamp] = await pController6.compute(
        CONTROLLER,
        VALUE,
        negativeSkew,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(computeNewValue(VALUE, negativeSkew, CONTROLLER.k))
      // Value will be max after TO_TIMESTAMP, so interceptTimestamp is clamped to TO_TIMESTAMP
      expect(interceptTimestamp).to.equal(TO_TIMESTAMP_UFIXED6)
    })

    it('negative range, clamps to max', async () => {
      const [newValue, interceptTimestamp] = await pController6.compute(
        CONTROLLER_LOW_MAX,
        VALUE.mul(-1),
        SKEW.mul(-1),
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(CONTROLLER_LOW_MAX.max.mul(-1))
      // Reaches max at the halfway point
      expect(interceptTimestamp).to.equal(TO_TIMESTAMP_UFIXED6.sub(FROM_TIMESTAMP_UFIXED6).div(2))
    })

    it('zero range (no skew)', async () => {
      const [newValue, interceptTimestamp] = await pController6.compute(
        CONTROLLER,
        VALUE,
        0,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(VALUE)
      expect(interceptTimestamp).to.equal(TO_TIMESTAMP_UFIXED6)
    })

    it('zero range (no time difference)', async () => {
      const [newValue, interceptTimestamp] = await pController6.compute(
        CONTROLLER,
        VALUE,
        SKEW,
        TO_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(VALUE)
      expect(interceptTimestamp).to.equal(TO_TIMESTAMP_UFIXED6)
    })

    it('clamps to max', async () => {
      const [newValue, interceptTimestamp] = await pController6.compute(
        CONTROLLER_VERY_LOW_MAX,
        VALUE,
        SKEW,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(CONTROLLER_VERY_LOW_MAX.max)
      // The range is not zero, so interceptTimestamp is FROM_TIMESTAMP_UFIXED6
      expect(interceptTimestamp).to.equal(FROM_TIMESTAMP_UFIXED6)
    })

    it('zero range, clamps to max', async () => {
      const [newValue, interceptTimestamp] = await pController6.compute(
        CONTROLLER_VERY_LOW_MAX,
        VALUE,
        0,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(CONTROLLER_VERY_LOW_MAX.max)
      expect(interceptTimestamp).to.equal(TO_TIMESTAMP_UFIXED6)
    })

    it('fromTimestamp must be before toTimestamp', async () => {
      await expect(pController6.compute(CONTROLLER, VALUE, SKEW, TO_TIMESTAMP, FROM_TIMESTAMP)).to.be.reverted
    })
  })
})
