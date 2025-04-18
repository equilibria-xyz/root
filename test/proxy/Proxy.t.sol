// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { ProxyTest, NonSampleContract, SampleContractV1, SampleContractV2 } from "./ProxyTest.sol";
import { IOwnable, Ownable } from "../../src/attribute/Ownable.sol";
import { Version } from "../../src/attribute/types/Version.sol";
import { IProxy } from "../../src/proxy/interfaces/IProxy.sol";
import { Proxy, ProxyAdmin } from "../../src/proxy/Proxy.sol";

contract ProxyTestV1 is ProxyTest {
    function test_creation() public view {
        assertEq(instance1.version(), Version(1, 0, 1), "Version should be 1.0.1 after deployment");
        assertEq(instance1.immutableValue(), 101, "Immutable value should be 101");
        assertEq(instance1.getValue(), 112, "Initializer should have set value");
    }

    function test_identify() public view {
        assertEq(instance1.nameHash(), keccak256(bytes("SampleContract")), "Implementation name should be SampleContract");
        assertEq(instance1.version(), Version(1, 0, 1), "Implementation version should be 1.0.1");
    }

    function test_interaction() public {
        vm.prank(implementationOwner);
        instance1.setValue(153);
        assertEq(instance1.getValue(), 153, "Value should be 153");
    }

    function test_upgrade() public {
        SampleContractV2 instance2 = upgrade();
        assertEq(instance2.version(), Version(2, 0, 1), "Version should be 2.0.1 after upgrade");
        assertEq(instance2.owner(), implementationOwner, "Owner should still be implementationOwner");
        assertEq(instance2.immutableValue(), 201, "Immutable value should be 201");
        (uint256 value1, int256 value2) = instance2.getValues();
        assertEq(value1, 113, "Value1 should have incremented by initializer");
        assertEq(value2, 222, "Value2 should have set the initializer using initParams");
    }

    function test_upgradeWithDifferentInitVersion() public {
        // upgrade passing the initializer a different version than the contract
        SampleContractV2 instance2 = upgradeWithVersion(Version(2, 0, 0));

        // confirm upgrade worked and immutable value was updated
        assertEq(instance2.version(), Version(2, 0, 1), "Version should be 2.0.1 after upgrade");
        assertEq(instance2.immutableValue(), 201, "Immutable value should be 201");

        // confirm initializer did not run
        (uint256 value1, int256 value2) = instance2.getValues();
        assertEq(value1, 112, "Value1 not incremented when init version doesn't match");
        assertEq(value2, 0, "Value2 should be 0 when init version doesn't match");
    }

    function test_nonOwnerCannotInteract() public {
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, address(this)));
        instance1.setValue(106);
    }

    function test_proxyAdminCannotInteract() public {
        vm.prank(address(proxyAdmin));
        vm.expectRevert(Proxy.ProxyDeniedAdminAccessError.selector);
        instance1.setValue(106);
    }

    function test_proxyAdminOwnerCannotInteract() public {
        assertEq(proxyAdmin.owner(), proxyOwner, "ProxyAdmin owner should be proxyOwner");
        vm.prank(proxyOwner);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, address(proxyOwner)));
        instance1.setValue(106);
    }

    function test_nonProxyAdminCannotUpgrade() public {
        SampleContractV2 impl2 = new SampleContractV2(204);
        vm.expectRevert();
        proxy.upgradeToAndCall(impl2, "");
    }

    function test_revertsIfNameMismatch() public {
        NonSampleContract wrongContract = new NonSampleContract();
        vm.expectRevert(Proxy.ProxyNameMismatchError.selector);
        vm.prank(proxyOwner);
        proxyAdmin.upgradeToAndCall(proxy, wrongContract, "");
    }

    function test_canPause() public {
        /*vm.prank(implementationOwner);
        instance1.setValue(154);
        assertEq(instance1.value(), 154, "Value should be 154");*/

        vm.prank(proxyOwner);
        vm.expectEmit();
        emit Proxy.Paused();
        proxyAdmin.pause(proxy);

        // user can still read from contract
        /*assertEq(instance1.value(), 154, "Value should still be 154");
        assertEq(instance1.getValue(), 154, "Getter function should still return 154");*/

        // user cannot interact
        vm.prank(implementationOwner);
        vm.expectRevert(Proxy.ProxyPausedError.selector);
        instance1.setValue(444);
    }

    function test_canUnpause() public {
        vm.startPrank(proxyOwner);
        proxyAdmin.pause(proxy);
        vm.expectEmit();
        emit Proxy.Unpaused();
        proxyAdmin.unpause(proxy);
        vm.stopPrank();

        vm.prank(implementationOwner);
        instance1.setValue(555);
        assertEq(instance1.getValue(), 555, "User interacted after unpaused");
    }

    function test_upgradeWhilePaused() public {
        // change state and then pause the proxy
        vm.prank(implementationOwner);
        instance1.setValue(155);
        vm.prank(proxyOwner);
        proxyAdmin.pause(proxy);

        // upgrade while paused and then unpause
        SampleContractV2 instance2 = upgrade();
        vm.prank(proxyOwner);
        proxyAdmin.unpause(proxy);

        // check state
        assertEq(instance2.version(), Version(2, 0, 1), "Version change after upgrade while paused");
        assertEq(instance2.immutableValue(), 201, "Immutable value after upgrade while paused");
        assertEq(instance2.value1(), 156, "Value1 after upgrade while paused");
        assertEq(instance2.value2(), 222, "Value2 after upgrade while paused");

        // confirm interactions still work
        vm.prank(implementationOwner);
        instance2.setValues(255, -17);
        (uint256 val1, int256 val2) = instance2.getValues();
        assertEq(val1, 255, "Value1 should be mutable after upgrade while paused");
        assertEq(val2, -17, "Value2 should be mutable after upgrade while paused");
    }
}

contract ProxyTestV2 is ProxyTest {
    SampleContractV2 instance2;

    function setUp() public override {
        super.setUp();
        // upgrade the proxy
        instance2 = upgrade();
    }

    function test_identify() public view {
        assertEq(instance2.nameHash(), keccak256(bytes("SampleContract")), "Implementation name should be SampleContract2");
        assertEq(instance2.version(), Version(2, 0, 1), "Implementation version should be 2");
    }

    function test_interactionPostUpgrade() public {
        vm.prank(implementationOwner);
        instance2.setValues(253, -254);
        (uint256 val1, int256 val2) = instance2.getValues();
        assertEq(instance2.immutableValue(), 201, "Immutable value should still be 201");
        assertEq(val1, 253, "Value1 should be 253");
        assertEq(val2, -254, "Value2 should be -254");
    }

    function test_revertsOnDowngradeAttempt() public {
        SampleContractV1 impl1 = new SampleContractV1(104);
        vm.expectRevert(abi.encodeWithSelector(
            Proxy.ProxyVersionMismatchError.selector,
            Version(2, 0, 1),
            Version(1, 0, 1)
        ));
        vm.prank(proxyOwner);
        proxyAdmin.upgradeToAndCall(proxy, impl1, "");
    }

    function test_implementationCanRevert() public {
        vm.expectRevert(SampleContractV2.CustomError.selector);
        instance2.revertWhenCalled();
    }
}
