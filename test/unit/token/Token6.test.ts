import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockERC20, MockToken6, MockToken6__factory } from '../../../types/generated'
import { FakeContract, smock } from '@defi-wonderland/smock'

const { ethers } = HRE

const SLOT = ethers.utils.keccak256(Buffer.from('equilibria.root.Token6.testSlot'))

describe('Token6', () => {
  let user: SignerWithAddress
  let recipient: SignerWithAddress
  let token6: MockToken6
  let erc20: FakeContract<MockERC20>

  beforeEach(async () => {
    ;[user, recipient] = await ethers.getSigners()
    token6 = await new MockToken6__factory(user).deploy()
    erc20 = await smock.fake<MockERC20>('MockERC20')
  })

  describe('#zero', async () => {
    it('returns zero', async () => {
      expect(await token6.zero()).to.equal(ethers.constants.AddressZero)
    })
  })

  describe('#isZero', async () => {
    it('returns true', async () => {
      expect(await token6.isZero(ethers.constants.AddressZero)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await token6.isZero(erc20.address)).to.equal(false)
    })
  })

  describe('#eq', async () => {
    it('returns true', async () => {
      expect(await token6.eq(erc20.address, erc20.address)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await token6.eq(erc20.address, ethers.constants.AddressZero)).to.equal(false)
    })
  })

  describe('#approve', async () => {
    it('approves tokens', async () => {
      await erc20.allowance.whenCalledWith(token6.address, recipient.address).returns(0)
      await erc20.approve.whenCalledWith(recipient.address, utils.parseUnits('100', 6)).returns(true)

      await token6
        .connect(user)
        ['approve(address,address,uint256)'](erc20.address, recipient.address, utils.parseUnits('100', 6))
    })

    it('approves tokens all', async () => {
      await erc20.allowance.whenCalledWith(token6.address, recipient.address).returns(0)
      await erc20.approve.whenCalledWith(recipient.address, ethers.constants.MaxUint256).returns(true)

      await token6.connect(user)['approve(address,address)'](erc20.address, recipient.address)
    })

    describe('with prior allowance', () => {
      beforeEach(async () => {
        await erc20.allowance.whenCalledWith(token6.address, recipient.address).returns(utils.parseUnits('1', 6))
      })

      it('reverts when approving for a specific amount', async () => {
        await expect(
          token6
            .connect(user)
            ['approve(address,address,uint256)'](erc20.address, recipient.address, utils.parseUnits('100', 6)),
        ).to.be.reverted
      })

      it('approves tokens all', async () => {
        await erc20.approve.whenCalledWith(recipient.address, ethers.constants.MaxUint256).returns(true)

        await token6.connect(user)['approve(address,address)'](erc20.address, recipient.address)
      })
    })
  })

  describe('#push', async () => {
    it('transfers tokens', async () => {
      await erc20.transfer.whenCalledWith(recipient.address, utils.parseUnits('100', 6)).returns(true)

      await token6
        .connect(user)
        ['push(address,address,uint256)'](erc20.address, recipient.address, utils.parseUnits('100', 6))
    })

    it('transfers tokens all', async () => {
      await erc20.balanceOf.whenCalledWith(token6.address).returns(utils.parseUnits('100', 6))
      await erc20.transfer.whenCalledWith(recipient.address, utils.parseUnits('100', 6)).returns(true)

      await token6.connect(user)['push(address,address)'](erc20.address, recipient.address)
    })
  })

  describe('#pull', async () => {
    it('transfers tokens', async () => {
      await erc20.transferFrom.whenCalledWith(user.address, token6.address, utils.parseUnits('100', 6)).returns(true)

      await token6.connect(user).pull(erc20.address, user.address, utils.parseUnits('100', 6))
    })
  })

  describe('#pullTo', async () => {
    it('transfers tokens', async () => {
      await erc20.transferFrom.whenCalledWith(user.address, recipient.address, utils.parseUnits('100', 6)).returns(true)

      await token6.connect(user).pullTo(erc20.address, user.address, recipient.address, utils.parseUnits('100', 6))
    })
  })

  describe('#name', async () => {
    it('returns name', async () => {
      await erc20.name.whenCalledWith().returns('Token Name')
      expect(await token6.connect(user).name(erc20.address)).to.equal('Token Name')
    })
  })

  describe('#symbol', async () => {
    it('returns symbol', async () => {
      await erc20.symbol.whenCalledWith().returns('TN')
      expect(await token6.connect(user).symbol(erc20.address)).to.equal('TN')
    })
  })

  describe('#balanceOf', async () => {
    it('returns balance', async () => {
      await erc20.balanceOf.whenCalledWith(user.address).returns(utils.parseUnits('100', 6))
      expect(await token6.connect(user)['balanceOf(address,address)'](erc20.address, user.address)).to.equal(
        utils.parseUnits('100', 6),
      )
    })

    it('returns balance all', async () => {
      await erc20.balanceOf.whenCalledWith(token6.address).returns(utils.parseUnits('100', 6))
      expect(await token6.connect(user)['balanceOf(address)'](erc20.address)).to.equal(utils.parseUnits('100', 6))
    })
  })

  describe('#totalSupply', async () => {
    it('returns total supply', async () => {
      await erc20.totalSupply.whenCalledWith().returns(utils.parseUnits('100', 6))
      expect(await token6.connect(user).totalSupply(erc20.address)).to.equal(utils.parseUnits('100', 6))
    })
  })

  describe('#store(Token6)', async () => {
    it('sets value', async () => {
      await token6.store(SLOT, erc20.address)
      expect(await token6.read(SLOT)).to.equal(erc20.address)
    })
  })
})
