// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

/// @notice Fields which need to be hashed in any EIP712 action
struct Common {
    /// @dev The target account of the message (usually the account on behalf of which the action is being performed)
    address account;
    /// @dev EOA signing the message (usually either the account or a delegate of the account)
    address signer;
    /// @dev ensures the message is unique to a particular protocol version, chain, and verifier
    address domain;
    /// @dev per-sender nonce which is automatically cancelled upon validation
    uint256 nonce;
    /// @dev per-sender nonce which must be manually cancelled with a GroupCancellation message
    uint256 group;
    /// @dev prevents this message from having the intended effect after a specified timestamp
    uint256 expiry;
}
using CommonLib for Common global;

/// @title CommonLib
/// @notice Library collecting fields which need to be hashed in any EIP712 message
library CommonLib {
    /// @dev used to verify a signed message
    bytes32 constant public STRUCT_HASH =
        keccak256("Common(address account,address signer,address domain,uint256 nonce,uint256 group,uint256 expiry)");

    /// @dev used to create a signed message
    function hash(Common memory self) internal pure returns (bytes32) {
        return keccak256(abi.encode(STRUCT_HASH, self.account, self.signer, self.domain, self.nonce, self.group, self.expiry));
    }
}
