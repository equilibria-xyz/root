import { smock, FakeContract } from '@defi-wonderland/smock'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  MockUCrossChainOwnableArbitrum,
  MockUCrossChainOwnableArbitrum__factory,
  IArbSys,
} from '../../../types/generated'
import { impersonateWithBalance } from '../../testutil/impersonate'

const { ethers } = HRE

describe('UCrossChainOwnable_Arbitrum', () => {
  let owner: SignerWithAddress
  let xChainOwner: SignerWithAddress
  let user: SignerWithAddress
  let unrelated: SignerWithAddress
  let uOwnable: MockUCrossChainOwnableArbitrum
  let arbSys: FakeContract<IArbSys>

  beforeEach(async () => {
    ;[owner, xChainOwner, user, unrelated] = await ethers.getSigners()
    arbSys = await smock.fake<IArbSys>('IArbSys', {
      address: '0x0000000000000000000000000000000000000064',
    })
    arbSys.wasMyCallersAddressAliased.returns(true)
    await impersonateWithBalance(arbSys.address, ethers.utils.parseEther('10'))
    uOwnable = await new MockUCrossChainOwnableArbitrum__factory(owner).deploy()
  })

  describe('#UOwnable__initialize', async () => {
    beforeEach(async () => {
      arbSys.myCallersAddressWithoutAliasing.returns(xChainOwner.address)
    })

    it('initializes owner', async () => {
      expect(await uOwnable.owner()).to.equal(ethers.constants.AddressZero)

      await expect(uOwnable.connect(arbSys.wallet).__initialize())
        .to.emit(uOwnable, 'OwnerUpdated')
        .withArgs(xChainOwner.address)

      expect(await uOwnable.owner()).to.equal(xChainOwner.address)
    })

    it('reverts if not cross chain', async () => {
      arbSys.wasMyCallersAddressAliased.reset()
      await expect(uOwnable.connect(owner).__initialize()).to.be.revertedWith('NotCrossChainCall()')
    })
  })

  describe('#setPendingOwner', async () => {
    beforeEach(async () => {
      arbSys.myCallersAddressWithoutAliasing.returns(xChainOwner.address)
      await uOwnable.connect(arbSys.wallet).__initialize()
    })

    it('sets pending owner', async () => {
      await expect(uOwnable.connect(arbSys.wallet).updatePendingOwner(user.address))
        .to.emit(uOwnable, 'PendingOwnerUpdated')
        .withArgs(user.address)

      expect(await uOwnable.owner()).to.equal(xChainOwner.address)
      expect(await uOwnable.pendingOwner()).to.equal(user.address)
    })

    it('reverts if not owner', async () => {
      arbSys.myCallersAddressWithoutAliasing.reset()
      arbSys.myCallersAddressWithoutAliasing.returns(user.address)
      await expect(uOwnable.connect(arbSys.wallet).updatePendingOwner(user.address)).to.be.revertedWith(
        `UOwnableNotOwnerError("${user.address}")`,
      )
    })

    it('reset', async () => {
      await expect(uOwnable.connect(arbSys.wallet).updatePendingOwner(ethers.constants.AddressZero))
        .to.emit(uOwnable, 'PendingOwnerUpdated')
        .withArgs(ethers.constants.AddressZero)

      expect(await uOwnable.owner()).to.equal(xChainOwner.address)
      expect(await uOwnable.pendingOwner()).to.equal(ethers.constants.AddressZero)
    })
  })

  describe('#acceptOwner', async () => {
    beforeEach(async () => {
      arbSys.myCallersAddressWithoutAliasing.returns(xChainOwner.address)
      await uOwnable.connect(arbSys.wallet).__initialize()
      await uOwnable.connect(arbSys.wallet).updatePendingOwner(user.address)
    })

    it('transfers owner', async () => {
      arbSys.myCallersAddressWithoutAliasing.reset()
      arbSys.myCallersAddressWithoutAliasing.returns(user.address)
      await expect(uOwnable.connect(arbSys.wallet).acceptOwner())
        .to.emit(uOwnable, 'OwnerUpdated')
        .withArgs(user.address)

      expect(await uOwnable.owner()).to.equal(user.address)
      expect(await uOwnable.pendingOwner()).to.equal(ethers.constants.AddressZero)
    })

    it('reverts if owner not pending owner', async () => {
      await expect(uOwnable.connect(arbSys.wallet).acceptOwner()).to.be.revertedWith(
        `UOwnableNotPendingOwnerError("${xChainOwner.address}")`,
      )
    })

    it('reverts if unrelated not pending owner', async () => {
      arbSys.myCallersAddressWithoutAliasing.reset()
      arbSys.myCallersAddressWithoutAliasing.returns(unrelated.address)
      await expect(uOwnable.connect(arbSys.wallet).acceptOwner()).to.be.revertedWith(
        `UOwnableNotPendingOwnerError("${unrelated.address}")`,
      )
    })
  })

  describe('onlyOwner modifier', async () => {
    beforeEach(async () => {
      await uOwnable.connect(arbSys.wallet).__initialize()
    })

    it('reverts if not owner', async () => {
      arbSys.myCallersAddressWithoutAliasing.returns(user.address)
      await expect(uOwnable.connect(arbSys.wallet).mustOwner()).to.be.revertedWith(
        `UOwnableNotOwnerError("${user.address}")`,
      )
    })
  })
})
