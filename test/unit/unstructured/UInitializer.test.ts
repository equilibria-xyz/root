import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  MockUInitializable,
  MockUInitializable__factory,
  MockUInitializableConstructor1__factory,
  MockUInitializableConstructor2__factory,
  MockUInitializableConstructor3__factory,
  MockUInitializableConstructor4__factory,
  MockUInitializableConstructor5__factory,
  MockUInitializableConstructor6__factory,
} from '../../../types/generated'

const { ethers } = HRE

describe.only('UInitializer', () => {
  let owner: SignerWithAddress
  let uInitializable: MockUInitializable

  beforeEach(async () => {
    ;[owner] = await ethers.getSigners()
  })

  describe('#initalizer', async () => {
    beforeEach(async () => {
      uInitializable = await new MockUInitializable__factory(owner).deploy()
      expect(await uInitializable.__initialized()).to.equal(false)
    })

    it('successfully initializes', async () => {
      await expect(uInitializable.initialize()).to.emit(uInitializable, 'NoOp').withArgs()
      expect(await uInitializable.__initialized()).to.equal(true)
    })

    it('successfully initializes with children', async () => {
      await expect(uInitializable.initializeWithChildren())
        .to.emit(uInitializable, 'NoOp')
        .withArgs()
        .to.emit(uInitializable, 'NoOpChild')
        .withArgs()
      expect(await uInitializable.__initialized()).to.equal(true)
    })

    it('successfully initializes when constructor calls onlyInitializer (1)', async () => {
      const uInitializableConstructor1 = await new MockUInitializableConstructor1__factory(owner).deploy()
      expect(await uInitializableConstructor1.__initialized()).to.equal(false)
    })

    it('reverts when constructor calls initializer (2)', async () => {
      await expect(new MockUInitializableConstructor2__factory(owner).deploy()).to.be.revertedWith(
        `UInitializableCalledFromConstructorError()`,
      )
    })

    it('reverts when constructor has initializer modifier (3)', async () => {
      await expect(new MockUInitializableConstructor3__factory(owner).deploy()).to.be.revertedWith(
        `UInitializableCalledFromConstructorError()`,
      )
    })

    it('reverts when constructor calls initializer with children (4)', async () => {
      await expect(new MockUInitializableConstructor4__factory(owner).deploy()).to.be.revertedWith(
        `UInitializableCalledFromConstructorError()`,
      )
    })

    it('successfully initializes when inherited constructor calls onlyInitializer (5)', async () => {
      const uInitializableConstructor5 = await new MockUInitializableConstructor5__factory(owner).deploy()
      expect(await uInitializableConstructor5.__initialized()).to.equal(false)
    })

    it('successfully initializes when constructor and inherited constructor calls onlyInitializer (6)', async () => {
      const uInitializableConstructor6 = await new MockUInitializableConstructor6__factory(owner).deploy()
      expect(await uInitializableConstructor6.__initialized()).to.equal(false)
    })

    it('reverts if initialized twice', async () => {
      await expect(uInitializable.initialize()).to.emit(uInitializable, 'NoOp').withArgs()
      await expect(uInitializable.initialize()).to.be.revertedWith(`UInitializableAlreadyInitializedError()`)
    })

    it('reverts if double initialized', async () => {
      await expect(uInitializable.doubleInitialize()).to.be.revertedWith(`UInitializableAlreadyInitializedError()`)
    })
  })

  describe('#onlyInitializing', async () => {
    beforeEach(async () => {
      uInitializable = await new MockUInitializable__factory(owner).deploy()
      expect(await uInitializable.__initialized()).to.equal(false)
    })

    it('reverts if initialized twice', async () => {
      await expect(uInitializable.initialize()).to.emit(uInitializable, 'NoOp').withArgs()
      await expect(uInitializable.initialize()).to.be.revertedWith(`UInitializableAlreadyInitializedError()`)
    })

    it('reverts if initialized twice with children', async () => {
      await expect(uInitializable.initializeWithChildren()).to.emit(uInitializable, 'NoOp').withArgs()
      await expect(uInitializable.initializeWithChildren()).to.be.revertedWith(
        `UInitializableAlreadyInitializedError()`,
      )
    })

    it('reverts if child initializer called directly', async () => {
      await expect(uInitializable.childInitializer()).to.be.revertedWith(`UInitializableNotInitializingError()`)
    })

    it('reverts if child initializer called directly after initialization', async () => {
      await expect(uInitializable.initialize()).to.emit(uInitializable, 'NoOp').withArgs()
      await expect(uInitializable.childInitializer()).to.be.revertedWith(`UInitializableNotInitializingError()`)
    })
  })
})
