// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../UtilizationCurveProvider.sol";
import "../types/JumpRateUtilizationCurve.sol";
import "../../control/unstructured/UOwnable.sol";

/**
 * @title UJumpRateUtilizationCurveProvider
 * @notice Library for manage storing, surfacing, and upgrading a Jump Rate utilization curve model.
 * @dev Uses an unstructured storage pattern to store the utilization curve parameters which allows this provider to
 *      be safely used with upgradeable contracts.
 */
abstract contract UJumpRateUtilizationCurveProvider is UtilizationCurveProvider, UInitializable, UOwnable {
    event JumpRateUtilizationCurveUpdated(
        Fixed18 minRate,
        Fixed18 maxRate,
        Fixed18 targetRate,
        UFixed18 targetUtilization
    );

    /// @dev Unstructured storage slot for the JumpRateUtilizationCurve struct
    bytes32 private constant UTILIZATION_CURVE_SLOT =
        keccak256("equilibria.root.UJumpRateUtilizationCurveProvider.utilizationCurve");

    /**
     * @notice Initializes the contract state
     * @param initialUtilizationCurve Initial parameter set for the utilization curve
     */
    function __UJumpRateUtilizationCurveProvider__initialize(JumpRateUtilizationCurve memory initialUtilizationCurve)
    internal onlyInitializer {
        _updateUtilizationCurve(initialUtilizationCurve);
    }

    /**
     * @notice Allows the contract owner to update the curve parameters
     * @param newUtilizationCurve New curve parameter set
     */
    function updateUtilizationCurve(JumpRateUtilizationCurve memory newUtilizationCurve) external onlyOwner {
        _updateUtilizationCurve(newUtilizationCurve);
    }

    /**
     * @notice Returns the utilization curve parameter set
     * @return Current utilization curve parameter set
     */
    function utilizationCurve() external view returns (JumpRateUtilizationCurve memory) {
        return _storedUtilizationCurve();
    }

    /**
     * @notice Returns the computed rate based on the supplied `utilization`
     * @param utilization Utilization ratio
     * @return Corresponding rate
     */
    function _computeRate(UFixed18 utilization) internal override view returns (Fixed18) {
        return _storedUtilizationCurve().compute(utilization);
    }

    /**
     * @notice Returns the internal storage pointer for the curve parameter struct
     * @return storedUtilizationCurve Storage pointer for the curve parameter struct
     */
    function _storedUtilizationCurve() private pure returns (JumpRateUtilizationCurve storage storedUtilizationCurve) {
        bytes32 slot = UTILIZATION_CURVE_SLOT;
        assembly { storedUtilizationCurve.slot := slot }
    }

    /**
     * @notice Updates the curve parameters to `newUtilizationCurve` in storage
     * @param newUtilizationCurve New curve parameter set
     */
    function _updateUtilizationCurve(JumpRateUtilizationCurve memory newUtilizationCurve) private {
        JumpRateUtilizationCurve storage storedUtilizationCurve = _storedUtilizationCurve();

        storedUtilizationCurve.minRate = newUtilizationCurve.minRate;
        storedUtilizationCurve.maxRate = newUtilizationCurve.maxRate;
        storedUtilizationCurve.targetRate = newUtilizationCurve.targetRate;
        storedUtilizationCurve.targetUtilization = newUtilizationCurve.targetUtilization;

        emit JumpRateUtilizationCurveUpdated(
            newUtilizationCurve.minRate.unpack(),
            newUtilizationCurve.maxRate.unpack(),
            newUtilizationCurve.targetRate.unpack(),
            newUtilizationCurve.targetUtilization.unpack()
        );
    }
}
