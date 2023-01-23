import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockUFixed18, MockUFixed18__factory } from '../../../types/generated'

const { ethers } = HRE

const SLOT = ethers.utils.keccak256(Buffer.from('equilibria.root.UFixed18.testSlot'))

describe('UFixed18', () => {
  let user: SignerWithAddress
  let uFixed18: MockUFixed18

  beforeEach(async () => {
    ;[user] = await ethers.getSigners()
    uFixed18 = await new MockUFixed18__factory(user).deploy()
  })

  describe('#ZERO', async () => {
    it('returns zero', async () => {
      expect(await uFixed18.ZERO()).to.equal(0)
    })
  })

  describe('#ONE', async () => {
    it('returns one', async () => {
      expect(await uFixed18.ONE()).to.equal(utils.parseEther('1'))
    })
  })

  describe('#MAX', async () => {
    it('returns max', async () => {
      expect(await uFixed18.MAX()).to.equal(ethers.constants.MaxUint256)
    })
  })

  describe('#from(uint256)', async () => {
    it('creates new', async () => {
      expect(await uFixed18['from(uint256)'](10)).to.equal(utils.parseEther('10'))
    })
  })

  describe('#from(Fixed18)', async () => {
    it('creates positive', async () => {
      expect(await uFixed18['from(int256)'](utils.parseEther('10'))).to.equal(utils.parseEther('10'))
    })

    it('reverts if negative', async () => {
      await expect(uFixed18['from(int256)'](utils.parseEther('-10'))).to.be.revertedWith(
        `UFixed18UnderflowError(${utils.parseEther('-10')})`,
      )
    })
  })

  describe('#from(UFixed6)', async () => {
    it('creates new', async () => {
      expect(await uFixed18.fromUFixed6(utils.parseUnits('10', 6))).to.equal(utils.parseEther('10'))
    })

    it('reverts if too large', async () => {
      const TOO_LARGE = ethers.constants.MaxUint256.sub(10)
      await expect(uFixed18.fromUFixed6(TOO_LARGE)).to.be.reverted
    })
  })

  describe('#pack', async () => {
    it('creates new', async () => {
      expect(await uFixed18.pack(utils.parseEther('10'))).to.equal(utils.parseEther('10'))
    })

    it('reverts if too large', async () => {
      const TOO_LARGE = ethers.constants.MaxUint256
      await expect(uFixed18.pack(TOO_LARGE)).to.be.revertedWith(`UFixed18PackingOverflowError(${TOO_LARGE})`)
    })
  })

  describe('#isZero', async () => {
    it('returns true', async () => {
      expect(await uFixed18.isZero(0)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await uFixed18.isZero(1)).to.equal(false)
    })
  })

  describe('#add', async () => {
    it('adds', async () => {
      expect(await uFixed18.add(10, 20)).to.equal(30)
    })
  })

  describe('#sub', async () => {
    it('subs', async () => {
      expect(await uFixed18.sub(20, 10)).to.equal(10)
    })
  })

  describe('#mul', async () => {
    it('muls', async () => {
      expect(await uFixed18.mul(utils.parseEther('20'), utils.parseEther('10'))).to.equal(utils.parseEther('200'))
    })

    it('muls and rounds down', async () => {
      expect(await uFixed18.mul(1, 2)).to.equal(0)
    })
  })

  describe('#mulOut', async () => {
    it('muls without rounding', async () => {
      expect(await uFixed18.mul(utils.parseEther('20'), utils.parseEther('10'))).to.equal(utils.parseEther('200'))
    })

    it('muls and rounds up', async () => {
      expect(await uFixed18.mulOut(1, 2)).to.equal(1)
    })
  })

  describe('#div', async () => {
    it('divs', async () => {
      expect(await uFixed18.div(utils.parseEther('20'), utils.parseEther('10'))).to.equal(utils.parseEther('2'))
    })

    it('divs and floors', async () => {
      expect(await uFixed18.div(21, utils.parseEther('10'))).to.equal(2)
    })

    it('reverts', async () => {
      await expect(uFixed18.div(0, 0)).to.revertedWith('0x12')
    })

    it('reverts', async () => {
      await expect(uFixed18.div(utils.parseEther('20'), 0)).to.revertedWith('0x12')
    })
  })

  describe('#divOut', async () => {
    it('divs without rounding', async () => {
      expect(await uFixed18.divOut(utils.parseEther('20'), utils.parseEther('10'))).to.equal(utils.parseEther('2'))
    })

    it('divs and rounds up', async () => {
      expect(await uFixed18.divOut(21, utils.parseEther('10'))).to.equal(3)
    })

    it('divides 0', async () => {
      expect(await uFixed18.divOut(0, utils.parseEther('10'))).to.equal(0)
    })

    it('reverts', async () => {
      await expect(uFixed18.divOut(0, 0)).to.revertedWith('DivisionByZero()')
    })

    it('reverts', async () => {
      await expect(uFixed18.divOut(utils.parseEther('20'), 0)).to.revertedWith('DivisionByZero()')
    })
  })

  describe('#unsafeDiv', async () => {
    it('divs', async () => {
      expect(await uFixed18.unsafeDiv(utils.parseEther('20'), utils.parseEther('10'))).to.equal(utils.parseEther('2'))
    })

    it('divs and floors', async () => {
      expect(await uFixed18.unsafeDiv(21, utils.parseEther('10'))).to.equal(2)
    })

    it('divs (ONE)', async () => {
      expect(await uFixed18.unsafeDiv(0, 0)).to.equal(utils.parseEther('1'))
    })

    it('divs (MAX)', async () => {
      expect(await uFixed18.unsafeDiv(utils.parseEther('20'), 0)).to.equal(ethers.constants.MaxUint256)
    })
  })

  describe('#unsafeDivOut', async () => {
    it('divs', async () => {
      expect(await uFixed18.unsafeDivOut(utils.parseEther('20'), utils.parseEther('10'))).to.equal(
        utils.parseEther('2'),
      )
    })

    it('divs and ceils', async () => {
      expect(await uFixed18.unsafeDivOut(21, utils.parseEther('10'))).to.equal(3)
    })

    it('divs (ONE)', async () => {
      expect(await uFixed18.unsafeDivOut(0, 0)).to.equal(utils.parseEther('1'))
    })

    it('divs (MAX)', async () => {
      expect(await uFixed18.unsafeDivOut(utils.parseEther('20'), 0)).to.equal(ethers.constants.MaxUint256)
    })
  })

  describe('#muldiv', async () => {
    it('muldivs', async () => {
      expect(await uFixed18.muldiv1(utils.parseEther('20'), utils.parseEther('10'), utils.parseEther('2'))).to.equal(
        utils.parseEther('100'),
      )
    })

    it('muldivs', async () => {
      expect(await uFixed18.muldiv2(utils.parseEther('20'), 10, 2)).to.equal(utils.parseEther('100'))
    })

    it('muldivs (precision)', async () => {
      expect(
        await uFixed18.muldiv1(
          utils.parseEther('1.111111111111111111'),
          utils.parseEther('0.333333333333333333'),
          utils.parseEther('0.333333333333333333'),
        ),
      ).to.equal(utils.parseEther('1.111111111111111111'))
    })

    it('muldivs (precision)', async () => {
      expect(
        await uFixed18.muldiv2(
          utils.parseEther('1.111111111111111111'),
          utils.parseEther('0.333333333333333333'),
          utils.parseEther('0.333333333333333333'),
        ),
      ).to.equal(utils.parseEther('1.111111111111111111'))
    })

    it('muldivs (rounds down)', async () => {
      expect(await uFixed18.muldiv1(1, 21, 10)).to.equal(2)
      expect(await uFixed18.muldiv2(1, 21, 10)).to.equal(2)
    })

    it('reverts', async () => {
      await expect(
        uFixed18.muldiv1(utils.parseEther('20'), utils.parseEther('10'), utils.parseEther('0')),
      ).to.revertedWith('0x12')
    })

    it('reverts', async () => {
      await expect(
        uFixed18.muldiv2(utils.parseEther('20'), utils.parseEther('10'), utils.parseEther('0')),
      ).to.revertedWith('0x12')
    })
  })

  describe('#muldivOut', async () => {
    it('muldivs', async () => {
      expect(await uFixed18.muldivOut1(utils.parseEther('20'), utils.parseEther('10'), utils.parseEther('2'))).to.equal(
        utils.parseEther('100'),
      )
    })

    it('muldivs', async () => {
      expect(await uFixed18.muldivOut2(utils.parseEther('20'), 10, 2)).to.equal(utils.parseEther('100'))
    })

    it('muldivs (precision)', async () => {
      expect(
        await uFixed18.muldivOut1(
          utils.parseEther('1.111111111111111111'),
          utils.parseEther('0.333333333333333333'),
          utils.parseEther('0.333333333333333333'),
        ),
      ).to.equal(utils.parseEther('1.111111111111111111'))
    })

    it('muldivs (precision)', async () => {
      expect(
        await uFixed18.muldivOut2(
          utils.parseEther('1.111111111111111111'),
          utils.parseEther('0.333333333333333333'),
          utils.parseEther('0.333333333333333333'),
        ),
      ).to.equal(utils.parseEther('1.111111111111111111'))
    })

    it('muldivs (rounds up)', async () => {
      expect(await uFixed18.muldivOut1(1, 21, 10)).to.equal(3)
      expect(await uFixed18.muldivOut2(1, 21, 10)).to.equal(3)
    })

    it('reverts', async () => {
      await expect(
        uFixed18.muldivOut1(utils.parseEther('20'), utils.parseEther('10'), utils.parseEther('0')),
      ).to.revertedWith('DivisionByZero()')
    })

    it('reverts', async () => {
      await expect(
        uFixed18.muldivOut2(utils.parseEther('20'), utils.parseEther('10'), utils.parseEther('0')),
      ).to.revertedWith('DivisionByZero()')
    })
  })

  describe('#eq', async () => {
    it('returns true', async () => {
      expect(await uFixed18.eq(12, 12)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await uFixed18.eq(11, 12)).to.equal(false)
    })
  })

  describe('#gt', async () => {
    it('returns true', async () => {
      expect(await uFixed18.gt(13, 12)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await uFixed18.gt(12, 12)).to.equal(false)
    })

    it('returns false', async () => {
      expect(await uFixed18.gt(11, 12)).to.equal(false)
    })
  })

  describe('#lt', async () => {
    it('returns false', async () => {
      expect(await uFixed18.lt(13, 12)).to.equal(false)
    })

    it('returns false', async () => {
      expect(await uFixed18.lt(12, 12)).to.equal(false)
    })

    it('returns true', async () => {
      expect(await uFixed18.lt(11, 12)).to.equal(true)
    })
  })

  describe('#gte', async () => {
    it('returns true', async () => {
      expect(await uFixed18.gte(13, 12)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await uFixed18.gte(12, 12)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await uFixed18.gte(11, 12)).to.equal(false)
    })
  })

  describe('#lte', async () => {
    it('returns false', async () => {
      expect(await uFixed18.lte(13, 12)).to.equal(false)
    })

    it('returns true', async () => {
      expect(await uFixed18.lte(12, 12)).to.equal(true)
    })

    it('returns true', async () => {
      expect(await uFixed18.lte(11, 12)).to.equal(true)
    })
  })

  describe('#compare', async () => {
    it('is positive', async () => {
      expect(await uFixed18.compare(13, 12)).to.equal(2)
    })

    it('is zero', async () => {
      expect(await uFixed18.compare(12, 12)).to.equal(1)
    })

    it('is negative', async () => {
      expect(await uFixed18.compare(11, 12)).to.equal(0)
    })
  })

  describe('#ratio', async () => {
    it('returns ratio', async () => {
      expect(await uFixed18.ratio(2000, 100)).to.equal(utils.parseEther('20'))
    })
  })

  describe('#min', async () => {
    it('returns min', async () => {
      expect(await uFixed18.min(2000, 100)).to.equal(100)
    })

    it('returns min', async () => {
      expect(await uFixed18.min(100, 2000)).to.equal(100)
    })
  })

  describe('#max', async () => {
    it('returns max', async () => {
      expect(await uFixed18.max(2000, 100)).to.equal(2000)
    })

    it('returns max', async () => {
      expect(await uFixed18.max(100, 2000)).to.equal(2000)
    })
  })

  describe('#truncate', async () => {
    it('returns floor', async () => {
      expect(await uFixed18.truncate(utils.parseEther('123.456'))).to.equal(123)
    })
  })

  describe('#store(UFixed18)', async () => {
    it('sets value', async () => {
      await uFixed18.store(SLOT, 12)
      expect(await uFixed18.read(SLOT)).to.equal(12)
    })
  })
})
