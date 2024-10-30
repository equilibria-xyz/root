// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../adiabatic/types/NoopAdiabatic6.sol";

contract MockNoopAdiabatic6 {
    function linear(NoopAdiabatic6 memory self, Fixed6 change, UFixed6 price) external pure returns (UFixed6) {
        return NoopAdiabatic6Lib.linear(self, change, price);
    }

    function proportional(NoopAdiabatic6 memory self, Fixed6 change, UFixed6 price) external pure returns (UFixed6) {
        return NoopAdiabatic6Lib.proportional(self, change, price);
    }
}
