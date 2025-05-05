// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

import { Test } from "forge-std/Test.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IAirdrop, Airdrop } from "../../src/distribution/Airdrop.sol";
import { MerkleProof1, MerkleProof2 } from "../testutil/MerkleProofs.sol";
import { ERC20Mintable } from "../testutil/ERC20Mintable.sol";

contract AirdropTest is Test {
    Airdrop public airdrop;
    ERC20Mintable public airdropToken;
    MerkleProof1 public merkleProof1;
    MerkleProof2 public merkleProof2;
    address public owner = makeAddr("OWNER");

    function setUp() public {
        airdropToken = new ERC20Mintable("Test Token", "TEST");
        merkleProof1 = new MerkleProof1();
        merkleProof2 = new MerkleProof2();
        vm.prank(owner);
        airdrop = new Airdrop();
        airdropToken.mint(address(airdrop), 1_000_000_000 * 1e18);
    }

    function test_addDistribution() public {
        address token = address(new ERC20Mintable("Token", "TEST"));
        bytes32 merkleRoot = bytes32(uint256(1));
        vm.prank(owner);
        airdrop.addDistributions(token, merkleRoot);

        assertEq(airdrop.distributions(merkleRoot), token);

        vm.prank(owner);
        vm.expectRevert(IAirdrop.DistributionAlreadyExists.selector);
        airdrop.addDistributions(token, merkleRoot);
    }

    function test_getMerkleRoots() public {
        bytes32 merkleRoot1 = merkleProof1.airdropRoot();
        bytes32 merkleRoot2 = merkleProof2.airdropRoot();
        vm.prank(owner);
        airdrop.addDistributions(address(airdropToken), merkleRoot1);
        vm.prank(owner);
        airdrop.addDistributions(address(airdropToken), merkleRoot2);

        bytes32[] memory merkleRoots = airdrop.getMerkleRoots();
        assertEq(merkleRoots.length, 2);
        assertEq(merkleRoots[0], merkleRoot1);
        assertEq(merkleRoots[1], merkleRoot2);
    }

    function test_claimDistribution() public {
        address token = address(airdropToken);
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
            uint256 userBalanceBefore = airdropToken.balanceOf(user);
            uint256 airdropTokenBalanceBefore = airdropToken.balanceOf(address(airdrop));
            uint256[] memory indexes = new uint256[](1);
            indexes[0] = index;
            uint256[] memory amounts = new uint256[](1);
            amounts[0] = amount;
            bytes32[] memory merkleRoots = new bytes32[](1);
            merkleRoots[0] = merkleProof1.airdropRoot();
            assertFalse(airdrop.isClaimed(index, merkleRoots[0]));
            airdrop.claim(user, indexes, amounts, proofs, merkleRoots);

            assertEq(airdropToken.balanceOf(user), userBalanceBefore + amount);
            assertEq(airdropToken.balanceOf(address(airdrop)), airdropTokenBalanceBefore - amount);
            assertTrue(airdrop.isClaimed(index, merkleRoots[0]));
        }
    }

    function test_claimMultipleDistributions() public {
        address token1 = address(airdropToken);
        bytes32 merkleRoot1 = merkleProof1.airdropRoot();
        vm.prank(owner);
        airdrop.addDistributions(token1, merkleRoot1);

        address token2 = address(airdropToken);
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
            uint256 userBalanceBefore = airdropToken.balanceOf(user);
            uint256 airdropTokenBalanceBefore = airdropToken.balanceOf(address(airdrop));
            uint256[] memory indexes = new uint256[](1);
            indexes[0] = index;
            uint256[] memory amounts = new uint256[](1);
            amounts[0] = amount;
            bytes32[] memory merkleRoot = new bytes32[](1);
            merkleRoot[0] = merkleProof1.airdropRoot();
            assertFalse(airdrop.isClaimed(index, merkleRoot[0]));
            airdrop.claim(user, indexes, amounts, proofs, merkleRoot);

            assertEq(airdropToken.balanceOf(user), userBalanceBefore + amount);
            assertEq(airdropToken.balanceOf(address(airdrop)), airdropTokenBalanceBefore - amount);
            assertTrue(airdrop.isClaimed(index, merkleRoot[0]));
        }

        // Claim airdrop for each account in second distribution
        for (uint256 i = 0; i < merkleProof2.totalUsers(); i++) {
            uint256 index = vm.parseUint(merkleProof2.airdropLeafs(i, 0));
            address user = vm.parseAddress(merkleProof2.airdropLeafs(i, 1));
            uint256 amount = vm.parseUint(merkleProof2.airdropLeafs(i, 2));

            bytes32[][] memory proofs = new bytes32[][](1);
            proofs[0] = merkleProof2.getUserProofs(i);

            vm.prank(user);
            uint256 userBalanceBefore = airdropToken.balanceOf(user);
            uint256 airdropTokenBalanceBefore = airdropToken.balanceOf(address(airdrop));
            uint256[] memory indexes = new uint256[](1);
            indexes[0] = index;
            uint256[] memory amounts = new uint256[](1);
            amounts[0] = amount;
            bytes32[] memory merkleRoot = new bytes32[](1);
            merkleRoot[0] = merkleProof2.airdropRoot();
            assertFalse(airdrop.isClaimed(index, merkleRoot[0]));
            airdrop.claim(user, indexes, amounts, proofs, merkleRoot);

            assertEq(airdropToken.balanceOf(user), userBalanceBefore + amount);
            assertEq(airdropToken.balanceOf(address(airdrop)), airdropTokenBalanceBefore - amount);
            assertTrue(airdrop.isClaimed(index, merkleRoot[0]));
        }
    }

    function test_claimAirdropAlreadyClaimed() public {
        address token1 = address(airdropToken);
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
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        bytes32[] memory merkleRoot = new bytes32[](1);
        merkleRoot[0] = merkleProof1.airdropRoot();

        vm.prank(user);
        airdrop.claim(user, indexes, amounts, proofs, merkleRoot);

        vm.prank(user);
        vm.expectRevert(IAirdrop.AlreadyClaimed.selector);
        airdrop.claim(user, indexes, amounts, proofs, merkleRoot);
    }

    function test_claimAirdropInvalidProof() public {
        uint256 index = vm.parseUint(merkleProof1.airdropLeafs(0, 0));
        address user = vm.parseAddress(merkleProof1.airdropLeafs(0, 1));
        uint256 amount = vm.parseUint(merkleProof1.airdropLeafs(0, 2));

        bytes32[] memory proof = new bytes32[](3);
        proof[0] = bytes32(0x0000000000000000000000000000000000000000000000000000000000000000);
        proof[1] = bytes32(0x0000000000000000000000000000000000000000000000000000000000000000);
        proof[2] = bytes32(0x0000000000000000000000000000000000000000000000000000000000000000);
        uint256[] memory indexes = new uint256[](1);
        indexes[0] = index;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        bytes32[] memory merkleRoot = new bytes32[](1);
        merkleRoot[0] = merkleProof1.airdropRoot();
        bytes32[][] memory proofs = new bytes32[][](1);

        vm.prank(user);
        vm.expectRevert(IAirdrop.InvalidProof.selector);
        airdrop.claim(user, indexes, amounts, proofs, merkleRoot);
    }
}
