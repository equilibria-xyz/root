// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../CurveMath18.sol";
import "../../number/types/PackedUFixed18.sol";
import "../../number/types/PackedFixed18.sol";

/// @dev JumpRateUtilizationCurve18 type
struct JumpRateUtilizationCurve18 {
    PackedFixed18 minRate;
    PackedFixed18 maxRate;
    PackedFixed18 targetRate;
    PackedUFixed18 targetUtilization;
}
using JumpRateUtilizationCurve18Lib for JumpRateUtilizationCurve18 global;
type JumpRateUtilizationCurve18Storage is bytes32;
using JumpRateUtilizationCurve18StorageLib for JumpRateUtilizationCurve18Storage global;

/**
 * @title JumpRateUtilizationCurve18Lib
 * @notice Library for the Jump Rate utilization curve type
 */
library JumpRateUtilizationCurve18Lib {
    /**
     * @notice Computes the corresponding rate for a utilization ratio
     * @param utilization The utilization ratio
     * @return The corresponding rate
     */
    function compute(JumpRateUtilizationCurve18 memory self, UFixed18 utilization) internal pure returns (Fixed18) {
        UFixed18 targetUtilization = self.targetUtilization.unpack();
        if (utilization.lt(targetUtilization)) {
            return CurveMath18.linearInterpolation(
                UFixed18Lib.ZERO,
                self.minRate.unpack(),
                targetUtilization,
                self.targetRate.unpack(),
                utilization
            );
        }
        if (utilization.lt(UFixed18Lib.ONE)) {
            return CurveMath18.linearInterpolation(
                targetUtilization,
                self.targetRate.unpack(),
                UFixed18Lib.ONE,
                self.maxRate.unpack(),
                utilization
            );
        }
        return self.maxRate.unpack();
    }

    function accumulate(
        JumpRateUtilizationCurve18 memory self,
        UFixed18 utilization,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed18 notional
    ) internal pure returns (Fixed18) {
        return compute(self, utilization)
            .mul(Fixed18Lib.from(int256(toTimestamp - fromTimestamp)))
            .mul(Fixed18Lib.from(notional))
            .div(Fixed18Lib.from(365 days));
    }
}

library JumpRateUtilizationCurve18StorageLib {
    function read(JumpRateUtilizationCurve18Storage self) internal view returns (JumpRateUtilizationCurve18 memory) {
        return _storagePointer(self);
    }

    function store(JumpRateUtilizationCurve18Storage self, JumpRateUtilizationCurve18 memory value) internal {
        JumpRateUtilizationCurve18 storage storagePointer = _storagePointer(self);

        storagePointer.minRate = value.minRate;
        storagePointer.maxRate = value.maxRate;
        storagePointer.targetRate = value.targetRate;
        storagePointer.targetUtilization = value.targetUtilization;
    }

    function _storagePointer(JumpRateUtilizationCurve18Storage self)
    private pure returns (JumpRateUtilizationCurve18 storage pointer) {
        assembly ("memory-safe") { pointer.slot := self }
    }
}
