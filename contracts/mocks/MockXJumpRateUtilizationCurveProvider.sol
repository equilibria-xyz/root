// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/immutable/XJumpRateUtilizationCurveProvider.sol";

contract MockXJumpRateUtilizationCurveProvider is XJumpRateUtilizationCurveProvider {
    constructor(JumpRateUtilizationCurve memory initialUtilizationCurve)
    XJumpRateUtilizationCurveProvider(initialUtilizationCurve)
    { }

    function computeUtilizationCurve(UFixed18 utilization) external view returns (Fixed18) {
        return super._computeUtilizationCurve(utilization);
    }
}
