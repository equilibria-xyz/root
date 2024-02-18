import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockLinearAdiabatic6, MockLinearAdiabatic6__factory } from '../../../types/generated'
import { parseUnits } from 'ethers/lib/utils'

const { ethers } = HRE

describe('LinearAdiabatic6', () => {
  let user: SignerWithAddress
  let linearAdiabatic: MockLinearAdiabatic6

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    linearAdiabatic = await new MockLinearAdiabatic6__factory(user).deploy()
  })

  describe('#compute', async () => {
    it('returns correct fee with positive order', async () => {
      expect(
        await linearAdiabatic.compute(
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('50', 6),
          parseUnits('10', 6),
          parseUnits('123', 6),
        ),
      ).to.equal(ethers.utils.parseUnits('202.95', 6))
    })

    it('returns correct fee with negative order', async () => {
      expect(
        await linearAdiabatic.compute(
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('50', 6),
          parseUnits('-10', 6),
          parseUnits('123', 6),
        ),
      ).to.equal(ethers.utils.parseUnits('-166.05', 6))
    })

    it('returns correct fee with zero order', async () => {
      expect(
        await linearAdiabatic.compute(
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('50', 6),
          parseUnits('0', 6),
          parseUnits('123', 6),
        ),
      ).to.equal(ethers.utils.parseUnits('0', 6))
    })
  })

  describe('#exposure', async () => {
    it('returns correct fee with positive latest', async () => {
      expect(
        await linearAdiabatic.exposure(
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('50', 6),
        ),
      ).to.equal(ethers.utils.parseUnits('3.75', 6))
    })

    it('returns correct fee with negative latest', async () => {
      expect(
        await linearAdiabatic.exposure(
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('-50', 6),
        ),
      ).to.equal(ethers.utils.parseUnits('3.75', 6))
    })

    it('returns correct fee with zero latest', async () => {
      expect(
        await linearAdiabatic.exposure(
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('0', 6),
        ),
      ).to.equal(ethers.utils.parseUnits('0', 6))
    })
  })

  describe('#linear', async () => {
    it('returns correct fee with positive latest', async () => {
      const fee = await await linearAdiabatic.linear(
        {
          linearFee: parseUnits('0.1', 6),
          proportionalFee: parseUnits('0.2', 6),
          adiabaticFee: parseUnits('0.3', 6),
          scale: parseUnits('100', 6),
        },
        parseUnits('10', 6),
        parseUnits('123', 6),
      )
      expect(fee).to.equal(parseUnits('123', 6))
    })
  })

  describe('#proportional', async () => {
    it('returns correct fee with positive latest', async () => {
      const fee = await await linearAdiabatic.proportional(
        {
          linearFee: parseUnits('0.1', 6),
          proportionalFee: parseUnits('0.2', 6),
          adiabaticFee: parseUnits('0.3', 6),
          scale: parseUnits('100', 6),
        },
        parseUnits('10', 6),
        parseUnits('123', 6),
      )
      expect(fee).to.equal(parseUnits('24.6', 6))
    })
  })

  describe('#adiabatic', async () => {
    it('returns correct fee with positive latest', async () => {
      const fee = await await linearAdiabatic.adiabatic(
        {
          linearFee: parseUnits('0.1', 6),
          proportionalFee: parseUnits('0.2', 6),
          adiabaticFee: parseUnits('0.3', 6),
          scale: parseUnits('100', 6),
        },
        parseUnits('50', 6),
        parseUnits('10', 6),
        parseUnits('123', 6),
      )
      expect(fee).to.equal(parseUnits('202.95', 6))
    })
  })

  describe('#update', async () => {
    it('returns correct fee from zero w/ no latest', async () => {
      expect(
        await linearAdiabatic.update(
          {
            linearFee: parseUnits('0', 6),
            proportionalFee: parseUnits('0', 6),
            adiabaticFee: parseUnits('0', 6),
            scale: parseUnits('0', 6),
          },
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('0', 6),
          parseUnits('123', 6),
        ),
      ).to.equal(ethers.utils.parseUnits('0', 6))
    })

    it('reverts from zero w/ latest', async () => {
      await expect(
        linearAdiabatic.update(
          {
            linearFee: parseUnits('0', 6),
            proportionalFee: parseUnits('0', 6),
            adiabaticFee: parseUnits('0', 6),
            scale: parseUnits('0', 6),
          },
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('50', 6),
          parseUnits('123', 6),
        ),
      ).to.revertedWith('Adiabatic6ZeroScaleError')
    })

    it('returns correct fee from non-zero', async () => {
      expect(
        await linearAdiabatic.update(
          {
            linearFee: parseUnits('0.2', 6),
            proportionalFee: parseUnits('0.4', 6),
            adiabaticFee: parseUnits('0.6', 6),
            scale: parseUnits('400', 6),
          },
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('50', 6),
          parseUnits('123', 6),
        ),
      ).to.equal(ethers.utils.parseUnits('230.625', 6))
    })
  })
})
