import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'
import { MockUJumpRateUtilizationCurve18, MockUJumpRateUtilizationCurve18__factory } from '../../../types/generated'

const { ethers } = HRE

const CURVE_1 = {
  minRate: ethers.utils.parseEther('0.10'),
  maxRate: ethers.utils.parseEther('1.00'),
  targetRate: ethers.utils.parseEther('0.50'),
  targetUtilization: ethers.utils.parseEther('0.80'),
}

const CURVE_2 = {
  minRate: ethers.utils.parseEther('1.00'),
  maxRate: ethers.utils.parseEther('1.00'),
  targetRate: ethers.utils.parseEther('0.50'),
  targetUtilization: ethers.utils.parseEther('0.80'),
}

const CURVE_3 = {
  minRate: ethers.utils.parseEther('0.50'),
  maxRate: ethers.utils.parseEther('0.50'),
  targetRate: ethers.utils.parseEther('1.00'),
  targetUtilization: ethers.utils.parseEther('0.80'),
}

const CURVE_4 = {
  minRate: ethers.utils.parseEther('1.00'),
  maxRate: ethers.utils.parseEther('0.10'),
  targetRate: ethers.utils.parseEther('0.50'),
  targetUtilization: ethers.utils.parseEther('0.80'),
}

describe('UJumpRateUtilizationCurve18', () => {
  let user: SignerWithAddress
  let jumpRateUtilizationCurve: MockUJumpRateUtilizationCurve18

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    jumpRateUtilizationCurve = await new MockUJumpRateUtilizationCurve18__factory(user).deploy()
  })

  describe('#compute', async () => {
    context('CURVE_1', async () => {
      it('returns correct rate at zero', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_1, ethers.utils.parseEther('0.00'))).to.equal(
          ethers.utils.parseEther('0.10'),
        )
      })

      it('returns correct rate below target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_1, ethers.utils.parseEther('0.40'))).to.equal(
          ethers.utils.parseEther('0.30'),
        )
      })

      it('returns correct rate at target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_1, ethers.utils.parseEther('0.80'))).to.equal(
          ethers.utils.parseEther('0.50'),
        )
      })

      it('returns correct rate above target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_1, ethers.utils.parseEther('0.90'))).to.equal(
          ethers.utils.parseEther('0.75'),
        )
      })

      it('returns correct rate at max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_1, ethers.utils.parseEther('1.00'))).to.equal(
          ethers.utils.parseEther('1.00'),
        )
      })

      it('returns correct rate above max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_1, ethers.utils.parseEther('1.10'))).to.equal(
          ethers.utils.parseEther('1.00'),
        )
      })
    })

    context('CURVE_2', async () => {
      it('returns correct rate at zero', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_2, ethers.utils.parseEther('0.00'))).to.equal(
          ethers.utils.parseEther('1.00'),
        )
      })

      it('returns correct rate below target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_2, ethers.utils.parseEther('0.40'))).to.equal(
          ethers.utils.parseEther('0.75'),
        )
      })

      it('returns correct rate at target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_2, ethers.utils.parseEther('0.80'))).to.equal(
          ethers.utils.parseEther('0.50'),
        )
      })

      it('returns correct rate above target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_2, ethers.utils.parseEther('0.90'))).to.equal(
          ethers.utils.parseEther('0.75'),
        )
      })

      it('returns correct rate at max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_2, ethers.utils.parseEther('1.00'))).to.equal(
          ethers.utils.parseEther('1.00'),
        )
      })

      it('returns correct rate above max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_2, ethers.utils.parseEther('1.10'))).to.equal(
          ethers.utils.parseEther('1.00'),
        )
      })
    })

    context('CURVE_3', async () => {
      it('returns correct rate at zero', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_3, ethers.utils.parseEther('0.00'))).to.equal(
          ethers.utils.parseEther('0.50'),
        )
      })

      it('returns correct rate below target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_3, ethers.utils.parseEther('0.40'))).to.equal(
          ethers.utils.parseEther('0.75'),
        )
      })

      it('returns correct rate at target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_3, ethers.utils.parseEther('0.80'))).to.equal(
          ethers.utils.parseEther('1.00'),
        )
      })

      it('returns correct rate above target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_3, ethers.utils.parseEther('0.90'))).to.equal(
          ethers.utils.parseEther('0.75'),
        )
      })

      it('returns correct rate at max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_3, ethers.utils.parseEther('1.00'))).to.equal(
          ethers.utils.parseEther('0.50'),
        )
      })

      it('returns correct rate above max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_3, ethers.utils.parseEther('1.10'))).to.equal(
          ethers.utils.parseEther('0.50'),
        )
      })
    })

    context('CURVE_4', async () => {
      it('returns correct rate at zero', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_4, ethers.utils.parseEther('0.00'))).to.equal(
          ethers.utils.parseEther('1.00'),
        )
      })

      it('returns correct rate below target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_4, ethers.utils.parseEther('0.40'))).to.equal(
          ethers.utils.parseEther('0.75'),
        )
      })

      it('returns correct rate at target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_4, ethers.utils.parseEther('0.80'))).to.equal(
          ethers.utils.parseEther('0.50'),
        )
      })

      it('returns correct rate above target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_4, ethers.utils.parseEther('0.90'))).to.equal(
          ethers.utils.parseEther('0.30'),
        )
      })

      it('returns correct rate at max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_4, ethers.utils.parseEther('1.00'))).to.equal(
          ethers.utils.parseEther('0.10'),
        )
      })

      it('returns correct rate above max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_4, ethers.utils.parseEther('1.10'))).to.equal(
          ethers.utils.parseEther('0.10'),
        )
      })
    })
  })
})
