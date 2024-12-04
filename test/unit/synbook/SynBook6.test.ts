import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'
import { MockSynBook6, MockSynBook6__factory } from '../../../types/generated'

const { ethers } = HRE

const CURVE_1 = {
  d0: ethers.utils.parseUnits('0.002', 6),
  d1: ethers.utils.parseUnits('0.000', 6),
  d2: ethers.utils.parseUnits('0.001', 6),
  d3: ethers.utils.parseUnits('0.010', 6),
  scale: ethers.utils.parseUnits('1000', 6),
}

const CURVE_2 = {
  d0: ethers.utils.parseUnits('0.002', 6),
  d1: ethers.utils.parseUnits('0.004', 6),
  d2: ethers.utils.parseUnits('0.001', 6),
  d3: ethers.utils.parseUnits('0.010', 6),
  scale: ethers.utils.parseUnits('1000', 6),
}

describe('SynBook6', () => {
  let user: SignerWithAddress
  let synBook: MockSynBook6

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    synBook = await new MockSynBook6__factory(user).deploy()
  })

  describe('#compute', async () => {
    context('CURVE_1', async () => {
      it('zero skew, zero change', async () => {
        expect(
          await synBook.compute(
            CURVE_1,
            ethers.utils.parseUnits('0', 6),
            ethers.utils.parseUnits('0', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('0', 6))
      })

      it('zero skew, positive change', async () => {
        expect(
          await synBook.compute(
            CURVE_1,
            ethers.utils.parseUnits('0', 6),
            ethers.utils.parseUnits('100', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('2.467175', 6))
      })

      it('zero skew, negative change', async () => {
        expect(
          await synBook.compute(
            CURVE_1,
            ethers.utils.parseUnits('0', 6),
            ethers.utils.parseUnits('-100', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('2.467175', 6))
      })

      it('positive skew, zero change', async () => {
        expect(
          await synBook.compute(
            CURVE_1,
            ethers.utils.parseUnits('200', 6),
            ethers.utils.parseUnits('0', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('0', 6))
      })

      it('positive skew, positive change', async () => {
        expect(
          await synBook.compute(
            CURVE_1,
            ethers.utils.parseUnits('200', 6),
            ethers.utils.parseUnits('100', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('2.737775', 6))
      })

      it('positive skew, negative change', async () => {
        expect(
          await synBook.compute(
            CURVE_1,
            ethers.utils.parseUnits('200', 6),
            ethers.utils.parseUnits('-100', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('2.442575', 6))
      })

      it('negative skew, zero change', async () => {
        expect(
          await synBook.compute(
            CURVE_1,
            ethers.utils.parseUnits('-200', 6),
            ethers.utils.parseUnits('0', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('0', 6))
      })

      it('negative skew, positive change', async () => {
        expect(
          await synBook.compute(
            CURVE_1,
            ethers.utils.parseUnits('-200', 6),
            ethers.utils.parseUnits('100', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('2.442575', 6))
      })

      it('negative skew, negative change', async () => {
        expect(
          await synBook.compute(
            CURVE_1,
            ethers.utils.parseUnits('-200', 6),
            ethers.utils.parseUnits('-100', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('2.737775', 6))
      })
    })

    context('CURVE_2', async () => {
      it('zero skew, zero change', async () => {
        expect(
          await synBook.compute(
            CURVE_2,
            ethers.utils.parseUnits('0', 6),
            ethers.utils.parseUnits('0', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('0', 6))
      })

      it('zero skew, positive change', async () => {
        expect(
          await synBook.compute(
            CURVE_2,
            ethers.utils.parseUnits('0', 6),
            ethers.utils.parseUnits('100', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('2.713175', 6))
      })

      it('zero skew, negative change', async () => {
        expect(
          await synBook.compute(
            CURVE_2,
            ethers.utils.parseUnits('0', 6),
            ethers.utils.parseUnits('-100', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('2.713175', 6))
      })

      it('positive skew, zero change', async () => {
        expect(
          await synBook.compute(
            CURVE_2,
            ethers.utils.parseUnits('200', 6),
            ethers.utils.parseUnits('0', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('0', 6))
      })

      it('positive skew, positive change', async () => {
        expect(
          await synBook.compute(
            CURVE_2,
            ethers.utils.parseUnits('200', 6),
            ethers.utils.parseUnits('100', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('3.967775', 6))
      })

      it('positive skew, negative change', async () => {
        expect(
          await synBook.compute(
            CURVE_2,
            ethers.utils.parseUnits('200', 6),
            ethers.utils.parseUnits('-100', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('1.704575', 6))
      })

      it('negative skew, zero change', async () => {
        expect(
          await synBook.compute(
            CURVE_2,
            ethers.utils.parseUnits('-200', 6),
            ethers.utils.parseUnits('0', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('0', 6))
      })

      it('negative skew, positive change', async () => {
        expect(
          await synBook.compute(
            CURVE_2,
            ethers.utils.parseUnits('-200', 6),
            ethers.utils.parseUnits('100', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('1.704575', 6))
      })

      it('negative skew, negative change', async () => {
        expect(
          await synBook.compute(
            CURVE_2,
            ethers.utils.parseUnits('-200', 6),
            ethers.utils.parseUnits('-100', 6),
            ethers.utils.parseUnits('123', 6),
          ),
        ).to.equal(ethers.utils.parseUnits('3.967775', 6))
      })
    })
  })
})
