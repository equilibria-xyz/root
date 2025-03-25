// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../../number/types/Fixed6.sol";
import "../../number/types/UFixed6.sol";
import "../AdiabaticMath6.sol";

/// @dev LinearAdiabatic6 type
struct LinearAdiabatic6 {
    UFixed6 linearFee;
    UFixed6 proportionalFee;
    UFixed6 adiabaticFee;
    UFixed6 scale;
}
using LinearAdiabatic6Lib for LinearAdiabatic6 global;

/**
 * @title LinearAdiabatic6Lib
 * @notice Library that that manages the linear adiabatic fee algorithm
 * @dev This algorithm specifies an adiatatic fee over the function:
 *
 *      f(skew) = adiabaticFee * skew
 *
 *      This is used to reward or penalize actions that move skew up or down this curve accordingly with net-zero
 *      value to the system with respect to the underlying asset.
 */
library LinearAdiabatic6Lib {
    /// @notice Computes the adiabatic fee from a latest skew and change in skew
    /// @param self The adiabatic configuration
    /// @param latest The latest skew in asset terms
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The adiabatic fee in underlying terms
    function compute(
        LinearAdiabatic6 memory self,
        Fixed6 latest,
        Fixed6 change,
        UFixed6 price
    ) internal pure returns (Fixed6) {
        return AdiabaticMath6.linearCompute(
            self.scale,
            self.adiabaticFee,
            latest,
            change,
            price
        );
    }

    /// @notice Computes the latest exposure along with all fees
    /// @param self The adiabatic configuration
    /// @param latest The latest skew in asset terms
    /// @return The latest total exposure in asset terms
    function exposure(LinearAdiabatic6 memory self, Fixed6 latest) internal pure returns (Fixed6) {
        return compute(self, Fixed6Lib.ZERO, latest, UFixed6Lib.ONE);
    }

    /// @dev Computes the change in exposure from a new configuration
    /// @param self The latest fee configuration
    /// @param newConfig The new fee configuration
    /// @param latest The latest skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The update fee in underlying terms
    function exposure(
        LinearAdiabatic6 memory self,
        LinearAdiabatic6 memory newConfig,
        Fixed6 latest,
        UFixed6 price
    ) internal pure returns (Fixed6) {
        return compute(newConfig, Fixed6Lib.ZERO, latest, price).sub(compute(self, Fixed6Lib.ZERO, latest, price));
    }

    /// @notice Computes the linear fee
    /// @param self The adiabatic configuration
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The linear fee in underlying terms
    function linear(LinearAdiabatic6 memory self, Fixed6 change, UFixed6 price) internal pure returns (UFixed6) {
        return AdiabaticMath6.linearFee(self.linearFee, change, price);
    }

    /// @notice Computes the proportional fee
    /// @param self The adiabatic configuration
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The proportional fee in underlying terms
    function proportional(LinearAdiabatic6 memory self, Fixed6 change, UFixed6 price) internal pure returns (UFixed6) {
        return AdiabaticMath6.proportionalFee(self.scale, self.proportionalFee, change, price);
    }

    /// @notice Computes the adiabatic fee
    /// @param self The adiabatic configuration
    /// @param latest The latest skew in asset terms
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The adiabatic fee in underlying terms
    function adiabatic(
        LinearAdiabatic6 memory self,
        Fixed6 latest,
        Fixed6 change,
        UFixed6 price
    ) internal pure returns (Fixed6) {
        return compute(self, latest, change, price);
    }
}
