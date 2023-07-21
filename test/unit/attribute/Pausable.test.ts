import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockPausable, MockPausable__factory } from '../../../types/generated'

const { ethers } = HRE

describe('Pausable', () => {
  let owner: SignerWithAddress
  let newPauser: SignerWithAddress
  let user: SignerWithAddress
  let pausable: MockPausable

  beforeEach(async () => {
    ;[owner, newPauser, user] = await ethers.getSigners()
    pausable = await new MockPausable__factory(owner).deploy()
  })

  describe('#Pausable__initialize', async () => {
    it('initializes pauser', async () => {
      expect(await pausable.pauser()).to.equal(ethers.constants.AddressZero)

      await expect(pausable.connect(owner).__initialize()).to.emit(pausable, 'PauserUpdated').withArgs(owner.address)

      expect(await pausable.pauser()).to.equal(owner.address)
      expect(await pausable.owner()).to.equal(owner.address)
    })
  })

  describe('#updatePauser', async () => {
    beforeEach(async () => {
      await pausable.connect(owner).__initialize()
    })

    it('updates pauser', async () => {
      await expect(pausable.connect(owner).updatePauser(newPauser.address))
        .to.emit(pausable, 'PauserUpdated')
        .withArgs(newPauser.address)

      expect(await pausable.pauser()).to.equal(newPauser.address)
    })

    it('only owner can update pauser', async () => {
      await expect(pausable.connect(user).updatePauser(user.address)).to.be.revertedWith(
        `UOwnableNotOwnerError("${user.address}")`,
      )

      await pausable.connect(owner).updatePauser(newPauser.address)
      await expect(pausable.connect(newPauser).updatePauser(user.address)).to.be.revertedWith(
        `UOwnableNotOwnerError("${newPauser.address}")`,
      )
    })
  })

  describe('#pause', async () => {
    beforeEach(async () => {
      await pausable.connect(owner).__initialize()
    })

    async function testPause(pauser: SignerWithAddress) {
      const initialValue = await pausable.counter()
      await pausable.increment()
      const secondValue = await pausable.counter()
      expect(secondValue).to.equal(initialValue.add(1))

      await expect(pausable.connect(pauser).pause()).to.emit(pausable, 'Paused')

      expect(await pausable.paused()).to.equal(true)
      await expect(pausable.increment()).to.be.revertedWith(`PausablePausedError()`)

      // We should still be able to call incrementNoModifier
      await pausable.incrementNoModifier()
      expect(await pausable.counter()).to.equal(secondValue.add(1))
    }

    it('pauser can pause', async () => {
      await pausable.connect(owner).updatePauser(newPauser.address)
      await testPause(newPauser)
    })

    it('owner can pause', async () => {
      await pausable.connect(owner).updatePauser(newPauser.address)
      await testPause(owner)
    })

    it('other users cannot pause', async () => {
      await expect(pausable.connect(user).pause()).to.be.revertedWith(`PausableNotPauserError("${user.address}")`)
    })
  })

  describe('#unpause', async () => {
    beforeEach(async () => {
      await pausable.connect(owner).__initialize()
    })

    async function testUnpause(unpauser: SignerWithAddress) {
      await pausable.connect(unpauser).pause()
      expect(await pausable.paused()).to.equal(true)

      await expect(pausable.connect(unpauser).unpause()).to.emit(pausable, 'Unpaused')

      expect(await pausable.paused()).to.equal(false)

      const initialValue = await pausable.counter()
      await pausable.increment()
      expect(await pausable.counter()).to.equal(initialValue.add(1))
    }

    it('pauser can unpause', async () => {
      await pausable.connect(owner).updatePauser(newPauser.address)
      await testUnpause(newPauser)
    })

    it('owner can unpause', async () => {
      await pausable.connect(owner).updatePauser(newPauser.address)
      await testUnpause(owner)
    })

    it('other users cannot unpause', async () => {
      await pausable.connect(owner).pause()
      expect(await pausable.paused()).to.equal(true)

      await expect(pausable.connect(user).unpause()).to.be.revertedWith(`PausableNotPauserError("${user.address}")`)
    })
  })
})
