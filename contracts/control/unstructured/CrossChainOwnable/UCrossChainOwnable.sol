// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/crosschain/CrossChainEnabled.sol";
import "../UOwnable.sol";
import "../../../storage/UStorage.sol";

/**
 * @title UCrossChainOwnable
 * @notice Library to manage the cross-chain ownership lifecycle of upgradeable contracts.
 * @dev This contract has been extended from the Open Zeppelin library to include an
 *      unstructured storage pattern so that it can be safely mixed in with upgradeable
 *      contracts without affecting their storage patterns through inheritance.
 *
 *      Upon initialization, the `owner` will be set to the `msg.sender` of the initialize method.
 *      Ownership should then be transferred to the cross-chain owner via the `updatePendingOwner`
 *      and `acceptedPending` owner methods. Upon accepting ownership via the cross-chain address,
 *      a fuse will be tripped, preventing same-chain ownership going forward.
 */
abstract contract UCrossChainOwnable is UOwnable, CrossChainEnabled {
    BoolStorage private constant _crossChainRestricted = BoolStorage.wrap(keccak256("equilibria.root.UCrossChainOwnable.crossChainRestricted"));
    function crossChainRestricted() public view returns (bool) { return _crossChainRestricted.read(); }

    function _beforeAcceptOwner() internal override {
        if (!crossChainRestricted()) _crossChainRestricted.store(true);
    }

    function _sender() internal view override returns (address) {
        if (crossChainRestricted()) return _crossChainSender();
        return msg.sender;
    }
}
