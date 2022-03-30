// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../number/types/UFixed18.sol";
import "../number/types/Fixed18.sol";

/**
 * @title UtilizationCurveProvider
 * @notice Abstract contract defining the internal interface for utilization curve providers.
 */
abstract contract UtilizationCurveProvider {
    /**
     * @notice Returns the computed rate based on the supplied `utilization`
     * @param utilization Utilization ratio
     * @return Corresponding rate
     */
    function _computeUtilizationCurve(UFixed18 utilization) internal virtual view returns (Fixed18);
}
