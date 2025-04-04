# Root

Core library for DeFi.

## Facilities
| Name            | Purpose                                        |
|             ---:|------------------------------------------------|
| **accumulator** | tracks cumulative changes to a value           |
| **attribute**   | abstract contracts with foundational patterns  |
| **number**      | fixed decimal types and math functions         |
| **synbook**     | synthetic orderbook                            |
| **token**       | helpers for working with fungible tokens       |
| **utilization** | calculates rates based on a utilization curve  |
| **verifier**    | helps create and verify EIP712 signed messages |

## Installation
```sh
forge install equilibria/root@v3
```

## Usage

### console
This debugging library is designed to be a replacement for hardhat or forge's console library, adding support for logging signed integers and fixed **number** types in format strings. However, it only supports the following types:
- uint256
- int256
- UFixed6
- UFixed18
- Fixed6
- Fixed18
- address
- bool

It supports 1, 2, or 3 of the above values in a format string.

To use, import the library...
```
import { console } from "@equilibria/root/utils/console.sol";
```
...and then call `console.log` with your format string:
```
        console.log("Processing local order for %s with maker %s at %s",
            context.account,   // address
            newOrder.maker(),  // Fixed6 (without unwrap)
            newOrder.timestamp // uint256
        );
```

## Contributing

### Prerequisites
This package uses [Foundry](https://book.getfoundry.sh/), a smart contract development toolchain.

To install Foundry:

```sh
curl -L https://foundry.paradigm.xyz | bash
# (follow instructions to source environment or start a new shell)
foundryup
```
Other installation options available [here](https://book.getfoundry.sh/getting-started/installation).

Before running any command, make sure to install dependencies:
```sh
forge install
```

Optionally, to install [Slither](https://github.com/crytic/slither) static analyzer:
```sh
python3 -m pip install slither-analyzer
```
Other installation options available [here](https://github.com/crytic/slither?tab=readme-ov-file#how-to-install).

Optionally, to install solhint:
```sh
sudo npm install -g solhint
```

### Compile
```sh
forge build
```

### Test
```sh
forge test
```
or for coverage report
```sh
make coverage
```

### Documentation
To autogenerate Markdown documentation based on natspec comments:
```sh
forge doc
```
To run local server for browsing; add `--serve` option.  Details [here](https://book.getfoundry.sh/reference/forge/forge-doc?highlight=forge%20doc#forge-doc).
