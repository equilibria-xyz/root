import { expect } from 'chai'
import { ethers } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { MockERC20 } from '../../../types/generated/MockERC20'
import { MockERC20__factory, MockOwnerWithdrawable, MockOwnerWithdrawable__factory } from '../../../types/generated'

describe('OwnerWithdrawable', function () {
  let ownerWithdrawable: MockOwnerWithdrawable
  let owner: SignerWithAddress
  let addr1: SignerWithAddress
  let erc20: MockERC20

  beforeEach(async function () {
    ;[owner, addr1] = await ethers.getSigners()
    ownerWithdrawable = await new MockOwnerWithdrawable__factory(owner).deploy()
    await ownerWithdrawable.connect(owner).__initialize()

    erc20 = await new MockERC20__factory(owner).deploy('TestToken', 'TT')
    await erc20.connect(owner).mint(owner.address, 1000)
  })

  describe('withdrawERC20', function () {
    it('should allow the owner to withdraw ERC20 tokens', async function () {
      // Transfer some tokens to the contract
      await erc20.transfer(ownerWithdrawable.address, 100)

      // Check the contract balance
      expect(await erc20.balanceOf(ownerWithdrawable.address)).to.equal(100)

      // Withdraw tokens
      await ownerWithdrawable.connect(owner).withdraw(erc20.address)

      // Check the contract balance after withdrawal
      expect(await erc20.balanceOf(ownerWithdrawable.address)).to.equal(0)

      // Check the owner's balance after withdrawal
      expect(await erc20.balanceOf(owner.address)).to.equal(1000)
    })

    it('should not allow non-owners to withdraw ERC20 tokens', async function () {
      // Transfer some tokens to the contract
      await erc20.transfer(ownerWithdrawable.address, 100)

      // Check the contract balance
      expect(await erc20.balanceOf(ownerWithdrawable.address)).to.equal(100)

      // Attempt to withdraw tokens as a non-owner
      await expect(ownerWithdrawable.connect(addr1).withdraw(erc20.address))
        .to.be.revertedWithCustomError(ownerWithdrawable, 'OwnableNotOwnerError')
        .withArgs(addr1.address)

      // Check the contract balance after failed withdrawal
      expect(await erc20.balanceOf(ownerWithdrawable.address)).to.equal(100)
    })
  })
})
