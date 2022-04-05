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
    JumpRateUtilizationCurveStorage private constant _utilizationCurve =
        JumpRateUtilizationCurveStorage.wrap(keccak256("equilibria.root.UJumpRateUtilizationCurveProvider.utilizationCurve"));
    function utilizationCurve() public view returns (JumpRateUtilizationCurve memory) {return _utilizationCurve.read(); }

    /**
     * @notice Initializes the contract state
     * @param initialUtilizationCurve Initial parameter set for the utilization curve
     */
    function __UJumpRateUtilizationCurveProvider__initialize(JumpRateUtilizationCurve memory initialUtilizationCurve)
    internal onlyInitializer {
        updateUtilizationCurve(initialUtilizationCurve);
    }

    /**
     * @notice Allows the contract owner to update the curve parameters
     * @param newUtilizationCurve New curve parameter set
     */
    function updateUtilizationCurve(JumpRateUtilizationCurve memory newUtilizationCurve) public onlyOwner {
        _utilizationCurve.store(newUtilizationCurve);

        emit JumpRateUtilizationCurveUpdated(
            newUtilizationCurve.minRate.unpack(),
            newUtilizationCurve.maxRate.unpack(),
            newUtilizationCurve.targetRate.unpack(),
            newUtilizationCurve.targetUtilization.unpack()
        );
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
