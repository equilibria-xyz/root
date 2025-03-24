import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockCurveMath18, MockCurveMath18__factory } from '../../../types/generated'
import { PANIC_CODES } from '@nomicfoundation/hardhat-chai-matchers/panic'
const { ethers } = HRE

describe('CurveMath18', () => {
  let user: SignerWithAddress
  let curveMath: MockCurveMath18

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    curveMath = await new MockCurveMath18__factory(user).deploy()
  })

  describe('#linearInterpolation', async () => {
    context('increasing', async () => {
      it('reverts before start', async () => {
        await expect(curveMath.linearInterpolation(100, 0, 200, 100, 0)).to.be.revertedWithCustomError(
          curveMath,
          'CurveMath18OutOfBoundsError',
        )
      })

      it('returns correct y-coordinate at start', async () => {
        expect(await curveMath.linearInterpolation(0, 0, 100, 100, 0)).to.equal(0)
      })

      it('returns correct y-coordinate at middle', async () => {
        expect(await curveMath.linearInterpolation(0, 0, 100, 100, 50)).to.equal(50)
      })

      it('returns correct y-coordinate at end', async () => {
        expect(await curveMath.linearInterpolation(0, 0, 100, 100, 100)).to.equal(100)
      })

      it('reverts after end', async () => {
        await expect(curveMath.linearInterpolation(100, 0, 200, 100, 300)).to.be.revertedWithCustomError(
          curveMath,
          'CurveMath18OutOfBoundsError',
        )
      })
    })

    context('decreasing', async () => {
      it('reverts before start', async () => {
        await expect(curveMath.linearInterpolation(100, 100, 200, 0, 0)).to.be.revertedWithCustomError(
          curveMath,
          'CurveMath18OutOfBoundsError',
        )
      })

      it('returns correct y-coordinate at start', async () => {
        expect(await curveMath.linearInterpolation(0, 100, 100, 0, 0)).to.equal(100)
      })

      it('returns correct y-coordinate at middle', async () => {
        expect(await curveMath.linearInterpolation(0, 100, 100, 0, 50)).to.equal(50)
      })

      it('returns correct y-coordinate at end', async () => {
        expect(await curveMath.linearInterpolation(0, 100, 100, 0, 100)).to.equal(0)
      })

      it('reverts after end', async () => {
        await expect(curveMath.linearInterpolation(100, 100, 200, 0, 300)).to.be.revertedWithCustomError(
          curveMath,
          'CurveMath18OutOfBoundsError',
        )
      })
    })

    context('horizontal', async () => {
      it('reverts before start', async () => {
        await expect(curveMath.linearInterpolation(100, 100, 200, 100, 0)).to.be.revertedWithCustomError(
          curveMath,
          'CurveMath18OutOfBoundsError',
        )
      })

      it('returns correct y-coordinate at start', async () => {
        expect(await curveMath.linearInterpolation(0, 100, 100, 100, 0)).to.equal(100)
      })

      it('returns correct y-coordinate at middle', async () => {
        expect(await curveMath.linearInterpolation(0, 100, 100, 100, 50)).to.equal(100)
      })

      it('returns correct y-coordinate at end', async () => {
        expect(await curveMath.linearInterpolation(0, 100, 100, 100, 100)).to.equal(100)
      })

      it('reverts after end', async () => {
        await expect(curveMath.linearInterpolation(100, 100, 200, 100, 300)).to.be.revertedWithCustomError(
          curveMath,
          'CurveMath18OutOfBoundsError',
        )
      })
    })

    context('vertical', async () => {
      it('reverts before start', async () => {
        await expect(curveMath.linearInterpolation(100, 0, 200, 100, 0)).to.be.revertedWithCustomError(
          curveMath,
          'CurveMath18OutOfBoundsError',
        )
      })

      it('reverts with divide by zero', async () => {
        expect(curveMath.linearInterpolation(100, 0, 100, 100, 100)).to.be.revertedWithPanic(
          PANIC_CODES.DIVISION_BY_ZERO,
        )
      })

      it('reverts after end', async () => {
        await expect(curveMath.linearInterpolation(100, 0, 100, 100, 300)).to.be.revertedWithCustomError(
          curveMath,
          'CurveMath18OutOfBoundsError',
        )
      })
    })
  })
})
