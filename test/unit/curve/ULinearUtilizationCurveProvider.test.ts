import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  MockULinearUtilizationCurveProvider,
  MockULinearUtilizationCurveProvider__factory,
} from '../../../types/generated'

const { ethers } = HRE

const CURVE_1 = {
  minRate: ethers.utils.parseEther('0.10'),
  maxRate: ethers.utils.parseEther('1.00'),
}

const CURVE_2 = {
  minRate: ethers.utils.parseEther('1.00'),
  maxRate: ethers.utils.parseEther('0.10'),
}

describe('ULinearUtilizationCurveProvider', () => {
  let owner: SignerWithAddress
  let user: SignerWithAddress
  let uLinearUtilizationCurveProvider: MockULinearUtilizationCurveProvider

  beforeEach(async () => {
    ;[owner, user] = await ethers.getSigners()
    uLinearUtilizationCurveProvider = await new MockULinearUtilizationCurveProvider__factory(owner).deploy()
  })

  describe('#__MockULinearUtilizationCurveProvider__initialize', async () => {
    it('initializes utilization curve', async () => {
      await expect(uLinearUtilizationCurveProvider.connect(owner).__initialize(CURVE_1))
        .to.emit(uLinearUtilizationCurveProvider, 'LinearUtilizationCurveUpdated')
        .withArgs(CURVE_1.minRate, CURVE_1.maxRate)

      const utilizationCurve = await uLinearUtilizationCurveProvider.utilizationCurve()
      expect(utilizationCurve.minRate).to.equal(CURVE_1.minRate)
      expect(utilizationCurve.maxRate).to.equal(CURVE_1.maxRate)
    })
  })

  describe('#updateUtilizationCurve', async () => {
    beforeEach(async () => {
      await uLinearUtilizationCurveProvider.connect(owner).__initialize(CURVE_1)
    })

    it('updates utilization curve', async () => {
      await expect(uLinearUtilizationCurveProvider.connect(owner).updateUtilizationCurve(CURVE_2))
        .to.emit(uLinearUtilizationCurveProvider, 'LinearUtilizationCurveUpdated')
        .withArgs(CURVE_2.minRate, CURVE_2.maxRate)

      const utilizationCurve = await uLinearUtilizationCurveProvider.utilizationCurve()
      expect(utilizationCurve.minRate).to.equal(CURVE_2.minRate)
      expect(utilizationCurve.maxRate).to.equal(CURVE_2.maxRate)
    })

    it('reverts if not owner', async () => {
      await expect(uLinearUtilizationCurveProvider.connect(user).updateUtilizationCurve(CURVE_2)).to.be.revertedWith(
        `UOwnableNotOwnerError("${user.address}")`,
      )
    })
  })

  describe('#computeUtilizationCurve', async () => {
    beforeEach(async () => {
      await uLinearUtilizationCurveProvider.connect(owner).__initialize(CURVE_1)
    })

    it('computes from the utilization curve', async () => {
      expect(
        await uLinearUtilizationCurveProvider.connect(user).computeUtilizationCurve(ethers.utils.parseEther('0.40')),
      ).to.equal(ethers.utils.parseEther('0.46'))
    })
  })
})
