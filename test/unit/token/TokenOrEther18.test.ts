import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
import { expect } from 'chai'
import HRE, { waffle } from 'hardhat'

import { IERC20Metadata__factory, MockTokenOrEther18, MockTokenOrEther18__factory } from '../../../types/generated'
import { MockContract } from '@ethereum-waffle/mock-contract'

const { ethers } = HRE

const ETHER = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE'
const SLOT = ethers.utils.keccak256(Buffer.from('equilibria.root.Token.testSlot'))

describe('TokenOrEther18', () => {
  let user: SignerWithAddress
  let recipient: SignerWithAddress
  let tokenOrEther18: MockTokenOrEther18
  let erc20: MockContract

  beforeEach(async () => {
    ;[user, recipient] = await ethers.getSigners()
    tokenOrEther18 = await new MockTokenOrEther18__factory(user).deploy()
    erc20 = await waffle.deployMockContract(user, IERC20Metadata__factory.abi)
  })

  describe('#zero', async () => {
    it('returns zero', async () => {
      expect(await tokenOrEther18.zero()).to.equal(ethers.constants.AddressZero)
    })
  })

  describe('#ether', async () => {
    it('returns ether', async () => {
      expect(await tokenOrEther18.etherToken()).to.equal(ETHER)
    })
  })

  describe('#isZero', async () => {
    it('returns true', async () => {
      expect(await tokenOrEther18.isZero(ethers.constants.AddressZero)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await tokenOrEther18.isZero(ETHER)).to.equal(false)
    })
  })

  describe('#isEther', async () => {
    it('returns true', async () => {
      expect(await tokenOrEther18.isEther(ETHER)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await tokenOrEther18.isEther(erc20.address)).to.equal(false)
    })
  })

  describe('#eq', async () => {
    it('returns true', async () => {
      expect(await tokenOrEther18.eq(erc20.address, erc20.address)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await tokenOrEther18.eq(erc20.address, ethers.constants.AddressZero)).to.equal(false)
    })
  })

  describe('#approve', async () => {
    it('approves tokens (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.allowance.withArgs(tokenOrEther18.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100')).returns(true)

      await tokenOrEther18
        .connect(user)
        ['approve(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100'))
    })

    it('approves tokens (ether)', async () => {
      await expect(
        tokenOrEther18
          .connect(user)
          ['approve(address,address,uint256)'](ETHER, recipient.address, utils.parseEther('100')),
      ).to.be.revertedWith('TokenOrEther18ApproveEtherError()')
    })

    it('approves tokens (round down implicit) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.allowance.withArgs(tokenOrEther18.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').add(1)).returns(true)

      await tokenOrEther18
        .connect(user)
        ['approve(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100').add(1))
    })

    it('approves tokens (round down implicit) (ether)', async () => {
      await expect(
        tokenOrEther18
          .connect(user)
          ['approve(address,address,uint256)'](ETHER, recipient.address, utils.parseEther('100').add(1)),
      ).to.be.revertedWith('TokenOrEther18ApproveEtherError()')
    })

    it('approves tokens all (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.allowance.withArgs(tokenOrEther18.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, ethers.constants.MaxUint256).returns(true)

      await tokenOrEther18.connect(user)['approve(address,address)'](erc20.address, recipient.address)
    })

    it('approves tokens all (ether)', async () => {
      await expect(
        tokenOrEther18.connect(user)['approve(address,address)'](ETHER, recipient.address),
      ).to.be.revertedWith('TokenOrEther18ApproveEtherError()')
    })

    describe('with prior allowance', () => {
      beforeEach(async () => {
        await erc20.mock.allowance.withArgs(tokenOrEther18.address, recipient.address).returns(utils.parseEther('1'))
      })

      it('reverts when approving for a specific amount', async () => {
        await expect(
          tokenOrEther18
            .connect(user)
            ['approve(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100')),
        ).to.be.reverted
      })

      it('approves tokens all', async () => {
        await erc20.mock.approve.withArgs(recipient.address, ethers.constants.MaxUint256).returns(true)

        await tokenOrEther18.connect(user)['approve(address,address)'](erc20.address, recipient.address)
      })
    })
  })

  describe('#push', async () => {
    it('transfers tokens (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100')).returns(true)

      await tokenOrEther18
        .connect(user)
        ['push(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100'))
    })

    it('transfers tokens (ether)', async () => {
      const recipientBefore = await recipient.getBalance()
      await user.sendTransaction({ to: tokenOrEther18.address, value: ethers.utils.parseEther('100') })
      await tokenOrEther18
        .connect(user)
        ['push(address,address,uint256)'](ETHER, recipient.address, utils.parseEther('100'))
      expect(await recipient.getBalance()).to.equal(recipientBefore.add(ethers.utils.parseEther('100')))
    })

    it('transfers tokens (round down implicit) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').add(1)).returns(true)

      await tokenOrEther18
        .connect(user)
        ['push(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100').add(1))
    })

    it('transfers tokens (round down implicit) (ether)', async () => {
      const recipientBefore = await recipient.getBalance()
      await user.sendTransaction({ to: tokenOrEther18.address, value: ethers.utils.parseEther('100').add(1) })
      await tokenOrEther18
        .connect(user)
        ['push(address,address,uint256)'](ETHER, recipient.address, utils.parseEther('100').add(1))
      expect(await recipient.getBalance()).to.equal(recipientBefore.add(ethers.utils.parseEther('100').add(1)))
    })

    it('transfers tokens all (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.balanceOf.withArgs(tokenOrEther18.address).returns(utils.parseEther('100'))
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100')).returns(true)

      await tokenOrEther18.connect(user)['push(address,address)'](erc20.address, recipient.address)
    })

    it('transfers tokens all (ether)', async () => {
      const recipientBefore = await recipient.getBalance()
      await user.sendTransaction({ to: tokenOrEther18.address, value: ethers.utils.parseEther('100') })
      await tokenOrEther18.connect(user)['push(address,address)'](ETHER, recipient.address)
      expect(await recipient.getBalance()).to.equal(recipientBefore.add(ethers.utils.parseEther('100')))
    })
  })

  describe('#pull', async () => {
    it('transfers tokens (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom
        .withArgs(user.address, tokenOrEther18.address, utils.parseEther('100'))
        .returns(true)

      await tokenOrEther18.connect(user).pull(erc20.address, user.address, utils.parseEther('100'))
    })

    it('transfers tokens (ether)', async () => {
      await expect(tokenOrEther18.connect(user).pull(ETHER, user.address, utils.parseEther('100'))).to.be.revertedWith(
        'TokenOrEther18PullEtherError()',
      )
    })

    it('transfers tokens (round down implicit) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom
        .withArgs(user.address, tokenOrEther18.address, utils.parseEther('100').add(1))
        .returns(true)

      await tokenOrEther18.connect(user).pull(erc20.address, user.address, utils.parseEther('100').add(1))
    })

    it('transfers tokens (round down implicit) (ether)', async () => {
      await expect(
        tokenOrEther18.connect(user).pull(ETHER, user.address, utils.parseEther('100').add(1)),
      ).to.be.revertedWith('TokenOrEther18PullEtherError()')
    })
  })

  describe('#pullTo', async () => {
    it('transfers tokens (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom.withArgs(user.address, recipient.address, utils.parseEther('100')).returns(true)

      await tokenOrEther18.connect(user).pullTo(erc20.address, user.address, recipient.address, utils.parseEther('100'))
    })

    it('transfers tokens (ether)', async () => {
      await expect(
        tokenOrEther18.connect(user).pullTo(ETHER, user.address, recipient.address, utils.parseEther('100')),
      ).to.be.revertedWith('TokenOrEther18PullEtherError()')
    })

    it('transfers tokens (round down implicit) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').add(1))
        .returns(true)

      await tokenOrEther18
        .connect(user)
        .pullTo(erc20.address, user.address, recipient.address, utils.parseEther('100').add(1))
    })

    it('transfers tokens (round down implicit) (ether)', async () => {
      await expect(
        tokenOrEther18.connect(user).pullTo(ETHER, user.address, recipient.address, utils.parseEther('100').add(1)),
      ).to.be.revertedWith('TokenOrEther18PullEtherError()')
    })
  })

  describe('#name', async () => {
    it('returns name', async () => {
      await erc20.mock.name.withArgs().returns('Token Name')
      expect(await tokenOrEther18.connect(user).name(erc20.address)).to.equal('Token Name')
    })

    it('returns name (ether)', async () => {
      expect(await tokenOrEther18.connect(user).name(ETHER)).to.equal('Ether')
    })
  })

  describe('#symbol', async () => {
    it('returns symbol', async () => {
      await erc20.mock.symbol.withArgs().returns('TN')
      expect(await tokenOrEther18.connect(user).symbol(erc20.address)).to.equal('TN')
    })

    it('returns symbol (ether)', async () => {
      expect(await tokenOrEther18.connect(user).symbol(ETHER)).to.equal('ETH')
    })
  })

  describe('#balanceOf', async () => {
    it('returns balanceOf (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.balanceOf.withArgs(user.address).returns(utils.parseEther('100'))
      expect(await tokenOrEther18.connect(user)['balanceOf(address,address)'](erc20.address, user.address)).to.equal(
        utils.parseEther('100'),
      )
    })

    it('returns balanceOf (ether)', async () => {
      expect(await tokenOrEther18.connect(user)['balanceOf(address,address)'](ETHER, tokenOrEther18.address)).to.equal(
        utils.parseEther('0'),
      )
      await user.sendTransaction({ to: tokenOrEther18.address, value: ethers.utils.parseEther('100') })
      expect(await tokenOrEther18.connect(user)['balanceOf(address,address)'](ETHER, tokenOrEther18.address)).to.equal(
        utils.parseEther('100'),
      )
    })
  })

  describe('#balanceOf', async () => {
    it('returns balanceOf (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.balanceOf.withArgs(tokenOrEther18.address).returns(utils.parseEther('100'))
      expect(await tokenOrEther18.connect(user)['balanceOf(address)'](erc20.address)).to.equal(utils.parseEther('100'))
    })

    it('returns balanceOf (ether)', async () => {
      await user.sendTransaction({ to: tokenOrEther18.address, value: ethers.utils.parseEther('100') })
      expect(await tokenOrEther18.connect(user)['balanceOf(address)'](ETHER)).to.equal(utils.parseEther('100'))
    })
  })

  describe('#store(Token)', async () => {
    it('sets value', async () => {
      await tokenOrEther18.store(SLOT, erc20.address)
      expect(await tokenOrEther18.read(SLOT)).to.equal(erc20.address)
    })
  })
})
