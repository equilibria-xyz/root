// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { IERC1967 } from "@openzeppelin/contracts/interfaces/IERC1967.sol";

import { ProxyTestV1Deploy, SampleContractV2 } from "./ProxyTest.sol";
import { IOwnable } from "../../src/attribute/Ownable.sol";
import { Proxy, ProxyAdmin } from "../../src/proxy/Proxy.sol";

contract ProxyAdminTest is ProxyTestV1Deploy {
    address newOwner;

    function setUp() public override {
        super.setUp();
    }

    function updatePendingOwner() internal {
        // start with a pending update
        newOwner = makeAddr("newOwner");
        vm.prank(proxyOwner);
        vm.expectEmit();
        emit IOwnable.PendingOwnerUpdated(newOwner);
        proxyAdmin.updatePendingOwner(newOwner);
    }

    function test_oldOwnerCanUpgradeBeforeNewOwnerAccepts() public {
        updatePendingOwner();
        SampleContractV2 impl2 = new SampleContractV2(201);
        vm.prank(proxyOwner);
        vm.expectEmit();
        emit IERC1967.Upgraded(address(impl2));
        proxyAdmin.upgradeToAndCall(proxy, impl2, abi.encode(770));
    }

    function test_newOwnerMustAcceptChange() public {
        updatePendingOwner();
        assertEq(proxyAdmin.owner(), proxyOwner, "ProxyAdmin owner unchanged until accepted");

        vm.prank(newOwner);
        vm.expectEmit();
        emit IOwnable.OwnerUpdated(newOwner);
        proxyAdmin.acceptOwner();
        assertEq(proxyAdmin.owner(), newOwner, "ProxyAdmin owner changed");
    }

    function test_newOwnerCanUpgrade() public {
        updatePendingOwner();
        vm.prank(newOwner);
        proxyAdmin.acceptOwner();
        assertEq(proxyAdmin.owner(), newOwner, "ProxyAdmin owner should be newOwner");

        // old owner cannot upgrade
        SampleContractV2 impl2 = new SampleContractV2(201);
        vm.prank(proxyOwner);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, proxyOwner));
        proxyAdmin.upgradeToAndCall(proxy, impl2, abi.encode(771));

        // new owner can upgrade
        vm.prank(newOwner);
        vm.expectEmit();
        emit IERC1967.Upgraded(address(impl2));
        proxyAdmin.upgradeToAndCall(proxy, impl2, abi.encode(772));
    }

    function test_ownerCanPauseAndUnpause() public {
        vm.startPrank(proxyOwner);
        vm.expectEmit();
        emit Proxy.Paused();
        proxyAdmin.pause(proxy);

        vm.expectEmit();
        emit Proxy.Unpaused();
        proxyAdmin.unpause(proxy);
        vm.stopPrank();
    }

    function test_pauserAccessor() public {
        address pauser = makeAddr("pauser");
        vm.prank(proxyOwner);
        proxyAdmin.updatePauser(pauser);
        assertEq(proxyAdmin.pauser(), pauser, "Pauser should be set correctly");
    }

    function test_pauserCanPauseAndUnpause() public {
        address pauser = makeAddr("pauser");
        vm.prank(proxyOwner);
        proxyAdmin.updatePauser(pauser);

        vm.startPrank(pauser);
        vm.expectEmit();
        emit Proxy.Paused();
        proxyAdmin.pause(proxy);

        vm.expectEmit();
        emit Proxy.Unpaused();
        proxyAdmin.unpause(proxy);
        vm.stopPrank();
    }

    function test_revertsNonOwnerCannotSetPauser() public {
        address pauser = makeAddr("pauser");
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, address(this)));
        proxyAdmin.updatePauser(pauser);
    }

    function test_revertsOnUnauthorizedPause() public {
        vm.expectRevert(abi.encodeWithSelector(ProxyAdmin.ProxyAdminNotOwnerOrPauserError.selector, address(this)));
        proxyAdmin.pause(proxy);
    }

    function test_revertsOnUnauthorizedUnPause() public {
        vm.expectRevert(abi.encodeWithSelector(ProxyAdmin.ProxyAdminNotOwnerOrPauserError.selector, address(this)));
        proxyAdmin.unpause(proxy);
    }
}
