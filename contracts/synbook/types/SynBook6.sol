// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../../number/types/Fixed6.sol";
import "../../number/types/UFixed6.sol";

/// @dev SynBook6 type
struct SynBook6 {
    Fixed6 d0; // TODO: some of these should be unsigned, ensure p(s) > 0
    Fixed6 d1;
    Fixed6 d2;
    Fixed6 d3;
    UFixed6 scale;
}
using SynBook6Lib for SynBook6 global;

/**
 * @title SynBook6Lib
 * @notice Library that that manages the synthetic orderbook mechanism
 * @dev
 */
library SynBook6Lib {
    /// @notice Computes the spread from the synthetic orderbook
    /// @param self The synthetic orderbook configuration
    /// @param latest The latest skew in asset terms
    /// @param change The change in skew in asset terms
    /// @param price The price of the underlying asset
    /// @return The spread in dollar terms
    function compute(
        SynBook6 memory self,
        Fixed6 latest,
        Fixed6 change,
        UFixed6 price
    ) internal pure returns (Fixed6) {
        (Fixed6 from, Fixed6 to, Fixed6 sign) = (
            latest.div(Fixed6Lib.from(self.scale)),
            latest.add(change).div(Fixed6Lib.from(self.scale)),
            Fixed6Lib.from(change.sign(), UFixed6Lib.ONE)
        );

        Fixed6 spread = _indefinite(self.d0, self.d1, self.d2, self.d3, sign, to)
            .sub(_indefinite(self.d0, self.d1, self.d2, self.d3, sign, from));

        // TODO: put notional in indefinite for increased precision
        return spread.mul(Fixed6Lib.from(change.abs())).mul(Fixed6Lib.from(price));
    }

    /// @dev f(x) = d0 * x + d1 * x^2 / 2 + d2 * x^3 / 3 + d3 * x^4 / 4
    /// @dev sign = 1 for buy / ask and -1 for sell / bid
    function _indefinite(
        Fixed6 d0,
        Fixed6 d1,
        Fixed6 d2,
        Fixed6 d3,
        Fixed6 sign,
        Fixed6 value
    ) private pure returns (Fixed6 result) {
        Fixed6 x = value;
        Fixed6 s = sign;

        // d0 * x
        result = s.mul(x).mul(d0);
        x = x.mul(value);
        s = s.mul(sign);

        // d1 * x^2 / 2
        result = result.add(s.mul(x).mul(d1)).div(Fixed6Lib.from(2));
        x = x.mul(value);
        s = s.mul(sign);

        // d2 * x^3 / 3
        result = result.add(s.mul(x).mul(d2)).div(Fixed6Lib.from(3));
        x = x.mul(value);
        s = s.mul(sign);

        // d3 * x^4 / 4
        result = result.add(s.mul(x).mul(d3)).div(Fixed6Lib.from(4));
    }
}
