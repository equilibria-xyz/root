// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.20;

import { Fixed18, Fixed18Lib } from "../number/types/Fixed18.sol";
import { UFixed18, UFixed18Lib } from "../number/types/UFixed18.sol";

library VRGDADecayMath {
    /// @dev current block.timestamp in days
    function time() internal view returns (UFixed18) {
        return UFixed18Lib.ratio(block.timestamp, 1 days);
    }

    /// @notice Returns the cost of a purchase over a continuous VRGDA with exponential decay
    /// @param timestamp The timestamp of the start of the VRGDA
    /// @param price The price coefficient of the VRGDA
    /// @param decay The decay coefficient of the VRGDA
    /// @param from The time of the latest auction relative to the start of the VRGDA
    /// @param to The time of the latest auction after the purchase relative to the start of the VRGDA
    /// @return cost The cost of the purchase
    function exponentialDecay(UFixed18 timestamp, UFixed18 price, UFixed18 decay, UFixed18 from, UFixed18 to) internal view returns (UFixed18 cost) {
        (Fixed18 a, Fixed18 b) = (convert(timestamp + to), convert(timestamp + from));

        Fixed18 sDecay = Fixed18Lib.from(decay);

        return price * UFixed18Lib.from((-sDecay * a).exp() - (-sDecay * b).exp()) / decay;
    }

    /// @notice Returns time of the latest auction after the purchase over a continuous VRGDA with exponential decay
    /// @param price The price coefficient of the VRGDA
    /// @param decay The decay coefficient of the VRGDA
    /// @param from The time of the latest auction relative to the start of the VRGDA
    /// @param cost The cost of the purchase
    /// @return to The time of the latest auction after the purchase relative to the start of the VRGDA
    function exponentialDecayI(UFixed18 timestamp, UFixed18 price, UFixed18 decay, UFixed18 from, UFixed18 cost) internal view returns (UFixed18 to) {
        Fixed18 b = convert(timestamp + from);

        (Fixed18 sDecay, Fixed18 sPrice, Fixed18 sCost) = (Fixed18Lib.from(decay), Fixed18Lib.from(price), Fixed18Lib.from(cost));

        // increase precision by inverting the input to exp() if b is negative
        Fixed18 exp = b >= Fixed18Lib.ZERO ? sPrice / (sDecay * b).exp() : sPrice * (-sDecay * b).exp();

        Fixed18 a = ln(sPrice, (sCost * sDecay + exp)) / sDecay;

        return convert(a) - timestamp;
    }

    /// @dev Converts from an auction time to a time since auction
    function convert(UFixed18 auctionTime) internal view returns (Fixed18) {
        return Fixed18Lib.from(time()) - Fixed18Lib.from(auctionTime);
    }

    /// @dev Converts from a time since auction to an auction time
    function convert(Fixed18 timeSince) internal view returns (UFixed18) {
        return UFixed18Lib.from(Fixed18Lib.from(time()) - timeSince);
    }

    /// @notice Increased-precision natural logarithm
    /// @dev Inverses the input of the natural logarithm if the input is less than 1 to increase precision
    /// @param num The numerator of the input
    /// @param den The denominator of the input
    /// @return The natural logarithm of num / den
    function ln(Fixed18 num, Fixed18 den) internal pure returns (Fixed18) {
        return num >= den ? (num / den).ln() : -(den / num).ln();
    }
}