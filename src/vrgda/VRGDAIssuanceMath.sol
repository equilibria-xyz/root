// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.20;

import { UFixed18 } from "../number/types/UFixed18.sol";

library VRGDAIssuanceMath {
    /// @notice Returns the issuance of a VRGDA with linear issuance
    /// @dev issued = auction * emission
    ///      emission tokens will be issued per day of auctions
    /// @param emission The emission coefficient of the VRGDA
    /// @param auction The auction time relative to the start of the VRGDA
    /// @return issued The issued amount at the auction time
    function linearIssuance(UFixed18 emission, UFixed18 auction) internal pure returns (UFixed18) {
        return auction * emission;
    }

    /// @dev auction = issued / emission
    function linearIssuanceI(UFixed18 emission, UFixed18 issued) internal pure returns (UFixed18) {
        return issued / emission;
    }
}
