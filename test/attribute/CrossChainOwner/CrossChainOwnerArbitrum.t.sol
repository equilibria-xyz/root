// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { CrossChainOwner_Arbitrum } from "src/attribute/CrossChainOwner/CrossChainOwner_Arbitrum.sol";

import {
    CrossChainOwnableArbitrumTest,
    MockCrossChainOwnable_Arbitrum
} from "../CrossChainOwnable/CrossChainOwnableArbitrum.t.sol";
import { MockReceiver } from "../../testutil/MockReceiver.sol";

contract CrossChainOwnerArbitrumTest is CrossChainOwnableArbitrumTest {
    function setUp() public override {
        super.setUp();
        address mockCrossChainOwnerAddress = address(new MockCrossChainOwner_Arbitrum());
        vm.etch(address(ownable), address(mockCrossChainOwnerAddress).code);
    }

    // Internal helper that performs the common setup for tests of execute.
    function _setupExecute() internal {
        // The user calls initialize and updatePendingOwner.
        ownable.__initialize();
        ownable.updatePendingOwner(xChainOwner);

        // Simulate that arbSys (when queried) returns xChainOwner as the “unaliased” caller.
        arbSys.setCallerAddress(xChainOwner);
        arbSys.setIsAliased(true);

        // Now, the arbSys wallet calls acceptOwner.
        vm.prank(address(arbSys));
        ownable.acceptOwner();
    }

    function test_initialize() public {
        vm.prank(user);
        CrossChainOwner_Arbitrum(address(ownable)).initialize();
        assertEq(CrossChainOwner_Arbitrum(address(ownable)).owner(), user, "Owner should be the user");
    }

    function test_sendsFundsIfNoData() public {
        _setupExecute();

        uint256 beforeBalance = user.balance;
        uint256 sendAmount = 1 ether;

        // Deal the crossChainOwner address some funds.
        vm.deal(address(ownable), sendAmount);

        // Execute the call from the arbSys address, sending value along.
        vm.prank(address(arbSys));
        CrossChainOwner_Arbitrum(address(ownable)).execute(payable(user), "", sendAmount);

        assertEq(user.balance, beforeBalance + sendAmount, "User should receive the sent funds");
    }

    function test_callsAFunction() public {
        _setupExecute();

        MockReceiver receiver = new MockReceiver();
        assertEq(receiver.owner(), address(0), "Receiver should not have an owner");

        // Execute the call from the arbSys address
        vm.prank(address(arbSys));
        CrossChainOwner_Arbitrum(address(ownable)).execute(
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

        // Execute the call from the arbSys address, sending value along.
        vm.prank(address(arbSys));
        CrossChainOwner_Arbitrum(address(ownable)).execute(
            payable(receiver), abi.encodeWithSelector(MockReceiver.receiveFunds.selector), sendAmount
        );

        assertEq(address(receiver).balance, beforeBalance + sendAmount, "Receiver should receive the sent funds");
    }
}

// Mock CrossChainOwner_Arbitrum contract for testing
contract MockCrossChainOwner_Arbitrum is CrossChainOwner_Arbitrum, MockCrossChainOwnable_Arbitrum {}
