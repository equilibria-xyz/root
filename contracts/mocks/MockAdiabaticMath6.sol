// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../adiabatic/AdiabaticMath6.sol";

contract MockAdiabaticMath6 {
    function baseFee(
        UFixed6 scale,
        UFixed6 linearFee,
        UFixed6 proportionalFee,
        Fixed6 change,
        UFixed6 price
    ) external pure returns (UFixed6, UFixed6) {
        return AdiabaticMath6.baseFee(scale, linearFee, proportionalFee, change, price);
    }

    function linearCompute(
        UFixed6 scale,
        UFixed6 adiabaticFee,
        Fixed6 latest,
        Fixed6 change,
        UFixed6 notional
    ) external pure returns (Fixed6) {
        return AdiabaticMath6.linearCompute(scale, adiabaticFee, latest, change, notional);
    }
}
