import { smock, FakeContract } from '@defi-wonderland/smock'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  MockUCrossChainOwnableOptimism,
  MockUCrossChainOwnableOptimism__factory,
  ICrossDomainMessenger,
} from '../../../types/generated'
import { impersonateWithBalance } from '../../testutil/impersonate'

const { ethers } = HRE

describe('UCrossChainOwnable_Optimism', () => {
  let owner: SignerWithAddress
  let xChainOwner: SignerWithAddress
  let user: SignerWithAddress
  let unrelated: SignerWithAddress
  let uOwnable: MockUCrossChainOwnableOptimism
  let crossDomainMessenger: FakeContract<ICrossDomainMessenger>

  beforeEach(async () => {
    ;[owner, xChainOwner, user, unrelated] = await ethers.getSigners()
    crossDomainMessenger = await smock.fake<ICrossDomainMessenger>('ICrossDomainMessenger', {
      address: '0x4200000000000000000000000000000000000007',
    })
    await impersonateWithBalance(crossDomainMessenger.address, ethers.utils.parseEther('10'))
    uOwnable = await new MockUCrossChainOwnableOptimism__factory(owner).deploy()
  })

  describe('#UOwnable__initialize', async () => {
    beforeEach(async () => {
      crossDomainMessenger.xDomainMessageSender.returns(xChainOwner.address)
    })

    it('initializes owner to msg.sender', async () => {
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
      crossDomainMessenger.xDomainMessageSender.returns(xChainOwner.address)
      await uOwnable.connect(user).__initialize()
      await uOwnable.connect(user).updatePendingOwner(xChainOwner.address)
    })

    it('transfers owner', async () => {
      await expect(uOwnable.connect(crossDomainMessenger.wallet).acceptOwner())
        .to.emit(uOwnable, 'OwnerUpdated')
        .withArgs(xChainOwner.address)

      expect(await uOwnable.owner()).to.equal(xChainOwner.address)
      expect(await uOwnable.pendingOwner()).to.equal(ethers.constants.AddressZero)
    })

    it('reverts if not cross chain', async () => {
      await expect(uOwnable.connect(xChainOwner).acceptOwner()).to.be.revertedWith('NotCrossChainCall()')
    })

    it('reverts if owner not pending owner', async () => {
      crossDomainMessenger.xDomainMessageSender.reset()
      crossDomainMessenger.xDomainMessageSender.returns(user.address)
      await expect(uOwnable.connect(crossDomainMessenger.wallet).acceptOwner()).to.be.revertedWith(
        `UOwnableNotPendingOwnerError("${user.address}")`,
      )
    })

    it('reverts if unrelated not pending owner', async () => {
      crossDomainMessenger.xDomainMessageSender.reset()
      crossDomainMessenger.xDomainMessageSender.returns(unrelated.address)
      await expect(uOwnable.connect(crossDomainMessenger.wallet).acceptOwner()).to.be.revertedWith(
        `UOwnableNotPendingOwnerError("${unrelated.address}")`,
      )
    })
  })

  describe('onlyOwner modifier', async () => {
    beforeEach(async () => {
      await uOwnable.connect(user).__initialize()
      await uOwnable.connect(user).updatePendingOwner(xChainOwner.address)
      crossDomainMessenger.xDomainMessageSender.returns(xChainOwner.address)
      await uOwnable.connect(crossDomainMessenger.wallet).acceptOwner()
    })

    it('reverts if not owner', async () => {
      crossDomainMessenger.xDomainMessageSender.returns(user.address)
      await expect(uOwnable.connect(crossDomainMessenger.wallet).mustOwner()).to.be.revertedWith(
        `UOwnableNotOwnerError("${user.address}")`,
      )
    })
  })
})
