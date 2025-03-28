// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { CrossChainOwner_Optimism } from "src/attribute/CrossChainOwner/CrossChainOwner_Optimism.sol";

import {
    CrossChainOwnableOptimismTest,
    MockCrossChainOwnable_Optimism
} from "../CrossChainOwnable/CrossChainOwnableOptimism.t.sol";
import { MockReceiver } from "../../utlis/MockReceiver.sol";

contract CrossChainOwnerOptimismTest is CrossChainOwnableOptimismTest {
    function setUp() public override {
        super.setUp();
        address mockCrossChainOwnerAddress = address(new MockCrossChainOwner_Optimism());
        vm.etch(address(ownable), address(mockCrossChainOwnerAddress).code);
    }

    // Internal helper that performs the common setup for tests of execute.
    function _setupExecute() internal {
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

    function test_initialize() public {
        vm.prank(user);
        CrossChainOwner_Optimism(address(ownable)).initialize();
        assertEq(CrossChainOwner_Optimism(address(ownable)).owner(), user, "Owner should be the user");
    }

    function test_sendsFundsIfNoData() public {
        _setupExecute();

        uint256 beforeBalance = user.balance;
        uint256 sendAmount = 1 ether;

        // Deal the crossChainOwner address some funds.
        vm.deal(address(ownable), sendAmount);

        // Execute the call from the crossDomainMessenger address, sending value along.
        vm.prank(address(crossDomainMessenger));
        CrossChainOwner_Optimism(address(ownable)).execute(payable(user), "", sendAmount);

        assertEq(user.balance, beforeBalance + sendAmount, "User should receive the sent funds");
    }

    function test_callsAFunction() public {
        _setupExecute();

        MockReceiver receiver = new MockReceiver();
        assertEq(receiver.owner(), address(0), "Receiver should not have an owner");

        // Execute the call from the crossDomainMessenger address
        vm.prank(address(crossDomainMessenger));
        CrossChainOwner_Optimism(address(ownable)).execute(
            payable(receiver), abi.encodeWithSelector(MockReceiver.setOwner.selector, user), 0
        );

        assertEq(receiver.owner(), user, "User should be the owner of the receiver");
    }

    function test_callsAFunctionWithValue() public {
        _setupExecute();

        MockReceiver receiver = new MockReceiver();
        uint256 beforeBalance = address(receiver).balance;
        uint256 sendAmount = 1 ether;

        // Deal the crossChainOwner address some funds.
        vm.deal(address(ownable), sendAmount);

        // Execute the call from the crossDomainMessenger address, sending value along.
        vm.prank(address(crossDomainMessenger));
        CrossChainOwner_Optimism(address(ownable)).execute(
            payable(receiver), abi.encodeWithSelector(MockReceiver.receiveFunds.selector), sendAmount
        );

        assertEq(address(receiver).balance, beforeBalance + sendAmount, "Receiver should receive the sent funds");
    }
}

// Mock CrossChainOwner_Optimism contract for testing
contract MockCrossChainOwner_Optimism is CrossChainOwner_Optimism, MockCrossChainOwnable_Optimism {}
