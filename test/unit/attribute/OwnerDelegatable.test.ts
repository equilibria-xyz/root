import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  MockOwnerDelegatable,
  MockOwnerDelegatable__factory,
  MockERC20Votes,
  MockERC20Votes__factory,
} from '../../../types/generated'

const { ethers } = HRE

describe('OwnerDelegatable', () => {
  let owner: SignerWithAddress
  let user: SignerWithAddress
  let unrelated: SignerWithAddress
  let ownerDelegatable: MockOwnerDelegatable
  let mockToken: MockERC20Votes

  beforeEach(async () => {
    ;[owner, user, unrelated] = await ethers.getSigners()
    ownerDelegatable = await new MockOwnerDelegatable__factory(owner).deploy()
    await ownerDelegatable.connect(owner).__initialize()
    mockToken = await new MockERC20Votes__factory(owner).deploy()
    await mockToken.connect(owner).mint(owner.address, ethers.utils.parseEther('1000'))
  })

  describe('#delegate', async () => {
    it('delegates voting power successfully', async () => {
      await expect(ownerDelegatable.connect(owner).delegate(mockToken.address, user.address))
        .to.emit(mockToken, 'DelegateChanged')
        .withArgs(ownerDelegatable.address, ethers.constants.AddressZero, user.address)
    })

    it('reverts if not owner', async () => {
      await expect(ownerDelegatable.connect(user).delegate(mockToken.address, unrelated.address))
        .to.be.revertedWithCustomError(ownerDelegatable, 'OwnableNotOwnerError')
        .withArgs(user.address)
    })
  })
})
