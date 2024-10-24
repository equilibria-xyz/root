import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockFactory, MockFactory__factory, MockInstance, MockInstance__factory } from '../../../types/generated'
import { impersonateWithBalance } from '../../testutil/impersonate'
import { Signer } from 'ethers/lib/ethers'

const { ethers } = HRE

describe('Instance', () => {
  let owner: SignerWithAddress
  let pauser: SignerWithAddress
  let user: SignerWithAddress
  let factory: MockFactory
  let instanceImplementation: MockInstance
  let instance: MockInstance
  let factorySigner: Signer
  let instanceName: string

  beforeEach(async () => {
    ;[owner, pauser, user] = await ethers.getSigners()
    instanceImplementation = await new MockInstance__factory(owner).deploy()
    factory = await new MockFactory__factory(owner).deploy(instanceImplementation.address)
    await factory.connect(owner).initialize()
    await factory.connect(owner).updatePauser(pauser.address)
    instanceName = 'instance'
    const instanceAddress = await factory.connect(owner).callStatic.create(instanceName)
    await factory.connect(owner).create(instanceName)
    factorySigner = await impersonateWithBalance(factory.address, ethers.utils.parseEther('10'))
    instance = MockInstance__factory.connect(instanceAddress, owner)
  })

  describe('#initialize', async () => {
    it('reverts when reintializing', async () => {
      await expect(instance.connect(owner).initializeIncorrect()).to.be.reverted
    })
  })

  describe('#factory', async () => {
    it('initializes factory', async () => {
      expect(await instance.factory()).to.equal(factory.address)
    })
  })

  describe('#onlyOwner', async () => {
    it('restricts onlyOwner functions to only be called by the owner', async () => {
      await expect(instance.connect(user).protectedFunctionOwner(instanceName)).to.be.revertedWith(
        `InstanceNotOwnerError("${user.address}")`,
      )
      await expect(instance.connect(owner).protectedFunctionOwner(instanceName)).to.not.be.reverted
    })
  })

  describe('#onlyFactory', async () => {
    it('restricts onlyFactory functions to only be called by the factory signer', async () => {
      await expect(instance.connect(user).protectedFunctionFactory(instanceName)).to.be.revertedWith(
        `InstanceNotFactoryError("${user.address}")`,
      )
      await expect(instance.connect(factorySigner).protectedFunctionFactory(instanceName)).to.not.be.reverted
    })
  })

  describe('#whenNotPaused', async () => {
    it('restricts whenNotPaused functions to only be called when not paused', async () => {
      await expect(instance.connect(owner).protectedFunctionPaused(instanceName)).to.not.be.reverted
      await factory.connect(pauser).pause()
      await expect(instance.connect(owner).protectedFunctionPaused(instanceName)).to.be.revertedWith(
        `InstancePausedError()`,
      )
    })
  })
})
