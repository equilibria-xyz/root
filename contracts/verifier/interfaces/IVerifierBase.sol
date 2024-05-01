// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Common } from "../types/Common.sol";
import { GroupCancellation } from "../types/GroupCancellation.sol";

interface IVerifierBase {
    // sig: 0xfec563a0
    /// @custom:error Signer is trying to cancel a nonce for another user
    error VerifierInvalidSignerError();
    // sig: 0xb09262f6
    /// @custom:error Message was meant for another protocol, version, or chain
    error VerifierInvalidDomainError();
    // sig: 0xb09262f6
    /// @custom:error Signature length was unexpected
    error VerifierInvalidSignatureError();
    // sig: 0xe6784f14
    /// @custom:error Nonce has already been used
    error VerifierInvalidNonceError();
    // sig: 0x79998279
    /// @custom:error Group nonce has already been used
    error VerifierInvalidGroupError();
    // sig: 0x27661908
    /// @custom:error Block timestamp has exceeded user-assigned expiration
    error VerifierInvalidExpiryError();

    /// @notice Emitted when a nonce is cancelled
    event NonceCancelled(address indexed account, uint256 nonce);
    /// @notice Emitted when a group nonce is cancelled
    event GroupCancelled(address indexed account, uint256 group);

    /// @notice Verifies the signature of no-op common message
    /// @dev Cancels the nonce after verifying the signature
    /// @param common The common data of the message
    /// @param signature The signature of the account for the message
    /// @return The address corresponding to the signature
    function verifyCommon(Common calldata common, bytes calldata signature) external returns (address);

    /// @notice Verifies the signature of a group cancellation type
    /// @dev Cancels the nonce after verifying the signature
    /// @param groupCancellation The group cancellation to verify
    /// @param signature The signature of the account for the group cancellation
    /// @return The address corresponding to the signature    
    function verifyGroupCancellation(GroupCancellation calldata groupCancellation, bytes calldata signature) external returns (address);

    /// @notice Cancels a nonce
    /// @param nonce The nonce to cancel
    function cancelNonce(uint256 nonce) external;

    /// @notice Cancels a nonce for an account via a signed message
    /// @dev Process a no-op message that will invalidate the specified nonce
    /// @param common The common data of the message
    /// @param signature The signature of the account for the message
    function cancelNonceWithSignature(Common calldata common, bytes calldata signature) external;

    /// @notice Cancels a group nonce
    /// @param group The group nonce to cancel
    function cancelGroup(uint256 group) external;

    /// @notice Cancels a group for an account via a signed message
    /// @param groupCancellation The group cancellation message
    /// @param signature The signature of the account for the group cancellation
    function cancelGroupWithSignature(GroupCancellation calldata groupCancellation, bytes calldata signature) external;
}