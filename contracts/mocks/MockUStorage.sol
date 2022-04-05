// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../storage/UStorage.sol";

contract MockUStorage {
    function readBool(BoolStorage slot) external view returns (bool) {
        return slot.read();
    }

    function storeBool(BoolStorage slot, bool value) external {
        slot.store(value);
    }

    function readUint256(Uint256Storage slot) external view returns (uint256) {
        return slot.read();
    }

    function storeUint256(Uint256Storage slot, uint256 value) external {
        slot.store(value);
    }

    function readInt256(Int256Storage slot) external view returns (int256) {
        return slot.read();
    }

    function storeInt256(Int256Storage slot, int256 value) external {
        slot.store(value);
    }

    function readAddress(AddressStorage slot) external view returns (address) {
        return slot.read();
    }

    function storeAddress(AddressStorage slot, address value) external {
        slot.store(value);
    }

    function readBytes32(Bytes32Storage slot) external view returns (bytes32) {
        return slot.read();
    }

    function storeBytes32(Bytes32Storage slot, bytes32 value) external {
        slot.store(value);
    }
}
