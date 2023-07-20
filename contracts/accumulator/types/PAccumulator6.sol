// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../../number/types/Fixed6.sol";
import "./PController6.sol";

/// @dev PAccumulator6 type
struct PAccumulator6 {
    Fixed6 _value;
    Fixed6 _skew;
}
using PAccumulator6Lib for PAccumulator6 global;

/// @title PAccumulator6Lib
/// @notice Accumulator for a the fixed 6-decimal PID controller. This holds the "last seen state" of the PID controller
///         and works in conjunction with the PController6 to compute the current rate.
/// @dev This implementation is specifically a P controller, with I_k and D_k both set to 0. In between updates, it
///      continues to accumulate at a linear rate based on the previous skew, but the rate is capped at the max value.
///      Once the rate hits the max value, it will continue to accumulate at the max value until the next update.
library PAccumulator6Lib {
    /// @notice Accumulates the rate against notional given the prior and current state
    /// @param self The controller accumulator
    /// @param controller The controller configuration
    /// @param skew The current skew
    /// @param fromTimestamp The timestamp of the prior accumulation
    /// @param toTimestamp The current timestamp
    /// @param notional The notional to accumulate against
    /// @return accumulated The total accumulated amount
    function accumulate(
        PAccumulator6 memory self,
        PController6 memory controller,
        Fixed6 skew,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed6 notional
    ) internal pure returns (Fixed6 accumulated) {
        // compute new value and intercept
        (Fixed6 newValue, UFixed6 interceptTimestamp) =
            controller.compute(self._value, self._skew, fromTimestamp, toTimestamp);

        // accumulate rate within max
        accumulated = _accumulate(
            self._value.add(newValue),
            UFixed6Lib.from(fromTimestamp),
            interceptTimestamp,
            notional
        ).div(Fixed6Lib.from(2)); // rate = self._value + newValue / 2 -> divide here for added precision

        // accumulate rate outside of max
        accumulated = _accumulate(
            newValue,
            interceptTimestamp,
            UFixed6Lib.from(toTimestamp),
            notional
        ).add(accumulated);

        // update values
        self._value = newValue;
        self._skew = skew;
    }

    /// @notice Helper function to accumulate a singular rate against notional
    /// @param rate The rate to accumulate
    /// @param fromTimestamp The timestamp to accumulate from
    /// @param toTimestamp The timestamp to accumulate to
    /// @param notional The notional to accumulate against
    /// @return The accumulated amount
    function _accumulate(
        Fixed6 rate,
        UFixed6 fromTimestamp,
        UFixed6 toTimestamp,
        UFixed6 notional
    ) private pure returns (Fixed6) {
        return rate
            .mul(Fixed6Lib.from(toTimestamp.sub(fromTimestamp)))
            .mul(Fixed6Lib.from(notional))
            .div(Fixed6Lib.from(365 days));
    }
}
