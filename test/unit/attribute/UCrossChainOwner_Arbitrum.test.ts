import { smock, FakeContract } from '@defi-wonderland/smock'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  UCrossChainOwnerArbitrum,
  UCrossChainOwnerArbitrum__factory,
  IArbSys,
  MockERC20__factory,
} from '../../../types/generated'
import { impersonateWithBalance } from '../../testutil/impersonate'

const { ethers } = HRE

describe('UCrossChainOwner_Arbitrum', () => {
  let owner: SignerWithAddress
  let xChainOwner: SignerWithAddress
  let user: SignerWithAddress
  let uOwner: UCrossChainOwnerArbitrum
  let arbSys: FakeContract<IArbSys>

  beforeEach(async () => {
    ;[owner, xChainOwner, user] = await ethers.getSigners()
    arbSys = await smock.fake<IArbSys>('IArbSys', {
      address: '0x0000000000000000000000000000000000000064',
    })
    arbSys.wasMyCallersAddressAliased.returns(true)
    await impersonateWithBalance(arbSys.address, ethers.utils.parseEther('10'))
    uOwner = await new UCrossChainOwnerArbitrum__factory(owner).deploy()
  })

  describe('#execute', async () => {
    beforeEach(async () => {
      await uOwner.connect(user).initialize()
      await uOwner.connect(user).updatePendingOwner(xChainOwner.address)

      arbSys.myCallersAddressWithoutAliasing.returns(xChainOwner.address)
      await uOwner.connect(arbSys.wallet).acceptOwner()
    })

    it('sends funds if no data', async () => {
      const beforeBalance = await user.getBalance()
      arbSys.myCallersAddressWithoutAliasing.returns(xChainOwner.address)

      const sendAmount = ethers.utils.parseEther('1')
      await uOwner.connect(arbSys.wallet).execute(user.address, '0x', sendAmount, { value: sendAmount })
      expect(await user.getBalance()).to.equal(beforeBalance.add(sendAmount))
    })

    it('calls a function', async () => {
      const contract = await new MockERC20__factory(owner).deploy('TEST', 'TEST')
      await contract.grantRole(await contract.MINTER_ROLE(), uOwner.address)

      arbSys.myCallersAddressWithoutAliasing.returns(xChainOwner.address)
      const mintAmount = ethers.utils.parseEther('1')

      await uOwner
        .connect(arbSys.wallet)
        .execute(contract.address, contract.interface.encodeFunctionData('mint', [user.address, mintAmount]), 0)
      expect(await contract.balanceOf(user.address)).to.equal(mintAmount)
    })

    it('calls a function with value', async () => {
      const contract = await new MockERC20__factory(owner).deploy('TEST', 'TEST')
      await contract.grantRole(await contract.MINTER_ROLE(), uOwner.address)

      arbSys.myCallersAddressWithoutAliasing.returns(xChainOwner.address)
      const sendAmount = ethers.utils.parseEther('2')

      await uOwner
        .connect(arbSys.wallet)
        .execute(contract.address, contract.interface.encodeFunctionData('wrap', [user.address]), sendAmount, {
          value: sendAmount,
        })
      expect(await contract.balanceOf(user.address)).to.equal(sendAmount)
    })

    it('reverts if not owner', async () => {
      arbSys.myCallersAddressWithoutAliasing.returns(user.address)
      await expect(uOwner.connect(arbSys.wallet).execute(ethers.constants.AddressZero, '0x', 0)).to.be.revertedWith(
        `UOwnableNotOwnerError("${user.address}")`,
      )
    })
  })
})
