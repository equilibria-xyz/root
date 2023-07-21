import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  MockInitializable,
  MockInitializable__factory,
  MockUInitializableConstructor1__factory,
  MockUInitializableConstructor3__factory,
  MockUInitializableConstructor5__factory,
  MockUInitializableConstructor6__factory,
  MockUInitializableConstructor8__factory,
  MockUInitializableMulti__factory,
} from '../../../types/generated'

const { ethers } = HRE

describe('Initializable', () => {
  let owner: SignerWithAddress
  let initializable: MockInitializable

  beforeEach(async () => {
    ;[owner] = await ethers.getSigners()
  })

  describe('#initalizer', async () => {
    beforeEach(async () => {
      initializable = await new MockInitializable__factory(owner).deploy()
      expect(await initializable.__version()).to.equal(0)
    })

    it('successfully initializes', async () => {
      await expect(initializable.initialize())
        .to.emit(initializable, 'NoOp')
        .withArgs()
        .to.emit(initializable, 'Initialized')
        .withArgs(1)
      expect(await initializable.__version()).to.equal(1)
    })

    it('successfully initializes with children', async () => {
      await expect(initializable.initializeWithChildren())
        .to.emit(initializable, 'NoOp')
        .withArgs()
        .to.emit(initializable, 'NoOpChild')
        .withArgs()
        .to.emit(initializable, 'Initialized')
        .withArgs(1)
      expect(await initializable.__version()).to.equal(1)
    })

    it('successfully initializes when constructor calls onlyInitializer (1)', async () => {
      const initializableConstructor1 = await new MockUInitializableConstructor1__factory(owner).deploy()
      expect(await initializableConstructor1.__version()).to.equal(0)
    })

    it('successfully initializes when constructor has initializer modifier (3)', async () => {
      const initializableConstructor3 = await new MockUInitializableConstructor3__factory(owner).deploy()
      expect(await initializableConstructor3.__version()).to.equal(1)
    })

    it('successfully initializes when inherited constructor calls onlyInitializer (5)', async () => {
      const initializableConstructor5 = await new MockUInitializableConstructor5__factory(owner).deploy()
      expect(await initializableConstructor5.__version()).to.equal(0)
    })

    it('successfully initializes when constructor and inherited constructor calls onlyInitializer (6)', async () => {
      const initializableConstructor6 = await new MockUInitializableConstructor6__factory(owner).deploy()
      expect(await initializableConstructor6.__version()).to.equal(0)
    })

    it('successfully initializes when inherited constructor has initializer modifier (8)', async () => {
      const initializableConstructor8 = await new MockUInitializableConstructor8__factory(owner).deploy()
      expect(await initializableConstructor8.__version()).to.equal(1)
    })

    it('reverts if initialized twice', async () => {
      await expect(initializable.initialize()).to.emit(initializable, 'NoOp').withArgs()
      await expect(initializable.initialize()).to.be.revertedWith(`UInitializableAlreadyInitializedError(1)`)
    })

    it('reverts if double initialized', async () => {
      await expect(initializable.doubleInitialize()).to.be.revertedWith(`UInitializableAlreadyInitializedError(1)`)
    })

    it('reverts if invalid version', async () => {
      await expect(initializable.customInitializer(0)).to.be.revertedWith(`UInitializableZeroVersionError()`)
    })

    it('doesnt revert for valid version', async () => {
      await initializable.customInitializer(1)
    })

    it('successfully initializes new version', async () => {
      const initializableMulti = await new MockUInitializableMulti__factory(owner).deploy()
      await initializableMulti.initialize1()

      await expect(initializableMulti.initialize2())
        .to.emit(initializableMulti, 'NoOp')
        .withArgs(2)
        .to.emit(initializableMulti, 'Initialized')
        .withArgs(2)
      expect(await initializableMulti.__version()).to.equal(2)
    })

    it('successfully initializes new version way ahead', async () => {
      const initializableMulti = await new MockUInitializableMulti__factory(owner).deploy()
      await initializableMulti.initialize1()

      await expect(initializableMulti.initialize17())
        .to.emit(initializableMulti, 'NoOp')
        .withArgs(17)
        .to.emit(initializableMulti, 'Initialized')
        .withArgs(17)
      expect(await initializableMulti.__version()).to.equal(17)
    })

    it('successfully initializes new version max', async () => {
      const initializableMulti = await new MockUInitializableMulti__factory(owner).deploy()
      await initializableMulti.initialize1()

      await expect(initializableMulti.initializeMax())
        .to.emit(initializableMulti, 'NoOp')
        .withArgs(ethers.constants.MaxUint256)
        .to.emit(initializableMulti, 'Initialized')
        .withArgs(ethers.constants.MaxUint256)
      expect(await initializableMulti.__version()).to.equal(ethers.constants.MaxUint256)
    })

    it('reverts if same version', async () => {
      const initializableMulti = await new MockUInitializableMulti__factory(owner).deploy()
      await initializableMulti.initialize17()

      await expect(initializableMulti.initialize17()).to.be.revertedWith(`UInitializableAlreadyInitializedError(17)`)
    })

    it('reverts if lesser version', async () => {
      const initializableMulti = await new MockUInitializableMulti__factory(owner).deploy()
      await initializableMulti.initialize17()

      await expect(initializableMulti.initialize2()).to.be.revertedWith(`UInitializableAlreadyInitializedError(2)`)
    })
  })

  describe('#onlyInitializing', async () => {
    beforeEach(async () => {
      initializable = await new MockInitializable__factory(owner).deploy()
      expect(await initializable.__version()).to.equal(0)
    })

    it('reverts if initialized twice', async () => {
      await expect(initializable.initialize()).to.emit(initializable, 'NoOp').withArgs()
      await expect(initializable.initialize()).to.be.revertedWith(`UInitializableAlreadyInitializedError(1)`)
    })

    it('reverts if initialized twice with children', async () => {
      await expect(initializable.initializeWithChildren()).to.emit(initializable, 'NoOp').withArgs()
      await expect(initializable.initializeWithChildren()).to.be.revertedWith(
        `UInitializableAlreadyInitializedError(1)`,
      )
    })

    it('reverts if child initializer called directly', async () => {
      await expect(initializable.childInitializer()).to.be.revertedWith(`UInitializableNotInitializingError()`)
    })

    it('reverts if child initializer called directly after initialization', async () => {
      await expect(initializable.initialize()).to.emit(initializable, 'NoOp').withArgs()
      await expect(initializable.childInitializer()).to.be.revertedWith(`UInitializableNotInitializingError()`)
    })
  })
})
