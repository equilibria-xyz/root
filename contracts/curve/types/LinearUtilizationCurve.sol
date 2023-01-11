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
type LinearUtilizationCurveStorage is bytes32;
using LinearUtilizationCurveStorageLib for LinearUtilizationCurveStorage global;

/**
 * @title LinearUtilizationCurveLib
 * @notice Library for the Linear utilization curve type
 */
library LinearUtilizationCurveLib {
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

library LinearUtilizationCurveStorageLib {
    function read(LinearUtilizationCurveStorage self) internal view returns (LinearUtilizationCurve memory) {
        return _storagePointer(self);
    }

    function store(LinearUtilizationCurveStorage self, LinearUtilizationCurve memory value) internal {
        LinearUtilizationCurve storage storagePointer = _storagePointer(self);

        storagePointer.minRate = value.minRate;
        storagePointer.maxRate = value.maxRate;
    }

    function _storagePointer(LinearUtilizationCurveStorage self)
    private pure returns (LinearUtilizationCurve storage pointer) {
        assembly ("memory-safe") { pointer.slot := self }
    }
}
