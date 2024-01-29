import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockInverseAdiabatic6, MockInverseAdiabatic6__factory } from '../../../types/generated'
import { parseUnits } from 'ethers/lib/utils'

const { ethers } = HRE

describe('InverseAdiabatic6', () => {
  let user: SignerWithAddress
  let linearAdiabatic: MockInverseAdiabatic6

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    linearAdiabatic = await new MockInverseAdiabatic6__factory(user).deploy()
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
      ).to.equal(ethers.utils.parseUnits('-166.05', 6))
    })

    it('returns correct fee with positive order across scale', async () => {
      expect(
        await linearAdiabatic.compute(
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('95', 6),
          parseUnits('10', 6),
          parseUnits('123', 6),
        ),
      ).to.equal(ethers.utils.parseUnits('-4.6125', 6))
    })

    it('returns correct fee with positive order above scale', async () => {
      expect(
        await linearAdiabatic.compute(
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('105', 6),
          parseUnits('10', 6),
          parseUnits('123', 6),
        ),
      ).to.equal(ethers.utils.parseUnits('0', 6))
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
      ).to.equal(ethers.utils.parseUnits('202.95', 6))
    })

    it('returns correct fee with negative order across scale', async () => {
      expect(
        await linearAdiabatic.compute(
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('105', 6),
          parseUnits('-10', 6),
          parseUnits('123', 6),
        ),
      ).to.equal(ethers.utils.parseUnits('4.6125', 6))
    })

    it('returns correct fee with negative order above scale', async () => {
      expect(
        await linearAdiabatic.compute(
          {
            linearFee: parseUnits('0.1', 6),
            proportionalFee: parseUnits('0.2', 6),
            adiabaticFee: parseUnits('0.3', 6),
            scale: parseUnits('100', 6),
          },
          parseUnits('115', 6),
          parseUnits('-10', 6),
          parseUnits('123', 6),
        ),
      ).to.equal(ethers.utils.parseUnits('0', 6))
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
      ).to.equal(ethers.utils.parseUnits('-11.25', 6))
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

  describe('#fee', async () => {
    it('returns correct fee with positive latest', async () => {
      const fees = await await linearAdiabatic.fee(
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
      expect(fees[0]).to.equal(parseUnits('123', 6))
      expect(fees[1]).to.equal(parseUnits('24.6', 6))
      expect(fees[2]).to.equal(parseUnits('-166.05', 6))
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
      ).to.equal(
        ethers.utils.parseUnits('2075.625', 6), // -1383.75 - -3459.375
      )
    })
  })
})
