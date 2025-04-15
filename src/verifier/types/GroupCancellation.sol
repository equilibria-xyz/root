// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Common, CommonLib } from "./Common.sol";

struct GroupCancellation {
    /// @dev The group to cancel
    uint256 group;

    /// @dev The common information for EIP712 actions
    Common common;
}
using GroupCancellationLib for GroupCancellation global;

/// @title GroupCancellationLib
/// @notice Library used to hash and verify action to cancel a group nonce.
library GroupCancellationLib {
    bytes32 constant public STRUCT_HASH = keccak256(
        "GroupCancellation(uint256 group,Common common)"
        "Common(address account,address signer,address domain,uint256 nonce,uint256 group,uint256 expiry)"
    );

    function hash(GroupCancellation memory self) internal pure returns (bytes32) {
        return keccak256(abi.encode(STRUCT_HASH, self.group, CommonLib.hash(self.common)));
    }
}
