import { smock, FakeContract } from '@defi-wonderland/smock'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import HRE from 'hardhat'

import { AggregatorV3Interface, GasOracle__factory, GasOracleRunner__factory } from '../../../types/generated'
import { BigNumber } from 'ethers'

const { ethers } = HRE

describe('GasOracle', () => {
  let owner: SignerWithAddress
  let keeper: SignerWithAddress
  let ethTokenOracleFeed: FakeContract<AggregatorV3Interface>

  async function setBaseFee(baseFee: BigNumber) {
    await ethers.provider.send('hardhat_setNextBlockBaseFeePerGas', [baseFee.toHexString()])
    await ethers.provider.send('evm_mine', [])
  }

  beforeEach(async () => {
    ;[owner, keeper] = await ethers.getSigners()

    ethTokenOracleFeed = await smock.fake<AggregatorV3Interface>('AggregatorV3Interface')

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

      // total gas cost = (1_000_000 * 1.1 + 200_000) = 1_300_000
      // total eth cost = 1_300_000 * 1 gwei = 1.3 * 10^15 = 0.0013 eth
      // total usd cost = 0.0025 * 1000 = 1.3 usd
      expect(await gasOracleRunner.cost(0, { gasPrice: baseFee }))
        .to.emit(gasOracleRunner, 'Cost')
        .withArgs(ethers.utils.parseEther('1.3'))
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
      // total eth cost = 1_300_000 * 1 gwei + 0.0012 eth = 1.3 * 10^15 + 0.0012 eth = 0.0025 eth
      // total usd cost = 0.0025 * 1000 = 2.5 usd
      expect(await gasOracleRunner.cost(value, { gasPrice: baseFee }))
        .to.emit(gasOracleRunner, 'Cost')
        .withArgs(ethers.utils.parseEther('2.5'))
    })
  })
})
