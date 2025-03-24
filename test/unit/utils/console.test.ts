import 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { BigNumber, utils } from 'ethers'
import { assert, expect } from 'chai'
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

  function randomBigNumber(lowerBound: BigNumber, upperBound: BigNumber): BigNumber {
    assert(lowerBound.lt(upperBound))

    const range = upperBound.sub(lowerBound).add(1) // Range size
    const randomOffset = BigNumber.from(
      Math.floor(Math.random() * Number(range.toString())), // Generate random offset
    )
    return lowerBound.add(randomOffset)
  }

  it('should log single values without a format string', async () => {
    await expect(tester.testSingleValues(23)).to.not.be.reverted
  })

  it('should log a string with a single value', async () => {
    await expect(tester.testFormatNonNumericValues(owner.address)).to.not.be.reverted

    await expect(tester.testFormatInt(123)).to.not.be.reverted
    await expect(tester.testFormatInt(-321)).to.not.be.reverted

    await expect(
      tester.testFormatUFixed(
        utils.parseUnits('1000001.012345', 6),
        ethers.utils.parseEther('1000002.012345678901234567'),
      ),
    ).to.not.be.reverted
    await expect(
      tester.testFormatFixed(utils.parseUnits('54321.987654', 6), ethers.utils.parseEther('-60000.012345678901234567')),
    ).to.not.be.reverted
    await expect(
      tester.testFormatFixed(utils.parseUnits('-9.012345', 6), ethers.utils.parseEther('-8.012345678901234567')),
    ).to.not.be.reverted
  })

  it('should log fixed decimal types near type boundaries', async () => {
    await expect(tester.testFormatUFixed(0, 0)).to.not.be.reverted
    await expect(tester.testFormatFixed(0, 0)).to.not.be.reverted
    await expect(tester.testFormatUFixed(1, 1)).to.not.be.reverted
    await expect(tester.testFormatFixed(1, 1)).to.not.be.reverted
    await expect(tester.testFormatFixed(-1, -1)).to.not.be.reverted
    await expect(tester.testFormatUFixed(ethers.constants.MaxUint256.sub(1), ethers.constants.MaxUint256.sub(1))).to.not
      .be.reverted
    await expect(tester.testFormatFixed(ethers.constants.MaxInt256.sub(1), ethers.constants.MaxInt256.sub(1))).to.not.be
      .reverted
    await expect(tester.testFormatFixed(ethers.constants.MinInt256.add(1), ethers.constants.MinInt256.add(1))).to.not.be
      .reverted
  })

  it('should log a string with two values', async () => {
    await expect(tester.testFormatTwoInts(23, 34)).to.not.be.reverted
    await expect(
      tester.testFormatTwoFixedValues(
        utils.parseUnits('5678.001', 6),
        ethers.utils.parseEther('67899.002000333'),
        utils.parseUnits('-4321.003', 6),
        ethers.utils.parseEther('-3210.003000444'),
      ),
    ).to.not.be.reverted
  })

  it('should log a string with two and three fuzzed values', async () => {
    const u = randomBigNumber(BigNumber.from(0), BigNumber.from(100_000_000))
    const i = randomBigNumber(BigNumber.from(-200_000_000), BigNumber.from(10_000))

    let wholePart = randomBigNumber(BigNumber.from(3_000_000), BigNumber.from(3_999_999)).mul(1e6)
    let decimalPart = randomBigNumber(BigNumber.from(0), BigNumber.from(999999))
    const uf6 = wholePart.add(decimalPart)

    wholePart = randomBigNumber(BigNumber.from(400_000_000), BigNumber.from(499_999_999)).mul(1e9).mul(1e9)
    decimalPart = BigNumber.from(Math.floor(Math.random() * 1_000_000_000_000_000_000).toString())
    const uf18 = wholePart.add(decimalPart)

    wholePart = randomBigNumber(BigNumber.from(-59_999_999), BigNumber.from(-50_000_000)).mul(1e9).mul(1e9)
    decimalPart = randomBigNumber(BigNumber.from(0), BigNumber.from(999999))
    const f6 = wholePart.add(decimalPart)

    wholePart = randomBigNumber(BigNumber.from(-699_999), BigNumber.from(-600_000)).mul(1e6)
    decimalPart = BigNumber.from(Math.floor(Math.random() * 1_000_000_000_000_000_000).toString())
    const f18 = wholePart.add(decimalPart)

    const b = Math.random() < 0.5

    console.log('Fuzzed inputs to full coverage test:')
    console.log('  u =', u.toString())
    console.log('  i =', i.toString())
    console.log('  uf6 =', uf6.toString())
    console.log('  uf18 =', uf18.toString())
    console.log('  f6 =', f6.toString())
    console.log('  f18 =', f18.toString())
    console.log('  a =', owner.address)
    console.log('  b =', b)

    await expect(tester.testFormatTwoValues(u, i, uf6, uf18, f6, f18, owner.address, b)).to.not.be.reverted
    await expect(tester.testFormatThreeValues(u, i, uf6, uf18, f6, f18, owner.address, b)).to.not.be.reverted
  })
})
