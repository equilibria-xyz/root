import { smock, FakeContract } from '@defi-wonderland/smock'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  AggregatorV3Interface,
  MockERC20,
  MockERC20__factory,
  MockUKept,
  MockUKept__factory,
} from '../../../types/generated'
import { BigNumber } from 'ethers'

const { ethers } = HRE

const ETH_PRICE_USD = 1000

describe.only('UKept', () => {
  let owner: SignerWithAddress
  let keeper: SignerWithAddress
  let keeperToken: MockERC20
  let ethTokenOracleFeed: FakeContract<AggregatorV3Interface>
  let uKept: MockUKept

  async function computeAndAssertKeeperFee(
    multiplier: BigNumber,
    buffer: BigNumber,
    baseFee: number,
  ): Promise<BigNumber> {
    const gasUsed = BigNumber.from(10) // The gas used by MockUKept.toBeKept
    const [, answer, , ,] = await ethTokenOracleFeed.latestRoundData()
    const ethPrice = answer.div(10 ** 8)
    const originalBenefactorBalance = await keeperToken.balanceOf(owner.address)
    const originalKeeperBalance = await keeperToken.balanceOf(keeper.address)

    // Set baseFee
    await ethers.provider.send('hardhat_setNextBlockBaseFeePerGas', [`0x${baseFee.toString(16)}`])

    // Check that keeperFee = (gasUsed * multiplier + buffer) * ethPrice * block.baseFee
    const expectedKeeperFee = gasUsed
      .mul(multiplier.div(BigNumber.from(10).pow(18)))
      .add(buffer)
      .mul(ethPrice)
      .mul(baseFee)
    await expect(uKept.toBeKept(multiplier, buffer, keeper.address, '0x'))
      .to.emit(uKept, 'RaiseKeeperFeeCalled')
      .withArgs(expectedKeeperFee, '0x')

    // Check that keeperFee is transferred from owner to uKept to keeper
    expect(await keeperToken.balanceOf(owner.address)).to.equal(originalBenefactorBalance.sub(expectedKeeperFee))
    expect(expectedKeeperFee).to.equal((await keeperToken.balanceOf(keeper.address)).sub(originalKeeperBalance))

    return expectedKeeperFee
  }

  function setEthPrice(priceInUSD: number) {
    ethTokenOracleFeed.latestRoundData.returns([
      0, // roundId
      ethers.utils.parseUnits(priceInUSD.toString(), 8),
      0, // startedAt
      0, // updatedAt
      0, // answeredInRound
    ])
  }

  beforeEach(async () => {
    ;[owner, keeper] = await ethers.getSigners()
    keeperToken = await new MockERC20__factory(owner).deploy('dsu', 'DSU')
    ethTokenOracleFeed = await smock.fake<AggregatorV3Interface>('AggregatorV3Interface')
    uKept = await new MockUKept__factory(owner).deploy()
    await uKept.connect(owner).initialize(ethTokenOracleFeed.address, keeperToken.address)

    setEthPrice(ETH_PRICE_USD)

    await keeperToken.mint(owner.address, ethers.utils.parseEther('1000'))
    await keeperToken.connect(owner).approve(uKept.address, ethers.constants.MaxUint256)
  })

  describe('#__UKept__initialize', async () => {
    it('initializes keeperToken and ethTokenOracleFeed', async () => {
      expect(await uKept.keeperToken()).to.equal(keeperToken.address)
      expect(await uKept.ethTokenOracleFeed()).to.equal(ethTokenOracleFeed.address)
    })
  })

  describe('#keep', async () => {
    it('passes `data` to _raiseKeeperFee', async () => {
      const data = '0xabcd'
      await expect(uKept.toBeKept(0, 0, owner.address, data)).to.emit(uKept, 'RaiseKeeperFeeCalled').withArgs(0, data)
    })

    it('keeperFee is directly proportional to multiplier (given 0 buffer)', async () => {
      const multiplier = ethers.utils.parseEther('2')
      const keeperFee = await computeAndAssertKeeperFee(multiplier, BigNumber.from(0), 100)

      // If multiplier is doubled, keeperFee should be doubled
      expect(keeperFee.mul(2)).to.equal(await computeAndAssertKeeperFee(multiplier.mul(2), BigNumber.from(0), 100))
    })

    it('buffer adds buffer to keeperFee', async () => {
      const buffer = BigNumber.from(0)
      setEthPrice(1)
      const keeperFee = await computeAndAssertKeeperFee(BigNumber.from(1), buffer, 1)

      const addToBuffer = BigNumber.from(5)
      expect(keeperFee.add(addToBuffer)).to.equal(
        await computeAndAssertKeeperFee(BigNumber.from(1), buffer.add(addToBuffer), 1),
      )
    })

    it('keeperFee is directly proportional to eth price', async () => {
      const keeperFee = await computeAndAssertKeeperFee(BigNumber.from(1), BigNumber.from(0), 100)

      // If eth price is doubled, keeperFee should be doubled
      setEthPrice(ETH_PRICE_USD * 2)
      expect(keeperFee.mul(2)).to.equal(await computeAndAssertKeeperFee(BigNumber.from(1), BigNumber.from(0), 100))
    })

    it('keeperFee is directly proportional to block.baseFee', async () => {
      const baseFee = 100
      const keeperFee = await computeAndAssertKeeperFee(ethers.utils.parseEther('1'), BigNumber.from(0), baseFee)

      // If baseFee is doubled, keeperFee should be doubled
      expect(keeperFee.mul(2)).to.equal(
        await computeAndAssertKeeperFee(ethers.utils.parseEther('1'), BigNumber.from(0), baseFee * 2),
      )
    })

    it('0 multiplier results in 0 keeperFee', async () => {
      expect(await computeAndAssertKeeperFee(BigNumber.from(0), BigNumber.from(0), 100)).to.be.equal(0)
    })

    it('0 eth price results in 0 keeperFee', async () => {
      setEthPrice(0)
      expect(await computeAndAssertKeeperFee(BigNumber.from(1), BigNumber.from(0), 100)).to.be.equal(0)
    })

    it('0 base fee results in 0 keeperFee', async () => {
      expect(await computeAndAssertKeeperFee(BigNumber.from(1), BigNumber.from(0), 0)).to.be.equal(0)
    })
  })
})
