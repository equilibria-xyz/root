// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../adiabatic/types/InverseAdiabatic6.sol";

contract MockInverseAdiabatic6 {
    function compute(
        InverseAdiabatic6 memory self,
        UFixed6 latest,
        Fixed6 change,
        UFixed6 price
    ) external pure returns (Fixed6) {
        return InverseAdiabatic6Lib.compute(self, latest, change, price);
    }

    function exposure(InverseAdiabatic6 memory self, UFixed6 latest) external pure returns (Fixed6) {
        return InverseAdiabatic6Lib.exposure(self, latest);
    }

    function linear(InverseAdiabatic6 memory self, Fixed6 change, UFixed6 price) external pure returns (UFixed6) {
        return InverseAdiabatic6Lib.linear(self, change, price);
    }

    function proportional(InverseAdiabatic6 memory self, Fixed6 change, UFixed6 price) external pure returns (UFixed6) {
        return InverseAdiabatic6Lib.proportional(self, change, price);
    }

    function adiabatic(InverseAdiabatic6 memory self, UFixed6 latest, Fixed6 change, UFixed6 price) external pure returns (Fixed6) {
        return InverseAdiabatic6Lib.adiabatic(self, latest, change, price);
    }

    function update(
        InverseAdiabatic6 memory self,
        InverseAdiabatic6 memory newConfig,
        UFixed6 latest,
        UFixed6 price
    ) external pure returns (Fixed6) {
        return InverseAdiabatic6Lib.update(self, newConfig, latest, price);
    }
}
