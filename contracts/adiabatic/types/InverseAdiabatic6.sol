// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../../number/types/Fixed6.sol";
import "../../number/types/UFixed6.sol";

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
 *      f(skew) = adiabaticFee * max(scale - skew, 0)
 * 
 *      This is used to reward or penalize actions that move skew up or down this curve accordingly with net-zero
 *      value to the system with respect to the underlying asset.
 */
library InverseAdiabatic6Lib {
    error Adiabatic6ZeroScaleError();

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
        UFixed6 latestSkew = self.scale.unsafeSub(latest);
        Fixed6 orderSkew = change.min(Fixed6Lib.from(latestSkew)).mul(Fixed6Lib.NEG_ONE);

        if (latestSkew.isZero() && orderSkew.isZero()) return Fixed6Lib.ZERO;
        if (self.scale.isZero()) revert Adiabatic6ZeroScaleError();

        // normalize for skew scale
        (Fixed6 latestScaled, Fixed6 changeScaled) =
            (Fixed6Lib.from(latestSkew.div(self.scale)), orderSkew.div(Fixed6Lib.from(self.scale)));

        // adiabatic fee = skew change * fee percentage * mean of skew range
        return change.mul(Fixed6Lib.from(price)).mul(Fixed6Lib.NEG_ONE)
            .mul(Fixed6Lib.from(self.adiabaticFee)).mul(_mean(latestScaled, latestScaled.add(changeScaled)));
    }

    /// @notice Computes the latest exposure along with all fees
    /// @param self The adiabatic configuration
    /// @param latest The latest skew in asset terms
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return latestExposure The latest total exposure in asset terms
    /// @return linearFee The linear fee in underlying terms
    /// @return proportionalFee The proportional fee in underlying terms
    /// @return adiabaticFee The adiabatic fee in underlying terms
    function sync(InverseAdiabatic6 memory self, UFixed6 latest, Fixed6 change, UFixed6 price) internal pure returns (
        Fixed6 latestExposure,
        UFixed6 linearFee,
        UFixed6 proportionalFee,
        Fixed6 adiabaticFee
    ) {
        latestExposure = compute(self, UFixed6Lib.ZERO, Fixed6Lib.from(latest), UFixed6Lib.ONE);
        linearFee = change.abs().mul(price).mul(self.linearFee);
        proportionalFee = change.abs().mul(price).muldiv(change.abs(), self.scale).mul(self.proportionalFee);
        adiabaticFee = compute(self, latest, change, price);
    }

    /// @dev Updates the scale and compute the resultant change fee
    /// @param self The adiabatic configuration
    /// @param newConfig The new fee config
    /// @param latest The latest skew
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

    /// @notice Finds the mean value of the impact function f(x) = x over `from` to `to`
    /// @param from The lower bound
    /// @param to The upper bound
    /// @return The mean value
    function _mean(Fixed6 from, Fixed6 to) private pure returns (Fixed6) {
        return from.add(to).div(Fixed6Lib.from(2));
    }
}
