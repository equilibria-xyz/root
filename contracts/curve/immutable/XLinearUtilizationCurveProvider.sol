// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../types/LinearUtilizationCurve.sol";
import "../UtilizationCurveProvider.sol";
import "../../number/types/UFixed18.sol";
import "../../number/types/Fixed18.sol";

/**
 * @title XLinearUtilizationCurveProvider
 * @notice Library for manage storing and surfacing a Linear utilization curve model.
 * @dev Uses an immutable storage pattern to store the utilization curve parameters which is more gas efficient,
 *      but does not allow parameters to be updated over time.
 */
abstract contract XLinearUtilizationCurveProvider is UtilizationCurveProvider {
    PackedFixed18 private immutable _minRate;
    PackedFixed18 private immutable _maxRate;

    /**
     * @notice Initializes the contract state
     * @param initialUtilizationCurve Initial parameter set for the utilization curve
     */
    constructor(LinearUtilizationCurve memory initialUtilizationCurve) {
        _minRate = initialUtilizationCurve.minRate;
        _maxRate = initialUtilizationCurve.maxRate;
    }

    /**
     * @notice Returns the utilization curve parameter set
     * @return Current utilization curve parameter set
     */
    function utilizationCurve() public view returns (LinearUtilizationCurve memory) {
        return LinearUtilizationCurve({
            minRate: _minRate,
            maxRate: _maxRate
        });
    }

    /**
     * @notice Returns the computed rate based on the supplied `utilization`
     * @param utilization Utilization ratio
     * @return Corresponding rate
     */
    function _computeRate(UFixed18 utilization) internal override view returns (Fixed18) {
        return utilizationCurve().compute(utilization);
    }
}
