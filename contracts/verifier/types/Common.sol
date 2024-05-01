// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

/// @notice Fields which need to be hashed in any EIP712 action
struct Common {
    /// EOA signing the message
    address account;
    /// ensures the message is unique to a particular protocol version, chain, and verifier
    address domain;
    /// TODO: document
    uint256 nonce;
    /// TODO: document
    uint256 group;
    /// prevents this message from having the intended effect after a specified timestamp
    uint256 expiry;
}
using CommonLib for Common global;

/// @title CommonLib
/// @notice Library collecting fields which need to be hashed in any EIP712 message
library CommonLib {
    /// @dev used to verify a signed message
    bytes32 constant public STRUCT_HASH =
        keccak256("Common(address account,address domain,uint256 nonce,uint256 group,uint256 expiry)");

    /// @dev used to create a signed message
    function hash(Common memory self) internal pure returns (bytes32) {
        return keccak256(abi.encode(STRUCT_HASH, self.account, self.domain, self.nonce, self.group, self.expiry));
    }
}
