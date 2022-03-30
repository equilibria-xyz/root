// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../CurveMath.sol";
import "../../number/types/PackedFixed18.sol";

/// @dev LinearUtilizationCurve type
struct LinearUtilizationCurve {
    PackedFixed18 minRate;
    PackedFixed18 maxRate;
}
using LinearUtilizationCurveLib for LinearUtilizationCurve global;

/**
 * @title LinearUtilizationCurveLib
 * @notice Library for the Linear utilization curve type
 */
library LinearUtilizationCurveLib {
    error LinearInvalidParametersError();

    /**
     * @notice Creates a Linear utilization curve from its parameters
     * @param minRate The rate at zero utilization
     * @param maxRate The rate at complete utilization
     * @return New Linear utilization curve
     */
    function from(Fixed18 minRate, Fixed18 maxRate)
    internal pure returns (LinearUtilizationCurve memory)
    {
        // Rate must be monotonically increasing
        if (minRate.gt(maxRate)) revert LinearInvalidParametersError();

        return LinearUtilizationCurve({minRate: minRate.pack(), maxRate: maxRate.pack() });
    }

    /**
     * @notice Computes the corresponding rate for a utilization ratio
     * @param utilization The utilization ratio
     * @return The corresponding rate
     */
    function compute(LinearUtilizationCurve memory self, UFixed18 utilization) internal pure returns (Fixed18) {
        if (utilization.lt(UFixed18Lib.ONE)) {
            return CurveMath.linearInterpolation(
                UFixed18Lib.ZERO,
                self.minRate.unpack(),
                UFixed18Lib.ONE,
                self.maxRate.unpack(),
                utilization
            );
        }
        return self.maxRate.unpack();
    }
}
