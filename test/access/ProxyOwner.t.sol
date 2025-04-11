// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { TransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import { Test } from "forge-std/Test.sol";
import { ERC20TestToken } from "../token/TokenTest.sol";
import { ProxyOwner } from "../../src/access/ProxyOwner.sol";

contract ProxyOwnerTest is Test {
    address public immutable owner;
    ERC20TestToken public impl;
    ProxyAdmin public proxyAdmin;
    ProxyOwner public proxyOwner;
    TransparentUpgradeableProxy public proxy;

    constructor() {
        owner = makeAddr("owner");
    }

    function setUp() public virtual {
        impl = new ERC20TestToken("Test", "TEST", 18, 1000e18);
        vm.startPrank(owner);
        proxyOwner = new ProxyOwner();
        vm.stopPrank();
        proxyAdmin = new ProxyAdmin(owner);
        proxy = new TransparentUpgradeableProxy(address(impl), address(proxyAdmin), "");
    }
}

contract ChangeProxyAdminToProxyOwnerTest is ProxyOwnerTest {
    function test_transferOwnership() public {
        vm.startPrank(owner);
        proxyAdmin.transferOwnership(address(proxyOwner));
        assertEq(proxyAdmin.owner(), address(proxyOwner));
    }
}

contract ChangeProxyOwnerToAnotherProxyOwnerTest is ProxyOwnerTest {
    address user = makeAddr("user");
    ProxyOwner public proxyOwner2;

    function setUp() public override {
        super.setUp();
        // transfer ownership of the ProxyAdmin to our ProxyOwner
        vm.startPrank(owner);
        proxyAdmin.transferOwnership(address(proxyOwner));
        proxyOwner2 = new ProxyOwner();
        vm.stopPrank();
    }

    function test_transferOwnership() public {
        address owner2 = makeAddr("owner2");
        vm.startPrank(owner);
        proxyOwner.transferOwnership(owner2);
        assertEq(proxyOwner.owner(), owner, "Owner should not have changed");
        assertEq(proxyOwner.pendingOwner(), owner2, "Pending owner should be owner2");

        vm.startPrank(owner2);
        proxyOwner.acceptOwnership();
        assertEq(proxyOwner.owner(), owner2, "Owner should have changed");
        assertEq(proxyOwner.pendingOwner(), address(0), "Pending owner should be cleared");
    }
}
