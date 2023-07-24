import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockFixed6, MockFixed6__factory } from '../../../types/generated'

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
      expect(await fixed6.ONE()).to.equal(utils.parseUnits('1', 6))
    })
  })

  describe('#NEG_ONE', async () => {
    it('returns negative one', async () => {
      expect(await fixed6.NEG_ONE()).to.equal(utils.parseUnits('-1', 6))
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
      expect(await fixed6['from(int256)'](10)).to.equal(utils.parseUnits('10', 6))
    })

    it('reverts if too large', async () => {
      const TOO_LARGE = ethers.constants.MaxInt256.sub(10)
      await expect(fixed6['from(int256)'](TOO_LARGE)).to.be.reverted
    })
  })

  describe('#from(int256,UFixed6)', async () => {
    it('creates positive', async () => {
      expect(await fixed6['from(int256,uint256)'](1, utils.parseUnits('10', 6))).to.equal(utils.parseUnits('10', 6))
    })

    it('creates zero', async () => {
      expect(await fixed6['from(int256,uint256)'](0, utils.parseUnits('10', 6))).to.equal(0)
    })

    it('creates negative', async () => {
      expect(await fixed6['from(int256,uint256)'](-1, utils.parseUnits('10', 6))).to.equal(utils.parseUnits('-10', 6))
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
      expect(await fixed6['from(uint256)'](utils.parseUnits('10', 6))).to.equal(utils.parseUnits('10', 6))
    })

    it('reverts if too large', async () => {
      const TOO_LARGE = ethers.BigNumber.from(2).pow(256).sub(10)
      await expect(fixed6['from(uint256)'](TOO_LARGE)).to.be.revertedWith(`Fixed6OverflowError(${TOO_LARGE})`)
    })
  })

  describe('#from(UFixed18)', async () => {
    it('creates new (no rounding)', async () => {
      expect(await fixed6['fromBase18(int256)'](utils.parseEther('10.1'))).to.equal(utils.parseUnits('10.1', 6))
      expect(await fixed6['fromBase18(int256,bool)'](utils.parseEther('10.1'), true)).to.equal(
        utils.parseUnits('10.1', 6),
      )
      expect(await fixed6['fromBase18(int256,bool)'](utils.parseEther('10.1'), false)).to.equal(
        utils.parseUnits('10.1', 6),
      )

      expect(await fixed6['fromBase18(int256)'](utils.parseEther('-10.1'))).to.equal(utils.parseUnits('-10.1', 6))
      expect(await fixed6['fromBase18(int256,bool)'](utils.parseEther('-10.1'), true)).to.equal(
        utils.parseUnits('-10.1', 6),
      )
      expect(await fixed6['fromBase18(int256,bool)'](utils.parseEther('-10.1'), false)).to.equal(
        utils.parseUnits('-10.1', 6),
      )
    })

    it('creates new (round towards 0 implicit)', async () => {
      expect(await fixed6['fromBase18(int256)'](utils.parseEther('10').add(1))).to.equal(utils.parseUnits('10', 6))
      expect(await fixed6['fromBase18(int256)'](utils.parseEther('-10').sub(1))).to.equal(utils.parseUnits('-10', 6))
    })

    it('creates new (round towards 0 explicit)', async () => {
      expect(await fixed6['fromBase18(int256,bool)'](utils.parseEther('10').add(1), false)).to.equal(
        utils.parseUnits('10', 6),
      )
      expect(await fixed6['fromBase18(int256,bool)'](utils.parseEther('-10').sub(1), false)).to.equal(
        utils.parseUnits('-10', 6),
      )
    })

    it('creates new (round away from 0)', async () => {
      expect(await fixed6['fromBase18(int256,bool)'](utils.parseEther('10').add(1), true)).to.equal(
        utils.parseUnits('10', 6).add(1),
      )
      expect(await fixed6['fromBase18(int256,bool)'](utils.parseEther('-10').sub(1), true)).to.equal(
        utils.parseUnits('-10', 6).sub(1),
      )
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
      expect(await fixed6.mul(utils.parseUnits('20', 6), utils.parseUnits('10', 6))).to.equal(
        utils.parseUnits('200', 6),
      )
      expect(await fixed6.mul(utils.parseUnits('-20', 6), utils.parseUnits('10', 6))).to.equal(
        utils.parseUnits('-200', 6),
      )
      expect(await fixed6.mul(utils.parseUnits('20', 6), utils.parseUnits('-10', 6))).to.equal(
        utils.parseUnits('-200', 6),
      )
      expect(await fixed6.mul(utils.parseUnits('-20', 6), utils.parseUnits('-10', 6))).to.equal(
        utils.parseUnits('200', 6),
      )
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
      expect(await fixed6.mulOut(utils.parseUnits('20', 6), utils.parseUnits('10', 6))).to.equal(
        utils.parseUnits('200', 6),
      )
      expect(await fixed6.mulOut(utils.parseUnits('-20', 6), utils.parseUnits('10', 6))).to.equal(
        utils.parseUnits('-200', 6),
      )
      expect(await fixed6.mulOut(utils.parseUnits('20', 6), utils.parseUnits('-10', 6))).to.equal(
        utils.parseUnits('-200', 6),
      )
      expect(await fixed6.mulOut(utils.parseUnits('-20', 6), utils.parseUnits('-10', 6))).to.equal(
        utils.parseUnits('200', 6),
      )
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
      expect(await fixed6.div(utils.parseUnits('20', 6), utils.parseUnits('10', 6))).to.equal(utils.parseUnits('2', 6))
    })

    it('divs', async () => {
      expect(await fixed6.div(utils.parseUnits('-20', 6), utils.parseUnits('-10', 6))).to.equal(
        utils.parseUnits('2', 6),
      )
    })

    it('divs and rounds towards zero', async () => {
      expect(await fixed6.div(21, utils.parseUnits('10', 6))).to.equal(2)
      expect(await fixed6.div(-21, utils.parseUnits('10', 6))).to.equal(-2)
    })

    it('reverts', async () => {
      await expect(fixed6.div(0, 0)).to.revertedWith('0x12')
    })

    it('reverts', async () => {
      await expect(fixed6.div(utils.parseUnits('20', 6), 0)).to.revertedWith('0x12')
    })

    it('reverts', async () => {
      await expect(fixed6.div(utils.parseUnits('-20', 6), 0)).to.revertedWith('0x12')
    })
  })

  describe('#divOut', async () => {
    it('divs without rounding', async () => {
      expect(await fixed6.divOut(utils.parseUnits('20', 6), utils.parseUnits('10', 6))).to.equal(
        utils.parseUnits('2', 6),
      )
      expect(await fixed6.divOut(utils.parseUnits('-20', 6), utils.parseUnits('-10', 6))).to.equal(
        utils.parseUnits('2', 6),
      )
      expect(await fixed6.divOut(utils.parseUnits('20', 6), utils.parseUnits('-10', 6))).to.equal(
        utils.parseUnits('-2', 6),
      )
      expect(await fixed6.divOut(utils.parseUnits('-20', 6), utils.parseUnits('10', 6))).to.equal(
        utils.parseUnits('-2', 6),
      )
    })

    it('divs and rounds away from zero', async () => {
      expect(await fixed6.divOut(21, utils.parseUnits('10', 6))).to.equal(3)
      expect(await fixed6.divOut(-21, utils.parseUnits('10', 6))).to.equal(-3)
      expect(await fixed6.divOut(21, utils.parseUnits('-10', 6))).to.equal(-3)
      expect(await fixed6.divOut(-21, utils.parseUnits('-10', 6))).to.equal(3)
    })

    it('reverts', async () => {
      await expect(fixed6.divOut(0, 0)).to.revertedWith('DivisionByZero()')
    })

    it('reverts', async () => {
      await expect(fixed6.divOut(utils.parseUnits('20', 6), 0)).to.revertedWith('DivisionByZero()')
    })

    it('reverts', async () => {
      await expect(fixed6.divOut(utils.parseUnits('-20', 6), 0)).to.revertedWith('DivisionByZero()')
    })
  })

  describe('#unsafeDiv', async () => {
    it('divs', async () => {
      expect(await fixed6.unsafeDiv(utils.parseUnits('20', 6), utils.parseUnits('10', 6))).to.equal(
        utils.parseUnits('2', 6),
      )
    })

    it('divs', async () => {
      expect(await fixed6.unsafeDiv(utils.parseUnits('-20', 6), utils.parseUnits('-10', 6))).to.equal(
        utils.parseUnits('2', 6),
      )
    })

    it('divs and floors', async () => {
      expect(await fixed6.unsafeDiv(21, utils.parseUnits('10', 6))).to.equal(2)
    })

    it('divs (ONE)', async () => {
      expect(await fixed6.unsafeDiv(0, 0)).to.equal(utils.parseUnits('1', 6))
    })

    it('divs (MAX)', async () => {
      expect(await fixed6.unsafeDiv(utils.parseUnits('20', 6), 0)).to.equal(ethers.constants.MaxInt256)
    })

    it('divs (MIN)', async () => {
      expect(await fixed6.unsafeDiv(utils.parseUnits('-20', 6), 0)).to.equal(ethers.constants.MinInt256)
    })
  })

  describe('#unsafeDivOut', async () => {
    it('divs', async () => {
      expect(await fixed6.unsafeDivOut(utils.parseUnits('20', 6), utils.parseUnits('10', 6))).to.equal(
        utils.parseUnits('2', 6),
      )
    })

    it('divs', async () => {
      expect(await fixed6.unsafeDivOut(utils.parseUnits('-20', 6), utils.parseUnits('-10', 6))).to.equal(
        utils.parseUnits('2', 6),
      )
    })

    it('divs and ceils', async () => {
      expect(await fixed6.unsafeDivOut(21, utils.parseUnits('10', 6))).to.equal(3)
    })

    it('divs (ONE)', async () => {
      expect(await fixed6.unsafeDivOut(0, 0)).to.equal(utils.parseUnits('1', 6))
    })

    it('divs (MAX)', async () => {
      expect(await fixed6.unsafeDivOut(utils.parseUnits('20', 6), 0)).to.equal(ethers.constants.MaxInt256)
    })

    it('divs (MIN)', async () => {
      expect(await fixed6.unsafeDivOut(utils.parseUnits('-20', 6), 0)).to.equal(ethers.constants.MinInt256)
    })
  })

  describe('#muldiv', async () => {
    it('muldivs', async () => {
      expect(
        await fixed6.muldiv1(utils.parseUnits('20', 6), utils.parseUnits('10', 6), utils.parseUnits('2', 6)),
      ).to.equal(utils.parseUnits('100', 6))
    })

    it('muldivs', async () => {
      expect(await fixed6.muldiv2(utils.parseUnits('20', 6), 10, 2)).to.equal(utils.parseUnits('100', 6))
    })

    it('muldivs', async () => {
      expect(
        await fixed6.muldiv1(utils.parseUnits('-20', 6), utils.parseUnits('10', 6), utils.parseUnits('2', 6)),
      ).to.equal(utils.parseUnits('-100', 6))
    })

    it('muldivs', async () => {
      expect(await fixed6.muldiv2(utils.parseUnits('-20', 6), 10, 2)).to.equal(utils.parseUnits('-100', 6))
    })

    it('muldivs (precision)', async () => {
      expect(
        await fixed6.muldiv1(
          utils.parseUnits('1.111111', 6),
          utils.parseUnits('0.333333', 6),
          utils.parseUnits('0.333333', 6),
        ),
      ).to.equal(utils.parseUnits('1.111111', 6))
    })

    it('muldivs (precision)', async () => {
      expect(
        await fixed6.muldiv2(
          utils.parseUnits('1.111111', 6),
          utils.parseUnits('0.333333', 6),
          utils.parseUnits('0.333333', 6),
        ),
      ).to.equal(utils.parseUnits('1.111111', 6))
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
      await expect(
        fixed6.muldiv1(utils.parseUnits('20', 6), utils.parseUnits('10', 6), utils.parseUnits('0', 6)),
      ).to.revertedWith('0x12')
    })

    it('reverts', async () => {
      await expect(
        fixed6.muldiv2(utils.parseUnits('20', 6), utils.parseUnits('10', 6), utils.parseUnits('0', 6)),
      ).to.revertedWith('0x12')
    })
  })

  describe('#muldivOut', async () => {
    it('muldivs', async () => {
      expect(
        await fixed6.muldivOut1(utils.parseUnits('20', 6), utils.parseUnits('10', 6), utils.parseUnits('2', 6)),
      ).to.equal(utils.parseUnits('100', 6))
    })

    it('muldivs', async () => {
      expect(await fixed6.muldivOut2(utils.parseUnits('20', 6), 10, 2)).to.equal(utils.parseUnits('100', 6))
    })

    it('muldivs', async () => {
      expect(
        await fixed6.muldivOut1(utils.parseUnits('-20', 6), utils.parseUnits('10', 6), utils.parseUnits('2', 6)),
      ).to.equal(utils.parseUnits('-100', 6))
    })

    it('muldivs', async () => {
      expect(await fixed6.muldivOut2(utils.parseUnits('-20', 6), 10, 2)).to.equal(utils.parseUnits('-100', 6))
    })

    it('muldivs (precision)', async () => {
      expect(
        await fixed6.muldivOut1(
          utils.parseUnits('1.111111', 6),
          utils.parseUnits('0.333333', 6),
          utils.parseUnits('0.333333', 6),
        ),
      ).to.equal(utils.parseUnits('1.111111', 6))
    })

    it('muldivs (precision)', async () => {
      expect(
        await fixed6.muldivOut2(
          utils.parseUnits('1.111111', 6),
          utils.parseUnits('0.333333', 6),
          utils.parseUnits('0.333333', 6),
        ),
      ).to.equal(utils.parseUnits('1.111111', 6))
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
      await expect(
        fixed6.muldivOut1(utils.parseUnits('20', 6), utils.parseUnits('10', 6), utils.parseUnits('0', 6)),
      ).to.revertedWith('DivisionByZero()')
    })

    it('reverts', async () => {
      await expect(
        fixed6.muldivOut2(utils.parseUnits('20', 6), utils.parseUnits('10', 6), utils.parseUnits('0', 6)),
      ).to.revertedWith('DivisionByZero()')
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
      expect(await fixed6.ratio(2000, 100)).to.equal(utils.parseUnits('20', 6))
    })

    it('returns ratio', async () => {
      expect(await fixed6.ratio(-2000, -100)).to.equal(utils.parseUnits('20', 6))
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
      expect(await fixed6.truncate(utils.parseUnits('123.456', 6))).to.equal(123)
    })

    it('returns floor', async () => {
      expect(await fixed6.truncate(utils.parseUnits('-123.456', 6))).to.equal(-123)
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
