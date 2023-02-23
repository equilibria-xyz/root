// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../../number/types/UFixed6.sol";

/// @dev UAccumulator6 type
struct UAccumulator6 {
    UFixed6 _value;
}

using UAccumulator6Lib for UAccumulator6 global;
struct StoredUAccumulator6 {
    uint256 _value;
}
struct UAccumulator6Storage { StoredUAccumulator6 value; }
using UAccumulator6StorageLib for UAccumulator6Storage global;


/**
 * @title UAccumulator6Lib
 * @notice Library that surfaces math operations for the unsigned Accumulator type.
 * @dev This accumulator tracks cumulative changes to a monotonically increasing value over time. Using the `accumulated` function, one
 * can determine how much a value has changed between two points in time. The `increment` function can be used to update the accumulator.
 */
library UAccumulator6Lib {
    /**
     * Returns how much has been accumulated between two accumulators
     * @param self The current point of the accumulation to compare with `from`
     * @param from The starting point of the accumulation
     * @param total Demoninator of the ratio (see `increment` function)
     */
    function accumulated(UAccumulator6 memory self, UAccumulator6 memory from, UFixed6 total) internal pure returns (UFixed6) {
        return self._value.sub(from._value).mul(total);
    }

    /**
     * @notice Increments an accumulator by a given ratio
     * @dev Always rounds down in order to prevent overstating the accumulated value
     * @param self The accumulator to increment
     * @param amount Numerator of the ratio
     * @param total Denominator of the ratio
     */
    function increment(UAccumulator6 memory self, UFixed6 amount, UFixed6 total) internal pure {
        self._value = self._value.add(amount.div(total));
    }
}

library UAccumulator6StorageLib {
    function read(UAccumulator6Storage storage self) internal view returns (UAccumulator6 memory) {
        StoredUAccumulator6 memory storedValue = self.value;
        return UAccumulator6(UFixed6.wrap(uint256(storedValue._value)));
    }

    function store(UAccumulator6Storage storage self, UAccumulator6 memory newValue) internal {
        self.value = StoredUAccumulator6(UFixed6.unwrap(newValue._value));
    }
}
