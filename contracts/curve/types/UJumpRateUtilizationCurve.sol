// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../CurveMath.sol";
import "../../number/types/PackedUFixed18.sol";
import "../../number/types/PackedFixed18.sol";

/// @dev UJumpRateUtilizationCurve type
struct UJumpRateUtilizationCurve {
    PackedUFixed18 minRate;
    PackedUFixed18 maxRate;
    PackedUFixed18 targetRate;
    PackedUFixed18 targetUtilization;
}
using UJumpRateUtilizationCurveLib for UJumpRateUtilizationCurve global;
type UJumpRateUtilizationCurveStorage is bytes32;
using UJumpRateUtilizationCurveStorageLib for UJumpRateUtilizationCurveStorage global;

/**
 * @title UJumpRateUtilizationCurveLib
 * @notice Library for the unsigned Jump Rate utilization curve type
 */
library UJumpRateUtilizationCurveLib {
    /**
     * @notice Computes the corresponding rate for a utilization ratio
     * @param utilization The utilization ratio
     * @return The corresponding rate
     */
    function compute(UJumpRateUtilizationCurve memory self, UFixed18 utilization) internal pure returns (UFixed18) {
        UFixed18 targetUtilization = self.targetUtilization.unpack();
        if (utilization.lt(targetUtilization)) {
            return CurveMath.linearInterpolation(
                UFixed18Lib.ZERO,
                self.minRate.unpack(),
                targetUtilization,
                self.targetRate.unpack(),
                utilization
            );
        }
        if (utilization.lt(UFixed18Lib.ONE)) {
            return CurveMath.linearInterpolation(
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
        UJumpRateUtilizationCurve memory self,
        UFixed18 utilization,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed18 notional
    ) internal pure returns (UFixed18) {
        return compute(self, utilization)
            .mul(UFixed18Lib.from(toTimestamp - fromTimestamp))
            .mul(notional)
            .div(UFixed18Lib.from(365 days));
    }
}

library UJumpRateUtilizationCurveStorageLib {
    function read(UJumpRateUtilizationCurveStorage self) internal view returns (UJumpRateUtilizationCurve memory) {
        return _storagePointer(self);
    }

    function store(UJumpRateUtilizationCurveStorage self, UJumpRateUtilizationCurve memory value) internal {
        UJumpRateUtilizationCurve storage storagePointer = _storagePointer(self);

        storagePointer.minRate = value.minRate;
        storagePointer.maxRate = value.maxRate;
        storagePointer.targetRate = value.targetRate;
        storagePointer.targetUtilization = value.targetUtilization;
    }

    function _storagePointer(UJumpRateUtilizationCurveStorage self)
    private pure returns (UJumpRateUtilizationCurve storage pointer) {
        assembly ("memory-safe") { pointer.slot := self }
    }
}
