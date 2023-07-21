import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockFactory, MockFactory__factory, MockInstance, MockInstance__factory } from '../../../types/generated'

const { ethers } = HRE

describe('Factory', () => {
  let owner: SignerWithAddress
  let pauser: SignerWithAddress
  let user: SignerWithAddress
  let factory: MockFactory
  let instanceImplementation: MockInstance

  beforeEach(async () => {
    ;[owner, pauser, user] = await ethers.getSigners()
    instanceImplementation = await new MockInstance__factory(owner).deploy()
    factory = await new MockFactory__factory(owner).deploy(instanceImplementation.address)
    await factory.connect(owner).initialize()
    await factory.connect(owner).updatePauser(pauser.address)
  })

  describe('#initialize', async () => {
    it('initializes implementation/pauser/owner', async () => {
      expect(await factory.implementation()).to.equal(instanceImplementation.address)
      expect(await factory.pauser()).to.equal(pauser.address)
      expect(await factory.owner()).to.equal(owner.address)
    })
  })

  describe('#_create', async () => {
    it('creates instance', async () => {
      const instanceName = 'instance'
      const instanceAddress = await factory.connect(owner).callStatic.create(instanceName)
      await expect(factory.connect(owner).create(instanceName))
        .to.emit(factory, 'InstanceRegistered')
        .withArgs(instanceAddress)
      const instance = MockInstance__factory.connect(instanceAddress, owner)
      expect(await instance.name()).to.equal(instanceName)
    })
  })

  describe('#instances', async () => {
    it('returns false if instance does not exist', async () => {
      expect(await factory.instances(user.address)).to.be.false
    })

    it('returns true if instance exists', async () => {
      const instanceName = 'instance'
      const instanceAddress = await factory.connect(owner).callStatic.create(instanceName)
      await factory.connect(owner).create(instanceName)
      expect(await factory.instances(instanceAddress)).to.be.true
    })
  })

  describe('#onlyInstance', async () => {
    it('guards against non-instances calling', async () => {
      await expect(factory.connect(user).onlyCallableByInstance()).to.be.revertedWith(`FactoryNotInstanceError()`)
    })

    it('allows instances to call', async () => {
      const instanceName = 'instance'
      const instanceAddress = await factory.connect(owner).callStatic.create(instanceName)
      await factory.connect(owner).create(instanceName)
      const instance = MockInstance__factory.connect(instanceAddress, owner)
      await expect(instance.connect(user).callOnlyInstanceFunction()).to.not.be.reverted
    })
  })
})
