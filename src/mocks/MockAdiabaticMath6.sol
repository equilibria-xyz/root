// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../adiabatic/AdiabaticMath6.sol";

contract MockAdiabaticMath6 {
    function linearFee(
        UFixed6 fee,
        Fixed6 change,
        UFixed6 price
    ) external pure returns (UFixed6) {
        return AdiabaticMath6.linearFee(fee, change, price);
    }

    function proportionalFee(
        UFixed6 scale,
        UFixed6 fee,
        Fixed6 change,
        UFixed6 price
    ) external pure returns (UFixed6) {
        return AdiabaticMath6.proportionalFee(scale, fee, change, price);
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
