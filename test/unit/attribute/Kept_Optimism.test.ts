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
import { parseEther } from 'ethers/lib/utils'

const { ethers } = HRE

const ETH_PRICE_USD = 1000
const computeL1Fee = (l1TotalFee: BigNumberish) => BigNumber.from(l1TotalFee)
const computeL2Fee = (gasUsed: BigNumber, multiplier: BigNumber, buffer: BigNumber, baseFee: number) =>
  gasUsed
    .mul(multiplier.div(BigNumber.from(10).pow(18)))
    .add(buffer)
    .mul(baseFee)

describe('Kept_Arbitrum', () => {
  let owner: SignerWithAddress
  let keeper: SignerWithAddress
  let keeperToken: MockERC20
  let ethTokenOracleFeed: FakeContract<AggregatorV3Interface>
  let optGas: FakeContract<OptGasInfo>
  let gasUsed: BigNumber
  let kept: MockKeptOptimism

  async function computeAndAssertKeeperFee(
    multiplier: BigNumber,
    buffer: BigNumber,
    payload: string,
    baseFee: number,
    l1TotalFee: BigNumberish,
  ): Promise<BigNumber> {
    const [, answer, , ,] = await ethTokenOracleFeed.latestRoundData()
    const ethPrice = answer.div(10 ** 8)
    const originalBenefactorBalance = await keeperToken.balanceOf(owner.address)
    const originalKeeperBalance = await keeperToken.balanceOf(keeper.address)

    // Set baseFee
    await ethers.provider.send('hardhat_setNextBlockBaseFeePerGas', [`0x${baseFee.toString(16)}`])

    const l1Fee = computeL1Fee(l1TotalFee)
    const l2Fee = computeL2Fee(gasUsed, multiplier, buffer, baseFee)

    // Check that keeperFee = ((gasUsed * multiplier + buffer) * block.baseFee + l1Fee) * ethPrice
    const expectedKeeperFee = l2Fee.add(l1Fee).mul(ethPrice)
    await expect(kept.connect(keeper).toBeKept(multiplier, buffer, payload, '0x', { gasPrice: baseFee }))
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

    await keeperToken.mint(owner.address, ethers.utils.parseEther('1000'))
    await keeperToken.connect(owner).approve(kept.address, ethers.constants.MaxUint256)
  })

  after(async () => {
    await ethers.provider.send('hardhat_setNextBlockBaseFeePerGas', ['0x1'])
  })

  describe('#__Kept__initialize', async () => {
    it('initializes keeperToken and ethTokenOracleFeed', async () => {
      expect(await kept.keeperToken()).to.equal(keeperToken.address)
      expect(await kept.ethTokenOracleFeed()).to.equal(ethTokenOracleFeed.address)
    })
  })

  describe('#keep', () => {
    it('passes `data` to _raiseKeeperFee', async () => {
      const data = '0xabcd'
      await expect(kept.toBeKept(0, 0, '0x', data)).to.emit(kept, 'RaiseKeeperFeeCalled').withArgs(0, data)
    })
  })

  context('L1 Fee is 0', () => {
    beforeEach(() => {
      optGas.getL1Fee.returns(0)
    })

    describe('#keep', async () => {
      it('keeperFee is directly proportional to multiplier (given 0 buffer and 0 updateData)', async () => {
        const multiplier = ethers.utils.parseEther('2')
        const keeperFee = await computeAndAssertKeeperFee(multiplier, BigNumber.from(0), '0x', 100, 0)

        // If multiplier is doubled, keeperFee should be doubled
        expect(keeperFee.mul(2)).to.equal(
          await computeAndAssertKeeperFee(multiplier.mul(2), BigNumber.from(0), '0x', 100, 0),
        )
      })

      it('buffer adds buffer to keeperFee', async () => {
        const buffer = BigNumber.from(0)
        setEthPrice(1)
        const keeperFee = await computeAndAssertKeeperFee(BigNumber.from(1), buffer, '0x', 1, 0)

        const addToBuffer = BigNumber.from(5)
        expect(keeperFee.add(addToBuffer)).to.equal(
          await computeAndAssertKeeperFee(BigNumber.from(1), buffer.add(addToBuffer), '0x', 1, 0),
        )
      })

      it('keeperFee is directly proportional to eth price', async () => {
        const keeperFee = await computeAndAssertKeeperFee(BigNumber.from(1), BigNumber.from(0), '0x', 100, 0)

        // If eth price is doubled, keeperFee should be doubled
        setEthPrice(ETH_PRICE_USD * 2)
        expect(keeperFee.mul(2)).to.equal(
          await computeAndAssertKeeperFee(BigNumber.from(1), BigNumber.from(0), '0x', 100, 0),
        )
      })

      it('keeperFee is directly proportional to block.baseFee', async () => {
        const baseFee = 100
        const keeperFee = await computeAndAssertKeeperFee(
          ethers.utils.parseEther('1'),
          BigNumber.from(0),
          '0x',
          baseFee,
          0,
        )

        // If baseFee is doubled, keeperFee should be doubled
        expect(keeperFee.mul(2)).to.equal(
          await computeAndAssertKeeperFee(ethers.utils.parseEther('1'), BigNumber.from(0), '0x', baseFee * 2, 0),
        )
      })

      it('0 multiplier results in 0 keeperFee', async () => {
        expect(await computeAndAssertKeeperFee(BigNumber.from(0), BigNumber.from(0), '0x', 100, 0)).to.be.equal(0)
      })

      it('0 eth price results in 0 keeperFee', async () => {
        setEthPrice(0)
        expect(await computeAndAssertKeeperFee(BigNumber.from(1), BigNumber.from(0), '0x', 100, 0)).to.be.equal(0)
      })

      it('0 base fee results in 0 keeperFee', async () => {
        expect(await computeAndAssertKeeperFee(BigNumber.from(1), BigNumber.from(0), '0x', 0, 0)).to.be.equal(0)
      })
    })
  })

  context('L1 Fee is > 0', () => {
    const L1_FEE = parseEther('0.0123')
    beforeEach(() => {
      optGas.getL1Fee.returns(L1_FEE)
    })

    describe('#keep', () => {
      it('compensates for L1 overhead with no data', async () => {
        await computeAndAssertKeeperFee(parseEther('1'), BigNumber.from(0), '0x', 0, L1_FEE)
      })

      it('compensates for L1 overhead and data', async () => {
        await computeAndAssertKeeperFee(parseEther('1'), BigNumber.from(0), HEX_DATA_STRING, 0, L1_FEE)
      })

      it('keeperFee is directly proportional to eth price', async () => {
        const keeperFee = await computeAndAssertKeeperFee(
          BigNumber.from(1),
          BigNumber.from(0),
          HEX_DATA_STRING,
          0,
          L1_FEE,
        )

        // If eth price is doubled, keeperFee should be doubled
        setEthPrice(ETH_PRICE_USD * 2)
        expect(keeperFee.mul(2)).to.equal(
          await computeAndAssertKeeperFee(BigNumber.from(1), BigNumber.from(0), HEX_DATA_STRING, 0, L1_FEE),
        )
      })

      it('keeperFee is directly proportional to l1 fee', async () => {
        const keeperFee = await computeAndAssertKeeperFee(
          ethers.utils.parseEther('1'),
          BigNumber.from(0),
          HEX_DATA_STRING,
          0,
          L1_FEE,
        )

        optGas.getL1Fee.returns(L1_FEE.mul(2))
        // If l1 fee is doubled, keeperFee should be doubled
        expect(keeperFee.mul(2)).to.equal(
          await computeAndAssertKeeperFee(
            ethers.utils.parseEther('1'),
            BigNumber.from(0),
            HEX_DATA_STRING,
            0,
            L1_FEE.mul(2),
          ),
        )
      })

      it('only applies multiplier to L2 portion', async () => {
        const multiplier = ethers.utils.parseEther('2')

        const l1Portion = computeL1Fee(L1_FEE)
        const l2Portion = computeL2Fee(gasUsed, multiplier, BigNumber.from(0), 100)

        // If multiplier is doubled, keeperFee should be doubled
        expect(l2Portion.mul(2).add(l1Portion).mul(ETH_PRICE_USD)).to.equal(
          await computeAndAssertKeeperFee(multiplier.mul(2), BigNumber.from(0), HEX_DATA_STRING, 100, L1_FEE),
        )
      })

      it('handles all params', async () => {
        await computeAndAssertKeeperFee(
          ethers.utils.parseEther('1'),
          ethers.utils.parseEther('0.00001'),
          HEX_DATA_STRING,
          100,
          L1_FEE,
        )
      })
    })
  })
})

