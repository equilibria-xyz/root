import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockNumberMath, MockNumberMath__factory } from '../../../types/generated'

const { ethers } = HRE

describe('NumberMath', () => {
  let user: SignerWithAddress
  let math: MockNumberMath

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    math = await new MockNumberMath__factory(user).deploy()
  })

  describe('#divOut (unsigned)', async () => {
    it('divs without rounding', async () => {
      expect(await math['divOut(uint256,uint256)'](20, 10)).to.equal(2)
    })

    it('divs and rounds away from 0', async () => {
      expect(await math['divOut(uint256,uint256)'](21, 10)).to.equal(3)
    })

    it('divides 0', async () => {
      expect(await math['divOut(uint256,uint256)'](0, 10)).to.equal(0)
    })

    it('reverts', async () => {
      // We get an overflow/underflow error because we subtract 1 from 0.
      await expect(math['divOut(uint256,uint256)'](0, 0)).to.be.revertedWith('DivisionByZero()')
    })

    it('reverts', async () => {
      await expect(math['divOut(uint256,uint256)'](20, 0)).to.be.revertedWith('DivisionByZero()')
    })
  })

  describe('#divOut (signed)', async () => {
    it('divs without rounding', async () => {
      expect(await math['divOut(int256,int256)'](20, 10)).to.equal(2)
      expect(await math['divOut(int256,int256)'](20, -10)).to.equal(-2)
      expect(await math['divOut(int256,int256)'](-20, 10)).to.equal(-2)
      expect(await math['divOut(int256,int256)'](-20, -10)).to.equal(2)
    })

    it('divs and rounds away from zero', async () => {
      expect(await math['divOut(int256,int256)'](21, 10)).to.equal(3)
      expect(await math['divOut(int256,int256)'](-21, 10)).to.equal(-3)
      expect(await math['divOut(int256,int256)'](21, -10)).to.equal(-3)
      expect(await math['divOut(int256,int256)'](-21, -10)).to.equal(3)
    })

    it('reverts', async () => {
      await expect(math['divOut(int256,int256)'](0, 0)).to.revertedWith('DivisionByZero()')
    })

    it('reverts', async () => {
      await expect(math['divOut(int256,int256)'](20, 0)).to.revertedWith('DivisionByZero()')
    })

    it('reverts', async () => {
      await expect(math['divOut(int256,int256)'](-20, 0)).to.revertedWith('DivisionByZero()')
    })
  })

  describe('#sign', async () => {
    it('is positive', async () => {
      expect(await math.sign(12)).to.equal(1)
    })

    it('is zero', async () => {
      expect(await math.sign(0)).to.equal(0)
    })

    it('is negative', async () => {
      expect(await math.sign(-12)).to.equal(-1)
    })
  })
})
