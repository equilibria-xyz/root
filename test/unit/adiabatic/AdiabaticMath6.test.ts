import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockAdiabaticMath6, MockAdiabaticMath6__factory } from '../../../types/generated'
import { parseUnits } from 'ethers/lib/utils'

const { ethers } = HRE

describe('AdiabaticMath6', () => {
  let user: SignerWithAddress
  let adiabaticMath: MockAdiabaticMath6

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    adiabaticMath = await new MockAdiabaticMath6__factory(user).deploy()
  })

  describe('#linearFee', async () => {
    it('returns correct base fees', async () => {
      const fee = await adiabaticMath.linearFee(parseUnits('0.1', 6), parseUnits('10', 6), parseUnits('123', 6))
      expect(fee).to.equal(parseUnits('123', 6))
    })

    it('returns correct base fees with empty order', async () => {
      const fee = await adiabaticMath.linearFee(parseUnits('0.1', 6), parseUnits('0', 6), parseUnits('123', 6))
      expect(fee).to.equal(parseUnits('0', 6))
    })
  })

  describe('#proportionalFee', async () => {
    it('returns correct base fees', async () => {
      const fee = await adiabaticMath.proportionalFee(
        parseUnits('100', 6),
        parseUnits('0.2', 6),
        parseUnits('10', 6),
        parseUnits('123', 6),
      )
      expect(fee).to.equal(parseUnits('24.6', 6))
    })

    it('returns correct base fees with empty order', async () => {
      const fee = await adiabaticMath.proportionalFee(
        parseUnits('100', 6),
        parseUnits('0.2', 6),
        parseUnits('0', 6),
        parseUnits('123', 6),
      )
      expect(fee).to.equal(parseUnits('0', 6))
    })

    it('reverts with zero scale', async () => {
      await expect(
        adiabaticMath.proportionalFee(
          parseUnits('0', 6),
          parseUnits('0.2', 6),
          parseUnits('10', 6),
          parseUnits('123', 6),
        ),
      ).to.be.reverted
    })
  })

  describe('#linearCompute', async () => {
    context('positive latest', async () => {
      context('positive change', async () => {
        it('returns correct adiabatic fee', async () => {
          const fee = await adiabaticMath.linearCompute(
            parseUnits('100', 6),
            parseUnits('0.1', 6),
            parseUnits('50', 6),
            parseUnits('10', 6),
            parseUnits('123', 6),
          )
          expect(fee).to.equal(parseUnits('67.65', 6))
        })
      })

      context('negative change', async () => {
        it('returns correct adiabatic fee', async () => {
          const fee = await adiabaticMath.linearCompute(
            parseUnits('100', 6),
            parseUnits('0.1', 6),
            parseUnits('50', 6),
            parseUnits('-10', 6),
            parseUnits('123', 6),
          )
          expect(fee).to.equal(parseUnits('-55.35', 6))
        })
      })
    })

    context('negative latest', async () => {
      context('positive change', async () => {
        it('returns correct adiabatic fee', async () => {
          const fee = await adiabaticMath.linearCompute(
            parseUnits('100', 6),
            parseUnits('0.1', 6),
            parseUnits('-50', 6),
            parseUnits('10', 6),
            parseUnits('123', 6),
          )
          expect(fee).to.equal(parseUnits('-55.35', 6))
        })
      })

      context('negative change', async () => {
        it('returns correct adiabatic fee', async () => {
          const fee = await adiabaticMath.linearCompute(
            parseUnits('100', 6),
            parseUnits('0.1', 6),
            parseUnits('-50', 6),
            parseUnits('-10', 6),
            parseUnits('123', 6),
          )
          expect(fee).to.equal(parseUnits('67.65', 6))
        })
      })
    })

    context('zero latest and change', async () => {
      it('returns correct adiabatic fee', async () => {
        const fee = await adiabaticMath.linearCompute(
          parseUnits('100', 6),
          parseUnits('0.1', 6),
          parseUnits('0', 6),
          parseUnits('0', 6),
          parseUnits('0', 6),
        )
        expect(fee).to.equal(parseUnits('0', 6))
      })
    })

    context('zero scale', async () => {
      it('revert', async () => {
        await expect(
          adiabaticMath.linearCompute(
            parseUnits('0', 6),
            parseUnits('0.1', 6),
            parseUnits('50', 6),
            parseUnits('10', 6),
            parseUnits('123', 6),
          ),
        ).to.be.revertedWith('Adiabatic6ZeroScaleError()')
      })
    })
  })
})
