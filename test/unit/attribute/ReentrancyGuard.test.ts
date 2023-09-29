import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockReentrancyGuard, MockReentrancyGuard__factory } from '../../../types/generated'

const { ethers } = HRE

describe('ReentrancyGuard', () => {
  let owner: SignerWithAddress
  let reentrancyGuard: MockReentrancyGuard

  beforeEach(async () => {
    ;[owner] = await ethers.getSigners()
    reentrancyGuard = await new MockReentrancyGuard__factory(owner).deploy()
  })

  describe('#ReentrancyGuard__initialize', async () => {
    it('unset if not initialize', async () => {
      expect(await reentrancyGuard.__status()).to.equal(0)
    })

    it('initializes status', async () => {
      await reentrancyGuard.connect(owner).__initialize()
      expect(await reentrancyGuard.__status()).to.equal(1)
    })
  })

  describe('doesnt reenter', async () => {
    it('reverts', async () => {
      await expect(reentrancyGuard.noReenter()).to.emit(reentrancyGuard, 'NoOp')
    })
  })

  describe('reenter same function', async () => {
    it('reverts', async () => {
      await expect(reentrancyGuard.reenterRecursive()).to.be.revertedWith(`ReentrancyGuardReentrantCallError()`)
    })
  })

  describe('reenter different function', async () => {
    it('reverts', async () => {
      await expect(reentrancyGuard.reenterDifferent()).to.be.revertedWith(`ReentrancyGuardReentrantCallError()`)
    })
  })
})
