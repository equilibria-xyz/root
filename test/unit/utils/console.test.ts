import 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { ConsoleTester, ConsoleTester__factory } from '../../../types/generated'

const { ethers } = HRE

describe('Console', () => {
  let owner: SignerWithAddress
  let tester: ConsoleTester

  before(async () => {
    ;[owner] = await ethers.getSigners()
    tester = await new ConsoleTester__factory(owner).deploy()
  })

  it('should log a string with signed integer', async () => {
    await expect(tester.testLogWithInt(123)).to.not.be.reverted
    await expect(tester.testLogWithInt(-321)).to.not.be.reverted
  })

  it('should log a string with multiple integers', async () => {
    await expect(tester.testLogWithMultipleInts(23, 34)).to.not.be.reverted
    await expect(tester.testLogWithMultipleInts(-54, -65)).to.not.be.reverted
  })
})
