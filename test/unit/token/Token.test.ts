import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
import { expect } from 'chai'
import HRE, { waffle } from 'hardhat'

import { IERC20Metadata__factory, MockToken, MockToken__factory } from '../../../types/generated'
import { MockContract } from '@ethereum-waffle/mock-contract'

const { ethers } = HRE

const ETHER = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE'
const SLOT = ethers.utils.keccak256(Buffer.from('equilibria.root.Token.testSlot'))

describe('Token', () => {
  let user: SignerWithAddress
  let recipient: SignerWithAddress
  let token: MockToken
  let erc20: MockContract

  beforeEach(async () => {
    ;[user, recipient] = await ethers.getSigners()
    token = await new MockToken__factory(user).deploy()
    erc20 = await waffle.deployMockContract(user, IERC20Metadata__factory.abi)
  })

  describe('#ether', async () => {
    it('returns zero', async () => {
      expect(await token.etherToken()).to.equal(ETHER)
    })
  })

  describe('#isEther', async () => {
    it('returns true', async () => {
      expect(await token.isEther(ETHER)).to.equal(true)
    })

    it('returns false', async () => {
      expect(await token.isEther(erc20.address)).to.equal(false)
    })
  })

  describe('#approve', async () => {
    it('approves tokens (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').div(1000000)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100'))
    })

    it('approves tokens (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100')).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100'))
    })

    it('approves tokens (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').mul(1000000)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100'))
    })

    it('approves tokens (ether)', async () => {
      await expect(
        token.connect(user)['approve(address,address,uint256)'](ETHER, recipient.address, utils.parseEther('100')),
      ).to.be.revertedWith('TokenApproveEtherError()')
    })

    it('approves tokens (round down implicit) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').div(1000000)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100').add(1))
    })

    it('approves tokens (round down implicit) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').add(1)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100').add(1))
    })

    it('approves tokens (round down implicit) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').add(1).mul(1000000)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100').add(1))
    })

    it('approves tokens (round down implicit) (ether)', async () => {
      await expect(
        token
          .connect(user)
          ['approve(address,address,uint256)'](ETHER, recipient.address, utils.parseEther('100').add(1)),
      ).to.be.revertedWith('TokenApproveEtherError()')
    })

    it('approves tokens (round down explicit) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').div(1000000)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256,bool)'](
          erc20.address,
          recipient.address,
          utils.parseEther('100').add(1),
          false,
        )
    })

    it('approves tokens (round down explicit) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').add(1)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256,bool)'](
          erc20.address,
          recipient.address,
          utils.parseEther('100').add(1),
          false,
        )
    })

    it('approves tokens (round down explicit) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').add(1).mul(1000000)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256,bool)'](
          erc20.address,
          recipient.address,
          utils.parseEther('100').add(1),
          false,
        )
    })

    it('approves tokens (round down explicit) (ether)', async () => {
      await expect(
        token
          .connect(user)
          ['approve(address,address,uint256,bool)'](ETHER, recipient.address, utils.parseEther('100').add(1), false),
      ).to.be.revertedWith('TokenApproveEtherError()')
    })

    it('approves tokens (round up) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').div(1000000).add(1)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256,bool)'](
          erc20.address,
          recipient.address,
          utils.parseEther('100').add(1),
          true,
        )
    })

    it('approves tokens (round up) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').add(1)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256,bool)'](
          erc20.address,
          recipient.address,
          utils.parseEther('100').add(1),
          true,
        )
    })

    it('approves tokens (round up) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').add(1).mul(1000000)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256,bool)'](
          erc20.address,
          recipient.address,
          utils.parseEther('100').add(1),
          true,
        )
    })

    it('approves tokens (round up) (ether)', async () => {
      await expect(
        token
          .connect(user)
          ['approve(address,address,uint256,bool)'](ETHER, recipient.address, utils.parseEther('100').add(1), true),
      ).to.be.revertedWith('TokenApproveEtherError()')
    })

    it('approves tokens (round up when no decimal) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').div(1000000)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256,bool)'](erc20.address, recipient.address, utils.parseEther('100'), true)
    })

    it('approves tokens (round up when no decimal) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100')).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256,bool)'](erc20.address, recipient.address, utils.parseEther('100'), true)
    })

    it('approves tokens (round up when no decimal) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100').mul(1000000)).returns(true)

      await token
        .connect(user)
        ['approve(address,address,uint256,bool)'](erc20.address, recipient.address, utils.parseEther('100'), true)
    })

    it('approves tokens (round up when no decimal) (ether)', async () => {
      await expect(
        token
          .connect(user)
          ['approve(address,address,uint256,bool)'](ETHER, recipient.address, utils.parseEther('100'), true),
      ).to.be.revertedWith('TokenApproveEtherError()')
    })

    it('approves tokens all (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, ethers.constants.MaxUint256).returns(true)

      await token.connect(user)['approve(address,address)'](erc20.address, recipient.address)
    })

    it('approves tokens all (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, ethers.constants.MaxUint256).returns(true)

      await token.connect(user)['approve(address,address)'](erc20.address, recipient.address)
    })

    it('approves tokens all (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.allowance.withArgs(token.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, ethers.constants.MaxUint256).returns(true)

      await token.connect(user)['approve(address,address)'](erc20.address, recipient.address)
    })

    it('approves tokens all (ether)', async () => {
      await expect(token.connect(user)['approve(address,address)'](ETHER, recipient.address)).to.be.revertedWith(
        'TokenApproveEtherError()',
      )
    })
  })

  describe('#push', async () => {
    it('transfers tokens (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').div(1000000)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100'))
    })

    it('transfers tokens (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100')).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100'))
    })

    it('transfers tokens (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').mul(1000000)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100'))
    })

    it('transfers tokens (ether)', async () => {
      const recipientBefore = await recipient.getBalance()
      await user.sendTransaction({ to: token.address, value: ethers.utils.parseEther('100') })
      await token.connect(user)['push(address,address,uint256)'](ETHER, recipient.address, utils.parseEther('100'))
      expect(await recipient.getBalance()).to.equal(recipientBefore.add(ethers.utils.parseEther('100')))
    })

    it('transfers tokens (round down implicit) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').div(1000000)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100').add(1))
    })

    it('transfers tokens (round down implicit) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').add(1)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100').add(1))
    })

    it('transfers tokens (round down implicit) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').add(1).mul(1000000)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100').add(1))
    })

    it('transfers tokens (round down implicit) (ether)', async () => {
      const recipientBefore = await recipient.getBalance()
      await user.sendTransaction({ to: token.address, value: ethers.utils.parseEther('100').add(1) })
      await token
        .connect(user)
        ['push(address,address,uint256)'](ETHER, recipient.address, utils.parseEther('100').add(1))
      expect(await recipient.getBalance()).to.equal(recipientBefore.add(ethers.utils.parseEther('100').add(1)))
    })

    it('transfers tokens (round down explicit) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').div(1000000)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256,bool)'](erc20.address, recipient.address, utils.parseEther('100').add(1), false)
    })

    it('transfers tokens (round down explicit) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').add(1)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256,bool)'](erc20.address, recipient.address, utils.parseEther('100').add(1), false)
    })

    it('transfers tokens (round down explicit) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').add(1).mul(1000000)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256,bool)'](erc20.address, recipient.address, utils.parseEther('100').add(1), false)
    })

    it('transfers tokens (round down explicit) (ether)', async () => {
      const recipientBefore = await recipient.getBalance()
      await user.sendTransaction({ to: token.address, value: ethers.utils.parseEther('100').add(1) })
      await token
        .connect(user)
        ['push(address,address,uint256,bool)'](ETHER, recipient.address, utils.parseEther('100').add(1), false)
      expect(await recipient.getBalance()).to.equal(recipientBefore.add(ethers.utils.parseEther('100').add(1)))
    })

    it('transfers tokens (round up) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').div(1000000).add(1)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256,bool)'](erc20.address, recipient.address, utils.parseEther('100').add(1), true)
    })

    it('transfers tokens (round up) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').add(1)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256,bool)'](erc20.address, recipient.address, utils.parseEther('100').add(1), true)
    })

    it('transfers tokens (round up) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').add(1).mul(1000000)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256,bool)'](erc20.address, recipient.address, utils.parseEther('100').add(1), true)
    })

    it('transfers tokens (round up) (ether)', async () => {
      const recipientBefore = await recipient.getBalance()
      await user.sendTransaction({ to: token.address, value: ethers.utils.parseEther('100').add(1) })
      await token
        .connect(user)
        ['push(address,address,uint256,bool)'](ETHER, recipient.address, utils.parseEther('100').add(1), true)
      expect(await recipient.getBalance()).to.equal(recipientBefore.add(ethers.utils.parseEther('100').add(1)))
    })

    it('transfers tokens (round up when no decimal) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').div(1000000)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256,bool)'](erc20.address, recipient.address, utils.parseEther('100'), true)
    })

    it('transfers tokens (round up when no decimal) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100')).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256,bool)'](erc20.address, recipient.address, utils.parseEther('100'), true)
    })

    it('transfers tokens (round up when no decimal) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').mul(1000000)).returns(true)

      await token
        .connect(user)
        ['push(address,address,uint256,bool)'](erc20.address, recipient.address, utils.parseEther('100'), true)
    })

    it('transfers tokens (round up when no decimal) (ether)', async () => {
      const recipientBefore = await recipient.getBalance()
      await user.sendTransaction({ to: token.address, value: ethers.utils.parseEther('100') })
      await token
        .connect(user)
        ['push(address,address,uint256,bool)'](ETHER, recipient.address, utils.parseEther('100'), true)
      expect(await recipient.getBalance()).to.equal(recipientBefore.add(ethers.utils.parseEther('100')))
    })

    it('transfers tokens all (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.balanceOf.withArgs(token.address).returns(utils.parseEther('100').div(1000000))
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').div(1000000)).returns(true)

      await token.connect(user)['push(address,address)'](erc20.address, recipient.address)
    })

    it('transfers tokens all (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.balanceOf.withArgs(token.address).returns(utils.parseEther('100'))
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100')).returns(true)

      await token.connect(user)['push(address,address)'](erc20.address, recipient.address)
    })

    it('transfers tokens all (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.balanceOf.withArgs(token.address).returns(utils.parseEther('100').mul(1000000))
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100').mul(1000000)).returns(true)

      await token.connect(user)['push(address,address)'](erc20.address, recipient.address)
    })

    it('transfers tokens all (ether)', async () => {
      const recipientBefore = await recipient.getBalance()
      await user.sendTransaction({ to: token.address, value: ethers.utils.parseEther('100') })
      await token.connect(user)['push(address,address)'](ETHER, recipient.address)
      expect(await recipient.getBalance()).to.equal(recipientBefore.add(ethers.utils.parseEther('100')))
    })
  })

  describe('#pull', async () => {
    it('transfers tokens (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transferFrom
        .withArgs(user.address, token.address, utils.parseEther('100').div(1000000))
        .returns(true)

      await token.connect(user)['pull(address,address,uint256)'](erc20.address, user.address, utils.parseEther('100'))
    })

    it('transfers tokens (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom.withArgs(user.address, token.address, utils.parseEther('100')).returns(true)

      await token.connect(user)['pull(address,address,uint256)'](erc20.address, user.address, utils.parseEther('100'))
    })

    it('transfers tokens (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transferFrom
        .withArgs(user.address, token.address, utils.parseEther('100').mul(1000000))
        .returns(true)

      await token.connect(user)['pull(address,address,uint256)'](erc20.address, user.address, utils.parseEther('100'))
    })

    it('transfers tokens (ether)', async () => {
      await expect(
        token.connect(user)['pull(address,address,uint256)'](ETHER, user.address, utils.parseEther('100')),
      ).to.be.revertedWith('TokenPullEtherError()')
    })

    it('transfers tokens (round down implicit) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transferFrom
        .withArgs(user.address, token.address, utils.parseEther('100').div(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pull(address,address,uint256)'](erc20.address, user.address, utils.parseEther('100').add(1))
    })

    it('transfers tokens (round down implicit) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom.withArgs(user.address, token.address, utils.parseEther('100').add(1)).returns(true)

      await token
        .connect(user)
        ['pull(address,address,uint256)'](erc20.address, user.address, utils.parseEther('100').add(1))
    })

    it('transfers tokens (round down implicit) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transferFrom
        .withArgs(user.address, token.address, utils.parseEther('100').add(1).mul(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pull(address,address,uint256)'](erc20.address, user.address, utils.parseEther('100').add(1))
    })

    it('transfers tokens (round down implicit) (ether)', async () => {
      await expect(
        token.connect(user)['pull(address,address,uint256)'](ETHER, user.address, utils.parseEther('100').add(1)),
      ).to.be.revertedWith('TokenPullEtherError()')
    })

    it('transfers tokens (round down explicit) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transferFrom
        .withArgs(user.address, token.address, utils.parseEther('100').div(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pull(address,address,uint256,bool)'](erc20.address, user.address, utils.parseEther('100').add(1), false)
    })

    it('transfers tokens (round down explicit) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom.withArgs(user.address, token.address, utils.parseEther('100').add(1)).returns(true)

      await token
        .connect(user)
        ['pull(address,address,uint256,bool)'](erc20.address, user.address, utils.parseEther('100').add(1), false)
    })

    it('transfers tokens (round down explicit) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transferFrom
        .withArgs(user.address, token.address, utils.parseEther('100').add(1).mul(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pull(address,address,uint256,bool)'](erc20.address, user.address, utils.parseEther('100').add(1), false)
    })

    it('transfers tokens (round down explicit) (ether)', async () => {
      await expect(
        token
          .connect(user)
          ['pull(address,address,uint256,bool)'](ETHER, user.address, utils.parseEther('100').add(1), false),
      ).to.be.revertedWith('TokenPullEtherError()')
    })

    it('transfers tokens (round up) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transferFrom
        .withArgs(user.address, token.address, utils.parseEther('100').div(1000000).add(1))
        .returns(true)

      await token
        .connect(user)
        ['pull(address,address,uint256,bool)'](erc20.address, user.address, utils.parseEther('100').add(1), true)
    })

    it('transfers tokens (round up) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom.withArgs(user.address, token.address, utils.parseEther('100').add(1)).returns(true)

      await token
        .connect(user)
        ['pull(address,address,uint256,bool)'](erc20.address, user.address, utils.parseEther('100').add(1), true)
    })

    it('transfers tokens (round up) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transferFrom
        .withArgs(user.address, token.address, utils.parseEther('100').add(1).mul(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pull(address,address,uint256,bool)'](erc20.address, user.address, utils.parseEther('100').add(1), true)
    })

    it('transfers tokens (round up) (ether)', async () => {
      await expect(
        token
          .connect(user)
          ['pull(address,address,uint256,bool)'](ETHER, user.address, utils.parseEther('100').add(1), true),
      ).to.be.revertedWith('TokenPullEtherError()')
    })

    it('transfers tokens (round up when no decimal) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transferFrom
        .withArgs(user.address, token.address, utils.parseEther('100').div(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pull(address,address,uint256,bool)'](erc20.address, user.address, utils.parseEther('100'), true)
    })

    it('transfers tokens (round up when no decimal) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom.withArgs(user.address, token.address, utils.parseEther('100')).returns(true)

      await token
        .connect(user)
        ['pull(address,address,uint256,bool)'](erc20.address, user.address, utils.parseEther('100'), true)
    })

    it('transfers tokens (round up when no decimal) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transferFrom
        .withArgs(user.address, token.address, utils.parseEther('100').mul(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pull(address,address,uint256,bool)'](erc20.address, user.address, utils.parseEther('100'), true)
    })

    it('transfers tokens (round up when no decimal) (ether)', async () => {
      await expect(
        token.connect(user)['pull(address,address,uint256,bool)'](ETHER, user.address, utils.parseEther('100'), true),
      ).to.be.revertedWith('TokenPullEtherError()')
    })
  })

  describe('#pullTo', async () => {
    it('transfers tokens (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').div(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100'),
        )
    })

    it('transfers tokens (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom.withArgs(user.address, recipient.address, utils.parseEther('100')).returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100'),
        )
    })

    it('transfers tokens (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').mul(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100'),
        )
    })

    it('transfers tokens (ether)', async () => {
      await expect(
        token
          .connect(user)
          ['pullTo(address,address,address,uint256)'](ETHER, user.address, recipient.address, utils.parseEther('100')),
      ).to.be.revertedWith('TokenPullEtherError()')
    })

    it('transfers tokens (round down implicit) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').div(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100').add(1),
        )
    })

    it('transfers tokens (round down implicit) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').add(1))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100').add(1),
        )
    })

    it('transfers tokens (round down implicit) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').add(1).mul(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100').add(1),
        )
    })

    it('transfers tokens (round down implicit) (ether)', async () => {
      await expect(
        token
          .connect(user)
          ['pullTo(address,address,address,uint256)'](
            ETHER,
            user.address,
            recipient.address,
            utils.parseEther('100').add(1),
          ),
      ).to.be.revertedWith('TokenPullEtherError()')
    })

    it('transfers tokens (round down explicit) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').div(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256,bool)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100').add(1),
          false,
        )
    })

    it('transfers tokens (round down explicit) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').add(1))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256,bool)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100').add(1),
          false,
        )
    })

    it('transfers tokens (round down explicit) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').add(1).mul(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256,bool)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100').add(1),
          false,
        )
    })

    it('transfers tokens (round down explicit) (ether)', async () => {
      await expect(
        token
          .connect(user)
          ['pullTo(address,address,address,uint256,bool)'](
            ETHER,
            user.address,
            recipient.address,
            utils.parseEther('100').add(1),
            false,
          ),
      ).to.be.revertedWith('TokenPullEtherError()')
    })

    it('transfers tokens (round up) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').div(1000000).add(1))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256,bool)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100').add(1),
          true,
        )
    })

    it('transfers tokens (round up) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').add(1))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256,bool)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100').add(1),
          true,
        )
    })

    it('transfers tokens (round up) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').add(1).mul(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256,bool)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100').add(1),
          true,
        )
    })

    it('transfers tokens (round up) (ether)', async () => {
      await expect(
        token
          .connect(user)
          ['pullTo(address,address,address,uint256,bool)'](
            ETHER,
            user.address,
            recipient.address,
            utils.parseEther('100').add(1),
            true,
          ),
      ).to.be.revertedWith('TokenPullEtherError()')
    })

    it('transfers tokens (round up when no decimal) (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').div(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256,bool)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100'),
          true,
        )
    })

    it('transfers tokens (round up when no decimal) (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.transferFrom.withArgs(user.address, recipient.address, utils.parseEther('100')).returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256,bool)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100'),
          true,
        )
    })

    it('transfers tokens (round up when no decimal) (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.transferFrom
        .withArgs(user.address, recipient.address, utils.parseEther('100').mul(1000000))
        .returns(true)

      await token
        .connect(user)
        ['pullTo(address,address,address,uint256,bool)'](
          erc20.address,
          user.address,
          recipient.address,
          utils.parseEther('100'),
          true,
        )
    })

    it('transfers tokens (round up when no decimal) (ether)', async () => {
      await expect(
        token
          .connect(user)
          ['pullTo(address,address,address,uint256)'](
            ETHER,
            user.address,
            recipient.address,
            utils.parseEther('100').add(1),
          ),
      ).to.be.revertedWith('TokenPullEtherError()')
    })
  })

  describe('#name', async () => {
    it('returns name', async () => {
      await erc20.mock.name.withArgs().returns('Token Name')
      expect(await token.connect(user).name(erc20.address)).to.equal('Token Name')
    })

    it('returns name (ether)', async () => {
      expect(await token.connect(user).name(ETHER)).to.equal('Ether')
    })
  })

  describe('#symbol', async () => {
    it('returns symbol', async () => {
      await erc20.mock.symbol.withArgs().returns('TN')
      expect(await token.connect(user).symbol(erc20.address)).to.equal('TN')
    })

    it('returns symbol (ether)', async () => {
      expect(await token.connect(user).symbol(ETHER)).to.equal('ETH')
    })
  })

  describe('#decimals', async () => {
    it('returns decimals', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      expect(await token.connect(user).decimals(erc20.address)).to.equal(18)
    })

    it('returns decimals (ether)', async () => {
      expect(await token.connect(user).decimals(ETHER)).to.equal(18)
    })
  })

  describe('#balanceOf', async () => {
    it('returns balanceOf (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.balanceOf.withArgs(user.address).returns(utils.parseEther('100').div(1000000))
      expect(await token.connect(user)['balanceOf(address,address)'](erc20.address, user.address)).to.equal(
        utils.parseEther('100'),
      )
    })

    it('returns balanceOf (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.balanceOf.withArgs(user.address).returns(utils.parseEther('100'))
      expect(await token.connect(user)['balanceOf(address,address)'](erc20.address, user.address)).to.equal(
        utils.parseEther('100'),
      )
    })

    it('returns balanceOf (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.balanceOf.withArgs(user.address).returns(utils.parseEther('100').mul(1000000))
      expect(await token.connect(user)['balanceOf(address,address)'](erc20.address, user.address)).to.equal(
        utils.parseEther('100'),
      )
    })

    it('returns balanceOf (ether)', async () => {
      expect(await token.connect(user)['balanceOf(address,address)'](ETHER, token.address)).to.equal(
        utils.parseEther('0'),
      )
      await user.sendTransaction({ to: token.address, value: ethers.utils.parseEther('100') })
      expect(await token.connect(user)['balanceOf(address,address)'](ETHER, token.address)).to.equal(
        utils.parseEther('100'),
      )
    })
  })

  describe('#balanceOf', async () => {
    it('returns balanceOf (12)', async () => {
      await erc20.mock.decimals.withArgs().returns(12)
      await erc20.mock.balanceOf.withArgs(token.address).returns(utils.parseEther('100').div(1000000))
      expect(await token.connect(user)['balanceOf(address)'](erc20.address)).to.equal(utils.parseEther('100'))
    })

    it('returns balanceOf (18)', async () => {
      await erc20.mock.decimals.withArgs().returns(18)
      await erc20.mock.balanceOf.withArgs(token.address).returns(utils.parseEther('100'))
      expect(await token.connect(user)['balanceOf(address)'](erc20.address)).to.equal(utils.parseEther('100'))
    })

    it('returns balanceOf (24)', async () => {
      await erc20.mock.decimals.withArgs().returns(24)
      await erc20.mock.balanceOf.withArgs(token.address).returns(utils.parseEther('100').mul(1000000))
      expect(await token.connect(user)['balanceOf(address)'](erc20.address)).to.equal(utils.parseEther('100'))
    })

    it('returns balanceOf (ether)', async () => {
      await user.sendTransaction({ to: token.address, value: ethers.utils.parseEther('100') })
      expect(await token.connect(user)['balanceOf(address)'](ETHER)).to.equal(utils.parseEther('100'))
    })
  })

  describe('#store(Token)', async () => {
    it('sets value', async () => {
      await token.store(SLOT, erc20.address)
      expect(await token.read(SLOT)).to.equal(erc20.address)
    })
  })
})
