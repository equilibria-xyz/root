import { expect } from 'chai'
import { ethers } from 'hardhat'
import { OwnableStub } from '../../../types/generated/OwnableStub'
import { MockOwnable } from '../../../types/generated/MockOwnable'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { MockOwnable__factory, OwnableStub__factory } from '../../../types/generated'

describe('OwnableStub', function () {
  let ownableStub: OwnableStub
  let ownableContract: MockOwnable
  let owner: SignerWithAddress
  let addr1: SignerWithAddress

  beforeEach(async function () {
    ;[owner, addr1] = await ethers.getSigners()

    ownableStub = await new OwnableStub__factory(owner).deploy()
    ownableContract = await new MockOwnable__factory(owner).deploy()
    await ownableContract.__initialize()
  })

  describe('acceptOwner', function () {
    it('should accept ownership of an ownable contract', async function () {
      // Set the stub as pending owner
      await ownableContract.connect(owner).updatePendingOwner(ownableStub.address)
      expect(await ownableContract.pendingOwner()).to.equal(ownableStub.address)

      // Accept ownership through the stub
      await ownableStub.acceptOwner(ownableContract.address)

      // Verify ownership was transferred
      expect(await ownableContract.owner()).to.equal(ownableStub.address)
      expect(await ownableContract.pendingOwner()).to.equal(ethers.constants.AddressZero)
    })

    it('should revert if stub is not the pending owner', async function () {
      // Set addr1 as pending owner instead of stub
      await ownableContract.connect(owner).updatePendingOwner(addr1.address)

      // Attempt to accept ownership through stub should fail
      await expect(ownableStub.acceptOwner(ownableContract.address)).to.be.revertedWithCustomError(
        ownableContract,
        'OwnableNotPendingOwnerError',
      )
    })
  })
})
