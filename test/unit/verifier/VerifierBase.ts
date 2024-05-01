import 'hardhat'
import { constants } from 'ethers'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

import { expect } from 'chai'
import HRE from 'hardhat'

import { VerifierBaseTester, VerifierBaseTester__factory } from '../../../types/generated'
import { signCommon, signGroupCancellation } from '../../testutil/erc712'
import { currentBlockTimestamp } from '../../testutil/time'

const { ethers } = HRE

describe('VerifierBase', () => {
  let owner: SignerWithAddress
  let market: SignerWithAddress
  let caller: SignerWithAddress
  let caller2: SignerWithAddress
  let verifier: VerifierBaseTester

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
      const now = await currentBlockTimestamp()
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: caller.address, expiry: now + 2 }
      const signature = await signCommon(caller, verifier, common)

      const result = await verifier.connect(caller).callStatic.verifyCommon(common, signature)
      await expect(verifier.connect(caller).verifyCommon(common, signature))
        .to.emit(verifier, 'NonceCancelled')
        .withArgs(caller.address, 0)

      expect(result).to.eq(caller.address)
      expect(await verifier.nonces(caller.address, 0)).to.eq(true)
    })

    it('should reject common w/ invalid expiry', async () => {
      const now = await currentBlockTimestamp()
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: caller.address, expiry: now }
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

  describe('#verifyGroupCancellation', () => {
    const DEFAULT_GROUP_CANCELLATION = {
      group: 0,
      common: {
        account: constants.AddressZero,
        domain: constants.AddressZero,
        nonce: 0,
        group: 0,
        expiry: constants.MaxUint256,
      },
    }

    it('should verify default group cancellation', async () => {
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address, domain: caller.address },
      }
      const signature = await signGroupCancellation(caller, verifier, groupCancellation)

      const result = await verifier.connect(caller).callStatic.verifyGroupCancellation(groupCancellation, signature)
      await expect(verifier.connect(caller).verifyGroupCancellation(groupCancellation, signature))
        .to.emit(verifier, 'NonceCancelled')
        .withArgs(caller.address, 0)

      expect(result).to.eq(caller.address)
      expect(await verifier.nonces(caller.address, 0)).to.eq(true)
    })

    it('should verify group cancellation w/ expiry', async () => {
      const now = await currentBlockTimestamp()
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: {
          ...DEFAULT_GROUP_CANCELLATION.common,
          account: caller.address,
          domain: caller.address,
          expiry: now + 2,
        },
      } // callstatic & call each take one second
      const signature = await signGroupCancellation(caller, verifier, groupCancellation)

      const result = await verifier.connect(caller).callStatic.verifyGroupCancellation(groupCancellation, signature)
      await expect(verifier.connect(caller).verifyGroupCancellation(groupCancellation, signature))
        .to.emit(verifier, 'NonceCancelled')
        .withArgs(caller.address, 0)

      expect(result).to.eq(caller.address)
      expect(await verifier.nonces(caller.address, 0)).to.eq(true)
    })

    it('should reject group cancellation w/ invalid expiry', async () => {
      const now = await currentBlockTimestamp()
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address, domain: caller.address, expiry: now },
      }
      const signature = await signGroupCancellation(caller, verifier, groupCancellation)

      await expect(verifier.connect(caller).verifyGroupCancellation(groupCancellation, signature)).to.revertedWith(
        'VerifierInvalidExpiryError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })

    it('should reject group cancellation w/ invalid expiry (zero)', async () => {
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address, domain: caller.address, expiry: 0 },
      }
      const signature = await signGroupCancellation(caller, verifier, groupCancellation)

      await expect(verifier.connect(caller).verifyGroupCancellation(groupCancellation, signature)).to.revertedWith(
        'VerifierInvalidExpiryError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })

    it('should verify group cancellation w/ domain', async () => {
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address, domain: market.address },
      }
      const signature = await signGroupCancellation(caller, verifier, groupCancellation)

      const result = await verifier.connect(market).callStatic.verifyGroupCancellation(groupCancellation, signature)
      await expect(verifier.connect(market).verifyGroupCancellation(groupCancellation, signature))
        .to.emit(verifier, 'NonceCancelled')
        .withArgs(caller.address, 0)

      expect(result).to.eq(caller.address)
      expect(await verifier.nonces(caller.address, 0)).to.eq(true)
    })

    it('should reject group cancellation w/ invalid domain', async () => {
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address, domain: market.address },
      }
      const signature = await signGroupCancellation(caller, verifier, groupCancellation)

      await expect(verifier.connect(caller).verifyGroupCancellation(groupCancellation, signature)).to.revertedWith(
        'VerifierInvalidDomainError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })

    it('should reject group cancellation w/ invalid domain (zero)', async () => {
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address },
      }
      const signature = await signGroupCancellation(caller, verifier, groupCancellation)

      await expect(verifier.connect(caller).verifyGroupCancellation(groupCancellation, signature)).to.revertedWith(
        'VerifierInvalidDomainError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })

    it('should reject group cancellation w/ invalid signature (too small)', async () => {
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address, domain: caller.address },
      }
      const signature =
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'

      await expect(verifier.connect(caller).verifyGroupCancellation(groupCancellation, signature)).to.revertedWith(
        'VerifierInvalidSignatureError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })

    it('should reject group cancellation w/ invalid signature (too large)', async () => {
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address, domain: caller.address },
      }
      const signature =
        '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123'

      await expect(verifier.connect(caller).verifyGroupCancellation(groupCancellation, signature)).to.revertedWith(
        'VerifierInvalidSignatureError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })

    it('should reject group cancellation w/ invalid nonce', async () => {
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address, domain: caller.address, nonce: 17 },
      }
      const signature = await signGroupCancellation(caller, verifier, groupCancellation)

      await verifier.connect(caller).cancelNonce(17)

      await expect(verifier.connect(caller).verifyGroupCancellation(groupCancellation, signature)).to.revertedWith(
        'VerifierInvalidNonceError',
      )

      expect(await verifier.nonces(caller.address, 17)).to.eq(true)
    })

    it('should reject group cancellation w/ invalid nonce', async () => {
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address, domain: caller.address, group: 17 },
      }
      const signature = await signGroupCancellation(caller, verifier, groupCancellation)

      await verifier.connect(caller).cancelGroup(17)

      await expect(verifier.connect(caller).verifyGroupCancellation(groupCancellation, signature)).to.revertedWith(
        'VerifierInvalidGroupError',
      )

      expect(await verifier.nonces(caller.address, 0)).to.eq(false)
    })
  })

  describe('#cancelNonce', () => {
    it('should cancel the nonce for the account', async () => {
      await expect(verifier.connect(caller).cancelNonce(1))
        .to.emit(verifier, 'NonceCancelled')
        .withArgs(caller.address, 1)

      expect(await verifier.nonces(caller.address, 1)).to.eq(true)
    })
  })

  describe('#cancelNonceWithSignature', () => {
    const DEFAULT_COMMON = {
      account: constants.AddressZero,
      domain: constants.AddressZero,
      nonce: 1,
      group: 0,
      expiry: constants.MaxUint256,
    }

    it('should cancel the nonce for the account', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: verifier.address }
      const signature = await signCommon(caller, verifier, common)

      await expect(verifier.connect(caller).cancelNonceWithSignature(common, signature))
        .to.emit(verifier, 'NonceCancelled')
        .withArgs(caller.address, 1)

      expect(await verifier.nonces(caller.address, 1)).to.eq(true)
    })

    it('rejects the incorrect signer', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: verifier.address }
      const signature = await signCommon(market, verifier, common)

      await expect(verifier.connect(caller).cancelNonceWithSignature(common, signature)).to.revertedWith(
        'VerifierInvalidSignerError',
      )

      expect(await verifier.nonces(caller.address, 1)).to.eq(false)
    })

    it('rejects the incorrect domain', async () => {
      const common = { ...DEFAULT_COMMON, account: caller.address, domain: caller.address }
      const signature = await signCommon(caller, verifier, common)

      await expect(verifier.connect(caller).cancelNonceWithSignature(common, signature)).to.revertedWith(
        'VerifierInvalidDomainError',
      )

      expect(await verifier.nonces(caller.address, 1)).to.eq(false)
    })
  })

  describe('#cancelGroup', () => {
    it('should cancel the group for the account', async () => {
      await expect(verifier.connect(caller).cancelGroup(1))
        .to.emit(verifier, 'GroupCancelled')
        .withArgs(caller.address, 1)

      expect(await verifier.groups(caller.address, 1)).to.eq(true)
    })
  })

  describe('#cancelGroupWithSignature', () => {
    const DEFAULT_GROUP_CANCELLATION = {
      group: 1,
      common: {
        account: constants.AddressZero,
        domain: constants.AddressZero,
        nonce: 0,
        group: 1,
        expiry: constants.MaxUint256,
      },
    }

    it('should cancel the group for the account', async () => {
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address, domain: verifier.address },
      }
      const signature = await signGroupCancellation(caller, verifier, groupCancellation)

      await expect(verifier.connect(caller).cancelGroupWithSignature(groupCancellation, signature))
        .to.emit(verifier, 'GroupCancelled')
        .withArgs(caller.address, 1)

      expect(await verifier.groups(caller.address, 1)).to.eq(true)
    })

    it('rejects the incorrect signer', async () => {
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address, domain: verifier.address },
      }
      const signature = await signGroupCancellation(market, verifier, groupCancellation)

      await expect(verifier.connect(caller).cancelGroupWithSignature(groupCancellation, signature)).to.revertedWith(
        'VerifierInvalidSignerError',
      )

      expect(await verifier.groups(caller.address, 1)).to.eq(false)
    })

    it('rejects the incorrect domain', async () => {
      const groupCancellation = {
        ...DEFAULT_GROUP_CANCELLATION,
        common: { ...DEFAULT_GROUP_CANCELLATION.common, account: caller.address, domain: caller.address },
      }
      const signature = await signGroupCancellation(caller, verifier, groupCancellation)

      await expect(verifier.connect(caller).cancelGroupWithSignature(groupCancellation, signature)).to.revertedWith(
        'VerifierInvalidDomainError',
      )

      expect(await verifier.groups(caller.address, 1)).to.eq(false)
    })
  })
})
