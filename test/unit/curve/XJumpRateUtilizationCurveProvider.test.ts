import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  MockXJumpRateUtilizationCurveProvider,
  MockXJumpRateUtilizationCurveProvider__factory,
} from '../../../types/generated'

const { ethers } = HRE

const CURVE_1 = {
  minRate: ethers.utils.parseEther('0.10'),
  maxRate: ethers.utils.parseEther('1.00'),
  targetRate: ethers.utils.parseEther('0.50'),
  targetUtilization: ethers.utils.parseEther('0.80'),
}

describe('XJumpRateUtilizationCurveProvider', () => {
  let owner: SignerWithAddress
  let user: SignerWithAddress
  let xJumpRateUtilizationCurveProvider: MockXJumpRateUtilizationCurveProvider

  beforeEach(async () => {
    ;[owner, user] = await ethers.getSigners()
    xJumpRateUtilizationCurveProvider = await new MockXJumpRateUtilizationCurveProvider__factory(owner).deploy(CURVE_1)
  })

  describe('#constructor', async () => {
    it('initializes utilization curve', async () => {
      const utilizationCurve = await xJumpRateUtilizationCurveProvider.utilizationCurve()
      expect(utilizationCurve.minRate).to.equal(CURVE_1.minRate)
      expect(utilizationCurve.maxRate).to.equal(CURVE_1.maxRate)
      expect(utilizationCurve.targetRate).to.equal(CURVE_1.targetRate)
      expect(utilizationCurve.targetUtilization).to.equal(CURVE_1.targetUtilization)
    })
  })

  describe('#computeUtilizationCurve', async () => {
    it('computes from the utilization curve', async () => {
      expect(
        await xJumpRateUtilizationCurveProvider.connect(user).computeRate(ethers.utils.parseEther('0.40')),
      ).to.equal(ethers.utils.parseEther('0.30'))
    })
  })
})
