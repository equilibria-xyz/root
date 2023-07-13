// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../../number/types/Fixed6.sol";

/// @dev PController6 type
struct PController6 {
    UFixed6 k;
    UFixed6 max;
}
using PController6Lib for PController6 global;

/**
 * @title PController6Lib
 * @notice
 * @dev
 */
library PController6Lib {
    function compute(
        PController6 memory self,
        Fixed6 value,
        Fixed6 skew,
        uint256 fromTimestamp,
        uint256 toTimestamp
    ) internal pure returns (Fixed6 newValue, Fixed6 newValueCapped, UFixed6 interceptTimestamp) {
        newValue = value.add(Fixed6Lib.from(int256(toTimestamp - fromTimestamp)).mul(skew).div(Fixed6Lib.from(self.k)));

        newValueCapped = Fixed6Lib.from(newValue.sign(), self.max.min(newValue.abs()));

        (UFixed6 distance, Fixed6 range) = (UFixed6Lib.from(toTimestamp - fromTimestamp), newValue.sub(value));
        UFixed6 buffer = newValue.sub(Fixed6Lib.from(range.sign(), self.max)).abs();
        interceptTimestamp = range.isZero() ?
            UFixed6Lib.MAX :
            UFixed6Lib.from(fromTimestamp).add(distance.muldiv(buffer, range.abs()));
    }
}
