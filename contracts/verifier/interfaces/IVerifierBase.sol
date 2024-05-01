// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Common } from "../types/Common.sol";
import { GroupCancellation } from "../types/GroupCancellation.sol";

// TODO: document
interface IVerifierBase {
    // sig: 0xfec563a0
    error VerifierInvalidSignerError();
    // sig: 0xb09262f6
    error VerifierInvalidDomainError();
    // sig: 0xb09262f6
    error VerifierInvalidSignatureError();
    // sig: 0xe6784f14
    error VerifierInvalidNonceError();
    // sig: 0x79998279
    error VerifierInvalidGroupError();
    // sig: 0x27661908
    error VerifierInvalidExpiryError();

    event NonceCancelled(address indexed account, uint256 nonce);
    event GroupCancelled(address indexed account, uint256 group);

    function verifyGroupCancellation(GroupCancellation calldata groupCancellation, bytes calldata signature) external returns (address);

    function cancelNonce(uint256 nonce) external;
    function cancelNonceWithSignature(Common calldata common, bytes calldata signature) external;
    function cancelGroup(uint256 group) external;
    function cancelGroupWithSignature(GroupCancellation calldata groupCancellation, bytes calldata signature) external;
}