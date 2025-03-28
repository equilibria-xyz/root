// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Mock contract for testing that receives funds.
contract MockReceiver {
    address public owner;

    function setOwner(address _owner) public {
        owner = _owner;
    }

    function receiveFunds() public payable {}

    receive() external payable {}
}
