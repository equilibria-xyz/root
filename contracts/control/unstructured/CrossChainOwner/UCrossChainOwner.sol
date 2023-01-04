// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Address.sol";
import "../CrossChainOwnable/UCrossChainOwnable.sol";

/**
 * @title UCrossChainOwner
 * @notice Contract to act as an owner of other contracts
 * @dev This contract is designed to act as an owner of any Ownable contract, allowing
 *      Cross Chain Ownership without modification to the underlying ownable contract
 */
abstract contract UCrossChainOwner is UCrossChainOwnable {
    function initialize() external initializer(1) {
        super.__UOwnable__initialize();
    }

    function execute(
        address payable to,
        bytes memory data,
        uint256 value
    ) payable external onlyOwner returns (bytes memory ret) {
        if (data.length == 0) {
            Address.sendValue(to, value);
        } else {
            ret = Address.functionCallWithValue(to, data, value);
        }
    }
}
