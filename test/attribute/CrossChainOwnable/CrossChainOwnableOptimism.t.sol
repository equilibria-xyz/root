// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

import { CrossChainOwnable_Optimism } from "src/attribute/CrossChainOwnable/CrossChainOwnable_Optimism.sol";

contract CrossChainOwnableOptimismTest is Test {
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
    MockCrossChainOwnable_Optimism public ownable;
    MockCrossDomainMessenger public crossDomainMessenger;

    function setUp() public virtual {
        // Setting up the accounts to be used in the tests
        owner = makeAddr("owner");
        xChainOwner = makeAddr("xChainOwner");
        user = makeAddr("user");
        unrelated = makeAddr("unrelated");

        // Deploy MockCrossChainOwnable_Optimism contract
        ownable = new MockCrossChainOwnable_Optimism();

        // Deploy the fake contract (fake crossDomainMessenger for simulation)
        // Using the standard Optimism CrossDomainMessenger address
        bytes memory code = address(new MockCrossDomainMessenger()).code;
        address targetAddr = address(0x4200000000000000000000000000000000000007);

        // Etch the code of fake crossDomainMessenger to Optimism's CrossDomainMessenger address
        vm.etch(targetAddr, code);
        crossDomainMessenger = MockCrossDomainMessenger(targetAddr);

        // Initial setup for testing
        vm.deal(address(crossDomainMessenger), 10 ether);
    }

    function test_ownableInitialize() public {
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

    function test_setPendingOwner() public {
        // Initialize contract
        vm.prank(user);
        ownable.__initialize();

        // Test setting pending owner
        vm.expectEmit(true, true, true, true);
        emit PendingOwnerUpdated(xChainOwner);

        vm.prank(user);
        ownable.updatePendingOwner(xChainOwner);

        assertEq(ownable.owner(), user);
        assertEq(ownable.pendingOwner(), xChainOwner);
    }

    function test_setPendingOwnerNotOwner() public {
        // Initialize contract
        vm.prank(user);
        ownable.__initialize();

        // Simulate call from unrelated user
        vm.expectRevert(abi.encodeWithSelector(OwnableNotOwnerError.selector, unrelated));
        vm.prank(unrelated);
        ownable.updatePendingOwner(unrelated);
    }

    function test_resetPendingOwner() public {
        // Initialize contract
        vm.prank(user);
        ownable.__initialize();

        // Reset pending owner
        vm.expectEmit(true, true, true, true);
        emit PendingOwnerUpdated(address(0));

        vm.prank(user);
        ownable.updatePendingOwner(address(0));

        assertEq(ownable.owner(), user);
        assertEq(ownable.pendingOwner(), address(0));
    }

    function test_acceptOwner() public {
        // Initialize contract and set pending owner
        vm.prank(user);
        ownable.__initialize();
        vm.prank(user);
        ownable.updatePendingOwner(xChainOwner);

        // Simulate accepting the owner by crossDomainMessenger
        crossDomainMessenger.setXDomainMessageSender(xChainOwner);
        vm.expectEmit(true, true, true, true);
        emit OwnerUpdated(xChainOwner);

        vm.prank(address(crossDomainMessenger));
        ownable.acceptOwner();

        assertEq(ownable.owner(), xChainOwner);
        assertEq(ownable.pendingOwner(), address(0));
    }

    function test_acceptOwnerNotCrossChain() public {
        // Initialize contract and set pending owner
        vm.prank(user);
        ownable.__initialize();
        vm.prank(user);
        ownable.updatePendingOwner(xChainOwner);

        // Attempt to accept ownership without cross-chain context
        vm.expectRevert(NotCrossChainCall.selector);
        vm.prank(user);
        ownable.acceptOwner();
    }

    function test_acceptOwnerNotPendingOwner() public {
        // Initialize contract and set pending owner
        vm.prank(user);
        ownable.__initialize();
        vm.prank(user);
        ownable.updatePendingOwner(unrelated);

        // Simulate call from an address that is not the pending owner
        crossDomainMessenger.setXDomainMessageSender(xChainOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableNotPendingOwnerError.selector, xChainOwner));
        vm.prank(address(crossDomainMessenger));
        ownable.acceptOwner();
    }

    function test_onlyOwnerModifier() public {
        // Initialize contract and set pending owner
        vm.prank(user);
        ownable.__initialize();
        vm.prank(user);
        ownable.updatePendingOwner(xChainOwner);

        // Accept ownership via cross-chain message
        crossDomainMessenger.setXDomainMessageSender(xChainOwner);
        vm.prank(address(crossDomainMessenger));
        ownable.acceptOwner();

        // Attempt to access onlyOwner function by non-owner
        crossDomainMessenger.setXDomainMessageSender(user);
        vm.expectRevert(abi.encodeWithSelector(OwnableNotOwnerError.selector, user));
        vm.prank(address(crossDomainMessenger));
        ownable.mustOwner();

        crossDomainMessenger.setXDomainMessageSender(xChainOwner);
        vm.prank(address(crossDomainMessenger));
        ownable.mustOwner();
    }
}

// Mock CrossChainOwnable_Optimism contract for testing
contract MockCrossChainOwnable_Optimism is CrossChainOwnable_Optimism {
    function __initialize() external initializer(1) {
        super.__Ownable__initialize();
    }

    function mustOwner() public view onlyOwner returns (bool) {
        return true;
    }
}

// Mock CrossDomainMessenger contract for testing
contract MockCrossDomainMessenger {
    address public xDomainMessageSenderValue;

    function xDomainMessageSender() external view returns (address) {
        return xDomainMessageSenderValue;
    }

    function setXDomainMessageSender(address _xDomainMessageSender) external {
        xDomainMessageSenderValue = _xDomainMessageSender;
    }
}