const HEX_DATA_STRING =
  '0x504e41550100000000a00100000000010074a36ec3160391bc40b38bad4794b9ebacaf5bffc50fa608480c113d4d97d5a253684dda011e4a298c8347bf24d236c5af5e25b5e7931d68238fffd571c7fb830064ee057a00000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa7100000000013ad0a50141555756000000000005964161000027100421d38d57bf88144444124672f56daacab34db402005500ca80ba6dc32e08d06f1aa886011eed1d77c77be9eb761cc10d72b7d0a2fd57a6000000280dba39400000000006b58398fffffff80000000064ee057a0000000064ee057900000026fc205e680000000003b8e1ab09259ba78fc581f8fcc4ea906fc3fd16a4ba788ecd5f2a2cac9d666ba377798334fd0970a6c3c43e379c05378a0e9db2483c6baebc38482074bd09bfe089af51a66ed6a2c60625a8c0f8d44d8ab03cc891225c890dc3312f972ce445435d2279ad57195c68a3c1ee33d23c5914395a0e229ad97e52d44ae4e38c13b833f14b7fd350277753e323fc52930f64a1dd38f0da18fcb0f7ead4d1de56db6c0442b9488324165dff13801de9693ee7079c00992b18725e0600550002c1cc29f62ce849611bafc6bd4860e0113300d76db6f95dd753ab76e4f0beeb00000000000ed09700000000000004effffffff80000000064ee057a0000000064ee057900000000000e73c2000000000000055409932737ff6104ca5282406a2132489adc0fcbcbcbf9767043d94a382547fe199641b71fc8527e43c81048711c045d27b72cb1f573ced1e54dfe1b1e917a8e746bd898c95337846f998467ddd4c8beaf339a1d828b821efab34b9fee707504435fbaa9137a0977d1857126f58451831d557749f1a65a7348f2704d10ca567bfe8b70cf7b5f3d754cf72df4932fb16c721d59a58d4640abc970f81f30c5c600b6fea47beddc509ab5bddfd3c23474222a119e1051c1'
