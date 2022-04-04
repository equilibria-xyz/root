import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'
import { MockLinearUtilizationCurve, MockLinearUtilizationCurve__factory } from '../../../types/generated'

const { ethers } = HRE

const CURVE_1 = {
  minRate: ethers.utils.parseEther('0.10'),
  maxRate: ethers.utils.parseEther('1.00'),
}

const CURVE_2 = {
  minRate: ethers.utils.parseEther('1.00'),
  maxRate: ethers.utils.parseEther('0.10'),
}

const SLOT = ethers.utils.keccak256(Buffer.from('equilibria.root.JumpRateUtilizationCurve.testSlot'))

describe('linearUtilizationCurve', () => {
  let user: SignerWithAddress
  let linearUtilizationCurve: MockLinearUtilizationCurve

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    linearUtilizationCurve = await new MockLinearUtilizationCurve__factory(user).deploy()
  })

  describe('#compute', async () => {
    context('CURVE_1', async () => {
      it('returns correct rate at zero', async () => {
        expect(await linearUtilizationCurve.compute(CURVE_1, ethers.utils.parseEther('0.00'))).to.equal(
          ethers.utils.parseEther('0.10'),
        )
      })

      it('returns correct rate in middle', async () => {
        expect(await linearUtilizationCurve.compute(CURVE_1, ethers.utils.parseEther('0.50'))).to.equal(
          ethers.utils.parseEther('0.55'),
        )
      })

      it('returns correct rate at max', async () => {
        expect(await linearUtilizationCurve.compute(CURVE_1, ethers.utils.parseEther('1.00'))).to.equal(
          ethers.utils.parseEther('1.00'),
        )
      })

      it('returns correct rate above max', async () => {
        expect(await linearUtilizationCurve.compute(CURVE_1, ethers.utils.parseEther('1.10'))).to.equal(
          ethers.utils.parseEther('1.00'),
        )
      })
    })

    context('CURVE_2', async () => {
      it('returns correct rate at zero', async () => {
        expect(await linearUtilizationCurve.compute(CURVE_2, ethers.utils.parseEther('0.00'))).to.equal(
          ethers.utils.parseEther('1.00'),
        )
      })

      it('returns correct rate in middle', async () => {
        expect(await linearUtilizationCurve.compute(CURVE_2, ethers.utils.parseEther('0.50'))).to.equal(
          ethers.utils.parseEther('0.55'),
        )
      })

      it('returns correct rate at max', async () => {
        expect(await linearUtilizationCurve.compute(CURVE_2, ethers.utils.parseEther('1.00'))).to.equal(
          ethers.utils.parseEther('0.10'),
        )
      })

      it('returns correct rate above max', async () => {
        expect(await linearUtilizationCurve.compute(CURVE_2, ethers.utils.parseEther('1.10'))).to.equal(
          ethers.utils.parseEther('0.10'),
        )
      })
    })
  })

  describe('#store(LinearUtilizationCurve)', async () => {
    it('sets value', async () => {
      await linearUtilizationCurve.store(SLOT, CURVE_1)

      const storedCurve = await linearUtilizationCurve.read(SLOT)
      expect(storedCurve.minRate).to.equal(CURVE_1.minRate)
      expect(storedCurve.maxRate).to.equal(CURVE_1.maxRate)
    })
  })
})
