// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../types/JumpRateUtilizationCurve.sol";
import "../UtilizationCurveProvider.sol";
import "../../number/types/UFixed18.sol";
import "../../number/types/Fixed18.sol";

/**
 * @title XJumpRateUtilizationCurveProvider
 * @notice Library for manage storing and surfacing a Jump Rate utilization curve model.
 * @dev Uses an immutable storage pattern to store the utilization curve parameters which is more gas efficient,
 *      but does not allow parameters to be updated over time.
 */
abstract contract XJumpRateUtilizationCurveProvider is UtilizationCurveProvider {
    PackedFixed18 private immutable _minRate;
    PackedFixed18 private immutable _maxRate;
    PackedFixed18 private immutable _targetRate;
    PackedUFixed18 private immutable _targetUtilization;

    /**
     * @notice Initializes the contract state
     * @param initialUtilizationCurve Initial parameter set for the utilization curve
     */
    constructor(JumpRateUtilizationCurve memory initialUtilizationCurve) {
        _minRate = initialUtilizationCurve.minRate;
        _maxRate = initialUtilizationCurve.maxRate;
        _targetRate = initialUtilizationCurve.targetRate;
        _targetUtilization = initialUtilizationCurve.targetUtilization;
    }

    /**
     * @notice Returns the utilization curve parameter set
     * @return Current utilization curve parameter set
     */
    function utilizationCurve() public view returns (JumpRateUtilizationCurve memory) {
        return JumpRateUtilizationCurve({
            minRate: _minRate,
            maxRate: _maxRate,
            targetRate: _targetRate,
            targetUtilization: _targetUtilization
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
