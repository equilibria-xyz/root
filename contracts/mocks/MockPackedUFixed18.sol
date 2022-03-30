// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../number/types/PackedUFixed18.sol";

contract MockPackedUFixed18 {
    function MAX() external pure returns (PackedUFixed18) {
        return PackedUFixed18Lib.MAX;
    }

    function unpack(PackedUFixed18 a) external pure returns (UFixed18) {
        return PackedUFixed18Lib.unpack(a);
    }
}
