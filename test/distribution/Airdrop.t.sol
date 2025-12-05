// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

import { IAirdrop, Airdrop } from "../../src/distribution/Airdrop.sol";
import { UFixed18 } from "../../src/number/types/UFixed18.sol";
import { IOwnable } from "../../src/attribute/interfaces/IOwnable.sol";
import { Token18 } from "../../src/token/types/Token18.sol";

import { MerkleProof1, MerkleProof2 } from "../testutil/MerkleProofs.sol";
import { ERC20Mintable } from "../testutil/ERC20Mintable.sol";
import { RootTest } from "../RootTest.sol";

contract AirdropTest is RootTest {
    Airdrop public airdrop;
    Token18 public airdropToken;
    MerkleProof1 public merkleProof1;
    MerkleProof2 public merkleProof2;
    address public owner = makeAddr("OWNER");
    address public nonOwner = makeAddr("NON_OWNER");

    function setUp() public {
        airdropToken = Token18.wrap(address(new ERC20Mintable("Test Token", "TEST")));
        merkleProof1 = new MerkleProof1();
        merkleProof2 = new MerkleProof2();
        vm.prank(owner);
        airdrop = new Airdrop();
        ERC20Mintable(Token18.unwrap(airdropToken)).mint(address(airdrop), 1_000_000_000 * 1e18);
    }

    function test_addDistribution() public {
        Token18 token = airdropToken;
        bytes32 merkleRoot = bytes32(uint256(1));

        // Non-owner tries to add a distribution
        vm.prank(owner);
        airdrop.addDistributions(token, merkleRoot);

        assertEq(Token18.unwrap(airdrop.distributions(merkleRoot)), Token18.unwrap(token));

        vm.prank(owner);
        vm.expectRevert(IAirdrop.AirdropDistributionAlreadyExists.selector);
        airdrop.addDistributions(token, merkleRoot);
    }

    function test_removeRoot() public {
        Token18 token = airdropToken;
        bytes32 merkleRoot = bytes32(uint256(1));
        vm.prank(owner);
        airdrop.addDistributions(token, merkleRoot);

        assertEq(Token18.unwrap(airdrop.distributions(merkleRoot)), Token18.unwrap(token));

        // Owner tries to remove a non-existent root
        vm.prank(owner);
        vm.expectRevert(IAirdrop.AirdropRootDoesNotExist.selector);
        airdrop.removeDistribution(bytes32(uint256(2)));

        // Non-owner tries to remove a root
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, nonOwner));
        airdrop.removeDistribution(merkleRoot);

        // Owner removes a distribution
        vm.prank(owner);
        airdrop.removeDistribution(merkleRoot);

        // Check that the distribution is removed
        assertEq(Token18.unwrap(airdrop.distributions(merkleRoot)), address(0));
    }

    function test_merkleRoots() public {
        bytes32 merkleRoot1 = merkleProof1.airdropRoot();
        bytes32 merkleRoot2 = merkleProof2.airdropRoot();
        vm.prank(owner);
        airdrop.addDistributions(airdropToken, merkleRoot1);
        vm.prank(owner);
        airdrop.addDistributions(airdropToken, merkleRoot2);

        bytes32[] memory merkleRoots = airdrop.merkleRoots();
        assertEq(merkleRoots.length, 2);
        assertEq(merkleRoots[0], merkleRoot1);
        assertEq(merkleRoots[1], merkleRoot2);
    }

    function test_claim() public {
        Token18 token = airdropToken;
        bytes32 merkleRoot = merkleProof1.airdropRoot();
        vm.prank(owner);
        airdrop.addDistributions(token, merkleRoot);

        // Claim airdrop for each leaf
        for (uint256 i = 0; i < merkleProof1.totalUsers(); i++) {
            uint256 index = vm.parseUint(merkleProof1.airdropLeafs(i, 0));
            address user = vm.parseAddress(merkleProof1.airdropLeafs(i, 1));
            uint256 amount = vm.parseUint(merkleProof1.airdropLeafs(i, 2));

            bytes32[][] memory proofs = new bytes32[][](1);
            proofs[0] = new bytes32[](3);
            proofs[0][0] = bytes32(merkleProof1.airdropUserProofs(i, 0));
            proofs[0][1] = bytes32(merkleProof1.airdropUserProofs(i, 1));
            proofs[0][2] = bytes32(merkleProof1.airdropUserProofs(i, 2));

            vm.prank(user);
            UFixed18 userBalanceBefore = airdropToken.balanceOf(user);
            UFixed18 airdropTokenBalanceBefore = airdropToken.balanceOf(address(airdrop));
            uint256[] memory indexes = new uint256[](1);
            indexes[0] = index;
            UFixed18[] memory amounts = new UFixed18[](1);
            amounts[0] = UFixed18.wrap(amount);
            bytes32[] memory merkleRoots = new bytes32[](1);
            merkleRoots[0] = merkleProof1.airdropRoot();
            assertFalse(airdrop.claimed(index, merkleRoots[0]));
            airdrop.claim(user, indexes, amounts, proofs, merkleRoots);

            assertUFixed18Eq(airdropToken.balanceOf(user), userBalanceBefore + amounts[0]);
            assertUFixed18Eq(airdropToken.balanceOf(address(airdrop)), airdropTokenBalanceBefore - amounts[0]);
            assertTrue(airdrop.claimed(index, merkleRoots[0]));
        }
    }

    function test_claimMultiple() public {
        Token18 token1 = airdropToken;
        bytes32 merkleRoot1 = merkleProof1.airdropRoot();
        vm.prank(owner);
        airdrop.addDistributions(token1, merkleRoot1);

        Token18 token2 = airdropToken;
        bytes32 merkleRoot2 = merkleProof2.airdropRoot();
        vm.prank(owner);
        airdrop.addDistributions(token2, merkleRoot2);

        // Claim airdrop for each account in first distribution
        for (uint256 i = 0; i < merkleProof1.totalUsers(); i++) {
            uint256 index = vm.parseUint(merkleProof1.airdropLeafs(i, 0));
            address user = vm.parseAddress(merkleProof1.airdropLeafs(i, 1));
            uint256 amount = vm.parseUint(merkleProof1.airdropLeafs(i, 2));

            bytes32[][] memory proofs = new bytes32[][](1);
            proofs[0] = new bytes32[](3);
            proofs[0][0] = bytes32(merkleProof1.airdropUserProofs(i, 0));
            proofs[0][1] = bytes32(merkleProof1.airdropUserProofs(i, 1));
            proofs[0][2] = bytes32(merkleProof1.airdropUserProofs(i, 2));

            vm.prank(user);
            UFixed18 userBalanceBefore = airdropToken.balanceOf(user);
            UFixed18 airdropTokenBalanceBefore = airdropToken.balanceOf(address(airdrop));
            uint256[] memory indexes = new uint256[](1);
            indexes[0] = index;
            UFixed18[] memory amounts = new UFixed18[](1);
            amounts[0] = UFixed18.wrap(amount);
            bytes32[] memory merkleRoot = new bytes32[](1);
            merkleRoot[0] = merkleProof1.airdropRoot();
            assertFalse(airdrop.claimed(index, merkleRoot[0]));
            airdrop.claim(user, indexes, amounts, proofs, merkleRoot);

            assertUFixed18Eq(airdropToken.balanceOf(user), userBalanceBefore + amounts[0]);
            assertUFixed18Eq(airdropToken.balanceOf(address(airdrop)), airdropTokenBalanceBefore - amounts[0]);
            assertTrue(airdrop.claimed(index, merkleRoot[0]));
        }

        // Claim airdrop for each account in second distribution
        for (uint256 i = 0; i < merkleProof2.totalUsers(); i++) {
            uint256 index = vm.parseUint(merkleProof2.airdropLeafs(i, 0));
            address user = vm.parseAddress(merkleProof2.airdropLeafs(i, 1));
            uint256 amount = vm.parseUint(merkleProof2.airdropLeafs(i, 2));

            bytes32[][] memory proofs = new bytes32[][](1);
            proofs[0] = merkleProof2.getUserProofs(i);

            vm.prank(user);
            UFixed18 userBalanceBefore = airdropToken.balanceOf(user);
            UFixed18 airdropTokenBalanceBefore = airdropToken.balanceOf(address(airdrop));
            uint256[] memory indexes = new uint256[](1);
            indexes[0] = index;
            UFixed18[] memory amounts = new UFixed18[](1);
            amounts[0] = UFixed18.wrap(amount);
            bytes32[] memory merkleRoot = new bytes32[](1);
            merkleRoot[0] = merkleProof2.airdropRoot();
            assertFalse(airdrop.claimed(index, merkleRoot[0]));
            airdrop.claim(user, indexes, amounts, proofs, merkleRoot);

            assertUFixed18Eq(airdropToken.balanceOf(user), userBalanceBefore + amounts[0]);
            assertUFixed18Eq(airdropToken.balanceOf(address(airdrop)), airdropTokenBalanceBefore - amounts[0]);
            assertTrue(airdrop.claimed(index, merkleRoot[0]));
        }
    }

    function test_claimAlreadyClaimed() public {
        Token18 token1 = airdropToken;
        bytes32 merkleRoot1 = merkleProof1.airdropRoot();
        vm.prank(owner);
        airdrop.addDistributions(token1, merkleRoot1);

        uint256 index = vm.parseUint(merkleProof1.airdropLeafs(0, 0));
        address user = vm.parseAddress(merkleProof1.airdropLeafs(0, 1));
        uint256 amount = vm.parseUint(merkleProof1.airdropLeafs(0, 2));

        bytes32[][] memory proofs = new bytes32[][](1);
        proofs[0] = new bytes32[](3);
        proofs[0][0] = bytes32(merkleProof1.airdropUserProofs(0, 0));
        proofs[0][1] = bytes32(merkleProof1.airdropUserProofs(0, 1));
        proofs[0][2] = bytes32(merkleProof1.airdropUserProofs(0, 2));
        uint256[] memory indexes = new uint256[](1);
        indexes[0] = index;
        UFixed18[] memory amounts = new UFixed18[](1);
        amounts[0] = UFixed18.wrap(amount);
        bytes32[] memory merkleRoot = new bytes32[](1);
        merkleRoot[0] = merkleProof1.airdropRoot();

        vm.prank(user);
        airdrop.claim(user, indexes, amounts, proofs, merkleRoot);

        vm.prank(user);
        vm.expectRevert(IAirdrop.AirdropAlreadyClaimed.selector);
        airdrop.claim(user, indexes, amounts, proofs, merkleRoot);
    }

    function test_claimInvalidProof() public {
        uint256 index = vm.parseUint(merkleProof1.airdropLeafs(0, 0));
        address user = vm.parseAddress(merkleProof1.airdropLeafs(0, 1));
        uint256 amount = vm.parseUint(merkleProof1.airdropLeafs(0, 2));

        bytes32[] memory proof = new bytes32[](3);
        proof[0] = bytes32(0x0000000000000000000000000000000000000000000000000000000000000000);
        proof[1] = bytes32(0x0000000000000000000000000000000000000000000000000000000000000000);
        proof[2] = bytes32(0x0000000000000000000000000000000000000000000000000000000000000000);
        uint256[] memory indexes = new uint256[](1);
        indexes[0] = index;
        UFixed18[] memory amounts = new UFixed18[](1);
        amounts[0] = UFixed18.wrap(amount);
        bytes32[] memory merkleRoot = new bytes32[](1);
        merkleRoot[0] = merkleProof1.airdropRoot();
        bytes32[][] memory proofs = new bytes32[][](1);

        vm.prank(user);
        vm.expectRevert(IAirdrop.AirdropInvalidProof.selector);
        airdrop.claim(user, indexes, amounts, proofs, merkleRoot);
    }

    function test_drain() public {
        // Non-owner tries to withdraw unused tokens
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, nonOwner));
        airdrop.drain(airdropToken, UFixed18.wrap(100_000_000 * 1e18));

        UFixed18 balanceBefore = airdropToken.balanceOf(address(airdrop));

        // Owner withdraws unused tokens
        vm.prank(owner);
        airdrop.drain(airdropToken, UFixed18.wrap(100_000_000 * 1e18));

        // Check that the tokens are withdrawn
        assertUFixed18Eq(airdropToken.balanceOf(owner), UFixed18.wrap(100_000_000 * 1e18));
        assertUFixed18Eq(airdropToken.balanceOf(address(airdrop)), balanceBefore - UFixed18.wrap(100_000_000 * 1e18));
    }
}
