import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  MockXLinearUtilizationCurveProvider,
  MockXLinearUtilizationCurveProvider__factory,
} from '../../../types/generated'

const { ethers } = HRE

const CURVE_1 = {
  minRate: ethers.utils.parseEther('0.10'),
  maxRate: ethers.utils.parseEther('1.00'),
}

describe('XLinearUtilizationCurveProvider', () => {
  let owner: SignerWithAddress
  let user: SignerWithAddress
  let xLinearUtilizationCurveProvider: MockXLinearUtilizationCurveProvider

  beforeEach(async () => {
    ;[owner, user] = await ethers.getSigners()
    xLinearUtilizationCurveProvider = await new MockXLinearUtilizationCurveProvider__factory(owner).deploy(CURVE_1)
  })

  describe('#constructor', async () => {
    it('initializes utilization curve', async () => {
      const utilizationCurve = await xLinearUtilizationCurveProvider.utilizationCurve()
      expect(utilizationCurve.minRate).to.equal(CURVE_1.minRate)
      expect(utilizationCurve.maxRate).to.equal(CURVE_1.maxRate)
    })
  })

  describe('#computeUtilizationCurve', async () => {
    it('computes from the utilization curve', async () => {
      expect(await xLinearUtilizationCurveProvider.connect(user).computeRate(ethers.utils.parseEther('0.40'))).to.equal(
        ethers.utils.parseEther('0.46'),
      )
    })
  })
})
