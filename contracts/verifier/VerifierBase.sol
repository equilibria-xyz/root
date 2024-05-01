// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { Common, CommonLib } from "./types/Common.sol";
import { GroupCancellation, GroupCancellationLib } from "./types/GroupCancellation.sol";
import "./interfaces/IVerifierBase.sol";

abstract contract VerifierBase is IVerifierBase, EIP712 {
    // TODO: migrate logic from perenial-verifier package

    /// @dev mapping of nonces per account and their cancelled state
    mapping(address => mapping(uint256 => bool)) public nonces;

    /// @dev mapping of group nonces per account and their cancelled state
    mapping(address => mapping(uint256 => bool)) public groups;

    /// @notice Verifies the signature of no-op common message
    /// @dev Cancels the nonce after verifying the signature
    /// @param common The common data of the message
    /// @param signature The signature of the account for the message
    /// @return The address corresponding to the signature
    function verifyCommon(Common calldata common, bytes calldata signature)
        external
        validateAndCancel(common, signature) returns (address)
    {
        return ECDSA.recover(_hashTypedDataV4(CommonLib.hash(common)), signature);
    }

    /// @notice Verifies the signature of a group cancellation type
    /// @dev Cancels the nonce after verifying the signature
    /// @param groupCancellation The group cancellation to verify
    /// @param signature The signature of the account for the group cancellation
    /// @return The address corresponding to the signature
    function verifyGroupCancellation(GroupCancellation calldata groupCancellation, bytes calldata signature)
        external
        validateAndCancel(groupCancellation.common, signature) returns (address)
    {
        return ECDSA.recover(_hashTypedDataV4(GroupCancellationLib.hash(groupCancellation)), signature);
    }
 
    /// @notice Cancels a nonce
    /// @param nonce The nonce to cancel
    function cancelNonce(uint256 nonce) external {
        _cancelNonce(msg.sender, nonce);
    }

    /// @notice Cancels a group nonce
    /// @param group The group nonce to cancel
    function cancelGroup(uint256 group) external {
        _cancelGroup(msg.sender, group);
    }   
    /// @notice Cancels a nonce for an account via a signed message
    /// @dev Process a no-op message that will invalidate the specified nonce
    /// @param common The common data of the message
    /// @param signature The signature of the account for the message
    function cancelNonceWithSignature(Common calldata common, bytes calldata signature) external {
        address signer = IVerifierBase(this).verifyCommon(common, signature);
        if (signer != common.account) revert VerifierInvalidSignerError();
    }

    /// @notice Cancels a group for an account via a signed message
    /// @param groupCancellation The group cancellation message
    /// @param signature The signature of the account for the group cancellation
    function cancelGroupWithSignature(GroupCancellation calldata groupCancellation, bytes calldata signature) external {
        address signer = IVerifierBase(this).verifyGroupCancellation(groupCancellation, signature);
        if (signer != groupCancellation.common.account) revert VerifierInvalidSignerError();

        _cancelGroup(groupCancellation.common.account, groupCancellation.group);
    }

    /// @notice Cancels a nonce
    /// @param account The account to cancel the nonce for
    /// @param nonce The nonce to cancel
    function _cancelNonce(address account, uint256 nonce) private {
        nonces[account][nonce] = true;
        emit NonceCancelled(account, nonce);
    }

    /// @notice Cancels a group nonce
    /// @param account The account to cancel the group nonce for
    /// @param group The group nonce to cancel
    function _cancelGroup(address account, uint256 group) private {
        groups[account][group] = true;
        emit GroupCancelled(account, group);
    }

    /// @dev Validates the common data of a message
    modifier validateAndCancel(Common calldata common, bytes calldata signature) {
        if (common.domain != msg.sender) revert VerifierInvalidDomainError();
        if (signature.length != 65) revert VerifierInvalidSignatureError();
        if (nonces[common.account][common.nonce]) revert VerifierInvalidNonceError();
        if (groups[common.account][common.group]) revert VerifierInvalidGroupError();
        if (block.timestamp >= common.expiry) revert VerifierInvalidExpiryError();

        _cancelNonce(common.account, common.nonce);

        _;
    }
}