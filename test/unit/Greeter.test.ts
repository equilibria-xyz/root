import { expect } from 'chai'
import { Signer } from 'ethers'
import HRE from 'hardhat'

import { Greeter__factory } from '../../types/generated/factories/Greeter__factory'

const { ethers } = HRE

describe('Greeter', () => {
  let owner: Signer

  beforeEach(async () => {
    ;[owner] = await ethers.getSigners()
  })

  it("Should return the new greeting once it's changed", async function () {
    const greeter = await new Greeter__factory(owner).deploy('Hello, world!')

    await greeter.deployed()
    expect(await greeter.greet()).to.equal('Hello, world!')

    await greeter.setGreeting('Hola, mundo!')
    expect(await greeter.greet()).to.equal('Hola, mundo!')
  })
})
