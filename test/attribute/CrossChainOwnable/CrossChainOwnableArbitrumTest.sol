// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

import {CrossChainOwnable_Arbitrum} from "src/attribute/CrossChainOwnable/CrossChainOwnable_Arbitrum.sol";

contract CrossChainOwnableArbitrumTest is Test {
    // Events emitted by the contract
    event OwnerUpdated(address indexed newOwner);
    event PendingOwnerUpdated(address indexed pendingOwner);

    // Custom errors
    error NotCrossChainCall();
    error OwnableNotPendingOwnerError(address pendingOwner);
    error OwnableNotOwnerError(address owner);

    // Test addresses
    address public owner; // Initial owner address
    address public xChainOwner; // Cross-chain owner address
    address public user; // Regular user address
    address public unrelated; // Unrelated address with no permissions
    MockCrossChainOwnable_Arbitrum public ownable;
    MockArbSys public arbSys;

    function setUp() public virtual {
        // Setting up the accounts to be used in the tests
        owner = makeAddr("owner");
        xChainOwner = makeAddr("xChainOwner");
        user = makeAddr("user");
        unrelated = makeAddr("unrelated");

        // Deploy MockCrossChainOwnableArbitrum contract
        ownable = new MockCrossChainOwnable_Arbitrum();

        // Deploy the fake contract (fake arbSys for simulation)
        // Using the standard Arbitrum ArbSys address
        bytes memory code = address(new MockArbSys()).code;
        address arbSysAddress = address(0x0000000000000000000000000000000000000064);

        // Etch the code of fake arbSys to Arbitrum's ArbSys address
        vm.etch(arbSysAddress, code);
        arbSys = MockArbSys(arbSysAddress);

        // Initial setup for testing
        vm.deal(arbSysAddress, 10 ether);
    }

    function testOwnableInitialize() public {
        // Test initial ownership
        assertEq(ownable.owner(), address(0));

        // Expect an event
        vm.expectEmit(true, true, true, true);
        emit OwnerUpdated(user);

        // Simulate the __initialize function call
        vm.prank(user);
        ownable.__initialize();

        assertEq(ownable.owner(), user);
    }

    function testSetPendingOwner() public {
        vm.prank(user);
        // Initialize contract
        ownable.__initialize();

        // Test setting pending owner
        vm.expectEmit(true, true, true, true);
        emit PendingOwnerUpdated(xChainOwner);

        vm.prank(user);
        ownable.updatePendingOwner(xChainOwner);

        assertEq(ownable.owner(), user);
        assertEq(ownable.pendingOwner(), xChainOwner);
    }

    function testSetPendingOwnerNotOwner() public {
        vm.prank(user);
        // Initialize contract
        ownable.__initialize();

        // Simulate call from unrelated user
        vm.expectRevert(abi.encodeWithSelector(OwnableNotOwnerError.selector, unrelated));
        vm.prank(unrelated);
        ownable.updatePendingOwner(unrelated);
    }

    function testResetPendingOwner() public {
        vm.prank(user);
        // Initialize contract
        ownable.__initialize();

        // Reset pending owner
        vm.expectEmit(true, true, true, true);
        emit PendingOwnerUpdated(address(0));

        vm.prank(user);
        ownable.updatePendingOwner(address(0));

        assertEq(ownable.owner(), user);
        assertEq(ownable.pendingOwner(), address(0));
    }

    function testAcceptOwner() public {
        vm.prank(user);
        // Initialize contract and set pending owner
        ownable.__initialize();
        vm.prank(user);
        ownable.updatePendingOwner(xChainOwner);

        // Simulate accepting the owner by arbSys
        arbSys.setCallerAddress(xChainOwner);
        arbSys.setIsAliased(true);
        vm.expectEmit(true, true, true, true);
        emit OwnerUpdated(xChainOwner);

        vm.prank(address(arbSys));
        ownable.acceptOwner();

        assertEq(ownable.owner(), xChainOwner);
        assertEq(ownable.pendingOwner(), address(0));
        assertTrue(ownable.crossChainRestricted());
    }

    function testAcceptOwnerNotCrossChain() public {
        vm.prank(user);
        // Initialize contract and set pending owner
        ownable.__initialize();
        vm.prank(user);
        ownable.updatePendingOwner(xChainOwner);

        // Set myCallersAddressWithoutAliasing to false
        vm.expectRevert(NotCrossChainCall.selector);
        vm.prank(user);
        ownable.acceptOwner();
    }

    function testAcceptOwnerNotPendingOwner() public {
        vm.prank(user);
        // Initialize contract and set pending owner
        ownable.__initialize();
        vm.prank(user);
        ownable.updatePendingOwner(unrelated);

        // Simulate call from an unrelated address
        vm.prank(address(arbSys));
        arbSys.setCallerAddress(xChainOwner);
        arbSys.setIsAliased(true);
        vm.expectRevert(abi.encodeWithSelector(OwnableNotPendingOwnerError.selector, xChainOwner));
        vm.prank(user);
        ownable.acceptOwner();
    }

    function testOnlyOwnerModifier() public {
        vm.prank(user);
        // Initialize contract and set pending owner
        ownable.__initialize();
        vm.prank(user);
        ownable.updatePendingOwner(user);

        // Simulate accepting the owner by arbSys
        arbSys.setCallerAddress(user);
        arbSys.setIsAliased(true);
        vm.prank(address(arbSys));
        ownable.acceptOwner();

        // Attempt to access onlyOwner function by xChainOwner
        arbSys.setCallerAddress(xChainOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableNotOwnerError.selector, xChainOwner));
        vm.prank(user);
        ownable.mustOwner();

        arbSys.setCallerAddress(user);
        vm.prank(user);
        ownable.mustOwner();
    }
}

// Mock CrossChainOwnable_Arbitrum contract for testing
contract MockCrossChainOwnable_Arbitrum is CrossChainOwnable_Arbitrum {
    function __initialize() external initializer(1) {
        super.__Ownable__initialize();
    }

    function mustOwner() public view onlyOwner returns (bool) {
        return true;
    }
}

// Mock ArbSys contract for testing
contract MockArbSys {
    address public callerAddress;
    bool public isAliased;

    function wasMyCallersAddressAliased() external view returns (bool) {
        return isAliased;
    }

    function myCallersAddressWithoutAliasing() external view returns (address) {
        return callerAddress;
    }

    function setCallerAddress(address _callerAddress) external {
        callerAddress = _callerAddress;
    }

    function setIsAliased(bool _isAliased) external {
        isAliased = _isAliased;
    }
}
