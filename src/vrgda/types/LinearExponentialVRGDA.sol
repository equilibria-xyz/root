// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.20;

import { UFixed18 } from "../../number/types/UFixed18.sol";
import { VRGDADecayMath } from "../VRGDADecayMath.sol";
import { VRGDAIssuanceMath } from "../VRGDAIssuanceMath.sol";

// TODO: change time to year for bounds?
struct LinearExponentialVRGDA {
    UFixed18 timestamp; // in seconds
    UFixed18 price; // per token
    UFixed18 decay; // per day
    UFixed18 emission; // per day
}
using LinearExponentialVRGDALib for LinearExponentialVRGDA global;

library LinearExponentialVRGDALib {
    function toCost(LinearExponentialVRGDA memory self, UFixed18 issued, UFixed18 amount) internal view returns (UFixed18) {
        return VRGDADecayMath.exponentialDecay(
            self.timestamp,
            self.price,
            self.decay,
            VRGDAIssuanceMath.linearIssuanceI(self.emission, issued),
            VRGDAIssuanceMath.linearIssuanceI(self.emission, issued + amount)
        );
    }

    function toAmount(LinearExponentialVRGDA memory self, UFixed18 issued, UFixed18 cost) internal view returns (UFixed18) {
        return VRGDAIssuanceMath.linearIssuance(
            self.emission,
            VRGDADecayMath.exponentialDecayI(
                self.timestamp,
                self.price,
                self.decay,
                VRGDAIssuanceMath.linearIssuanceI(self.emission, issued),
                cost
            )
        );
    }
}