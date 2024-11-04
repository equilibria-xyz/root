import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { MockOwnerExecutable, MockOwnerExecutable__factory } from '../../../types/generated'

const { ethers } = HRE

describe('OwnerExecutable', () => {
  let owner: SignerWithAddress
  let user: SignerWithAddress
  let unrelated: SignerWithAddress
  let ownableExecutable: MockOwnerExecutable

  beforeEach(async () => {
    ;[owner, user, unrelated] = await ethers.getSigners()
    ownableExecutable = await new MockOwnerExecutable__factory(owner).deploy()
    await ownableExecutable.connect(owner).__initialize()
  })

  describe('#execute', async () => {
    it('executes call successfully', async () => {
      const target = ownableExecutable.address
      const data = ownableExecutable.interface.encodeFunctionData('owner')
      const returnData = await ownableExecutable.connect(owner).callStatic.execute(target, data)
      const decodedResult = ownableExecutable.interface.decodeFunctionResult('owner', returnData)

      expect(decodedResult[0]).to.equal(owner.address)
    })

    it('reverts if call fails', async () => {
      const target = ownableExecutable.address
      const data = '0x'

      await expect(ownableExecutable.connect(owner).execute(target, data)).to.be.revertedWith(
        'OwnableExecuteCallFailed',
      )
    })

    it('reverts if not owner', async () => {
      const target = ownableExecutable.address
      const data = ownableExecutable.interface.encodeFunctionData('owner')

      await expect(ownableExecutable.connect(user).execute(target, data)).to.be.revertedWith(
        `OwnableNotOwnerError("${user.address}")`,
      )
    })
  })
})
