// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Fixed6, Fixed6Lib } from "../../number/types/Fixed6.sol";
import { UFixed6, UFixed6Lib } from "../../number/types/UFixed6.sol";

/// @dev SynBook6 type
struct SynBook6 {
    UFixed6 d0;
    UFixed6 d1;
    UFixed6 d2;
    UFixed6 d3;
    UFixed6 limit;
}
using SynBook6Lib for SynBook6 global;

/// @title SynBook6Lib
/// @notice Library that that manages the synthetic orderbook mechanism
library SynBook6Lib {
    /// @notice Computes the quoted price from the synthetic orderbook
    /// @param self The synthetic orderbook configuration
    /// @param latest The latest position in asset terms
    /// @param change The change in position in asset terms
    /// @param price The midpoint price of the underlying asset
    /// @return newPrice The quoted price of the given order amount based on the synbook configuration
    function compute(
        SynBook6 memory self,
        Fixed6 latest,
        Fixed6 change,
        UFixed6 price
    ) internal pure returns (UFixed6) {
        bool isBid = change > Fixed6Lib.ZERO;

        // use -f(-x) for bid orders
        latest = _flipIfBid(latest, isBid);
        change = _flipIfBid(change, isBid);

        Fixed6 from = latest / Fixed6Lib.from(self.limit);
        Fixed6 to = (latest + change) / Fixed6Lib.from(self.limit);
        Fixed6 spread = _indefinite(self.d0, self.d1, self.d2, self.d3, to, price)
            - _indefinite(self.d0, self.d1, self.d2, self.d3, from, price);

        // use -f(-x) for bid orders
        spread = _flipIfBid(spread, isBid);

        return UFixed6Lib.unsafeFrom(Fixed6Lib.from(price) + spread);
    }

    function _flipIfBid(Fixed6 value, bool isBid) private pure returns (Fixed6) {
        return isBid ? value * Fixed6Lib.NEG_ONE : value;
    }

    /// @dev f(x) = d0 * x + d1 * x^2 / 2 + d2 * x^3 / 3 + d3 * x^4 / 4
    function _indefinite(
        UFixed6 d0,
        UFixed6 d1,
        UFixed6 d2,
        UFixed6 d3,
        Fixed6 value,
        UFixed6 price
    ) private pure returns (Fixed6 result) {
        // d0 * x
        result = Fixed6Lib.from(price) * value * Fixed6Lib.from(d0);

        // d1 * x^2 / 2
        result = result + (Fixed6Lib.from(price) * value * value * Fixed6Lib.from(d1) / Fixed6Lib.from(2));

        // d2 * x^3 / 3
        result = result + (Fixed6Lib.from(price) * value * value * value *  Fixed6Lib.from(d2) / Fixed6Lib.from(3));

        // d3 * x^4 / 4
        result = result + (Fixed6Lib.from(price) * value * value * value * value * Fixed6Lib.from(d3) / Fixed6Lib.from(4));
    }
}
