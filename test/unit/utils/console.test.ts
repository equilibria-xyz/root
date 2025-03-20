import 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { utils } from 'ethers'
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

  beforeEach(async () => {
    console.log() // newline for readability
  })

  it('should log single fixed decimal values without a string', async () => {
    await expect(
      tester.testSingleValues(
        utils.parseUnits('300001.012345', 6),
        ethers.utils.parseEther('300002.012345678901234567'),
        utils.parseUnits('-700001.012345', 6),
        ethers.utils.parseEther('-700002.012345678901234567'),
      ),
    ).to.not.be.reverted
  })

  it('should log a string with signed integer', async () => {
    await expect(tester.testLogWithInt(123)).to.not.be.reverted
    await expect(tester.testLogWithInt(-321)).to.not.be.reverted
  })

  it('should log fixed decimal types', async () => {
    await expect(
      tester.testLogWithUFixed(
        utils.parseUnits('1000001.012345', 6),
        ethers.utils.parseEther('1000002.012345678901234567'),
      ),
    ).to.not.be.reverted
    await expect(
      tester.testLogWithFixed(
        utils.parseUnits('54321.987654', 6),
        ethers.utils.parseEther('-60000.012345678901234567'),
      ),
    ).to.not.be.reverted
    await expect(
      tester.testLogWithFixed(utils.parseUnits('-9.012345', 6), ethers.utils.parseEther('-8.012345678901234567')),
    ).to.not.be.reverted
  })

  it('should log fixed decimal types near type boundaries', async () => {
    await expect(tester.testLogWithUFixed(0, 0)).to.not.be.reverted
    await expect(tester.testLogWithFixed(0, 0)).to.not.be.reverted
    await expect(tester.testLogWithUFixed(1, 1)).to.not.be.reverted
    await expect(tester.testLogWithFixed(1, 1)).to.not.be.reverted
    await expect(tester.testLogWithFixed(-1, -1)).to.not.be.reverted
    await expect(tester.testLogWithUFixed(ethers.constants.MaxUint256.sub(1), ethers.constants.MaxUint256.sub(1))).to
      .not.be.reverted
    await expect(tester.testLogWithFixed(ethers.constants.MaxInt256.sub(1), ethers.constants.MaxInt256.sub(1))).to.not
      .be.reverted
    await expect(tester.testLogWithFixed(ethers.constants.MinInt256.add(1), ethers.constants.MinInt256.add(1))).to.not
      .be.reverted
  })

  it('should log a string with multiple integers', async () => {
    await expect(tester.testLogWithTwoInts()).to.not.be.reverted
  })
})
