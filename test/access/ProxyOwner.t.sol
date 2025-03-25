// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { TransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { Test } from "forge-std/Test.sol";
import { ProxyOwner } from "../../src/access/ProxyOwner.sol";

contract ProxyOwnerTest is Test {
    address public immutable owner;
    ERC20 public impl;
    ProxyAdmin public proxyAdmin;
    ProxyOwner public proxyOwner;
    TransparentUpgradeableProxy public proxy;

    constructor() {
        owner = makeAddr("owner");
    }

    function setUp() public virtual {
        vm.startPrank(owner);
        impl = new ERC20("Test", "TEST");
        proxyOwner = new ProxyOwner();
        proxyAdmin = new ProxyAdmin();
        proxy = new TransparentUpgradeableProxy(address(impl), address(proxyAdmin), "");
    }
}

contract ProxyAdminIsProxyOwnerTest is ProxyOwnerTest {
    function test_transferOwnership() public {
        proxyAdmin.changeProxyAdmin(proxy, address(proxyOwner));
        assertEq(proxyOwner.getProxyAdmin(proxy), address(proxyOwner));
    }
}

contract ProxyOwnerIsProxyOwnerTest is ProxyOwnerTest {
    address user = makeAddr("user");
    ProxyOwner public proxyOwner2;

    function setUp() public override {
        super.setUp();
        proxyAdmin.changeProxyAdmin(proxy, address(proxyOwner));
        proxyOwner2 = new ProxyOwner();
    }

    function test_transferOwnership() public {
        address owner2 = makeAddr("owner2");
        vm.startPrank(owner);
        proxyOwner.transferOwnership(owner2);
        assertEq(proxyOwner.getProxyAdmin(proxy), address(proxyOwner), "ProxyOwner should still be the admin");
        assertEq(proxyOwner.owner(), owner, "Owner should not have changed");
        assertEq(proxyOwner.pendingOwner(), owner2, "Pending owner should be owner2");

        vm.startPrank(owner2);
        proxyOwner.acceptOwnership();
        assertEq(proxyOwner.owner(), owner2, "Owner should have changed");
        assertEq(proxyOwner.pendingOwner(), address(0), "Pending owner should be cleared");
    }

    function test_transferOwnershipOfProxy() public {
        vm.startPrank(owner);
        proxyOwner.changeProxyAdmin(proxy, address(proxyOwner2));
        assertEq(proxyOwner.getProxyAdmin(proxy), address(proxyOwner), "ProxyOwner should still be the admin");
        assertEq(proxyOwner.pendingAdmins(proxy), address(proxyOwner2), "Pending admin should be proxyOwner2");

        proxyOwner2.acceptProxyAdmin(proxyOwner, proxy);
        assertEq(proxyOwner2.getProxyAdmin(proxy), address(proxyOwner2), "ProxyOwner2 should be the admin");
        assertEq(proxyOwner.pendingAdmins(proxy), address(0), "Pending admin should be cleared");
    }

    function test_revertsIfNotOwnerWhenChangingProxyAdmin() public {
        vm.startPrank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        proxyOwner.changeProxyAdmin(proxy, address(proxyOwner2));
    }

    function test_revertsIfNotOwnerWhenAcceptingProxyAdmin() public {
        vm.startPrank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        proxyOwner.acceptProxyAdmin(proxyOwner2, proxy);
    }

    function test_revertsIfNotPending() public {
        vm.startPrank(owner);
        vm.expectRevert(ProxyOwner.ProxyOwnerNotPendingAdminError.selector);
        proxyOwner.acceptProxyAdmin(proxyOwner2, proxy);
    }

    function test_revertsIfNotPendingCallback() public {
        vm.startPrank(owner);
        vm.expectRevert(ProxyOwner.ProxyOwnerNotPendingAdminError.selector);
        proxyOwner.acceptProxyAdminCallback(proxy);
    }
}