// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../../number/types/Fixed6.sol";
import "../../number/types/UFixed6.sol";
import "../AdiabaticMath6.sol";

/// @dev InverseAdiabatic6 type
struct InverseAdiabatic6 {
    UFixed6 linearFee;
    UFixed6 proportionalFee;
    UFixed6 adiabaticFee;
    UFixed6 scale;
}
using InverseAdiabatic6Lib for InverseAdiabatic6 global;

/**
 * @title InverseAdiabatic6Lib
 * @notice Library that that manages the inverse adiabatic fee algorithm
 * @dev This algorithm specifies an adiatatic fee over the function:
 *
 *      f(skew) = adiabaticFee * max(scale - skew, 0), skew >= 0
 *
 *      This is used to reward or penalize actions that move skew up or down this curve accordingly with net-zero
 *      value to the system with respect to the underlying asset.
 */
library InverseAdiabatic6Lib {
    /// @notice Computes the adiabatic fee from a latest skew and change in skew
    /// @param self The adiabatic configuration
    /// @param latest The latest skew in asset terms
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The adiabatic fee in underlying terms
    function compute(
        InverseAdiabatic6 memory self,
        UFixed6 latest,
        Fixed6 change,
        UFixed6 price
    ) internal pure returns (Fixed6) {
        UFixed6 current = UFixed6Lib.from(Fixed6Lib.from(latest).add(change));
        Fixed6 latestSkew = Fixed6Lib.from(self.scale.unsafeSub(latest));
        Fixed6 currentSkew = Fixed6Lib.from(self.scale.unsafeSub(current));

        return AdiabaticMath6.linearCompute(
            self.scale,
            self.adiabaticFee,
            latestSkew,
            currentSkew.sub(latestSkew),
            price
        );
    }

    /// @notice Computes the latest exposure
    /// @param self The adiabatic configuration
    /// @param latest The latest skew in asset terms
    /// @return The latest total exposure in asset terms
    function exposure(InverseAdiabatic6 memory self, UFixed6 latest) internal pure returns (Fixed6) {
        return compute(self, UFixed6Lib.ZERO, Fixed6Lib.from(latest), UFixed6Lib.ONE);
    }

    /// @notice Computes the linear fee
    /// @param self The adiabatic configuration
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The linear fee in underlying terms
    function linear(InverseAdiabatic6 memory self, Fixed6 change, UFixed6 price) internal pure returns (UFixed6) {
        return AdiabaticMath6.linearFee(self.linearFee, change, price);
    }

    /// @notice Computes the proportional fee
    /// @param self The adiabatic configuration
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The proportional fee in underlying terms
    function proportional(InverseAdiabatic6 memory self, Fixed6 change, UFixed6 price) internal pure returns (UFixed6) {
        return AdiabaticMath6.proportionalFee(self.scale, self.proportionalFee, change, price);
    }

    /// @notice Computes the adiabatic fee
    /// @param self The adiabatic configuration
    /// @param latest The latest skew in asset terms
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The adiabatic fee in underlying terms
    function adiabatic(
        InverseAdiabatic6 memory self,
        UFixed6 latest,
        Fixed6 change,
        UFixed6 price
    ) internal pure returns (Fixed6) {
        return compute(self, latest, change, price);
    }

    /// @dev Updates the scale and compute the resultant change fee
    /// @param self The adiabatic configuration
    /// @param newConfig The new fee config
    /// @param latest The latest skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The update fee in underlying terms
    function update(
        InverseAdiabatic6 memory self,
        InverseAdiabatic6 memory newConfig,
        UFixed6 latest,
        UFixed6 price
    ) internal pure returns (Fixed6) {
        Fixed6 prior = compute(self, UFixed6Lib.ZERO, Fixed6Lib.from(latest), price);
        (self.linearFee, self.proportionalFee, self.adiabaticFee, self.scale) =
            (newConfig.linearFee, newConfig.proportionalFee, newConfig.adiabaticFee, newConfig.scale);
        return compute(self, UFixed6Lib.ZERO, Fixed6Lib.from(latest), price).sub(prior);
    }
}
