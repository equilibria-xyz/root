import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  MockUJumpRateUtilizationCurveProvider,
  MockUJumpRateUtilizationCurveProvider__factory,
} from '../../../types/generated'

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

describe('UJumpRateUtilizationCurveProvider', () => {
  let owner: SignerWithAddress
  let user: SignerWithAddress
  let uJumpRateUtilizationCurveProvider: MockUJumpRateUtilizationCurveProvider

  beforeEach(async () => {
    ;[owner, user] = await ethers.getSigners()
    uJumpRateUtilizationCurveProvider = await new MockUJumpRateUtilizationCurveProvider__factory(owner).deploy()
  })

  describe('#__MockUJumpRateUtilizationCurveProvider__initialize', async () => {
    it('initializes utilization curve', async () => {
      await expect(uJumpRateUtilizationCurveProvider.connect(owner).__initialize(CURVE_1))
        .to.emit(uJumpRateUtilizationCurveProvider, 'JumpRateUtilizationCurveUpdated')
        .withArgs(CURVE_1.minRate, CURVE_1.maxRate, CURVE_1.targetRate, CURVE_1.targetUtilization)

      const utilizationCurve = await uJumpRateUtilizationCurveProvider.utilizationCurve()
      expect(utilizationCurve.minRate).to.equal(CURVE_1.minRate)
      expect(utilizationCurve.maxRate).to.equal(CURVE_1.maxRate)
      expect(utilizationCurve.targetRate).to.equal(CURVE_1.targetRate)
      expect(utilizationCurve.targetUtilization).to.equal(CURVE_1.targetUtilization)
    })
  })

  describe('#updateUtilizationCurve', async () => {
    beforeEach(async () => {
      await uJumpRateUtilizationCurveProvider.connect(owner).__initialize(CURVE_1)
    })

    it('updates utilization curve', async () => {
      await expect(uJumpRateUtilizationCurveProvider.connect(owner).updateUtilizationCurve(CURVE_2))
        .to.emit(uJumpRateUtilizationCurveProvider, 'JumpRateUtilizationCurveUpdated')
        .withArgs(CURVE_2.minRate, CURVE_2.maxRate, CURVE_2.targetRate, CURVE_2.targetUtilization)

      const utilizationCurve = await uJumpRateUtilizationCurveProvider.utilizationCurve()
      expect(utilizationCurve.minRate).to.equal(CURVE_2.minRate)
      expect(utilizationCurve.maxRate).to.equal(CURVE_2.maxRate)
      expect(utilizationCurve.targetRate).to.equal(CURVE_2.targetRate)
      expect(utilizationCurve.targetUtilization).to.equal(CURVE_2.targetUtilization)
    })

    it('reverts if not owner', async () => {
      await expect(uJumpRateUtilizationCurveProvider.connect(user).updateUtilizationCurve(CURVE_2)).to.be.revertedWith(
        `UOwnableNotOwnerError("${user.address}")`,
      )
    })
  })

  describe('#computeUtilizationCurve', async () => {
    beforeEach(async () => {
      await uJumpRateUtilizationCurveProvider.connect(owner).__initialize(CURVE_1)
    })

    it('computes from the utilization curve', async () => {
      expect(
        await uJumpRateUtilizationCurveProvider.connect(user).computeUtilizationCurve(ethers.utils.parseEther('0.40')),
      ).to.equal(ethers.utils.parseEther('0.30'))
    })
  })
})
