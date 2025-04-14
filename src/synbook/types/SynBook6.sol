// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Fixed6, Fixed6Lib } from "src/number/types/Fixed6.sol";
import { UFixed6, UFixed6Lib } from "src/number/types/UFixed6.sol";

/// @dev SynBook6 type
struct SynBook6 {
    UFixed6 d0;
    UFixed6 d1;
    UFixed6 d2;
    UFixed6 d3;
    UFixed6 scale;
}
using SynBook6Lib for SynBook6 global;

/// @title SynBook6Lib
/// @notice Library that that manages the synthetic orderbook mechanism
library SynBook6Lib {
    /// @notice Computes the spread from the synthetic orderbook
    /// @param self The synthetic orderbook configuration
    /// @param latest The latest skew in asset terms
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return newPrice The price of a given order amount based on the synbook for the account
    function compute(
        SynBook6 memory self,
        Fixed6 latest,
        Fixed6 change,
        UFixed6 price
    ) internal pure returns (UFixed6 newPrice) {
        Fixed6 from = latest / (Fixed6Lib.from(self.scale));
        Fixed6 to = (latest + change) / (Fixed6Lib.from(self.scale));

        newPrice = UFixed6Lib.from(Fixed6Lib.from(price)
            + (_indefinite(self.d0, self.d1, self.d2, self.d3, to, price))
            - (_indefinite(self.d0, self.d1, self.d2, self.d3, from, price)));
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
