// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Ownable, Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

/**
 * @title ProxyOwner
 * @notice ProxyAdmin with 2-step ownership transfer
 * @dev Adds 2-step ownership transfer to the OpenZeppelin ProxyAdmin contract for the owner of the ProxyAdmin.
 */
contract ProxyOwner is ProxyAdmin, Ownable2Step {
    // sig: 0xd8921f35
    /// @custom:error Caller is not the pending admin
    error ProxyOwnerNotPendingAdminError();

    /// @dev Specify deployer as the initial owner
    constructor() ProxyAdmin(msg.sender) {}

    function transferOwnership(address newOwner) public override(Ownable, Ownable2Step) {
        super.transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal override(Ownable, Ownable2Step) {
        super._transferOwnership(newOwner);
    }
}
