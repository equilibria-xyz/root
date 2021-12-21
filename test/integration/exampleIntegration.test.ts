import { expect } from 'chai'
import HRE from 'hardhat'

const { ethers } = HRE

describe('example', () => {
  it('connects to mainnet fork', async () => {
    expect(await ethers.provider.getBlockNumber()).to.equal(12345678)
  })
})
