# Root

Core library for DeFi.

## Facilities
| Name            | Purpose                                        |
|             ---:|------------------------------------------------|
| **accumulator** | tracks cumulative changes to a value           |
| **attribute**   | abstract contracts with foundational patterns  |
| **number**      | fixed decimal types and math functions         |
| **pid**         | proportional integral derivative controller    |
| **token**       | helpers for working with fungible tokens       |
| **utilization** | calculates rates based on a utilization curve  |
| **verifier**    | helps create and verify EIP712 signed messages |

## Installation

```
npm install @equilibria/root
```

## Contributing

### Prerequisites

This repo works best with Node.js v16.x.x, this is preconfigured for users of [asdf](https://asdf-vm.com/).

Before running any command, make sure to install dependencies:

```sh
$ yarn
```

### Compile

Compile the smart contracts with Hardhat:

```sh
$ yarn compile
```

This also generates the Typechain types

### Test

Run the Mocha tests:

```sh
$ yarn test
```

To run tests against a Mainnet fork, set your `ALCHEMY_KEY` in `.env` and run

```sh
$ yarn test-integration
```

### Gas Report
To get a gas report based on unit test calls:

```sh
$ yarn gasReport
```

### Deploy contract to network (requires Mnemonic and infura API key)

```
npx hardhat run --network rinkeby ./scripts/deploy.ts
```

### Validate a contract with etherscan (requires API key)

```
npx hardhat verify --network <network> <DEPLOYED_CONTRACT_ADDRESS> "Constructor argument 1"
```

### Added plugins

- Contract Sizer [hardhat-contract-sizer](https://github.com/ItsNickBarry/hardhat-contract-sizer)
- Gas reporter [hardhat-gas-reporter](https://hardhat.org/plugins/hardhat-gas-reporter.html)
- Etherscan [hardhat-etherscan](https://hardhat.org/plugins/nomiclabs-hardhat-etherscan.html)
