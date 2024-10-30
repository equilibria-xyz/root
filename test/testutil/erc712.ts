import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { FakeContract } from '@defi-wonderland/smock'
import { IVerifierBase, VerifierBase } from '../../types/generated'
import { BigNumberish } from 'ethers'

export type CommonStruct = {
  account: string
  domain: string
  nonce: BigNumberish
  group: BigNumberish
  expiry: BigNumberish
}

export function erc721Domain(verifier: VerifierBase | FakeContract<IVerifierBase>) {
  return {
    name: 'Equilibria Root Unit Tests',
    version: '1.0.0',
    chainId: 31337, // hardhat chain id
    verifyingContract: verifier.address,
  }
}

export async function signCommon(
  signer: SignerWithAddress,
  verifier: VerifierBase | FakeContract<IVerifierBase>,
  common: CommonStruct,
): Promise<string> {
  const types = {
    Common: [
      { name: 'account', type: 'address' },
      { name: 'signer', type: 'address' },
      { name: 'domain', type: 'address' },
      { name: 'nonce', type: 'uint256' },
      { name: 'group', type: 'uint256' },
      { name: 'expiry', type: 'uint256' },
    ],
  }

  return await signer._signTypedData(erc721Domain(verifier), types, common)
}

export async function signGroupCancellation(
  signer: SignerWithAddress,
  verifier: VerifierBase | FakeContract<IVerifierBase>,
  groupCancellation: GroupCancellationStruct,
): Promise<string> {
  const types = {
    Common: [
      { name: 'account', type: 'address' },
      { name: 'signer', type: 'address' },
      { name: 'domain', type: 'address' },
      { name: 'nonce', type: 'uint256' },
      { name: 'group', type: 'uint256' },
      { name: 'expiry', type: 'uint256' },
    ],
    GroupCancellation: [
      { name: 'group', type: 'uint256' },
      { name: 'common', type: 'Common' },
    ],
  }

  return await signer._signTypedData(erc721Domain(verifier), types, groupCancellation)
}
