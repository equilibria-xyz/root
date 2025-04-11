// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";

import { IOwnable, Ownable } from "src/attribute/Ownable.sol";
import { IProxy, Proxy, ProxyAdmin } from "src/proxy/Proxy.sol";

contract ProxyTest is Test {
    address public immutable proxyOwner;
    address public immutable implementationOwner;
    IProxy public proxy;
    ProxyAdmin public proxyAdmin;
    SampleContractV1 instance1;

    constructor() {
        proxyOwner = makeAddr("owner");
        implementationOwner = makeAddr("implementationOwner");
    }

    function setUp() public {
        // create the proxy admin
        proxyAdmin = new ProxyAdmin();
        vm.prank(proxyOwner);
        proxyAdmin.initialize();

        // deploy the implementation and create the proxy
        SampleContractV1 impl = new SampleContractV1(101);
        Proxy proxyInstantiation = new Proxy(
            address(impl),
            proxyAdmin,
            "", // cannot initialize here because proxyOwner != implementationOwner
            "SampleContract"
        );
        proxy = IProxy(address(proxyInstantiation));

        // initialize the instance
        instance1 = SampleContractV1(address(proxy));
        vm.prank(implementationOwner);
        instance1.initialize();
    }

    function upgrade() internal returns (SampleContractV2) {
        SampleContractV2 impl2 = new SampleContractV2(201);
        assertEq(proxyAdmin.owner(), proxyOwner, "ProxyAdmin owner should be proxyOwner");
        vm.prank(proxyOwner);
        proxyAdmin.upgradeToAndCall(
            proxy,
            address(impl2),
            "",
            "SampleContract",
            2
        );
        return SampleContractV2(address(proxy));
    }

    function test_creation() public view {
        assertEq(instance1.immutableValue(), 101, "Immutable value should be 101");
        assertEq(instance1.getValue(), 0, "Initial value should be 0");
    }

    function test_identify() public {
        vm.expectEmit();
        emit Proxy.Identify("SampleContract", 0);
        proxy.identify();
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
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, address(proxyAdmin)));
        instance1.setValue(106);
    }

    function test_proxyAdminOwnerCannotInteract() public {
        assertEq(proxyAdmin.owner(), proxyOwner, "ProxyAdmin owner should be proxyOwner");
        vm.prank(proxyOwner);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, address(proxyOwner)));
        instance1.setValue(106);
    }

    /* TODO:
    - storage
    - permissions and ProxyOwner
    - test all the failure cases
    - ensure exceptions raised on sample contract make it to caller
    - confirm IERC1967 Upgraded and AdminChanged events are emitted
    */
}

contract SampleContractV1 is Ownable {
    uint256 public immutable immutableValue;
    uint256 public value;

    constructor(uint256 immutableValue_) {
        immutableValue = immutableValue_;
    }

    function initialize() external initializer(1) {
        __Ownable__initialize();
    }

    function setValue(uint256 value_) external onlyOwner() {
        value = value_;
    }

    function getValue() external view returns (uint256) {
        return value;
    }
}

contract SampleContractV2 is Ownable {
    uint256 public immutable immutableValue;
    uint256 public value1; // same storage location as `value` in V1
    int256 public value2;

    constructor(uint256 immutableValue_) {
        immutableValue = immutableValue_;
    }

    function initialize() external initializer(1) {
        __Ownable__initialize();
    }

    function setValues(uint256 value1_, int256 value2_) external onlyOwner() {
        value1 = value1_;
        value2 = value2_;
    }

    function getValues() external view returns (uint256, int256) {
        return (value1, value2);
    }
}
