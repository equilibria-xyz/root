import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockUFixed6, MockUFixed6__factory } from '../../../types/generated'
import { parseBase6 } from '../../testutil/number'

const { ethers } = HRE

const SLOT = ethers.utils.keccak256(Buffer.from('equilibria.root.UFixed6.testSlot'))

describe('UFixed6', () => {
  let user: SignerWithAddress
  let uFixed6: MockUFixed6

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    uFixed6 = await new MockUFixed6__factory(user).deploy()
  })

  describe('#ZERO', async () => {
    it('returns zero', async () => {
      expect(await uFixed6.ZERO()).to.equal(0)
    })
  })

  describe('#ONE', async () => {
    it('returns one', async () => {
      expect(await uFixed6.ONE()).to.equal(parseBase6('1'))
    })
  })

  describe('#MAX', async () => {
    it('returns max', async () => {
      expect(await uFixed6.MAX()).to.equal(ethers.constants.MaxUint256)
    })
  })

  describe('#from(uint256)', async () => {
    it('creates new', async () => {
      expect(await uFixed6['from(uint256)'](10)).to.equal(parseBase6('10'))
    })
  })

  describe('#from(Fixed6)', async () => {
    it('creates positive', async () => {
      expect(await uFixed6['from(int256)'](parseBase6('10'))).to.equal(parseBase6('10'))
    })

    it('reverts if negative', async () => {
      await expect(uFixed6['from(int256)'](parseBase6('-10'))).to.be.revertedWith(
        `UFixed6UnderflowError(${parseBase6('-10')})`,
      )
    })
  })

  describe('#from(UFixed18)', async () => {
    it('creates new (no rounding)', async () => {
      expect(await uFixed6['fromBase18(uint256)'](utils.parseEther('10.1'))).to.equal(parseBase6('10.1'))
      expect(await uFixed6['fromBase18(uint256,bool)'](utils.parseEther('10.1'), true)).to.equal(parseBase6('10.1'))
      expect(await uFixed6['fromBase18(uint256,bool)'](utils.parseEther('10.1'), false)).to.equal(parseBase6('10.1'))
    })

    it('creates new (round towards 0 implicit)', async () => {
      expect(await uFixed6['fromBase18(uint256)'](utils.parseEther('10').add(1))).to.equal(parseBase6('10'))
    })

    it('creates new (round towards 0 explicit)', async () => {
      expect(await uFixed6['fromBase18(uint256,bool)'](utils.parseEther('10').add(1), false)).to.equal(parseBase6('10'))
    })

    it('creates new (round away from 0)', async () => {
      expect(await uFixed6['fromBase18(uint256,bool)'](utils.parseEther('10').add(1), true)).to.equal(
        parseBase6('10').add(1),
      )
    })
  })

  describe('#isZero', async () => {
    it('returns true', async () => {
      expect(await uFixed6.isZero(0)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await uFixed6.isZero(1)).to.equal(false)
    })
  })

  describe('#add', async () => {
    it('adds', async () => {
      expect(await uFixed6.add(10, 20)).to.equal(30)
    })
  })

  describe('#sub', async () => {
    it('subs', async () => {
      expect(await uFixed6.sub(20, 10)).to.equal(10)
    })
  })

  describe('#mul', async () => {
    it('muls', async () => {
      expect(await uFixed6.mul(parseBase6('20'), parseBase6('10'))).to.equal(parseBase6('200'))
    })

    it('muls and rounds down', async () => {
      expect(await uFixed6.mul(1, 2)).to.equal(0)
    })
  })

  describe('#mulOut', async () => {
    it('muls without rounding', async () => {
      expect(await uFixed6.mul(parseBase6('20'), parseBase6('10'))).to.equal(parseBase6('200'))
    })

    it('muls and rounds up', async () => {
      expect(await uFixed6.mulOut(1, 2)).to.equal(1)
    })
  })

  describe('#div', async () => {
    it('divs', async () => {
      expect(await uFixed6.div(parseBase6('20'), parseBase6('10'))).to.equal(parseBase6('2'))
    })

    it('divs and floors', async () => {
      expect(await uFixed6.div(21, parseBase6('10'))).to.equal(2)
    })

    it('reverts', async () => {
      await expect(uFixed6.div(0, 0)).to.revertedWith('0x12')
    })

    it('reverts', async () => {
      await expect(uFixed6.div(parseBase6('20'), 0)).to.revertedWith('0x12')
    })
  })

  describe('#divOut', async () => {
    it('divs without rounding', async () => {
      expect(await uFixed6.divOut(parseBase6('20'), parseBase6('10'))).to.equal(parseBase6('2'))
    })

    it('divs and rounds up', async () => {
      expect(await uFixed6.divOut(21, parseBase6('10'))).to.equal(3)
    })

    it('divides 0', async () => {
      expect(await uFixed6.divOut(0, parseBase6('10'))).to.equal(0)
    })

    it('reverts', async () => {
      await expect(uFixed6.divOut(0, 0)).to.revertedWith('DivisionByZero()')
    })

    it('reverts', async () => {
      await expect(uFixed6.divOut(parseBase6('20'), 0)).to.revertedWith('DivisionByZero()')
    })
  })

  describe('#unsafeDiv', async () => {
    it('divs', async () => {
      expect(await uFixed6.unsafeDiv(parseBase6('20'), parseBase6('10'))).to.equal(parseBase6('2'))
    })

    it('divs and floors', async () => {
      expect(await uFixed6.unsafeDiv(21, parseBase6('10'))).to.equal(2)
    })

    it('divs (ONE)', async () => {
      expect(await uFixed6.unsafeDiv(0, 0)).to.equal(parseBase6('1'))
    })

    it('divs (MAX)', async () => {
      expect(await uFixed6.unsafeDiv(parseBase6('20'), 0)).to.equal(ethers.constants.MaxUint256)
    })
  })

  describe('#unsafeDivOut', async () => {
    it('divs', async () => {
      expect(await uFixed6.unsafeDivOut(parseBase6('20'), parseBase6('10'))).to.equal(parseBase6('2'))
    })

    it('divs and ceils', async () => {
      expect(await uFixed6.unsafeDivOut(21, parseBase6('10'))).to.equal(3)
    })

    it('divs (ONE)', async () => {
      expect(await uFixed6.unsafeDivOut(0, 0)).to.equal(parseBase6('1'))
    })

    it('divs (MAX)', async () => {
      expect(await uFixed6.unsafeDivOut(parseBase6('20'), 0)).to.equal(ethers.constants.MaxUint256)
    })
  })

  describe('#muldiv', async () => {
    it('muldivs', async () => {
      expect(await uFixed6.muldiv1(parseBase6('20'), parseBase6('10'), parseBase6('2'))).to.equal(parseBase6('100'))
    })

    it('muldivs', async () => {
      expect(await uFixed6.muldiv2(parseBase6('20'), 10, 2)).to.equal(parseBase6('100'))
    })

    it('muldivs (precision)', async () => {
      expect(await uFixed6.muldiv1(parseBase6('1.111111'), parseBase6('0.333333'), parseBase6('0.333333'))).to.equal(
        parseBase6('1.111111'),
      )
    })

    it('muldivs (precision)', async () => {
      expect(await uFixed6.muldiv2(parseBase6('1.111111'), parseBase6('0.333333'), parseBase6('0.333333'))).to.equal(
        parseBase6('1.111111'),
      )
    })

    it('muldivs (rounds down)', async () => {
      expect(await uFixed6.muldiv1(1, 21, 10)).to.equal(2)
      expect(await uFixed6.muldiv2(1, 21, 10)).to.equal(2)
    })

    it('reverts', async () => {
      await expect(uFixed6.muldiv1(parseBase6('20'), parseBase6('10'), parseBase6('0'))).to.revertedWith('0x12')
    })

    it('reverts', async () => {
      await expect(uFixed6.muldiv2(parseBase6('20'), parseBase6('10'), parseBase6('0'))).to.revertedWith('0x12')
    })
  })

  describe('#muldivOut', async () => {
    it('muldivs', async () => {
      expect(await uFixed6.muldivOut1(parseBase6('20'), parseBase6('10'), parseBase6('2'))).to.equal(parseBase6('100'))
    })

    it('muldivs', async () => {
      expect(await uFixed6.muldivOut2(parseBase6('20'), 10, 2)).to.equal(parseBase6('100'))
    })

    it('muldivs (precision)', async () => {
      expect(await uFixed6.muldivOut1(parseBase6('1.111111'), parseBase6('0.333333'), parseBase6('0.333333'))).to.equal(
        parseBase6('1.111111'),
      )
    })

    it('muldivs (precision)', async () => {
      expect(await uFixed6.muldivOut2(parseBase6('1.111111'), parseBase6('0.333333'), parseBase6('0.333333'))).to.equal(
        parseBase6('1.111111'),
      )
    })

    it('muldivs (rounds up)', async () => {
      expect(await uFixed6.muldivOut1(1, 21, 10)).to.equal(3)
      expect(await uFixed6.muldivOut2(1, 21, 10)).to.equal(3)
    })

    it('reverts', async () => {
      await expect(uFixed6.muldivOut1(parseBase6('20'), parseBase6('10'), parseBase6('0'))).to.revertedWith(
        'DivisionByZero()',
      )
    })

    it('reverts', async () => {
      await expect(uFixed6.muldivOut2(parseBase6('20'), parseBase6('10'), parseBase6('0'))).to.revertedWith(
        'DivisionByZero()',
      )
    })
  })

  describe('#eq', async () => {
    it('returns true', async () => {
      expect(await uFixed6.eq(12, 12)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await uFixed6.eq(11, 12)).to.equal(false)
    })
  })

  describe('#gt', async () => {
    it('returns true', async () => {
      expect(await uFixed6.gt(13, 12)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await uFixed6.gt(12, 12)).to.equal(false)
    })

    it('returns false', async () => {
      expect(await uFixed6.gt(11, 12)).to.equal(false)
    })
  })

  describe('#lt', async () => {
    it('returns false', async () => {
      expect(await uFixed6.lt(13, 12)).to.equal(false)
    })

    it('returns false', async () => {
      expect(await uFixed6.lt(12, 12)).to.equal(false)
    })

    it('returns true', async () => {
      expect(await uFixed6.lt(11, 12)).to.equal(true)
    })
  })

  describe('#gte', async () => {
    it('returns true', async () => {
      expect(await uFixed6.gte(13, 12)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await uFixed6.gte(12, 12)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await uFixed6.gte(11, 12)).to.equal(false)
    })
  })

  describe('#lte', async () => {
    it('returns false', async () => {
      expect(await uFixed6.lte(13, 12)).to.equal(false)
    })

    it('returns true', async () => {
      expect(await uFixed6.lte(12, 12)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await uFixed6.lte(11, 12)).to.equal(true)
    })
  })

  describe('#compare', async () => {
    it('is positive', async () => {
      expect(await uFixed6.compare(13, 12)).to.equal(2)
    })

    it('is zero', async () => {
      expect(await uFixed6.compare(12, 12)).to.equal(1)
    })

    it('is negative', async () => {
      expect(await uFixed6.compare(11, 12)).to.equal(0)
    })
  })

  describe('#ratio', async () => {
    it('returns ratio', async () => {
      expect(await uFixed6.ratio(2000, 100)).to.equal(parseBase6('20'))
    })
  })

  describe('#min', async () => {
    it('returns min', async () => {
      expect(await uFixed6.min(2000, 100)).to.equal(100)
    })

    it('returns min', async () => {
      expect(await uFixed6.min(100, 2000)).to.equal(100)
    })
  })

  describe('#max', async () => {
    it('returns max', async () => {
      expect(await uFixed6.max(2000, 100)).to.equal(2000)
    })

    it('returns max', async () => {
      expect(await uFixed6.max(100, 2000)).to.equal(2000)
    })
  })

  describe('#truncate', async () => {
    it('returns floor', async () => {
      expect(await uFixed6.truncate(parseBase6('123.456'))).to.equal(123)
    })
  })

  describe('#store(UFixed6)', async () => {
    it('sets value', async () => {
      await uFixed6.store(SLOT, 12)
      expect(await uFixed6.read(SLOT)).to.equal(12)
    })
  })
})
