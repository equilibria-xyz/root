import { smock, FakeContract } from '@defi-wonderland/smock'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  AggregatorV3Interface,
  MockERC20,
  MockERC20__factory,
  MockKeptOptimism,
  MockKeptOptimism__factory,
  OptGasInfo,
} from '../../../types/generated'
import { BigNumber, BigNumberish } from 'ethers'
import { parseEther, parseUnits } from 'ethers/lib/utils'

const { ethers } = HRE

const ETH_PRICE_USD = 1000
const computeFee = (gasUsed: BigNumberish, multiplier: BigNumberish, buffer: BigNumberish, baseFee: BigNumberish) =>
  BigNumber.from(gasUsed)
    .mul(BigNumber.from(multiplier).div(BigNumber.from(10).pow(18)))
    .add(buffer)
    .mul(baseFee)

describe('Kept_Optimism', () => {
  let owner: SignerWithAddress
  let keeper: SignerWithAddress
  let keeperToken: MockERC20
  let ethTokenOracleFeed: FakeContract<AggregatorV3Interface>
  let optGas: FakeContract<OptGasInfo>
  let gasUsed: BigNumber
  let kept: MockKeptOptimism

  async function computeAndAssertKeeperFee(
    multiplier: BigNumberish,
    buffer: BigNumberish,
    multiplierCalldata: BigNumberish,
    bufferCalldata: BigNumberish,
    applicableCalldata: string,
    applicableValue: BigNumberish,
    baseFee: number,
  ): Promise<BigNumber> {
    const [, answer, , ,] = await ethTokenOracleFeed.latestRoundData()
    const ethPrice = answer.div(10 ** 8)
    const originalBenefactorBalance = await keeperToken.balanceOf(owner.address)
    const originalKeeperBalance = await keeperToken.balanceOf(keeper.address)

    // Set baseFee
    await ethers.provider.send('hardhat_setNextBlockBaseFeePerGas', [`0x${baseFee.toString(16)}`])
    const [l1BaseFee, l1GasUsed, l1Scalar, l1Decimals] = await Promise.all([
      optGas.l1BaseFee(),
      optGas.getL1GasUsed(applicableCalldata),
      optGas.scalar(),
      optGas.decimals(),
    ])

    const l1Fee = computeFee(
      l1GasUsed,
      multiplierCalldata,
      bufferCalldata,
      l1BaseFee.mul(l1Scalar).div(BigNumber.from(10).pow(l1Decimals)),
    )
    const l2Fee = computeFee(gasUsed, multiplier, buffer, baseFee)

    // Check that keeperFee = ((gasUsed * multiplier + buffer) * block.baseFee + l1Fee) * ethPrice
    const expectedKeeperFee = l2Fee.add(l1Fee).mul(ethPrice)
    await expect(
      kept
        .connect(keeper)
        .toBeKept(multiplier, buffer, multiplierCalldata, bufferCalldata, applicableCalldata, applicableValue, '0x', {
          gasPrice: baseFee,
        }),
    )
      .to.emit(kept, 'RaiseKeeperFeeCalled')
      .withArgs(expectedKeeperFee, '0x')

    // Check that keeperFee is transferred from owner to kept to keeper
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
    // Set baseFee to 0 to fix sc-coverage issue
    await ethers.provider.send('hardhat_setNextBlockBaseFeePerGas', ['0x0'])
    keeperToken = await new MockERC20__factory(owner).deploy('dsu', 'DSU')
    ethTokenOracleFeed = await smock.fake<AggregatorV3Interface>('AggregatorV3Interface')
    optGas = await smock.fake<OptGasInfo>('OptGasInfo', {
      address: '0x420000000000000000000000000000000000000F',
    })
    kept = await new MockKeptOptimism__factory(owner).deploy(owner.address)
    await kept.connect(owner).initialize(ethTokenOracleFeed.address, keeperToken.address)

    gasUsed = await kept.callStatic.instrumentGas()

    setEthPrice(ETH_PRICE_USD)

    await keeperToken.mint(owner.address, parseEther('1000'))
    await keeperToken.connect(owner).approve(kept.address, ethers.constants.MaxUint256)
  })

  after(async () => {
    await ethers.provider.send('hardhat_setNextBlockBaseFeePerGas', ['0x1'])
  })

  context('L1 Fee is > 0', () => {
    const L1_BASE_FEE = parseUnits('10', 'gwei')
    const L1_GAS_USED = parseUnits('2000000', 'wei')
    beforeEach(() => {
      optGas.getL1GasUsed.whenCalledWith('0x').returns(0)
      optGas.getL1GasUsed.whenCalledWith(HEX_DATA_STRING).returns(L1_GAS_USED)
      optGas.l1BaseFee.returns(L1_BASE_FEE)
      optGas.scalar.returns(684000)
      optGas.decimals.returns(6)
    })

    context('L1 multiplier is 0', () => {
      describe('#keep', () => {
        it('compensates for L1 overhead with no data', async () => {
          await computeAndAssertKeeperFee(0, 0, parseEther('1'), 0, '0x', 0, 0)
        })

        it('compensates for L1 overhead and data', async () => {
          await computeAndAssertKeeperFee(0, 0, parseEther('1'), 0, HEX_DATA_STRING, 0, 0)
        })

        it('keeperFee is directly proportional to eth price', async () => {
          const keeperFee = await computeAndAssertKeeperFee(0, 0, parseEther('1'), 0, HEX_DATA_STRING, 0, 0)

          // If eth price is doubled, keeperFee should be doubled
          setEthPrice(ETH_PRICE_USD * 2)
          expect(keeperFee.mul(2)).to.equal(
            await computeAndAssertKeeperFee(0, 0, parseEther('1'), 0, HEX_DATA_STRING, 0, 0),
          )
        })

        it('keeperFee is directly proportional to l1 base fee', async () => {
          const keeperFee = await computeAndAssertKeeperFee(0, 0, parseEther('1'), 0, HEX_DATA_STRING, 0, 0)

          // If l1 base fee is doubled, keeperFee should be doubled
          optGas.l1BaseFee.returns(L1_BASE_FEE.mul(2))
          expect(keeperFee.mul(2)).to.equal(
            await computeAndAssertKeeperFee(0, 0, parseEther('1'), 0, HEX_DATA_STRING, 0, 0),
          )
        })

        it('keeperFee is directly proportional to l1 gas used', async () => {
          const keeperFee = await computeAndAssertKeeperFee(0, 0, parseEther('1'), 0, HEX_DATA_STRING, 0, 0)

          optGas.getL1GasUsed.reset()
          optGas.getL1GasUsed.whenCalledWith(HEX_DATA_STRING).returns(L1_GAS_USED.mul(2))

          // If l1 gas used is doubled, keeperFee should be doubled
          expect(keeperFee.mul(2)).to.equal(
            await computeAndAssertKeeperFee(0, 0, parseEther('1'), 0, HEX_DATA_STRING, 0, 0),
          )
        })

        it('keeperFee is directly proportional to l1 multipler', async () => {
          const keeperFee = await computeAndAssertKeeperFee(0, 0, parseEther('1'), 0, HEX_DATA_STRING, 0, 0)

          // If l1 multiplier is doubled, keeperFee should be doubled
          expect(keeperFee.mul(2)).to.equal(
            await computeAndAssertKeeperFee(0, 0, parseEther('2'), 0, HEX_DATA_STRING, 0, 0),
          )
        })

        it('keeperFee is increased by l1 buffer', async () => {
          setEthPrice(1)
          const keeperFee = await computeAndAssertKeeperFee(0, 0, parseEther('1'), 0, HEX_DATA_STRING, 0, 0)

          // If l1 buffer is set, keeperFee should incraese by the same amount
          const bufferAmount = parseUnits('100000', 'wei')
          const bufferFee = computeFee(0, 0, bufferAmount, (L1_BASE_FEE.toNumber() * 684000) / 10 ** 6)
          expect(keeperFee.add(bufferFee)).to.equal(
            await computeAndAssertKeeperFee(0, 0, parseEther('1'), bufferAmount, HEX_DATA_STRING, 0, 0),
          )
        })
      })
    })
  })
})

