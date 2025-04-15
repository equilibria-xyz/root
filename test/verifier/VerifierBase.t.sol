// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

import { IVerifierBase, VerifierBase } from "../../src/verifier/VerifierBase.sol";
import { Common, CommonLib } from "../../src/verifier/types/Common.sol";
import { GroupCancellation, GroupCancellationLib } from "../../src/verifier/types/GroupCancellation.sol";
import { signCommon, signGroupCancellation } from "../testutil/erc712Helpers.sol";

contract VerifierBaseTest is Test {
    VerifierBaseTester public verifier;
    address public account;
    uint256 public accountKey;
    address public signer;
    uint256 public signerKey;
    address public invalidSigner;
    uint256 public invalidSignerKey;

    Common public DEFAULT_COMMON;
    GroupCancellation public DEFAULT_GROUP_CANCELLATION;

    function setUp() public {
        verifier = new VerifierBaseTester();
        (account, accountKey) = makeAddrAndKey("account");
        (signer, signerKey) = makeAddrAndKey("signer");
        (invalidSigner, invalidSignerKey) = makeAddrAndKey("invalidSigner");
        DEFAULT_COMMON = Common({ account: account, signer: account, domain: address(this), nonce: 0, group: 0, expiry: block.timestamp + 10 });
        DEFAULT_GROUP_CANCELLATION = GroupCancellation({ group: 0, common: DEFAULT_COMMON});
    }

    // verifyCommon

    function test_verifyCommon() public {
        bytes memory signature = signCommon(address(verifier), DEFAULT_COMMON, accountKey);
        verifier.verifyCommon(DEFAULT_COMMON, signature);
    }

    function test_verifyCommonWithSigner() public {
        // update signer for account
        verifier.updateSigner(account, signer);
        DEFAULT_COMMON.signer = signer;

        bytes memory signature = signCommon(address(verifier), DEFAULT_COMMON, signerKey);
        verifier.verifyCommon(DEFAULT_COMMON, signature);
    }

    function test_verifyCommonFailsInvalidSigner() public {
        DEFAULT_COMMON.signer = invalidSigner;

        bytes memory signature = signCommon(address(verifier), DEFAULT_COMMON, invalidSignerKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidSignerError.selector);
        verifier.verifyCommon(DEFAULT_COMMON, signature);

        // should also revert with zero address
        DEFAULT_COMMON.signer = address(0);

        signature = signCommon(address(verifier), DEFAULT_COMMON, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidSignerError.selector);
        verifier.verifyCommon(DEFAULT_COMMON, signature);
    }

    function test_verifyCommonFailsInvalidDomain() public {
        address invalidDomain = makeAddr("invalidDomain");
        DEFAULT_COMMON.domain = invalidDomain;

        bytes memory signature = signCommon(address(verifier), DEFAULT_COMMON, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidDomainError.selector);
        verifier.verifyCommon(DEFAULT_COMMON, signature);

        // should also revert with zero address
        DEFAULT_COMMON.domain = address(0);

        signature = signCommon(address(verifier), DEFAULT_COMMON, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidDomainError.selector);
        verifier.verifyCommon(DEFAULT_COMMON, signature);
    }

    function test_verifyCommonFailsInvalidNonce() public {
        bytes memory signature = signCommon(address(verifier), DEFAULT_COMMON, accountKey);
        verifier.verifyCommon(DEFAULT_COMMON, signature);

        // should fail with same nonce
        signature = signCommon(address(verifier), DEFAULT_COMMON, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidNonceError.selector);
        verifier.verifyCommon(DEFAULT_COMMON, signature);
    }

    function test_verifyCommonFailsExpired() public {
        DEFAULT_COMMON.expiry = block.timestamp - 1;

        bytes memory signature = signCommon(address(verifier), DEFAULT_COMMON, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidExpiryError.selector);
        verifier.verifyCommon(DEFAULT_COMMON, signature);

        // should also revert with zero expiry
        DEFAULT_COMMON.expiry = 0;

        signature = signCommon(address(verifier), DEFAULT_COMMON, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidExpiryError.selector);
        verifier.verifyCommon(DEFAULT_COMMON, signature);
    }

    function test_verifyCommonFailsInvalidSignature() public {
        // signature too small
        bytes memory signature = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        vm.expectRevert(IVerifierBase.VerifierInvalidSignatureError.selector);
        verifier.verifyCommon(DEFAULT_COMMON, signature);

        // signature too large
        signature = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123';
        vm.expectRevert(IVerifierBase.VerifierInvalidSignatureError.selector);
        verifier.verifyCommon(DEFAULT_COMMON, signature);
    }

    function test_verifyCommonFailsInvalidGroup() public {
        vm.prank(account);
        verifier.cancelGroup(DEFAULT_COMMON.group);

        bytes memory signature = signCommon(address(verifier), DEFAULT_COMMON, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidGroupError.selector);
        verifier.verifyCommon(DEFAULT_COMMON, signature);
    }

    // verifyGroupCancellation

    function test_verifyGroupCancellation() public {
        bytes memory signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, accountKey);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);
    }

    function test_verifyGroupCancellationWithSigner() public {
        // update signer for account
        verifier.updateSigner(account, signer);
        DEFAULT_GROUP_CANCELLATION.common.signer = signer;

        bytes memory signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, signerKey);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);
    }

    function test_verifyGroupCancellationFailsInvalidSigner() public {
        DEFAULT_GROUP_CANCELLATION.common.signer = invalidSigner;

        bytes memory signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, invalidSignerKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidSignerError.selector);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);

        // should also revert with zero address
        DEFAULT_GROUP_CANCELLATION.common.signer = address(0);

        signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidSignerError.selector);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);
    }

    function test_verifyGroupCancellationFailsInvalidDomain() public {
        address invalidDomain = makeAddr("invalidDomain");
        DEFAULT_GROUP_CANCELLATION.common.domain = invalidDomain;

        bytes memory signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidDomainError.selector);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);

        // should also revert with zero address
        DEFAULT_GROUP_CANCELLATION.common.domain = address(0);

        signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidDomainError.selector);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);
    }

    function test_verifyGroupCancellationFailsInvalidNonce() public {
        bytes memory signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, accountKey);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);

        // should fail with same nonce
        signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidNonceError.selector);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);
    }

    function test_verifyGroupCancellationFailsExpired() public {
        DEFAULT_GROUP_CANCELLATION.common.expiry = block.timestamp - 1;

        bytes memory signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidExpiryError.selector);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);

        // should also revert with zero expiry
        DEFAULT_GROUP_CANCELLATION.common.expiry = 0;

        signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidExpiryError.selector);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);
    }

    function test_verifyGroupCancellationFailsInvalidSignature() public {
        // signature too small
        bytes memory signature = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
        vm.expectRevert(IVerifierBase.VerifierInvalidSignatureError.selector);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);

        // signature too large
        signature = '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123';
        vm.expectRevert(IVerifierBase.VerifierInvalidSignatureError.selector);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);
    }

    function test_verifyGroupCancellationFailsInvalidGroup() public {
        vm.prank(account);
        verifier.cancelGroup(DEFAULT_GROUP_CANCELLATION.common.group);

        bytes memory signature = signCommon(address(verifier), DEFAULT_COMMON, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidGroupError.selector);
        verifier.verifyGroupCancellation(DEFAULT_GROUP_CANCELLATION, signature);
    }

    // cancelNonce

    function test_cancelNonce() public {
        vm.prank(account);
        verifier.cancelNonce(DEFAULT_COMMON.nonce);

        assertEq(verifier.nonces(account, DEFAULT_COMMON.nonce), true);
    }

    // cancelNonceWithSignature

    function test_cancelNonceWithSignature() public {
        DEFAULT_COMMON.domain = address(verifier);
        bytes memory signature = signCommon(address(verifier), DEFAULT_COMMON, accountKey);
        verifier.cancelNonceWithSignature(DEFAULT_COMMON, signature);

        assertEq(verifier.nonces(account, 0), true);
    }

    function test_cancelNonceWithSignatureFailsInvalidSigner() public {
        DEFAULT_COMMON.domain = address(verifier);
        DEFAULT_COMMON.signer = invalidSigner;

        bytes memory signature = signCommon(address(verifier), DEFAULT_COMMON, invalidSignerKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidSignerError.selector);
        verifier.cancelNonceWithSignature(DEFAULT_COMMON, signature);

        assertEq(verifier.nonces(account, 0), false);
    }

    function test_cancelNonceWithSignatureFailsInvalidDomain() public {
        bytes memory signature = signCommon(address(verifier), DEFAULT_COMMON, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidDomainError.selector);
        verifier.cancelNonceWithSignature(DEFAULT_COMMON, signature);

        assertEq(verifier.nonces(account, 0), false);
    }

    // cancelGroup

    function test_cancelGroup() public {
        vm.prank(account);
        verifier.cancelGroup(1);

        assertEq(verifier.groups(account, 1), true);
    }

    // cancelGroupWithSignature

    function test_cancelGroupWithSignature() public {
        DEFAULT_GROUP_CANCELLATION.common.domain = address(verifier);
        bytes memory signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, accountKey);
        verifier.cancelGroupWithSignature(DEFAULT_GROUP_CANCELLATION, signature);

        assertEq(verifier.groups(account, 0), true);
    }

    function test_cancelGroupWithSignatureFailsInvalidSigner() public {
        DEFAULT_GROUP_CANCELLATION.common.domain = address(verifier);
        DEFAULT_GROUP_CANCELLATION.common.signer = invalidSigner;
        bytes memory signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, invalidSignerKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidSignerError.selector);
        verifier.cancelGroupWithSignature(DEFAULT_GROUP_CANCELLATION, signature);

        assertEq(verifier.groups(account, 0), false);
    }

    function test_cancelGroupWithSignatureFailsInvalidDomain() public {
        bytes memory signature = signGroupCancellation(address(verifier), DEFAULT_GROUP_CANCELLATION, accountKey);
        vm.expectRevert(IVerifierBase.VerifierInvalidDomainError.selector);
        verifier.cancelGroupWithSignature(DEFAULT_GROUP_CANCELLATION, signature);

        assertEq(verifier.groups(account, 0), false);
    }
}

/// @dev Empty implementation for the sole purpose of testing base class
contract VerifierBaseTester is VerifierBase {
    mapping(address => address) public signers;

    constructor() EIP712("Equilibria Root Unit Tests", "1.0.0") { }

    function updateSigner(address account, address signer) public {
        signers[account] = signer;
    }

    function _authorized(address account, address signer) internal view override returns (bool) {
        return super._authorized(account, signer) || signers[account] == signer;
    }
}
