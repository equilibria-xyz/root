import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockFixed6, MockFixed6__factory } from '../../../types/generated'
import { parseBase6 } from '../../testutil/number'

const { ethers } = HRE

const SLOT = ethers.utils.keccak256(Buffer.from('equilibria.root.Fixed6.testSlot'))

describe('Fixed6', () => {
  let user: SignerWithAddress
  let fixed6: MockFixed6

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    fixed6 = await new MockFixed6__factory(user).deploy()
  })

  describe('#ZERO', async () => {
    it('returns zero', async () => {
      expect(await fixed6.ZERO()).to.equal(0)
    })
  })

  describe('#ONE', async () => {
    it('returns one', async () => {
      expect(await fixed6.ONE()).to.equal(parseBase6('1'))
    })
  })

  describe('#NEG_ONE', async () => {
    it('returns negative one', async () => {
      expect(await fixed6.NEG_ONE()).to.equal(parseBase6('-1'))
    })
  })

  describe('#MAX', async () => {
    it('returns max', async () => {
      expect(await fixed6.MAX()).to.equal(ethers.constants.MaxInt256)
    })
  })

  describe('#MIN', async () => {
    it('returns min', async () => {
      expect(await fixed6.MIN()).to.equal(ethers.constants.MinInt256)
    })
  })

  describe('#from(int256)', async () => {
    it('creates new', async () => {
      expect(await fixed6['from(int256)'](10)).to.equal(parseBase6('10'))
    })

    it('reverts if too large', async () => {
      const TOO_LARGE = ethers.constants.MaxInt256.sub(10)
      await expect(fixed6['from(int256)'](TOO_LARGE)).to.be.reverted
    })
  })

  describe('#from(int256,UFixed6)', async () => {
    it('creates positive', async () => {
      expect(await fixed6['from(int256,uint256)'](1, parseBase6('10'))).to.equal(parseBase6('10'))
    })

    it('creates zero', async () => {
      expect(await fixed6['from(int256,uint256)'](0, parseBase6('10'))).to.equal(0)
    })

    it('creates negative', async () => {
      expect(await fixed6['from(int256,uint256)'](-1, parseBase6('10'))).to.equal(parseBase6('-10'))
    })

    it('reverts if too large or small', async () => {
      const TOO_LARGE = ethers.BigNumber.from(2).pow(256).sub(10)
      await expect(fixed6['from(int256,uint256)'](1, TOO_LARGE)).to.be.revertedWith(`Fixed6OverflowError(${TOO_LARGE})`)
      await expect(fixed6['from(int256,uint256)'](-1, TOO_LARGE)).to.be.revertedWith(
        `Fixed6OverflowError(${TOO_LARGE})`,
      )
    })
  })

  describe('#from(UFixed6)', async () => {
    it('creates new', async () => {
      expect(await fixed6['from(uint256)'](parseBase6('10'))).to.equal(parseBase6('10'))
    })

    it('reverts if too large', async () => {
      const TOO_LARGE = ethers.BigNumber.from(2).pow(256).sub(10)
      await expect(fixed6['from(uint256)'](TOO_LARGE)).to.be.revertedWith(`Fixed6OverflowError(${TOO_LARGE})`)
    })
  })

  describe('#isZero', async () => {
    it('returns true', async () => {
      expect(await fixed6.isZero(0)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await fixed6.isZero(1)).to.equal(false)
    })
  })

  describe('#add', async () => {
    it('adds', async () => {
      expect(await fixed6.add(10, 20)).to.equal(30)
    })

    it('adds', async () => {
      expect(await fixed6.add(-10, -20)).to.equal(-30)
    })
  })

  describe('#sub', async () => {
    it('subs', async () => {
      expect(await fixed6.sub(20, 10)).to.equal(10)
    })

    it('subs', async () => {
      expect(await fixed6.sub(-20, -10)).to.equal(-10)
    })
  })

  describe('#mul', async () => {
    it('muls', async () => {
      expect(await fixed6.mul(parseBase6('20'), parseBase6('10'))).to.equal(parseBase6('200'))
      expect(await fixed6.mul(parseBase6('-20'), parseBase6('10'))).to.equal(parseBase6('-200'))
      expect(await fixed6.mul(parseBase6('20'), parseBase6('-10'))).to.equal(parseBase6('-200'))
      expect(await fixed6.mul(parseBase6('-20'), parseBase6('-10'))).to.equal(parseBase6('200'))
    })

    it('muls and rounds towards zero', async () => {
      expect(await fixed6.mul(1, 2)).to.equal(0)
      expect(await fixed6.mul(-1, 2)).to.equal(0)
      expect(await fixed6.mul(1, -2)).to.equal(0)
      expect(await fixed6.mul(-1, -2)).to.equal(0)
    })
  })

  describe('#mulOut', async () => {
    it('muls', async () => {
      expect(await fixed6.mulOut(parseBase6('20'), parseBase6('10'))).to.equal(parseBase6('200'))
      expect(await fixed6.mulOut(parseBase6('-20'), parseBase6('10'))).to.equal(parseBase6('-200'))
      expect(await fixed6.mulOut(parseBase6('20'), parseBase6('-10'))).to.equal(parseBase6('-200'))
      expect(await fixed6.mulOut(parseBase6('-20'), parseBase6('-10'))).to.equal(parseBase6('200'))
    })

    it('muls and rounds away from zero', async () => {
      expect(await fixed6.mulOut(1, 2)).to.equal(1)
      expect(await fixed6.mulOut(-1, 2)).to.equal(-1)
      expect(await fixed6.mulOut(1, -2)).to.equal(-1)
      expect(await fixed6.mulOut(-1, -2)).to.equal(1)
    })
  })

  describe('#div', async () => {
    it('divs', async () => {
      expect(await fixed6.div(parseBase6('20'), parseBase6('10'))).to.equal(parseBase6('2'))
    })

    it('divs', async () => {
      expect(await fixed6.div(parseBase6('-20'), parseBase6('-10'))).to.equal(parseBase6('2'))
    })

    it('divs and rounds towards zero', async () => {
      expect(await fixed6.div(21, parseBase6('10'))).to.equal(2)
      expect(await fixed6.div(-21, parseBase6('10'))).to.equal(-2)
    })

    it('reverts', async () => {
      await expect(fixed6.div(0, 0)).to.revertedWith('0x12')
    })

    it('reverts', async () => {
      await expect(fixed6.div(parseBase6('20'), 0)).to.revertedWith('0x12')
    })

    it('reverts', async () => {
      await expect(fixed6.div(parseBase6('-20'), 0)).to.revertedWith('0x12')
    })
  })

  describe('#divOut', async () => {
    it('divs without rounding', async () => {
      expect(await fixed6.divOut(parseBase6('20'), parseBase6('10'))).to.equal(parseBase6('2'))
      expect(await fixed6.divOut(parseBase6('-20'), parseBase6('-10'))).to.equal(parseBase6('2'))
      expect(await fixed6.divOut(parseBase6('20'), parseBase6('-10'))).to.equal(parseBase6('-2'))
      expect(await fixed6.divOut(parseBase6('-20'), parseBase6('10'))).to.equal(parseBase6('-2'))
    })

    it('divs and rounds away from zero', async () => {
      expect(await fixed6.divOut(21, parseBase6('10'))).to.equal(3)
      expect(await fixed6.divOut(-21, parseBase6('10'))).to.equal(-3)
      expect(await fixed6.divOut(21, parseBase6('-10'))).to.equal(-3)
      expect(await fixed6.divOut(-21, parseBase6('-10'))).to.equal(3)
    })

    it('reverts', async () => {
      await expect(fixed6.divOut(0, 0)).to.revertedWith('DivisionByZero()')
    })

    it('reverts', async () => {
      await expect(fixed6.divOut(parseBase6('20'), 0)).to.revertedWith('DivisionByZero()')
    })

    it('reverts', async () => {
      await expect(fixed6.divOut(parseBase6('-20'), 0)).to.revertedWith('DivisionByZero()')
    })
  })

  describe('#unsafeDiv', async () => {
    it('divs', async () => {
      expect(await fixed6.unsafeDiv(parseBase6('20'), parseBase6('10'))).to.equal(parseBase6('2'))
    })

    it('divs', async () => {
      expect(await fixed6.unsafeDiv(parseBase6('-20'), parseBase6('-10'))).to.equal(parseBase6('2'))
    })

    it('divs and floors', async () => {
      expect(await fixed6.unsafeDiv(21, parseBase6('10'))).to.equal(2)
    })

    it('divs (ONE)', async () => {
      expect(await fixed6.unsafeDiv(0, 0)).to.equal(parseBase6('1'))
    })

    it('divs (MAX)', async () => {
      expect(await fixed6.unsafeDiv(parseBase6('20'), 0)).to.equal(ethers.constants.MaxInt256)
    })

    it('divs (MIN)', async () => {
      expect(await fixed6.unsafeDiv(parseBase6('-20'), 0)).to.equal(ethers.constants.MinInt256)
    })
  })

  describe('#unsafeDivOut', async () => {
    it('divs', async () => {
      expect(await fixed6.unsafeDivOut(parseBase6('20'), parseBase6('10'))).to.equal(parseBase6('2'))
    })

    it('divs', async () => {
      expect(await fixed6.unsafeDivOut(parseBase6('-20'), parseBase6('-10'))).to.equal(parseBase6('2'))
    })

    it('divs and ceils', async () => {
      expect(await fixed6.unsafeDivOut(21, parseBase6('10'))).to.equal(3)
    })

    it('divs (ONE)', async () => {
      expect(await fixed6.unsafeDivOut(0, 0)).to.equal(parseBase6('1'))
    })

    it('divs (MAX)', async () => {
      expect(await fixed6.unsafeDivOut(parseBase6('20'), 0)).to.equal(ethers.constants.MaxInt256)
    })

    it('divs (MIN)', async () => {
      expect(await fixed6.unsafeDivOut(parseBase6('-20'), 0)).to.equal(ethers.constants.MinInt256)
    })
  })

  describe('#muldiv', async () => {
    it('muldivs', async () => {
      expect(await fixed6.muldiv1(parseBase6('20'), parseBase6('10'), parseBase6('2'))).to.equal(parseBase6('100'))
    })

    it('muldivs', async () => {
      expect(await fixed6.muldiv2(parseBase6('20'), 10, 2)).to.equal(parseBase6('100'))
    })

    it('muldivs', async () => {
      expect(await fixed6.muldiv1(parseBase6('-20'), parseBase6('10'), parseBase6('2'))).to.equal(parseBase6('-100'))
    })

    it('muldivs', async () => {
      expect(await fixed6.muldiv2(parseBase6('-20'), 10, 2)).to.equal(parseBase6('-100'))
    })

    it('muldivs (precision)', async () => {
      expect(await fixed6.muldiv1(parseBase6('1.111111'), parseBase6('0.333333'), parseBase6('0.333333'))).to.equal(
        parseBase6('1.111111'),
      )
    })

    it('muldivs (precision)', async () => {
      expect(await fixed6.muldiv2(parseBase6('1.111111'), parseBase6('0.333333'), parseBase6('0.333333'))).to.equal(
        parseBase6('1.111111'),
      )
    })

    it('muldivs (rounds towards zero)', async () => {
      expect(await fixed6.muldiv1(1, 21, 10)).to.equal(2)
      expect(await fixed6.muldiv1(1, 21, -10)).to.equal(-2)
      expect(await fixed6.muldiv1(-1, 21, 10)).to.equal(-2)
      expect(await fixed6.muldiv1(-1, 21, -10)).to.equal(2)

      expect(await fixed6.muldiv2(1, 21, 10)).to.equal(2)
      expect(await fixed6.muldiv2(1, 21, -10)).to.equal(-2)
      expect(await fixed6.muldiv2(-1, 21, 10)).to.equal(-2)
      expect(await fixed6.muldiv2(-1, 21, -10)).to.equal(2)
    })

    it('reverts', async () => {
      await expect(fixed6.muldiv1(parseBase6('20'), parseBase6('10'), parseBase6('0'))).to.revertedWith('0x12')
    })

    it('reverts', async () => {
      await expect(fixed6.muldiv2(parseBase6('20'), parseBase6('10'), parseBase6('0'))).to.revertedWith('0x12')
    })
  })

  describe('#muldivOut', async () => {
    it('muldivs', async () => {
      expect(await fixed6.muldivOut1(parseBase6('20'), parseBase6('10'), parseBase6('2'))).to.equal(parseBase6('100'))
    })

    it('muldivs', async () => {
      expect(await fixed6.muldivOut2(parseBase6('20'), 10, 2)).to.equal(parseBase6('100'))
    })

    it('muldivs', async () => {
      expect(await fixed6.muldivOut1(parseBase6('-20'), parseBase6('10'), parseBase6('2'))).to.equal(parseBase6('-100'))
    })

    it('muldivs', async () => {
      expect(await fixed6.muldivOut2(parseBase6('-20'), 10, 2)).to.equal(parseBase6('-100'))
    })

    it('muldivs (precision)', async () => {
      expect(await fixed6.muldivOut1(parseBase6('1.111111'), parseBase6('0.333333'), parseBase6('0.333333'))).to.equal(
        parseBase6('1.111111'),
      )
    })

    it('muldivs (precision)', async () => {
      expect(await fixed6.muldivOut2(parseBase6('1.111111'), parseBase6('0.333333'), parseBase6('0.333333'))).to.equal(
        parseBase6('1.111111'),
      )
    })

    it('muldivs (rounds away from zero)', async () => {
      expect(await fixed6.muldivOut1(1, 21, 10)).to.equal(3)
      expect(await fixed6.muldivOut1(1, 21, -10)).to.equal(-3)
      expect(await fixed6.muldivOut1(-1, 21, 10)).to.equal(-3)
      expect(await fixed6.muldivOut1(-1, 21, -10)).to.equal(3)

      expect(await fixed6.muldivOut2(1, 21, 10)).to.equal(3)
      expect(await fixed6.muldivOut2(1, 21, -10)).to.equal(-3)
      expect(await fixed6.muldivOut2(-1, 21, 10)).to.equal(-3)
      expect(await fixed6.muldivOut2(-1, 21, -10)).to.equal(3)
    })

    it('reverts', async () => {
      await expect(fixed6.muldivOut1(parseBase6('20'), parseBase6('10'), parseBase6('0'))).to.revertedWith(
        'DivisionByZero()',
      )
    })

    it('reverts', async () => {
      await expect(fixed6.muldivOut2(parseBase6('20'), parseBase6('10'), parseBase6('0'))).to.revertedWith(
        'DivisionByZero()',
      )
    })
  })

  describe('#eq', async () => {
    it('returns true', async () => {
      expect(await fixed6.eq(12, 12)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await fixed6.eq(-12, -12)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await fixed6.eq(11, 12)).to.equal(false)
    })
  })

  describe('#gt', async () => {
    it('returns true', async () => {
      expect(await fixed6.gt(13, 12)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await fixed6.gt(-12, -13)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await fixed6.gt(12, 12)).to.equal(false)
    })

    it('returns false', async () => {
      expect(await fixed6.gt(11, 12)).to.equal(false)
    })
  })

  describe('#lt', async () => {
    it('returns false', async () => {
      expect(await fixed6.lt(13, 12)).to.equal(false)
    })

    it('returns false', async () => {
      expect(await fixed6.lt(12, 12)).to.equal(false)
    })

    it('returns true', async () => {
      expect(await fixed6.lt(11, 12)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await fixed6.lt(-12, -11)).to.equal(true)
    })
  })

  describe('#gte', async () => {
    it('returns true', async () => {
      expect(await fixed6.gte(13, 12)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await fixed6.gte(-12, -13)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await fixed6.gte(12, 12)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await fixed6.gte(-12, -12)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await fixed6.gte(11, 12)).to.equal(false)
    })
  })

  describe('#lte', async () => {
    it('returns false', async () => {
      expect(await fixed6.lte(13, 12)).to.equal(false)
    })

    it('returns true', async () => {
      expect(await fixed6.lte(12, 12)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await fixed6.lte(-12, -12)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await fixed6.lte(11, 12)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await fixed6.lte(-12, -11)).to.equal(true)
    })
  })

  describe('#compare', async () => {
    it('is positive', async () => {
      expect(await fixed6.compare(13, 12)).to.equal(2)
    })

    it('is positive', async () => {
      expect(await fixed6.compare(-12, -13)).to.equal(2)
    })

    it('is zero', async () => {
      expect(await fixed6.compare(12, 12)).to.equal(1)
    })

    it('is negative', async () => {
      expect(await fixed6.compare(11, 12)).to.equal(0)
    })

    it('is negative', async () => {
      expect(await fixed6.compare(-12, -11)).to.equal(0)
    })
  })

  describe('#ratio', async () => {
    it('returns ratio', async () => {
      expect(await fixed6.ratio(2000, 100)).to.equal(parseBase6('20'))
    })

    it('returns ratio', async () => {
      expect(await fixed6.ratio(-2000, -100)).to.equal(parseBase6('20'))
    })
  })

  describe('#min', async () => {
    it('returns min', async () => {
      expect(await fixed6.min(2000, 100)).to.equal(100)
    })

    it('returns min', async () => {
      expect(await fixed6.min(-2000, -100)).to.equal(-2000)
    })

    it('returns min', async () => {
      expect(await fixed6.min(100, 2000)).to.equal(100)
    })

    it('returns min', async () => {
      expect(await fixed6.min(-100, -2000)).to.equal(-2000)
    })
  })

  describe('#max', async () => {
    it('returns max', async () => {
      expect(await fixed6.max(2000, 100)).to.equal(2000)
    })

    it('returns max', async () => {
      expect(await fixed6.max(-2000, -100)).to.equal(-100)
    })

    it('returns max', async () => {
      expect(await fixed6.max(100, 2000)).to.equal(2000)
    })

    it('returns max', async () => {
      expect(await fixed6.max(-100, -2000)).to.equal(-100)
    })
  })

  describe('#truncate', async () => {
    it('returns floor', async () => {
      expect(await fixed6.truncate(parseBase6('123.456'))).to.equal(123)
    })

    it('returns floor', async () => {
      expect(await fixed6.truncate(parseBase6('-123.456'))).to.equal(-123)
    })
  })

  describe('#sign', async () => {
    it('is positive', async () => {
      expect(await fixed6.sign(12)).to.equal(1)
    })

    it('is zero', async () => {
      expect(await fixed6.sign(0)).to.equal(0)
    })

    it('is negative', async () => {
      expect(await fixed6.sign(-12)).to.equal(-1)
    })
  })

  describe('#abs', async () => {
    it('is positive', async () => {
      expect(await fixed6.abs(12)).to.equal(12)
    })
    it('is zero', async () => {
      expect(await fixed6.abs(0)).to.equal(0)
    })
    it('is negative', async () => {
      expect(await fixed6.abs(-12)).to.equal(12)
    })
  })

  describe('#store(Fixed6)', async () => {
    it('sets value', async () => {
      await fixed6.store(SLOT, -12)
      expect(await fixed6.read(SLOT)).to.equal(-12)
    })
  })
})
