// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.20;

import { UFixed18 } from "../../number/types/UFixed18.sol";
import { VRGDADecayMath } from "../VRGDADecayMath.sol";
import { VRGDAIssuanceMath } from "../VRGDAIssuanceMath.sol";

// TODO: change time to year for bounds?
struct LinearExponentialVRGDA {
    UFixed18 timestamp; // block timestamp of the start of the auction (seconds)
    UFixed18 price; // Price coefficient of the VRGDA per token (k)
    UFixed18 decay; // Decay coefficient of the VRGDA per day
    UFixed18 emission; // tokens per day
}
using LinearExponentialVRGDALib for LinearExponentialVRGDA global;

/// @title Linear Exponential Variable Rate Gradual Dutch Auctions
library LinearExponentialVRGDALib {
    /// @notice Returns the cost to purchase a specified amount of tokens
    /// @param self VRGDA parameters
    /// @param issued Number of tokens currently issued by the auction
    /// @param amount The amount of tokens to purchase
    /// @return Cost of the purchase
    function toCost(LinearExponentialVRGDA memory self, UFixed18 issued, UFixed18 amount) internal view returns (UFixed18) {
        return VRGDADecayMath.exponentialDecay(
            self.timestamp,
            self.price,
            self.decay,
            VRGDAIssuanceMath.linearIssuanceI(self.emission, issued),
            VRGDAIssuanceMath.linearIssuanceI(self.emission, issued + amount)
        );
    }

    /// @notice Returns the amount of tokens that can be purchased for a specified cost
    /// @param self VRGDA parameters
    /// @param issued Number of tokens currently issued by the auction
    /// @param cost Funds to spend on the purchase
    /// @return Amount of tokens that can be purchased
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
        ) - issued;
    }
}
