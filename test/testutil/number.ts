import { BigNumber, parseFixed } from '@ethersproject/bignumber'

export function parseBase6(value: string): BigNumber {
  return parseFixed(value, 6)
}
