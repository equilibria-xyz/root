// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../../number/types/Fixed6.sol";
import "../../number/types/UFixed6.sol";
import "../AdiabaticMath6.sol";

/// @dev NoopAdiabatic6 type
struct NoopAdiabatic6 {
    UFixed6 linearFee;
    UFixed6 proportionalFee;
    UFixed6 scale;
}
using NoopAdiabatic6Lib for NoopAdiabatic6 global;

/**
 * @title NoopAdiabatic6Lib
 * @notice Library that that manages the no-op adiabatic fee algorithm
 * @dev This algorithm specifies a fee schedule without an adiabatic fee. This is used for fees that need unsigned
 *      fee impact without a signed shift fee based on skew.
 */
library NoopAdiabatic6Lib {
    /// @notice Computes the linear fee
    /// @param self The adiabatic configuration
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The linear fee in underlying terms
    function linear(NoopAdiabatic6 memory self, Fixed6 change, UFixed6 price) internal pure returns (UFixed6) {
        return AdiabaticMath6.linearFee(self.linearFee, change, price);
    }

    /// @notice Computes the proportional fee
    /// @param self The adiabatic configuration
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The proportional fee in underlying terms
    function proportional(NoopAdiabatic6 memory self, Fixed6 change, UFixed6 price) internal pure returns (UFixed6) {
        return AdiabaticMath6.proportionalFee(self.scale, self.proportionalFee, change, price);
    }
}
