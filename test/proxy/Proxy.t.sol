// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { IERC1967 } from "@openzeppelin/contracts/interfaces/IERC1967.sol";
import { Test } from "forge-std/Test.sol";

import { IOwnable, Ownable } from "src/attribute/Ownable.sol";
import { IProxy } from "src/proxy/interfaces/IProxy.sol";
import { Proxy, ProxyAdmin } from "src/proxy/Proxy.sol";

/// @dev Tests both Proxy and ProxyAdmin
abstract contract ProxyTest is Test {
    address public immutable proxyOwner;
    address public immutable implementationOwner;
    IProxy public proxy;
    ProxyAdmin public proxyAdmin;
    SampleContractV1 instance1;

    constructor() {
        proxyOwner = makeAddr("owner");
        implementationOwner = makeAddr("implementationOwner");
    }

    function setUp() public virtual {
        // create the proxy admin
        proxyAdmin = new ProxyAdmin();
        vm.startPrank(proxyOwner);
        proxyAdmin.initialize();

        // deploy the implementation and create the proxy
        SampleContractV1 impl = new SampleContractV1(101);
        Proxy proxyInstantiation = new Proxy(
            impl,
            proxyAdmin,
            abi.encodeWithSignature("initialize()")
        );
        vm.stopPrank();
        proxy = IProxy(address(proxyInstantiation));

        // initialize the instance
        instance1 = SampleContractV1(address(proxy));

        changeOwner(implementationOwner);
    }

    function changeOwner(address newOwner) internal {
        vm.prank(proxyOwner);
        instance1.updatePendingOwner(implementationOwner);
        vm.prank(newOwner);
        instance1.acceptOwner();
    }

    function upgrade() internal returns (SampleContractV2) {
        SampleContractV2 impl2 = new SampleContractV2(201);
        vm.prank(proxyOwner);
        vm.expectEmit();
        emit IERC1967.Upgraded(address(impl2));
        proxyAdmin.upgradeToAndCall(proxy, impl2, abi.encodeWithSignature("initialize()"));
        return SampleContractV2(address(proxy));
    }
}

contract ProxyTestV1 is ProxyTest {
    function test_creation() public view {
        assertEq(instance1.version(), 1, "Version should be 1 after deployment");
        assertEq(instance1.immutableValue(), 101, "Immutable value should be 101");
        assertEq(instance1.getValue(), 0, "Initial value should be 0");
    }

    function test_identify() public view {
        assertEq(instance1.name(), "SampleContract", "Implementation name should be SampleContract");
        assertEq(instance1.version(), 1, "Implementation version should be 1");
    }

    function test_interaction() public {
        vm.prank(implementationOwner);
        instance1.setValue(153);
        assertEq(instance1.getValue(), 153, "Value should be 153");
    }

    function test_upgrade() public {
        // set value on old version to confirm storage is not overwritten
        vm.prank(implementationOwner);
        instance1.setValue(153);

        SampleContractV2 instance2 = upgrade();
        assertEq(instance2.owner(), implementationOwner, "Owner should still be implementationOwner");
        assertEq(instance2.immutableValue(), 201, "Immutable value should be 201");
        (uint256 value1, int256 value2) = instance2.getValues();
        assertEq(value1, 153, "Value1 should still be 153");
        assertEq(value2, 0, "Value2 was never set");
    }

    function test_nonOwnerCannotInteract() public {
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, address(this)));
        instance1.setValue(106);
    }

    function test_proxyAdminCannotInteract() public {
        vm.prank(address(proxyAdmin));
        vm.expectRevert(Proxy.ProxyDeniedAdminAccess.selector);
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
        vm.expectRevert(abi.encodeWithSelector(Proxy.ProxyNameMismatch.selector, "SampleContract", "NonSampleContract"));
        vm.prank(proxyOwner);
        proxyAdmin.upgradeToAndCall(proxy, wrongContract, abi.encodeWithSignature("initialize(uint256)", 2));
    }
}

