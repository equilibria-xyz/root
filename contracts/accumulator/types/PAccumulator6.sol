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

/**
 * @title PAccumulator6Lib
 * @notice
 * @dev
 */
library PAccumulator6Lib {
    function accumulate(
        PAccumulator6 memory self,
        PController6 memory controller,
        Fixed6 skew,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed6 notional
    ) internal pure returns (Fixed6 accumulated) {
        (Fixed6 newValue, Fixed6 newValueCapped, UFixed6 interceptTimestamp) =
            controller.compute(self._value, skew, fromTimestamp, toTimestamp);
        interceptTimestamp = interceptTimestamp.min(UFixed6Lib.from(toTimestamp));

        // within max
        accumulated = _accumulate(self._value.add(newValue), UFixed6Lib.from(fromTimestamp), interceptTimestamp, notional)
            .div(Fixed6Lib.from(2));

        // outside of max
        accumulated = _accumulate(newValueCapped, interceptTimestamp, UFixed6Lib.from(toTimestamp), notional).add(accumulated);

        self._value = newValueCapped;
        self._skew = skew;
    }

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
