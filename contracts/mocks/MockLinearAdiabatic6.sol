// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../adiabatic/types/LinearAdiabatic6.sol";

contract MockLinearAdiabatic6 {
    function compute(
        LinearAdiabatic6 memory self,
        Fixed6 latest,
        Fixed6 change,
        UFixed6 price
    ) external pure returns (Fixed6) {
        return LinearAdiabatic6Lib.compute(self, latest, change, price);
    }

    function exposure(LinearAdiabatic6 memory self, Fixed6 latest) external pure returns (Fixed6) {
        return LinearAdiabatic6Lib.exposure(self, latest);
    }

    function linear(LinearAdiabatic6 memory self, Fixed6 change, UFixed6 price) external pure returns (UFixed6) {
        return LinearAdiabatic6Lib.linear(self, change, price);
    }

    function proportional(LinearAdiabatic6 memory self, Fixed6 change, UFixed6 price) external pure returns (UFixed6) {
        return LinearAdiabatic6Lib.proportional(self, change, price);
    }

    function adiabatic(LinearAdiabatic6 memory self, Fixed6 latest, Fixed6 change, UFixed6 price) external pure returns (Fixed6) {
        return LinearAdiabatic6Lib.adiabatic(self, latest, change, price);
    }

    function update(
        LinearAdiabatic6 memory self,
        LinearAdiabatic6 memory newConfig,
        Fixed6 latest,
        UFixed6 price
    ) external pure returns (Fixed6) {
        return LinearAdiabatic6Lib.update(self, newConfig, latest, price);
    }
}
