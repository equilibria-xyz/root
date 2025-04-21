// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { Initializable } from "src/attribute/Initializable.sol";
import { IProxy } from "./interfaces/IProxy.sol";
import { Ownable } from "../../src/attribute/Ownable.sol";
import { Version, VersionLib } from "../../src/attribute/types/Version.sol";

contract ProxyAdmin is Ownable {
    event PauserUpdated(address indexed newPauser);

    // sig: 0x108c51dc
    /// @custom:error Caller unauthorized to pause/unpause the proxied contract
    error ProxyAdminNotOwnerOrPauserError(address sender);

    constructor() Ownable("ProxyAdmin", VersionLib.from(0,0,0), VersionLib.from(0,0,0)) {}

    /// @dev The pauser address
    address private _pauser;
    function pauser() public view returns (address) {
        return _pauser;
    }

    /// @notice Sets initial owner to the sender
    function initialize(bytes memory)
        external override initializer(VersionLib.from(0,0,0))
    {
        __Ownable__initialize();
    }

    function updatePauser(address newPauser) public onlyOwner {
        _pauser = newPauser;
        emit PauserUpdated(newPauser);
    }

    /// @notice Upgrades the implementation of a proxy and optionally calls its initializer
    /// @param proxy Target to upgrade
    /// @param implementation New version of contract to be proxied
    /// @param data Calldata to invoke the instance's initializer
    function upgradeToAndCall(
        IProxy proxy,
        Initializable implementation,
        bytes memory data
    ) public payable virtual onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }

    /// @notice Prevents interaction with the proxied contract
    function pause(IProxy proxy) public ownerOrPauser {
        proxy.pause();
    }

    /// @notice Allows interaction with the proxied contract
    function unpause(IProxy proxy) public ownerOrPauser {
        proxy.unpause();
    }

    modifier ownerOrPauser {
        if (owner() != _sender() && pauser() != _sender()) {
            revert ProxyAdminNotOwnerOrPauserError(_sender());
        }
        _;
    }
}
