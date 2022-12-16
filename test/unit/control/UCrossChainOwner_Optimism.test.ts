import { smock, FakeContract } from '@defi-wonderland/smock'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  UCrossChainOwnerOptimism,
  UCrossChainOwnerOptimism__factory,
  ICrossDomainMessenger,
  ERC20PresetMinterPauser__factory,
} from '../../../types/generated'
import { impersonateWithBalance } from '../../testutil/impersonate'

const { ethers } = HRE

describe('UCrossChainOwner_Optimism', () => {
  let owner: SignerWithAddress
  let xChainOwner: SignerWithAddress
  let user: SignerWithAddress
  let uOwner: UCrossChainOwnerOptimism
  let crossDomainMessenger: FakeContract<ICrossDomainMessenger>

  beforeEach(async () => {
    ;[owner, xChainOwner, user] = await ethers.getSigners()
    crossDomainMessenger = await smock.fake<ICrossDomainMessenger>('ICrossDomainMessenger', {
      address: '0x4200000000000000000000000000000000000007',
    })
    await impersonateWithBalance(crossDomainMessenger.address, ethers.utils.parseEther('10'))
    uOwner = await new UCrossChainOwnerOptimism__factory(owner).deploy()
  })

  describe('#send', async () => {
    beforeEach(async () => {
      await uOwner.connect(user).initialize()
      await uOwner.connect(user).updatePendingOwner(xChainOwner.address)
      crossDomainMessenger.xDomainMessageSender.returns(xChainOwner.address)
      await uOwner.connect(crossDomainMessenger.wallet).acceptOwner()
    })

    it('sends funds', async () => {
      const beforeBalance = await user.getBalance()
      crossDomainMessenger.xDomainMessageSender.returns(xChainOwner.address)

      const sendAmount = ethers.utils.parseEther('1')
      await uOwner.connect(crossDomainMessenger.wallet).send(user.address, sendAmount, { value: sendAmount })
      expect(await user.getBalance()).to.equal(beforeBalance.add(sendAmount))
    })

    it('reverts if not owner', async () => {
      crossDomainMessenger.xDomainMessageSender.returns(user.address)
      await expect(
        uOwner.connect(crossDomainMessenger.wallet).send(ethers.constants.AddressZero, 0),
      ).to.be.revertedWith(`UOwnableNotOwnerError("${user.address}")`)
    })
  })

  describe('#execute', async () => {
    beforeEach(async () => {
      await uOwner.connect(user).initialize()
      await uOwner.connect(user).updatePendingOwner(xChainOwner.address)
      crossDomainMessenger.xDomainMessageSender.returns(xChainOwner.address)
      await uOwner.connect(crossDomainMessenger.wallet).acceptOwner()
    })

    it('calls a function', async () => {
      const contract = await new ERC20PresetMinterPauser__factory(owner).deploy('TEST', 'TEST')
      await contract.grantRole(await contract.MINTER_ROLE(), uOwner.address)

      crossDomainMessenger.xDomainMessageSender.returns(xChainOwner.address)
      const mintAmount = ethers.utils.parseEther('1')

      await uOwner
        .connect(crossDomainMessenger.wallet)
        .execute(contract.address, contract.interface.encodeFunctionData('mint', [user.address, mintAmount]), 0)
      expect(await contract.balanceOf(user.address)).to.equal(mintAmount)
    })

    it('reverts if not owner', async () => {
      crossDomainMessenger.xDomainMessageSender.returns(user.address)
      await expect(
        uOwner.connect(crossDomainMessenger.wallet).execute(ethers.constants.AddressZero, '0x', 0),
      ).to.be.revertedWith(`UOwnableNotOwnerError("${user.address}")`)
    })
  })
})