const HEX_DATA_STRING =
  '0x504e41550100000000a00100000000010074a36ec3160391bc40b38bad4794b9ebacaf5bffc50fa608480c113d4d97d5a253684dda011e4a298c8347bf24d236c5af5e25b5e7931d68238fffd571c7fb830064ee057a00000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa7100000000013ad0a50141555756000000000005964161000027100421d38d57bf88144444124672f56daacab34db402005500ca80ba6dc32e08d06f1aa886011eed1d77c77be9eb761cc10d72b7d0a2fd57a6000000280dba39400000000006b58398fffffff80000000064ee057a0000000064ee057900000026fc205e680000000003b8e1ab09259ba78fc581f8fcc4ea906fc3fd16a4ba788ecd5f2a2cac9d666ba377798334fd0970a6c3c43e379c05378a0e9db2483c6baebc38482074bd09bfe089af51a66ed6a2c60625a8c0f8d44d8ab03cc891225c890dc3312f972ce445435d2279ad57195c68a3c1ee33d23c5914395a0e229ad97e52d44ae4e38c13b833f14b7fd350277753e323fc52930f64a1dd38f0da18fcb0f7ead4d1de56db6c0442b9488324165dff13801de9693ee7079c00992b18725e0600550002c1cc29f62ce849611bafc6bd4860e0113300d76db6f95dd753ab76e4f0beeb00000000000ed09700000000000004effffffff80000000064ee057a0000000064ee057900000000000e73c2000000000000055409932737ff6104ca5282406a2132489adc0fcbcbcbf9767043d94a382547fe199641b71fc8527e43c81048711c045d27b72cb1f573ced1e54dfe1b1e917a8e746bd898c95337846f998467ddd4c8beaf339a1d828b821efab34b9fee707504435fbaa9137a0977d1857126f58451831d557749f1a65a7348f2704d10ca567bfe8b70cf7b5f3d754cf72df4932fb16c721d59a58d4640abc970f81f30c5c600b6fea47beddc509ab5bddfd3c23474222a119e1051c1'
