// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

import { Attribute, IAttribute } from "../../src/attribute/Attribute.sol";
import { Implementation } from "../../src/mutability/Implementation.sol";
import { MockMutable } from "../mutability/Mutable.t.sol";

contract AttributeTest is Test {
    MockAttribute public attribute;
    MockMutable public mockMutable;

    function setUp() public {
        attribute = new MockAttribute();
        mockMutable = new MockMutable(address(this));

        vm.prank(address(mockMutable));
        attribute.construct(abi.encode("foo"));
    }

    function test_attributeFromConstructor() public view {
        // Check that the attribute was set correctly in the constructor
        assertEq(attribute.value(), "foo");
    }

    function test_initOutsideConstructor() public {
        vm.expectRevert(IAttribute.AttributeNotConstructing.selector);
        attribute.init("bar");

        // Ensure the attribute was not set
        assertEq(attribute.value(), "foo");
    }
}

contract MockAttribute is Implementation, Attribute {
    string public value;

    function name() public pure override returns (string memory) { return "MockAttribute"; }

    constructor() Implementation("0.0.1", "0.0.0") {}

    function __constructor(bytes memory data) internal override returns (string memory) {
        _init(abi.decode(data, (string)));
        return "0.0.1";
    }

    function init(string memory attribute) external  {
        _init(attribute);
    }

    function _init(string memory attribute) internal initializer(attribute) {
        value = attribute;
    }
}
