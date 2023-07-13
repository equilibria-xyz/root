import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { BigNumber, utils } from 'ethers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockPController6, MockPController6__factory } from '../../../types/generated'

const { ethers } = HRE

const CONTROLLER = {
  k: utils.parseUnits('100', 6),
  max: utils.parseUnits('1000', 6),
}

const CONTROLLER_LOW_MAX = {
  k: utils.parseUnits('100', 6),
  max: utils.parseUnits('100', 6),
}

const VALUE = utils.parseUnits('500', 6)
const SKEW = utils.parseUnits('10', 6)
const FROM_TIMESTAMP = 1626156000
const TO_TIMESTAMP = 1626159000

describe('PController6', () => {
  let user: SignerWithAddress
  let pController6: MockPController6

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    pController6 = await new MockPController6__factory(user).deploy()
  })

  describe('#compute', async () => {
    it('computes new value, capped value, and intercept timestamp correctly', async () => {
      const [newValue, newValueCapped, interceptTimestamp] = await pController6.compute(
        CONTROLLER,
        VALUE,
        SKEW,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(utils.parseUnits('800', 6))
      expect(newValue).to.equal(newValueCapped)

      expect(interceptTimestamp).to.equal(utils.parseUnits('1626158000', 6))
    })

    it('computes new value, capped value, and intercept timestamp correctly (negative starting value)', async () => {
      const [newValue, newValueCapped, interceptTimestamp] = await pController6.compute(
        CONTROLLER,
        VALUE.mul(-1),
        SKEW,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(utils.parseUnits('-200', 6))
      expect(newValue).to.equal(newValueCapped)

      expect(interceptTimestamp).to.equal(utils.parseUnits('1626168000', 6))
    })

    it('clamps to max if newValue is too large', async () => {
      const [newValue, newValueCapped, interceptTimestamp] = await pController6.compute(
        CONTROLLER_LOW_MAX,
        VALUE,
        SKEW,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(utils.parseUnits('800', 6))
      expect(newValueCapped).to.equal(CONTROLLER_LOW_MAX.max)
      expect(interceptTimestamp).to.equal(utils.parseUnits('1626163000', 6))
    })

    it('clamps to max if newValue is too large (negative newValue)', async () => {
      const [newValue, newValueCapped, interceptTimestamp] = await pController6.compute(
        CONTROLLER_LOW_MAX,
        VALUE.mul(-1),
        SKEW,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(utils.parseUnits('-200', 6))
      expect(newValueCapped).to.equal(CONTROLLER_LOW_MAX.max.mul(-1))
      expect(interceptTimestamp).to.equal(utils.parseUnits('1626159000', 6))
    })

    it('negative range', async () => {
      const [newValue, newValueCapped, interceptTimestamp] = await pController6.compute(
        CONTROLLER,
        VALUE,
        SKEW.mul(-1),
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(utils.parseUnits('200', 6))
      expect(newValue).to.equal(newValueCapped)
      expect(interceptTimestamp).to.equal(utils.parseUnits('1626168000', 6))
    })

    it('negative range, clamps to max', async () => {
      const [newValue, newValueCapped, interceptTimestamp] = await pController6.compute(
        CONTROLLER_LOW_MAX,
        VALUE,
        SKEW.mul(-1),
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(utils.parseUnits('200', 6))
      expect(newValueCapped).to.equal(CONTROLLER_LOW_MAX.max)
      expect(interceptTimestamp).to.equal(utils.parseUnits('1626159000', 6))
    })

    it('zero range (no skew)', async () => {
      const [newValue, newValueCapped, interceptTimestamp] = await pController6.compute(
        CONTROLLER,
        VALUE,
        0,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(VALUE)
      expect(newValueCapped).to.equal(VALUE)
      expect(interceptTimestamp).to.equal(BigNumber.from(2).pow(256).sub(1))
    })

    it('zero range (no time difference)', async () => {
      const [newValue, newValueCapped, interceptTimestamp] = await pController6.compute(
        CONTROLLER,
        VALUE,
        SKEW,
        FROM_TIMESTAMP,
        FROM_TIMESTAMP,
      )

      expect(newValue).to.equal(VALUE)
      expect(newValueCapped).to.equal(VALUE)
      expect(interceptTimestamp).to.equal(BigNumber.from(2).pow(256).sub(1))
    })

    it('zero range, clamps to max', async () => {
      const [newValue, newValueCapped, interceptTimestamp] = await pController6.compute(
        CONTROLLER_LOW_MAX,
        VALUE,
        0,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
      )

      expect(newValue).to.equal(VALUE)
      expect(newValueCapped).to.equal(CONTROLLER_LOW_MAX.max)
      expect(interceptTimestamp).to.equal(BigNumber.from(2).pow(256).sub(1))
    })

    it('fromTimestamp must be before toTimestamp', async () => {
      await expect(pController6.compute(CONTROLLER, VALUE, SKEW, TO_TIMESTAMP, FROM_TIMESTAMP)).to.be.reverted
    })
  })
})
