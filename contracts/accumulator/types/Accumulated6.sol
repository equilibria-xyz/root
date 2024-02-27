// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../../number/types/Fixed6.sol";
import "../../number/types/UFixed6.sol";
import "./Accumulator6.sol";

/// @dev Accumulated6 type
struct Accumulated6 {
    Fixed6 _value;
}
using Accumulated6Lib for Accumulated6 global;

/**
 * @title Accumulated6Lib
 * @notice Library that surfaces math operations for the signed Accumulator type.
 * @dev This accumulator tracks cumulative changes to a value over time. Using the `accumulated` function, one
 * can determine how much a value has changed between two points in time. The `increment` and `decrement` functions
 * can be used to update the accumulator.
 */
library Accumulated6Lib {
    /**
     * @notice Creates an Accumulator6 from an Accumulated6 and a total
     * @param self The accumulated value
     * @param total The total for the accumulator
     * @return The Accumulator6
     */
    function with(Accumulated6 memory self, UFixed6 total) internal pure returns (Accumulator6 memory) {
        return Accumulator6(self, total);
    }

    /**
     * Returns how much has been accumulated between two accumulators
     * @param self The current point of the accumulation to compare with `from`
     * @param from The starting point of the accumulation
     * @param total Demoninator of the ratio (see `increment` and `decrement` functions)
     */
    function accumulated(Accumulated6 memory self, Accumulated6 memory from, UFixed6 total) internal pure returns (Fixed6) {
        return _mul(self._value.sub(from._value), total);
    }

    /**
     * @notice Increments an accumulator by a given ratio
     * @dev Always rounds down in order to prevent overstating the accumulated value
     * @param self The accumulator to increment
     * @param amount Numerator of the ratio
     * @param total Denominator of the ratio
     */
    function increment(Accumulated6 memory self, Fixed6 amount, UFixed6 total) internal pure {
        if (amount.isZero()) return;
        self._value = self._value.add(_div(amount, total));
    }

    /**
     * @notice Decrements an accumulator by a given ratio
     * @dev Always rounds down in order to prevent overstating the accumulated value
     * @param self The accumulator to decrement
     * @param amount Numerator of the ratio
     * @param total Denominator of the ratio
     */
    function decrement(Accumulated6 memory self, Fixed6 amount, UFixed6 total) internal pure {
        if (amount.isZero()) return;
        self._value = self._value.add(_div(amount.mul(Fixed6Lib.NEG_ONE), total));
    }

    function _div(Fixed6 amount, UFixed6 total) private pure returns (Fixed6) {
        return amount.sign() == -1 ? amount.divOut(Fixed6Lib.from(total)) : amount.div(Fixed6Lib.from(total));
    }

    function _mul(Fixed6 amount, UFixed6 total) private pure returns (Fixed6) {
        return amount.sign() == -1 ? amount.mulOut(Fixed6Lib.from(total)) : amount.mul(Fixed6Lib.from(total));
    }
}
