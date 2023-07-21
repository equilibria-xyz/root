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

    it('initializes owner as msg.sender', async () => {
      expect(await uOwnable.owner()).to.equal(ethers.constants.AddressZero)

      await expect(uOwnable.connect(user).__initialize()).to.emit(uOwnable, 'OwnerUpdated').withArgs(user.address)

      expect(await uOwnable.owner()).to.equal(user.address)
    })
  })

  describe('#setPendingOwner', async () => {
    beforeEach(async () => {
      await uOwnable.connect(user).__initialize()
    })

    it('sets pending owner', async () => {
      await expect(uOwnable.connect(user).updatePendingOwner(xChainOwner.address))
        .to.emit(uOwnable, 'PendingOwnerUpdated')
        .withArgs(xChainOwner.address)

      expect(await uOwnable.owner()).to.equal(user.address)
      expect(await uOwnable.pendingOwner()).to.equal(xChainOwner.address)
    })

    it('reverts if not owner', async () => {
      arbSys.myCallersAddressWithoutAliasing.reset()
      arbSys.myCallersAddressWithoutAliasing.returns(user.address)
      await expect(uOwnable.connect(unrelated).updatePendingOwner(unrelated.address)).to.be.revertedWith(
        `UOwnableNotOwnerError("${unrelated.address}")`,
      )
    })

    it('reset', async () => {
      await expect(uOwnable.connect(user).updatePendingOwner(ethers.constants.AddressZero))
        .to.emit(uOwnable, 'PendingOwnerUpdated')
        .withArgs(ethers.constants.AddressZero)

      expect(await uOwnable.owner()).to.equal(user.address)
      expect(await uOwnable.pendingOwner()).to.equal(ethers.constants.AddressZero)
    })
  })

  describe('#acceptOwner', async () => {
    beforeEach(async () => {
      arbSys.myCallersAddressWithoutAliasing.returns(xChainOwner.address)
      await uOwnable.connect(user).__initialize()
      await uOwnable.connect(user).updatePendingOwner(xChainOwner.address)
    })

    it('transfers owner', async () => {
      await expect(uOwnable.connect(arbSys.wallet).acceptOwner())
        .to.emit(uOwnable, 'OwnerUpdated')
        .withArgs(xChainOwner.address)

      expect(await uOwnable.owner()).to.equal(xChainOwner.address)
      expect(await uOwnable.pendingOwner()).to.equal(ethers.constants.AddressZero)
      expect(await uOwnable.crossChainRestricted()).to.equal(true)
    })

    it('reverts if not cross chain', async () => {
      arbSys.wasMyCallersAddressAliased.returns(false)
      await expect(uOwnable.connect(xChainOwner).acceptOwner()).to.be.revertedWith('NotCrossChainCall()')
    })

    it('reverts if owner not pending owner', async () => {
      arbSys.myCallersAddressWithoutAliasing.reset()
      arbSys.myCallersAddressWithoutAliasing.returns(user.address)
      await expect(uOwnable.connect(arbSys.wallet).acceptOwner()).to.be.revertedWith(
        `UOwnableNotPendingOwnerError("${user.address}")`,
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
      await uOwnable.connect(user).__initialize()
      await uOwnable.connect(user).updatePendingOwner(xChainOwner.address)

      arbSys.myCallersAddressWithoutAliasing.returns(xChainOwner.address)
      await uOwnable.connect(arbSys.wallet).acceptOwner()
    })

    it('reverts if not owner', async () => {
      arbSys.myCallersAddressWithoutAliasing.returns(user.address)
      await expect(uOwnable.connect(arbSys.wallet).mustOwner()).to.be.revertedWith(
        `UOwnableNotOwnerError("${user.address}")`,
      )
    })
  })
})
