// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../number/types/UFixed6.sol";
import "../number/types/Fixed6.sol";

/**
 * @title AdiabaticMath6
 * @notice Library for managing math operations for adiabatic fees.
 */
library AdiabaticMath6 {
    error Adiabatic6ZeroScaleError();

    /// @notice Computes the base fees for an order
    /// @param fee The linear fee percentage
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The linear fee in underlying terms
    function linearFee(UFixed6 fee, Fixed6 change, UFixed6 price) internal pure returns (UFixed6) {
        return change.abs().mul(price).mul(fee);
    }

    /// @notice Computes the base fees for an order
    /// @param scale The scale of the skew
    /// @param fee The proportional fee percentage
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The proportional fee in underlying terms
    function proportionalFee(UFixed6 scale, UFixed6 fee, Fixed6 change, UFixed6 price) internal pure returns (UFixed6) {
        return change.abs().mul(price).muldiv(change.abs(), scale).mul(fee);
    }

    /// @notice Computes the adiabatic fee from a latest skew and change in skew over a linear function
    /// @param scale The scale of the skew
    /// @param adiabaticFee The adiabatic fee percentage
    /// @param latest The latest skew in asset terms
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The adiabatic fee in underlying terms
    function linearCompute(
        UFixed6 scale,
        UFixed6 adiabaticFee,
        Fixed6 latest,
        Fixed6 change,
        UFixed6 price
    ) internal pure returns (Fixed6) {
        if (latest.isZero() && change.isZero()) return Fixed6Lib.ZERO;
        if (scale.isZero()) revert Adiabatic6ZeroScaleError();

        // normalize for skew scale
        (Fixed6 latestScaled, Fixed6 changeScaled) =
            (latest.div(Fixed6Lib.from(scale)), change.div(Fixed6Lib.from(scale)));

        // adiabatic fee = notional * fee percentage * mean of skew range
        return change.mul(Fixed6Lib.from(price)).mul(Fixed6Lib.from(adiabaticFee))
            .mul(_linearMean(latestScaled, latestScaled.add(changeScaled)));
    }

    /// @notice Finds the mean value of the function f(x) = x over `from` to `to`
    /// @param from The lower bound
    /// @param to The upper bound
    /// @return The mean value
    function _linearMean(Fixed6 from, Fixed6 to) private pure returns (Fixed6) {
        return from.add(to).div(Fixed6Lib.from(2));
    }
}
