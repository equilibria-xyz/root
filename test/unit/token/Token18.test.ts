import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
import { expect } from 'chai'
import HRE, { waffle } from 'hardhat'

import { IERC20Metadata__factory, MockToken18, MockToken18__factory } from '../../../types/generated'
import { MockContract } from '@ethereum-waffle/mock-contract'

const { ethers } = HRE

describe('Token18', () => {
  let user: SignerWithAddress
  let recipient: SignerWithAddress
  let token18: MockToken18
  let erc20: MockContract

  beforeEach(async () => {
    ;[user, recipient] = await ethers.getSigners()
    token18 = await new MockToken18__factory(user).deploy()
    erc20 = await waffle.deployMockContract(user, IERC20Metadata__factory.abi)
  })

  describe('#approve', async () => {
    it('approves tokens', async () => {
      await erc20.mock.allowance.withArgs(token18.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, utils.parseEther('100')).returns(true)

      await token18
        .connect(user)
        ['approve(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100'))
    })

    it('approves tokens all', async () => {
      await erc20.mock.allowance.withArgs(token18.address, recipient.address).returns(0)
      await erc20.mock.approve.withArgs(recipient.address, ethers.constants.MaxUint256).returns(true)

      await token18.connect(user)['approve(address,address)'](erc20.address, recipient.address)
    })
  })

  describe('#push', async () => {
    it('transfers tokens', async () => {
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100')).returns(true)

      await token18
        .connect(user)
        ['push(address,address,uint256)'](erc20.address, recipient.address, utils.parseEther('100'))
    })

    it('transfers tokens all', async () => {
      await erc20.mock.balanceOf.withArgs(token18.address).returns(utils.parseEther('100'))
      await erc20.mock.transfer.withArgs(recipient.address, utils.parseEther('100')).returns(true)

      await token18.connect(user)['push(address,address)'](erc20.address, recipient.address)
    })
  })

  describe('#pull', async () => {
    it('transfers tokens', async () => {
      await erc20.mock.transferFrom.withArgs(user.address, token18.address, utils.parseEther('100')).returns(true)

      await token18.connect(user).pull(erc20.address, user.address, utils.parseEther('100'))
    })
  })

  describe('#pullTo', async () => {
    it('transfers tokens', async () => {
      await erc20.mock.transferFrom.withArgs(user.address, recipient.address, utils.parseEther('100')).returns(true)

      await token18.connect(user).pullTo(erc20.address, user.address, recipient.address, utils.parseEther('100'))
    })
  })

  describe('#name', async () => {
    it('returns name', async () => {
      await erc20.mock.name.withArgs().returns('Token Name')
      expect(await token18.connect(user).name(erc20.address)).to.equal('Token Name')
    })
  })

  describe('#symbol', async () => {
    it('returns symbol', async () => {
      await erc20.mock.symbol.withArgs().returns('TN')
      expect(await token18.connect(user).symbol(erc20.address)).to.equal('TN')
    })
  })

  describe('#decimals', async () => {
    it('returns decimals', async () => {
      expect(await token18.connect(user).decimals(erc20.address)).to.equal(18)
    })
  })

  describe('#balanceOf', async () => {
    it('returns balance', async () => {
      await erc20.mock.balanceOf.withArgs(user.address).returns(utils.parseEther('100'))
      expect(await token18.connect(user)['balanceOf(address,address)'](erc20.address, user.address)).to.equal(
        utils.parseEther('100'),
      )
    })

    it('returns balance all', async () => {
      await erc20.mock.balanceOf.withArgs(token18.address).returns(utils.parseEther('100'))
      expect(await token18.connect(user)['balanceOf(address)'](erc20.address)).to.equal(utils.parseEther('100'))
    })
  })
})
