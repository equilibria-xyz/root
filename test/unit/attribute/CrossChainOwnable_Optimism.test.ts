import { smock, FakeContract } from '@defi-wonderland/smock'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  MockCrossChainOwnableOptimism,
  MockCrossChainOwnableOptimism__factory,
  ICrossDomainMessenger,
} from '../../../types/generated'
import { impersonateWithBalance } from '../../testutil/impersonate'

const { ethers } = HRE

describe('CrossChainOwnable_Optimism', () => {
  let owner: SignerWithAddress
  let xChainOwner: SignerWithAddress
  let user: SignerWithAddress
  let unrelated: SignerWithAddress
  let ownable: MockCrossChainOwnableOptimism
  let crossDomainMessenger: FakeContract<ICrossDomainMessenger>

  beforeEach(async () => {
    ;[owner, xChainOwner, user, unrelated] = await ethers.getSigners()
    crossDomainMessenger = await smock.fake<ICrossDomainMessenger>('ICrossDomainMessenger', {
      address: '0x4200000000000000000000000000000000000007',
    })
    await impersonateWithBalance(crossDomainMessenger.address, ethers.utils.parseEther('10'))
    ownable = await new MockCrossChainOwnableOptimism__factory(owner).deploy()
  })

  describe('#Ownable__initialize', async () => {
    beforeEach(async () => {
      crossDomainMessenger.xDomainMessageSender.returns(xChainOwner.address)
    })

    it('initializes owner to msg.sender', async () => {
      expect(await ownable.owner()).to.equal(ethers.constants.AddressZero)

      await expect(ownable.connect(user).__initialize()).to.emit(ownable, 'OwnerUpdated').withArgs(user.address)

      expect(await ownable.owner()).to.equal(user.address)
    })
  })

  describe('#setPendingOwner', async () => {
    beforeEach(async () => {
      await ownable.connect(user).__initialize()
    })

    it('sets pending owner', async () => {
      await expect(ownable.connect(user).updatePendingOwner(xChainOwner.address))
        .to.emit(ownable, 'PendingOwnerUpdated')
        .withArgs(xChainOwner.address)

      expect(await ownable.owner()).to.equal(user.address)
      expect(await ownable.pendingOwner()).to.equal(xChainOwner.address)
    })

    it('reverts if not owner', async () => {
      await expect(ownable.connect(unrelated).updatePendingOwner(unrelated.address)).to.be.revertedWith(
        `OwnableNotOwnerError("${unrelated.address}")`,
      )
    })

    it('reset', async () => {
      await expect(ownable.connect(user).updatePendingOwner(ethers.constants.AddressZero))
        .to.emit(ownable, 'PendingOwnerUpdated')
        .withArgs(ethers.constants.AddressZero)

      expect(await ownable.owner()).to.equal(user.address)
      expect(await ownable.pendingOwner()).to.equal(ethers.constants.AddressZero)
    })
  })

  describe('#acceptOwner', async () => {
    beforeEach(async () => {
      crossDomainMessenger.xDomainMessageSender.returns(xChainOwner.address)
      await ownable.connect(user).__initialize()
      await ownable.connect(user).updatePendingOwner(xChainOwner.address)
    })

    it('transfers owner', async () => {
      await expect(ownable.connect(crossDomainMessenger.wallet).acceptOwner())
        .to.emit(ownable, 'OwnerUpdated')
        .withArgs(xChainOwner.address)

      expect(await ownable.owner()).to.equal(xChainOwner.address)
      expect(await ownable.pendingOwner()).to.equal(ethers.constants.AddressZero)
    })

    it('reverts if not cross chain', async () => {
      await expect(ownable.connect(xChainOwner).acceptOwner()).to.be.revertedWith('NotCrossChainCall()')
    })

    it('reverts if owner not pending owner', async () => {
      crossDomainMessenger.xDomainMessageSender.reset()
      crossDomainMessenger.xDomainMessageSender.returns(user.address)
      await expect(ownable.connect(crossDomainMessenger.wallet).acceptOwner()).to.be.revertedWith(
        `OwnableNotPendingOwnerError("${user.address}")`,
      )
    })

    it('reverts if unrelated not pending owner', async () => {
      crossDomainMessenger.xDomainMessageSender.reset()
      crossDomainMessenger.xDomainMessageSender.returns(unrelated.address)
      await expect(ownable.connect(crossDomainMessenger.wallet).acceptOwner()).to.be.revertedWith(
        `OwnableNotPendingOwnerError("${unrelated.address}")`,
      )
    })
  })

  describe('onlyOwner modifier', async () => {
    beforeEach(async () => {
      await ownable.connect(user).__initialize()
      await ownable.connect(user).updatePendingOwner(xChainOwner.address)
      crossDomainMessenger.xDomainMessageSender.returns(xChainOwner.address)
      await ownable.connect(crossDomainMessenger.wallet).acceptOwner()
    })

    it('reverts if not owner', async () => {
      crossDomainMessenger.xDomainMessageSender.returns(user.address)
      await expect(ownable.connect(crossDomainMessenger.wallet).mustOwner()).to.be.revertedWith(
        `OwnableNotOwnerError("${user.address}")`,
      )
    })
  })
})
