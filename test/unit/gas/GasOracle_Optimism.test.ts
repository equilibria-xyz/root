import { smock, FakeContract } from '@defi-wonderland/smock'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import {
  AggregatorV3Interface,
  GasOracle__factory,
  GasOracleRunner__factory,
  OptGasInfo,
} from '../../../types/generated'
import { BigNumber } from 'ethers'

const { ethers } = HRE

describe('GasOracle_Optimism', () => {
  let owner: SignerWithAddress
  let keeper: SignerWithAddress
  let ethTokenOracleFeed: FakeContract<AggregatorV3Interface>
  let optGas: FakeContract<OptGasInfo>

  async function setBaseFee(baseFee: BigNumber) {
    await ethers.provider.send('hardhat_setNextBlockBaseFeePerGas', [baseFee.toHexString()])
    await ethers.provider.send('evm_mine', [])
  }

  beforeEach(async () => {
    ;[owner, keeper] = await ethers.getSigners()

    ethTokenOracleFeed = await smock.fake<AggregatorV3Interface>('AggregatorV3Interface')

    optGas = await smock.fake<OptGasInfo>('OptGasInfo', {
      address: '0x420000000000000000000000000000000000000F',
    })

    // Set baseFee to 0 to fix sc-coverage issue
    await ethers.provider.send('hardhat_setNextBlockBaseFeePerGas', ['0x0'])
  })

  after(async () => {
    await ethers.provider.send('hardhat_setNextBlockBaseFeePerGas', ['0x1'])
  })

  describe('#cost', async () => {
    it('returns correct cost (no value)', async () => {
      const gasOracle = await new GasOracle__factory(owner).deploy(
        ethTokenOracleFeed.address,
        8,
        1_000_000,
        ethers.utils.parseEther('1.1'),
        200_000,
        5_000_000,
        ethers.utils.parseEther('1.1'),
        1_000_000,
      )
      const gasOracleRunner = await new GasOracleRunner__factory(owner).deploy(gasOracle.address)

      // set eth price
      ethTokenOracleFeed.latestRoundData.returns([0, ethers.utils.parseUnits('1000', 8), 0, 0, 0])

      // set compute fee
      const baseFee = ethers.utils.parseUnits('1', 9)
      await setBaseFee(baseFee) // 1 gwei

      // set calldata fee
      const L1_BASE_FEE = ethers.utils.parseUnits('5', 'gwei')
      const L1_BLOB_BASE_FEE = ethers.utils.parseUnits('10', 'gwei')
      optGas.l1BaseFee.returns(L1_BASE_FEE)
      optGas.baseFeeScalar.returns(342000)
      optGas.blobBaseFee.returns(L1_BLOB_BASE_FEE)
      optGas.blobBaseFeeScalar.returns(684000)
      optGas.decimals.returns(6)

      // l2 base fee = (16 * 342000 * 5 + 684000 * 10) / (16 * 1_000_000) 2.1375 gwei
      // total l2 gas cost = (1_000_000 * 1.1 + 200_000) = 1_300_000
      // total l2 eth cost = 1_300_000 * 2.1375 gwei = 2778750 * 10^15 = 0.00277875 eth
      // total l1 gas cost = (5_000_000 * 1.2 + 1_000_000) = 7_000_000
      // total l1 eth cost = 7_000_000 * 10 gwei = 70 * 10^15 = 0.07 eth
      // total usd cost = 0.07277875 * 1000 = 72.77875 usd
      expect(await gasOracleRunner.cost(0, { gasPrice: baseFee }))
        .to.emit(gasOracleRunner, 'Cost')
        .withArgs(ethers.utils.parseEther('72.77875'))
    })

    it('returns correct cost (value)', async () => {
      const gasOracle = await new GasOracle__factory(owner).deploy(
        ethTokenOracleFeed.address,
        8,
        1_000_000,
        ethers.utils.parseEther('1.1'),
        200_000,
        0,
        0,
        0,
      )
      const gasOracleRunner = await new GasOracleRunner__factory(owner).deploy(gasOracle.address)

      // set eth price
      ethTokenOracleFeed.latestRoundData.returns([0, ethers.utils.parseUnits('1000', 8), 0, 0, 0])

      // set base fee
      const baseFee = ethers.utils.parseUnits('1', 9)
      await setBaseFee(baseFee) // 1 gwei

      // set value
      const value = ethers.utils.parseEther('0.0012') // 0.0012 eth

      // total gas cost = (1_000_000 * 1.1 + 200_000) = 1_300_000
      // total eth cost = 1_300_000 * 2.1375 gwei + 0.0012 eth = 1.3 * 10^15 + 0.0012 eth = 0.00397875 eth
      // total l1 gas cost = (5_000_000 * 1.2 + 1_000_000) = 7_000_000
      // total l1 eth cost = 7_000_000 * 10 gwei = 70 * 10^15 = 0.07 eth
      // total usd cost = 0.07397875 eth * 1000 = 73.97875 usd
      expect(await gasOracleRunner.cost(value, { gasPrice: baseFee }))
        .to.emit(gasOracleRunner, 'Cost')
        .withArgs(ethers.utils.parseEther('73.97875'))
    })
  })
})
