import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockOwnable, MockOwnable__factory } from '../../../types/generated'

const { ethers } = HRE

describe('Ownable', () => {
  let owner: SignerWithAddress
  let user: SignerWithAddress
  let unrelated: SignerWithAddress
  let ownable: MockOwnable

  beforeEach(async () => {
    ;[owner, user, unrelated] = await ethers.getSigners()
    ownable = await new MockOwnable__factory(owner).deploy()
  })

  describe('#Ownable__initialize', async () => {
    it('initializes owner', async () => {
      expect(await ownable.owner()).to.equal(ethers.constants.AddressZero)

      await expect(ownable.connect(owner).__initialize()).to.emit(ownable, 'OwnerUpdated').withArgs(owner.address)

      expect(await ownable.owner()).to.equal(owner.address)
    })
  })

  describe('#setPendingOwner', async () => {
    beforeEach(async () => {
      await ownable.connect(owner).__initialize()
    })

    it('set pending owner', async () => {
      await expect(ownable.connect(owner).updatePendingOwner(user.address))
        .to.emit(ownable, 'PendingOwnerUpdated')
        .withArgs(user.address)

      expect(await ownable.owner()).to.equal(owner.address)
      expect(await ownable.pendingOwner()).to.equal(user.address)
    })

    it('reverts if not owner', async () => {
      await expect(ownable.connect(user).updatePendingOwner(user.address)).to.be.revertedWith(
        `OwnableNotOwnerError("${user.address}")`,
      )
    })

    it('reset', async () => {
      await expect(ownable.connect(owner).updatePendingOwner(ethers.constants.AddressZero))
        .to.emit(ownable, 'PendingOwnerUpdated')
        .withArgs(ethers.constants.AddressZero)

      expect(await ownable.owner()).to.equal(owner.address)
      expect(await ownable.pendingOwner()).to.equal(ethers.constants.AddressZero)
    })
  })

  describe('#acceptOwner', async () => {
    beforeEach(async () => {
      await ownable.connect(owner).__initialize()
      await ownable.connect(owner).updatePendingOwner(user.address)
    })

    it('transfers owner', async () => {
      await expect(ownable.connect(user).acceptOwner()).to.emit(ownable, 'OwnerUpdated').withArgs(user.address)

      expect(await ownable.owner()).to.equal(user.address)
      expect(await ownable.pendingOwner()).to.equal(ethers.constants.AddressZero)
    })

    it('calls the _beforeAcceptOwner hook', async () => {
      expect(await ownable.beforeCalled()).to.equal(false)

      await expect(ownable.connect(user).acceptOwner()).to.emit(ownable, 'OwnerUpdated').withArgs(user.address)

      expect(await ownable.beforeCalled()).to.equal(true)
    })

    it('reverts if owner not pending owner', async () => {
      await expect(ownable.connect(owner).acceptOwner()).to.be.revertedWith(
        `OwnableNotPendingOwnerError("${owner.address}")`,
      )
    })

    it('reverts if unrelated not pending owner', async () => {
      await expect(ownable.connect(unrelated).acceptOwner()).to.be.revertedWith(
        `OwnableNotPendingOwnerError("${unrelated.address}")`,
      )
    })
  })
})
