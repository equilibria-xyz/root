import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  MockUInitializable,
  MockUInitializable__factory,
  MockUInitializableConstructor1__factory,
  MockUInitializableConstructor3__factory,
  MockUInitializableConstructor5__factory,
  MockUInitializableConstructor6__factory,
  MockUInitializableConstructor8__factory,
  MockUInitializableMulti__factory,
} from '../../../types/generated'

const { ethers } = HRE

describe('UInitializer', () => {
  let owner: SignerWithAddress
  let uInitializable: MockUInitializable

  beforeEach(async () => {
    ;[owner] = await ethers.getSigners()
  })

  describe('#initalizer', async () => {
    beforeEach(async () => {
      uInitializable = await new MockUInitializable__factory(owner).deploy()
      expect(await uInitializable.__version()).to.equal(0)
    })

    it('successfully initializes', async () => {
      await expect(uInitializable.initialize())
        .to.emit(uInitializable, 'NoOp')
        .withArgs()
        .to.emit(uInitializable, 'Initialized')
        .withArgs(1)
      expect(await uInitializable.__version()).to.equal(1)
    })

    it('successfully initializes with children', async () => {
      await expect(uInitializable.initializeWithChildren())
        .to.emit(uInitializable, 'NoOp')
        .withArgs()
        .to.emit(uInitializable, 'NoOpChild')
        .withArgs()
        .to.emit(uInitializable, 'Initialized')
        .withArgs(1)
      expect(await uInitializable.__version()).to.equal(1)
    })

    it('successfully initializes when constructor calls onlyInitializer (1)', async () => {
      const uInitializableConstructor1 = await new MockUInitializableConstructor1__factory(owner).deploy()
      expect(await uInitializableConstructor1.__version()).to.equal(0)
    })

    it('successfully initializes when constructor has initializer modifier (3)', async () => {
      const uInitializableConstructor3 = await new MockUInitializableConstructor3__factory(owner).deploy()
      expect(await uInitializableConstructor3.__version()).to.equal(1)
    })

    it('successfully initializes when inherited constructor calls onlyInitializer (5)', async () => {
      const uInitializableConstructor5 = await new MockUInitializableConstructor5__factory(owner).deploy()
      expect(await uInitializableConstructor5.__version()).to.equal(0)
    })

    it('successfully initializes when constructor and inherited constructor calls onlyInitializer (6)', async () => {
      const uInitializableConstructor6 = await new MockUInitializableConstructor6__factory(owner).deploy()
      expect(await uInitializableConstructor6.__version()).to.equal(0)
    })

    it('successfully initializes when inherited constructor has initializer modifier (8)', async () => {
      const uInitializableConstructor8 = await new MockUInitializableConstructor8__factory(owner).deploy()
      expect(await uInitializableConstructor8.__version()).to.equal(1)
    })

    it('reverts if initialized twice', async () => {
      await expect(uInitializable.initialize()).to.emit(uInitializable, 'NoOp').withArgs()
      await expect(uInitializable.initialize()).to.be.revertedWith(`UInitializableAlreadyInitializedError(1)`)
    })

    it('reverts if double initialized', async () => {
      await expect(uInitializable.doubleInitialize()).to.be.revertedWith(`UInitializableAlreadyInitializedError(1)`)
    })

    it('reverts if invalid version', async () => {
      await expect(uInitializable.customInitializer(0)).to.be.revertedWith(`UInitializableZeroVersionError()`)
    })

    it('doesnt revert for valid version', async () => {
      await uInitializable.customInitializer(1)
    })

    it('successfully initializes new version', async () => {
      const uInitializableMulti = await new MockUInitializableMulti__factory(owner).deploy()
      await uInitializableMulti.initialize1()

      await expect(uInitializableMulti.initialize2())
        .to.emit(uInitializableMulti, 'NoOp')
        .withArgs(2)
        .to.emit(uInitializableMulti, 'Initialized')
        .withArgs(2)
      expect(await uInitializableMulti.__version()).to.equal(2)
    })

    it('successfully initializes new version way ahead', async () => {
      const uInitializableMulti = await new MockUInitializableMulti__factory(owner).deploy()
      await uInitializableMulti.initialize1()

      await expect(uInitializableMulti.initialize17())
        .to.emit(uInitializableMulti, 'NoOp')
        .withArgs(17)
        .to.emit(uInitializableMulti, 'Initialized')
        .withArgs(17)
      expect(await uInitializableMulti.__version()).to.equal(17)
    })

    it('successfully initializes new version max', async () => {
      const uInitializableMulti = await new MockUInitializableMulti__factory(owner).deploy()
      await uInitializableMulti.initialize1()

      await expect(uInitializableMulti.initializeMax())
        .to.emit(uInitializableMulti, 'NoOp')
        .withArgs(ethers.constants.MaxUint256)
        .to.emit(uInitializableMulti, 'Initialized')
        .withArgs(ethers.constants.MaxUint256)
      expect(await uInitializableMulti.__version()).to.equal(ethers.constants.MaxUint256)
    })

    it('reverts if same version', async () => {
      const uInitializableMulti = await new MockUInitializableMulti__factory(owner).deploy()
      await uInitializableMulti.initialize17()

      await expect(uInitializableMulti.initialize17()).to.be.revertedWith(`UInitializableAlreadyInitializedError(17)`)
    })

    it('reverts if lesser version', async () => {
      const uInitializableMulti = await new MockUInitializableMulti__factory(owner).deploy()
      await uInitializableMulti.initialize17()

      await expect(uInitializableMulti.initialize2()).to.be.revertedWith(`UInitializableAlreadyInitializedError(2)`)
    })
  })

  describe('#onlyInitializing', async () => {
    beforeEach(async () => {
      uInitializable = await new MockUInitializable__factory(owner).deploy()
      expect(await uInitializable.__version()).to.equal(0)
    })

    it('reverts if initialized twice', async () => {
      await expect(uInitializable.initialize()).to.emit(uInitializable, 'NoOp').withArgs()
      await expect(uInitializable.initialize()).to.be.revertedWith(`UInitializableAlreadyInitializedError(1)`)
    })

    it('reverts if initialized twice with children', async () => {
      await expect(uInitializable.initializeWithChildren()).to.emit(uInitializable, 'NoOp').withArgs()
      await expect(uInitializable.initializeWithChildren()).to.be.revertedWith(
        `UInitializableAlreadyInitializedError(1)`,
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
