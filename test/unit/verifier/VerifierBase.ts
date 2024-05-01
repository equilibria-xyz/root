import 'hardhat'
import { constants } from 'ethers'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

import { expect, use } from 'chai'
import HRE from 'hardhat'

import { VerifierBaseTester, VerifierBaseTester__factory } from '../../../types/generated'
import { signCommon, signGroupCancellation } from '../../testutil/erc712'

const { ethers } = HRE

describe('Verifier', () => {
  let owner: SignerWithAddress
  let market: SignerWithAddress
  let caller: SignerWithAddress
  let caller2: SignerWithAddress
  let verifier: VerifierBaseTester

  function now(): number {
    return Math.round(Date.now() / 1000)
  }

  beforeEach(async () => {
    ;[owner, market, caller, caller2] = await ethers.getSigners()

    verifier = await new VerifierBaseTester__factory(owner).deploy()
  })

  describe('#verifyCommon', () => {
    const DEFAULT_COMMON = {
      account: constants.AddressZero,
      domain: constants.AddressZero,
      nonce: 0,
      group: 0,
      expiry: constants.MaxUint256,
    }

    it('should verify default common', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: caller.address }
      const signature = await signCommon(caller, verifier, common)

      const result = await verifier.connect(caller).callStatic.verifyCommon(common, signature)
      await expect(verifier.connect(caller).verifyCommon(common, signature))
        .to.emit(verifier, 'NonceCancelled')
        .withArgs(caller.address, 0)

      expect(result).to.eq(caller.address)
      expect(await verifier.nonces(caller.address, 0)).to.eq(true)
    })

    it('should verify common w/ expiry', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: caller.address, expiry: now() + 5 }
      const signature = await signCommon(caller, verifier, common)

      const result = await verifier.connect(caller).callStatic.verifyCommon(common, signature)
      await expect(verifier.connect(caller).verifyCommon(common, signature))
        .to.emit(verifier, 'NonceCancelled')
        .withArgs(caller.address, 0)

      expect(result).to.eq(caller.address)
      expect(await verifier.nonces(caller.address, 0)).to.eq(true)
    })

    it('should reject common w/ invalid expiry', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: caller.address, expiry: now() }
      const signature = await signCommon(caller, verifier, common)

      await expect(verifier.connect(caller).verifyCommon(common, signature)).to.be.revertedWith(
        'VerifierInvalidExpiryError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })

    it('should reject common w/ invalid expiry (zero)', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: caller.address, expiry: 0 }
      const signature = await signCommon(caller, verifier, common)

      await expect(verifier.connect(caller).verifyCommon(common, signature)).to.be.revertedWith(
        'VerifierInvalidExpiryError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })

    it('should verify common w/ domain', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: market.address }
      const signature = await signCommon(caller, verifier, common)

      const result = await verifier.connect(market).callStatic.verifyCommon(common, signature)
      await expect(verifier.connect(market).verifyCommon(common, signature))
        .to.emit(verifier, 'NonceCancelled')
        .withArgs(caller.address, 0)

      expect(result).to.eq(caller.address)
      expect(await verifier.nonces(caller.address, 0)).to.eq(true)
    })

    it('should reject common w/ invalid domain', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: market.address }
      const signature = await signCommon(caller, verifier, common)

      await expect(verifier.connect(caller).verifyCommon(common, signature)).to.revertedWith(
        'VerifierInvalidDomainError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })

    it('should reject common w/ invalid domain (zero)', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address }
      const signature = await signCommon(caller, verifier, common)

      await expect(verifier.connect(caller).verifyCommon(common, signature)).to.revertedWith(
        'VerifierInvalidDomainError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })

    it('should reject common w/ invalid signature (too small)', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: caller.address }
      const signature =
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'

      await expect(verifier.connect(caller).verifyCommon(common, signature)).to.revertedWith(
        'VerifierInvalidSignatureError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })

    it('should reject common w/ invalid signature (too large)', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: caller.address }
      const signature =
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123'

      await expect(verifier.connect(caller).verifyCommon(common, signature)).to.revertedWith(
        'VerifierInvalidSignatureError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })

    it('should reject common w/ invalid nonce', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: caller.address, nonce: 17 }
      const signature = await signCommon(caller, verifier, common)

      await verifier.connect(caller).cancelNonce(17)

      await expect(verifier.connect(caller).verifyCommon(common, signature)).to.revertedWith(
        'VerifierInvalidNonceError',
      )

      expect(await verifier.nonces(caller.address, 17)).to.eq(true)
    })

    it('should reject common w/ invalid nonce', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: caller.address, group: 17 }
      const signature = await signCommon(caller, verifier, common)

      await verifier.connect(caller).cancelGroup(17)

      await expect(verifier.connect(caller).verifyCommon(common, signature)).to.revertedWith(
        'VerifierInvalidGroupError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })
  })
})
