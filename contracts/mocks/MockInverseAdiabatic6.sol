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

    function fee(InverseAdiabatic6 memory self, UFixed6 latest, Fixed6 change, UFixed6 price) external pure returns (
        UFixed6 linearFee,
        UFixed6 proportionalFee,
        Fixed6 adiabaticFee
    ) {
        return InverseAdiabatic6Lib.fee(self, latest, change, price);
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