contract ProxyTestV2 is ProxyTest {
    SampleContractV2 instance2;

    function setUp() public override {
        super.setUp();
        // upgrade the proxy
        instance2 = upgrade();
        vm.prank(implementationOwner);
        instance2.setValues(153, -1);
    }

    function test_identify() public view {
        assertEq(instance2.name(), "SampleContract", "Implementation name should be SampleContract");
        assertEq(instance2.version(), 2, "Implementation version should be 2");
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
        vm.expectRevert(abi.encodeWithSelector(Proxy.ProxyVersionMismatch.selector, 2, 1));
        vm.prank(proxyOwner);
        proxyAdmin.upgradeToAndCall(proxy, impl1, abi.encodeWithSignature("initialize()"));
    }

    function test_implementationCanRevert() public {
        vm.expectRevert(SampleContractV2.CustomError.selector);
        instance2.revertWhenCalled();
    }
}

contract ProxyAdminTest is ProxyTest {
    address newOwner;

    function setUp() public override {
        super.setUp();

        // start with a pending update
        newOwner = makeAddr("newOwner");
        vm.prank(proxyOwner);
        vm.expectEmit();
        emit IOwnable.PendingOwnerUpdated(newOwner);
        proxyAdmin.updatePendingOwner(newOwner);
    }

    function test_oldOwnerCanUpgradeBeforeNewOwnerAccepts() public {
        SampleContractV2 impl2 = new SampleContractV2(201);
        vm.prank(proxyOwner);
        vm.expectEmit();
        emit IERC1967.Upgraded(address(impl2));
        proxyAdmin.upgradeToAndCall(proxy, impl2, abi.encodeWithSignature("initialize()"));
    }

    function test_newOwnerMustAcceptChange() public {
        assertEq(proxyAdmin.owner(), proxyOwner, "ProxyAdmin owner unchanged until accepted");

        vm.prank(newOwner);
        vm.expectEmit();
        emit IOwnable.OwnerUpdated(newOwner);
        proxyAdmin.acceptOwner();
        assertEq(proxyAdmin.owner(), newOwner, "ProxyAdmin owner changed");
    }

    function test_newOwnerCanUpgrade() public {
        vm.prank(newOwner);
        proxyAdmin.acceptOwner();
        assertEq(proxyAdmin.owner(), newOwner, "ProxyAdmin owner should be newOwner");

        // old owner cannot upgrade
        SampleContractV2 impl2 = new SampleContractV2(201);
        vm.prank(proxyOwner);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, proxyOwner));
        proxyAdmin.upgradeToAndCall(proxy, impl2, abi.encodeWithSignature("initialize()"));

        // new owner can upgrade
        vm.prank(newOwner);
        vm.expectEmit();
        emit IERC1967.Upgraded(address(impl2));
        proxyAdmin.upgradeToAndCall(proxy, impl2, abi.encodeWithSignature("initialize()"));
    }
}

/// @dev Initial implementation of an upgradable contract
contract SampleContractV1 is Ownable {
    uint256 public immutable immutableValue;
    uint256 public value;

    constructor(uint256 immutableValue_) {
        immutableValue = immutableValue_;
    }

    function initialize() external initializer("SampleContract", 1) {
        __Ownable__initialize();
    }

    function setValue(uint256 value_) external onlyOwner() {
        value = value_;
    }

    function getValue() external view returns (uint256) {
        return value;
    }
}

/// @dev Second implementation of an upgradable contract
contract SampleContractV2 is Ownable {
    uint256 public immutable immutableValue;
    uint256 public value1; // same storage location as `value` in V1
    int256 public value2;

    error CustomError();

    constructor(uint256 immutableValue_) {
        immutableValue = immutableValue_;
    }

    function initialize() external initializer("SampleContract", 2) {
        __Ownable__initialize();
    }

    function setValues(uint256 value1_, int256 value2_) external onlyOwner() {
        value1 = value1_;
        value2 = value2_;
    }

    function getValues() external view returns (uint256, int256) {
        return (value1, value2);
    }

    function revertWhenCalled() external pure {
        revert CustomError();
    }
}

/// @dev Contract whose name does not match that expected by the proxy
contract NonSampleContract is Ownable {
    function initialize(uint256 version) external initializer("NonSampleContract", version) {
        __Ownable__initialize();
    }
}
