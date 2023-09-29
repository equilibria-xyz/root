import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockFactory, MockFactory__factory, MockInstance, MockInstance__factory } from '../../../types/generated'

const { ethers } = HRE

describe('Instance', () => {
  let owner: SignerWithAddress
  let pauser: SignerWithAddress
  let user: SignerWithAddress
  let factory: MockFactory
  let instanceImplementation: MockInstance
  let instance: MockInstance

  beforeEach(async () => {
    ;[owner, pauser, user] = await ethers.getSigners()
    instanceImplementation = await new MockInstance__factory(owner).deploy()
    factory = await new MockFactory__factory(owner).deploy(instanceImplementation.address)
    await factory.connect(owner).initialize()
    await factory.connect(owner).updatePauser(pauser.address)
    const instanceName = 'instance'
    const instanceAddress = await factory.connect(owner).callStatic.create(instanceName)
    await factory.connect(owner).create(instanceName)
    instance = MockInstance__factory.connect(instanceAddress, owner)
  })

  describe('#factory', async () => {
    it('initializes factory', async () => {
      expect(await instance.factory()).to.equal(factory.address)
    })
  })

  describe('#onlyOwner', async () => {
    it('restricts onlyOwner functions to only be called by the owner', async () => {
      await expect(instance.connect(user).protectedFunction()).to.be.revertedWith(
        `InstanceNotOwnerError("${user.address}")`,
      )
      await expect(instance.connect(owner).protectedFunction()).to.not.be.reverted
    })
  })

  describe('#whenNotPaused', async () => {
    it('restricts whenNotPaused functions to only be called when not paused', async () => {
      await factory.connect(pauser).pause()
      await expect(instance.connect(owner).protectedFunction()).to.be.revertedWith(`InstancePausedError()`)
    })
  })
})
