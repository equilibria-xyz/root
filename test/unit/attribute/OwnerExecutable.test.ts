import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  MockTokenOrEther18__factory,
  MockOwnerExecutable,
  MockOwnerExecutable__factory,
  Ownable,
} from '../../../types/generated'
import { constants } from 'ethers'

const { ethers } = HRE

describe('OwnerExecutable', () => {
  let owner: SignerWithAddress
  let user: SignerWithAddress
  let ownableExecutable: MockOwnerExecutable

  beforeEach(async () => {
    ;[owner, user] = await ethers.getSigners()
    ownableExecutable = await new MockOwnerExecutable__factory(owner).deploy()
    await ownableExecutable.connect(owner).__initialize()
  })

  describe('#execute', async () => {
    it('executes call successfully', async () => {
      const target = ownableExecutable.address
      const data = ownableExecutable.interface.encodeFunctionData('owner')
      const returnData = await ownableExecutable.connect(owner).callStatic.execute(target, data)
      const decodedResult = ownableExecutable.interface.decodeFunctionResult('owner', returnData)

      expect(decodedResult[0]).to.equal(owner.address)
    })

    it('executes payable call successfully', async () => {
      const testContract = await new MockTokenOrEther18__factory(owner).deploy()
      const target = testContract.address
      const data = '0x'
      const value = ethers.utils.parseEther('1.0')

      const balanceBefore = await ethers.provider.getBalance(target)

      await ownableExecutable.connect(owner).execute(target, data, { value: value })

      const balanceAfter = await ethers.provider.getBalance(target)
      expect(balanceAfter.sub(balanceBefore)).to.equal(value)
    })

    it('reverts if call fails', async () => {
      const target = ownableExecutable.address
      const data = '0x'

      await expect(ownableExecutable.connect(owner).execute(target, data)).to.be.reverted
    })

    it('reverts if not owner', async () => {
      const target = ownableExecutable.address
      const data = ownableExecutable.interface.encodeFunctionData('owner')

      await expect(ownableExecutable.connect(user).execute(target, data)).to.be.revertedWith(
        `OwnableNotOwnerError("${user.address}")`,
      )
    })

    it('reverts if payable call fails', async () => {
      const target = ownableExecutable.address
      const data = ownableExecutable.interface.encodeFunctionData('owner')
      const value = ethers.utils.parseEther('1.0')

      await expect(ownableExecutable.connect(owner).execute(target, data, { value: value })).to.be.reverted
    })
  })
})
