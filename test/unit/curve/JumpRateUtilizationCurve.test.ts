import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'
import { MockJumpRateUtilizationCurve, MockJumpRateUtilizationCurve__factory } from '../../../types/generated'

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

const SLOT = ethers.utils.keccak256(Buffer.from('equilibria.root.JumpRateUtilizationCurve.testSlot'))

describe('JumpRateUtilizationCurve', () => {
  let user: SignerWithAddress
  let jumpRateUtilizationCurve: MockJumpRateUtilizationCurve

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    jumpRateUtilizationCurve = await new MockJumpRateUtilizationCurve__factory(user).deploy()
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

  describe('#store(JumpRateUtilizationCurve)', async () => {
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
