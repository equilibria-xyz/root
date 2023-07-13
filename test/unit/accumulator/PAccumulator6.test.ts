import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockPAccumulator6, MockPAccumulator6__factory } from '../../../types/generated'

const { ethers } = HRE

const CONTROLLER = {
  k: utils.parseUnits('100', 6),
  max: utils.parseUnits('1000', 6),
}

const ACCUMULATOR = {
  _value: 0,
  _skew: utils.parseUnits('10', 6),
}

const SKEW = utils.parseUnits('10', 6)
const FROM_TIMESTAMP = 1626156000
const TO_TIMESTAMP = 1626159000
const NOTIONAL = utils.parseUnits('500', 6)

describe.only('PAccumulator6', () => {
  let user: SignerWithAddress
  let pAccumulator6: MockPAccumulator6

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    pAccumulator6 = await new MockPAccumulator6__factory(user).deploy()
  })

  describe('#accumulate', async () => {
    it('accumulates correctly', async () => {
      const accumulated = await pAccumulator6.accumulate(
        ACCUMULATOR,
        CONTROLLER,
        SKEW,
        FROM_TIMESTAMP,
        TO_TIMESTAMP,
        NOTIONAL,
      )

      expect(accumulated).to.equal(7134703)
    })

    it('no accumulation (0 skew)', async () => {
      expect(
        await pAccumulator6.accumulate(ACCUMULATOR, CONTROLLER, 0, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
      ).to.equal(0)
    })

    it('no accumulation (0 notional)', async () => {
      expect(await pAccumulator6.accumulate(ACCUMULATOR, CONTROLLER, SKEW, FROM_TIMESTAMP, TO_TIMESTAMP, 0)).to.equal(0)
    })

    it('no accumulation (no time passed)', async () => {
      expect(
        await pAccumulator6.accumulate(ACCUMULATOR, CONTROLLER, SKEW, FROM_TIMESTAMP, FROM_TIMESTAMP, NOTIONAL),
      ).to.equal(0)
    })

    it('fromTimestamp must be before toTimestamp', async () => {
      await expect(pAccumulator6.accumulate(ACCUMULATOR, CONTROLLER, SKEW, TO_TIMESTAMP, FROM_TIMESTAMP, NOTIONAL)).to
        .be.reverted
    })
  })
})
