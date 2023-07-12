import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockUPausable, MockUPausable__factory } from '../../../types/generated'

const { ethers } = HRE

describe('UPausable', () => {
  let owner: SignerWithAddress
  let newPauser: SignerWithAddress
  let user: SignerWithAddress
  let uPausable: MockUPausable

  beforeEach(async () => {
    ;[owner, newPauser, user] = await ethers.getSigners()
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
      await expect(uPausable.connect(owner).updatePauser(newPauser.address))
        .to.emit(uPausable, 'PauserUpdated')
        .withArgs(newPauser.address)

      expect(await uPausable.pauser()).to.equal(newPauser.address)
    })

    it('only owner can update pauser', async () => {
      await expect(uPausable.connect(user).updatePauser(user.address)).to.be.revertedWith(
        `UOwnableNotOwnerError("${user.address}")`,
      )

      await uPausable.connect(owner).updatePauser(newPauser.address)
      await expect(uPausable.connect(newPauser).updatePauser(user.address)).to.be.revertedWith(
        `UOwnableNotOwnerError("${newPauser.address}")`,
      )
    })
  })

  describe('#pause', async () => {
    beforeEach(async () => {
      await uPausable.connect(owner).__initialize()
    })

    async function testPause(pauser: SignerWithAddress) {
      const initialValue = await uPausable.counter()
      await uPausable.increment()
      const secondValue = await uPausable.counter()
      expect(secondValue).to.equal(initialValue.add(1))

      await expect(uPausable.connect(pauser).pause()).to.emit(uPausable, 'Paused')

      expect(await uPausable.paused()).to.equal(true)
      await expect(uPausable.increment()).to.be.revertedWith(`UPausablePausedError()`)

      // We should still be able to call incrementNoModifier
      await uPausable.incrementNoModifier()
      expect(await uPausable.counter()).to.equal(secondValue.add(1))
    }

    it('pauser can pause', async () => {
      await uPausable.connect(owner).updatePauser(newPauser.address)
      await testPause(newPauser)
    })

    it('owner can pause', async () => {
      await uPausable.connect(owner).updatePauser(newPauser.address)
      await testPause(owner)
    })

    it('other users cannot pause', async () => {
      await expect(uPausable.connect(user).pause()).to.be.revertedWith(`UPausableNotPauserError("${user.address}")`)
    })
  })

  describe('#unpause', async () => {
    beforeEach(async () => {
      await uPausable.connect(owner).__initialize()
    })

    async function testUnpause(unpauser: SignerWithAddress) {
      await uPausable.connect(unpauser).pause()
      expect(await uPausable.paused()).to.equal(true)

      await expect(uPausable.connect(unpauser).unpause()).to.emit(uPausable, 'Unpaused')

      expect(await uPausable.paused()).to.equal(false)

      const initialValue = await uPausable.counter()
      await uPausable.increment()
      expect(await uPausable.counter()).to.equal(initialValue.add(1))
    }

    it('pauser can unpause', async () => {
      await uPausable.connect(owner).updatePauser(newPauser.address)
      await testUnpause(newPauser)
    })

    it('owner can unpause', async () => {
      await uPausable.connect(owner).updatePauser(newPauser.address)
      await testUnpause(owner)
    })

    it('other users cannot unpause', async () => {
      await uPausable.connect(owner).pause()
      expect(await uPausable.paused()).to.equal(true)

      await expect(uPausable.connect(user).unpause()).to.be.revertedWith(`UPausableNotPauserError("${user.address}")`)
    })
  })
})
