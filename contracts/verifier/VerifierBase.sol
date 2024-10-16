// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { Common, CommonLib } from "./types/Common.sol";
import { GroupCancellation, GroupCancellationLib } from "./types/GroupCancellation.sol";
import { IVerifierBase } from "./interfaces/IVerifierBase.sol";

abstract contract VerifierBase is IVerifierBase, EIP712 {
    /// @inheritdoc IVerifierBase
    mapping(address => mapping(uint256 => bool)) public nonces;

    /// @inheritdoc IVerifierBase
    mapping(address => mapping(uint256 => bool)) public groups;

    /// @inheritdoc IVerifierBase
    function verifyCommon(Common calldata common, bytes calldata signature)
        external
        validateAndCancel(common, signature)
    {
        if (!SignatureChecker.isValidSignatureNow(common.signer, _hashTypedDataV4(CommonLib.hash(common)), signature))
            revert VerifierInvalidSignerError();
    }

    /// @inheritdoc IVerifierBase
    function verifyGroupCancellation(GroupCancellation calldata groupCancellation, bytes calldata signature)
        external
        validateAndCancel(groupCancellation.common, signature)
    {
        if (!SignatureChecker.isValidSignatureNow(
            groupCancellation.common.signer,
            _hashTypedDataV4(GroupCancellationLib.hash(groupCancellation)),
            signature
        )) revert VerifierInvalidSignerError();
    }

    /// @inheritdoc IVerifierBase
    function cancelNonce(uint256 nonce) external {
        _cancelNonce(msg.sender, nonce);
    }

    /// @inheritdoc IVerifierBase
    function cancelGroup(uint256 group) external {
        _cancelGroup(msg.sender, group);
    }

    /// @inheritdoc IVerifierBase
    function cancelNonceWithSignature(Common calldata common, bytes calldata signature) external {
        IVerifierBase(this).verifyCommon(common, signature); // cancels nonce
    }

    /// @inheritdoc IVerifierBase
    function cancelGroupWithSignature(GroupCancellation calldata groupCancellation, bytes calldata signature) external {
        IVerifierBase(this).verifyGroupCancellation(groupCancellation, signature);
        _cancelGroup(groupCancellation.common.account, groupCancellation.group);
    }

    /// @notice Checks account authorization
    /// @param account the account to check authorization for
    /// @param signer the signer of the account
    /// @return whether the signer is authorized
    function _authorized(address account, address signer) internal view virtual returns (bool) {
        return account == signer;
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
        if (!_authorized(common.account, common.signer)) revert VerifierInvalidSignerError();
        if (common.domain != msg.sender) revert VerifierInvalidDomainError();
        if (signature.length != 65) revert VerifierInvalidSignatureError();
        if (nonces[common.account][common.nonce]) revert VerifierInvalidNonceError();
        if (groups[common.account][common.group]) revert VerifierInvalidGroupError();
        if (block.timestamp >= common.expiry) revert VerifierInvalidExpiryError();

        _cancelNonce(common.account, common.nonce);

        _;
    }
}
