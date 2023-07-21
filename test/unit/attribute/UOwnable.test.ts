import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockUOwnable, MockUOwnable__factory } from '../../../types/generated'

const { ethers } = HRE

describe('UOwnable', () => {
  let owner: SignerWithAddress
  let user: SignerWithAddress
  let unrelated: SignerWithAddress
  let uOwnable: MockUOwnable

  beforeEach(async () => {
    ;[owner, user, unrelated] = await ethers.getSigners()
    uOwnable = await new MockUOwnable__factory(owner).deploy()
  })

  describe('#UOwnable__initialize', async () => {
    it('initializes owner', async () => {
      expect(await uOwnable.owner()).to.equal(ethers.constants.AddressZero)

      await expect(uOwnable.connect(owner).__initialize()).to.emit(uOwnable, 'OwnerUpdated').withArgs(owner.address)

      expect(await uOwnable.owner()).to.equal(owner.address)
    })
  })

  describe('#setPendingOwner', async () => {
    beforeEach(async () => {
      await uOwnable.connect(owner).__initialize()
    })

    it('set pending owner', async () => {
      await expect(uOwnable.connect(owner).updatePendingOwner(user.address))
        .to.emit(uOwnable, 'PendingOwnerUpdated')
        .withArgs(user.address)

      expect(await uOwnable.owner()).to.equal(owner.address)
      expect(await uOwnable.pendingOwner()).to.equal(user.address)
    })

    it('reverts if not owner', async () => {
      await expect(uOwnable.connect(user).updatePendingOwner(user.address)).to.be.revertedWith(
        `UOwnableNotOwnerError("${user.address}")`,
      )
    })

    it('reset', async () => {
      await expect(uOwnable.connect(owner).updatePendingOwner(ethers.constants.AddressZero))
        .to.emit(uOwnable, 'PendingOwnerUpdated')
        .withArgs(ethers.constants.AddressZero)

      expect(await uOwnable.owner()).to.equal(owner.address)
      expect(await uOwnable.pendingOwner()).to.equal(ethers.constants.AddressZero)
    })
  })

  describe('#acceptOwner', async () => {
    beforeEach(async () => {
      await uOwnable.connect(owner).__initialize()
      await uOwnable.connect(owner).updatePendingOwner(user.address)
    })

    it('transfers owner', async () => {
      await expect(uOwnable.connect(user).acceptOwner()).to.emit(uOwnable, 'OwnerUpdated').withArgs(user.address)

      expect(await uOwnable.owner()).to.equal(user.address)
      expect(await uOwnable.pendingOwner()).to.equal(ethers.constants.AddressZero)
    })

    it('calls the _beforeAcceptOwner hook', async () => {
      expect(await uOwnable.beforeCalled()).to.equal(false)

      await expect(uOwnable.connect(user).acceptOwner()).to.emit(uOwnable, 'OwnerUpdated').withArgs(user.address)

      expect(await uOwnable.beforeCalled()).to.equal(true)
    })

    it('reverts if owner not pending owner', async () => {
      await expect(uOwnable.connect(owner).acceptOwner()).to.be.revertedWith(
        `UOwnableNotPendingOwnerError("${owner.address}")`,
      )
    })

    it('reverts if unrelated not pending owner', async () => {
      await expect(uOwnable.connect(unrelated).acceptOwner()).to.be.revertedWith(
        `UOwnableNotPendingOwnerError("${unrelated.address}")`,
      )
    })
  })
})
