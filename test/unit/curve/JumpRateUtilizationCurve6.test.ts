import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'
import { MockJumpRateUtilizationCurve6, MockJumpRateUtilizationCurve6__factory } from '../../../types/generated'

const { ethers } = HRE

const CURVE_1 = {
  minRate: ethers.utils.parseUnits('0.10', 6),
  maxRate: ethers.utils.parseUnits('1.00', 6),
  targetRate: ethers.utils.parseUnits('0.50', 6),
  targetUtilization: ethers.utils.parseUnits('0.80', 6),
}

const CURVE_2 = {
  minRate: ethers.utils.parseUnits('1.00', 6),
  maxRate: ethers.utils.parseUnits('1.00', 6),
  targetRate: ethers.utils.parseUnits('0.50', 6),
  targetUtilization: ethers.utils.parseUnits('0.80', 6),
}

const CURVE_3 = {
  minRate: ethers.utils.parseUnits('0.50', 6),
  maxRate: ethers.utils.parseUnits('0.50', 6),
  targetRate: ethers.utils.parseUnits('1.00', 6),
  targetUtilization: ethers.utils.parseUnits('0.80', 6),
}

const CURVE_4 = {
  minRate: ethers.utils.parseUnits('1.00', 6),
  maxRate: ethers.utils.parseUnits('0.10', 6),
  targetRate: ethers.utils.parseUnits('0.50', 6),
  targetUtilization: ethers.utils.parseUnits('0.80', 6),
}

const SLOT = ethers.utils.keccak256(Buffer.from('equilibria.root.JumpRateUtilizationCurve6.testSlot'))

describe('JumpRateUtilizationCurve6', () => {
  let user: SignerWithAddress
  let jumpRateUtilizationCurve: MockJumpRateUtilizationCurve6

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    jumpRateUtilizationCurve = await new MockJumpRateUtilizationCurve6__factory(user).deploy()
  })

  describe('#compute', async () => {
    context('CURVE_1', async () => {
      it('returns correct rate at zero', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_1, ethers.utils.parseUnits('0.00', 6))).to.equal(
          ethers.utils.parseUnits('0.10', 6),
        )
      })

      it('returns correct rate below target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_1, ethers.utils.parseUnits('0.40', 6))).to.equal(
          ethers.utils.parseUnits('0.30', 6),
        )
      })

      it('returns correct rate at target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_1, ethers.utils.parseUnits('0.80', 6))).to.equal(
          ethers.utils.parseUnits('0.50', 6),
        )
      })

      it('returns correct rate above target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_1, ethers.utils.parseUnits('0.90', 6))).to.equal(
          ethers.utils.parseUnits('0.75', 6),
        )
      })

      it('returns correct rate at max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_1, ethers.utils.parseUnits('1.00', 6))).to.equal(
          ethers.utils.parseUnits('1.00', 6),
        )
      })

      it('returns correct rate above max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_1, ethers.utils.parseUnits('1.10', 6))).to.equal(
          ethers.utils.parseUnits('1.00', 6),
        )
      })
    })

    context('CURVE_2', async () => {
      it('returns correct rate at zero', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_2, ethers.utils.parseUnits('0.00', 6))).to.equal(
          ethers.utils.parseUnits('1.00', 6),
        )
      })

      it('returns correct rate below target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_2, ethers.utils.parseUnits('0.40', 6))).to.equal(
          ethers.utils.parseUnits('0.75', 6),
        )
      })

      it('returns correct rate at target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_2, ethers.utils.parseUnits('0.80', 6))).to.equal(
          ethers.utils.parseUnits('0.50', 6),
        )
      })

      it('returns correct rate above target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_2, ethers.utils.parseUnits('0.90', 6))).to.equal(
          ethers.utils.parseUnits('0.75', 6),
        )
      })

      it('returns correct rate at max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_2, ethers.utils.parseUnits('1.00', 6))).to.equal(
          ethers.utils.parseUnits('1.00', 6),
        )
      })

      it('returns correct rate above max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_2, ethers.utils.parseUnits('1.10', 6))).to.equal(
          ethers.utils.parseUnits('1.00', 6),
        )
      })
    })

    context('CURVE_3', async () => {
      it('returns correct rate at zero', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_3, ethers.utils.parseUnits('0.00', 6))).to.equal(
          ethers.utils.parseUnits('0.50', 6),
        )
      })

      it('returns correct rate below target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_3, ethers.utils.parseUnits('0.40', 6))).to.equal(
          ethers.utils.parseUnits('0.75', 6),
        )
      })

      it('returns correct rate at target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_3, ethers.utils.parseUnits('0.80', 6))).to.equal(
          ethers.utils.parseUnits('1.00', 6),
        )
      })

      it('returns correct rate above target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_3, ethers.utils.parseUnits('0.90', 6))).to.equal(
          ethers.utils.parseUnits('0.75', 6),
        )
      })

      it('returns correct rate at max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_3, ethers.utils.parseUnits('1.00', 6))).to.equal(
          ethers.utils.parseUnits('0.50', 6),
        )
      })

      it('returns correct rate above max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_3, ethers.utils.parseUnits('1.10', 6))).to.equal(
          ethers.utils.parseUnits('0.50', 6),
        )
      })
    })

    context('CURVE_4', async () => {
      it('returns correct rate at zero', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_4, ethers.utils.parseUnits('0.00', 6))).to.equal(
          ethers.utils.parseUnits('1.00', 6),
        )
      })

      it('returns correct rate below target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_4, ethers.utils.parseUnits('0.40', 6))).to.equal(
          ethers.utils.parseUnits('0.75', 6),
        )
      })

      it('returns correct rate at target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_4, ethers.utils.parseUnits('0.80', 6))).to.equal(
          ethers.utils.parseUnits('0.50', 6),
        )
      })

      it('returns correct rate above target', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_4, ethers.utils.parseUnits('0.90', 6))).to.equal(
          ethers.utils.parseUnits('0.30', 6),
        )
      })

      it('returns correct rate at max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_4, ethers.utils.parseUnits('1.00', 6))).to.equal(
          ethers.utils.parseUnits('0.10', 6),
        )
      })

      it('returns correct rate above max', async () => {
        expect(await jumpRateUtilizationCurve.compute(CURVE_4, ethers.utils.parseUnits('1.10', 6))).to.equal(
          ethers.utils.parseUnits('0.10', 6),
        )
      })
    })
  })

  describe('#store(JumpRateUtilizationCurve6)', async () => {
    it('sets value', async () => {
      await jumpRateUtilizationCurve.store(SLOT, CURVE_1)

      const storedCurve = await jumpRateUtilizationCurve.read(SLOT)
      expect(storedCurve.minRate).to.equal(CURVE_1.minRate)
      expect(storedCurve.maxRate).to.equal(CURVE_1.maxRate)
      expect(storedCurve.targetRate).to.equal(CURVE_1.targetRate)
      expect(storedCurve.targetUtilization).to.equal(CURVE_1.targetUtilization)
    })
  })
})
