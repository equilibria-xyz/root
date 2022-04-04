// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../UtilizationCurveProvider.sol";
import "../types/LinearUtilizationCurve.sol";
import "../../control/unstructured/UOwnable.sol";

/**
 * @title ULinearUtilizationCurveProvider
 * @notice Library for manage storing, surfacing, and upgrading a Linear utilization curve model.
 * @dev Uses an unstructured storage pattern to store the utilization curve parameters which allows this provider to
 *      be safely used with upgradeable contracts.
 */
abstract contract ULinearUtilizationCurveProvider is UtilizationCurveProvider, UInitializable, UOwnable {
    event LinearUtilizationCurveUpdated(Fixed18 minRate, Fixed18 maxRate);

    /// @dev Unstructured storage slot for the LinearUtilizationCurve struct
    LinearUtilizationCurveStorage private constant _utilizationCurve =
        LinearUtilizationCurveStorage.wrap(keccak256("equilibria.root.ULinearUtilizationCurveProvider.utilizationCurve"));
    function utilizationCurve() public view returns (LinearUtilizationCurve memory) { return _utilizationCurve.read(); }

    /**
     * @notice Initializes the contract state
     * @param initialUtilizationCurve Initial parameter set for the utilization curve
     */
    function __ULinearUtilizationCurveProvider__initialize(LinearUtilizationCurve memory initialUtilizationCurve)
    internal onlyInitializer {
        updateUtilizationCurve(initialUtilizationCurve);
    }

    /**
     * @notice Allows the contract owner to update the curve parameters
     * @param newUtilizationCurve New curve parameter set
     */
    function updateUtilizationCurve(LinearUtilizationCurve memory newUtilizationCurve) public onlyOwner {
        _utilizationCurve.store(newUtilizationCurve);
        emit LinearUtilizationCurveUpdated(newUtilizationCurve.minRate.unpack(), newUtilizationCurve.maxRate.unpack());
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
