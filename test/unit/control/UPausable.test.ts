import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockUPausable, MockUPausable__factory } from '../../../types/generated'

const { ethers } = HRE

describe.only('UPausable', () => {
  let owner: SignerWithAddress
  let newOwner: SignerWithAddress
  let user: SignerWithAddress
  let uPausable: MockUPausable

  beforeEach(async () => {
    ;[owner, newOwner, user] = await ethers.getSigners()
    uPausable = await new MockUPausable__factory(owner).deploy()
  })

  describe('#UPausable__initialize', async () => {
    it('initializes pauser', async () => {
      expect(await uPausable.pauser()).to.equal(ethers.constants.AddressZero)

      await expect(uPausable.connect(owner).__initialize()).to.emit(uPausable, 'PauserUpdated').withArgs(owner.address)

      expect(await uPausable.pauser()).to.equal(owner.address)
      expect(await uPausable.owner()).to.equal(owner.address)
    })
  })

  describe('#updatePauser', async () => {
    beforeEach(async () => {
      await uPausable.connect(owner).__initialize()
    })

    it('updates pauser', async () => {
      await expect(uPausable.connect(owner).updatePauser(newOwner.address))
        .to.emit(uPausable, 'PauserUpdated')
        .withArgs(newOwner.address)

      expect(await uPausable.pauser()).to.equal(newOwner.address)
    })

    it('only pauser can update pauser', async () => {
      await expect(uPausable.connect(user).updatePauser(newOwner.address)).to.be.revertedWith(
        `UOwnableNotOwnerError("${user.address}")`,
      )
    })
  })

  describe('#pause', async () => {
    beforeEach(async () => {
      await uPausable.connect(owner).__initialize()
    })

    it('pauses', async () => {
      const initialValue = await uPausable.counter()
      await uPausable.increment()
      const secondValue = await uPausable.counter()
      expect(secondValue).to.equal(initialValue.add(1))

      await expect(uPausable.connect(owner).pause()).to.emit(uPausable, 'Paused')

      expect(await uPausable.paused()).to.equal(true)
      await expect(uPausable.increment()).to.be.revertedWith(`UPausablePausedError()`)

      // We should still be able to call incrementNoModifier
      await uPausable.incrementNoModifier()
      expect(await uPausable.counter()).to.equal(secondValue.add(1))
    })

    it('only pauser can pause', async () => {
      await expect(uPausable.connect(user).pause()).to.be.revertedWith(`UPausableNotPauserError("${user.address}")`)
    })
  })

  describe('#unpause', async () => {
    beforeEach(async () => {
      await uPausable.connect(owner).__initialize()
    })

    it('unpauses', async () => {
      await uPausable.connect(owner).pause()
      expect(await uPausable.paused()).to.equal(true)

      await expect(uPausable.connect(owner).unpause()).to.emit(uPausable, 'Unpaused')

      expect(await uPausable.paused()).to.equal(false)

      const initialValue = await uPausable.counter()
      await uPausable.increment()
      expect(await uPausable.counter()).to.equal(initialValue.add(1))
    })

    it('only pauser can unpause', async () => {
      await uPausable.connect(owner).pause()
      expect(await uPausable.paused()).to.equal(true)

      await expect(uPausable.connect(user).unpause()).to.be.revertedWith(`UPausableNotPauserError("${user.address}")`)
    })
  })
})
