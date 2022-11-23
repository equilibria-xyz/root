// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../IToken.sol";
import "../unstructured/IToken.sol";

/**
 * @title Token
 * @notice
 * @dev
 */
abstract contract Token is IToken, ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) { }

    function totalSupply() public view returns (UFixed18) {
        return UFixed18.wrap(super.totalSupply());
    }

    function balanceOf(address account) public view virtual override returns (UFixed18) {
        return UFixed18.wrap(super.balanceOf(account));
    }

    function transfer(address to, UFixed18 amount) public virtual override returns (bool) {
        return super.transfer(to, UFixed18.unwrap(amount));
    }

    function allowance(address owner, address spender) public view virtual override returns (UFixed18) {
        return UFixed18.wrap(super.allowance(owner, spender));
    }

    function approve(address spender, UFixed18 amount) public virtual override returns (bool) {
        return super.approve(spender, UFixed18.unwrap(amount));
    }

    function transferFrom(address from, address to, UFixed18 amount) public virtual override returns (bool) {
        return super.transferFrom(from, to, UFixed18.unwrap(amount));
    }

    function increaseAllowance(address spender, UFixed18 addedValue) public virtual override returns (bool) {
        return super.increaseAllowance(spender, UFixed18.unwrap(addedValue));
    }

    function decreaseAllowance(address spender, UFixed18 subtractedValue) public virtual override returns (bool) {
        return super.decreaseAllowance(spender, UFixed18.unwrap(subtractedValue));
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        super._transfer(from, to, UFixed18.wrap(amount));
    }

    function _transfer(address from, address to, UFixed18 amount) internal virtual { }

    function _mint(address account, uint256 amount) internal override {
        super._mint(account, UFixed18.wrap(amount));
    }

    function _mint(address account, UFixed18 amount) internal virtual { }

    function _burn(address account, uint256 amount) internal virtual override {
        super._burn(account, UFixed18.wrap(amount));
    }

    function _burn(address account, uint256 amount) internal virtual { }

    function _approve(address owner, address spender, uint256 amount) internal virtual override {
        super._approve(account, spender, UFixed18.unwrap(amount));
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual override {
        super._approve(account, spender, UFixed18.unwrap(amount));
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        super._spendAllowance(owner, spender, UFixed18.unwrap(amount));
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

type BalanceStorage is bytes32;
    using BalanceStorageLib for BalanceStorage;
library BalanceStorageLib {
    struct BalanceStoragePointer {
        mapping(address => UFixed18) value;
    }

    function read(BalanceStorage self, address account) internal view returns (UFixed18) {
        return _pointer(self).value[account];
    }

    function store(BalanceStorage self, address account, UFixed18 value) internal {
        _pointer(self).value[account] = value;
    }

    function _pointer(BalanceStorage self) private pure returns (BalanceStoragePointer storage pointer) {
        assembly { pointer.slot := self }
    }
}

type AllowanceStorage is bytes32;
    using AllowanceStorageLib for AllowanceStorage;
library AllowanceStorageLib {
    struct AllowanceStoragePointer {
        mapping(address => mapping(address => UFixed18)) value;
    }

    function read(AllowanceStorage self, address owner, address spender) internal view returns (UFixed18) {
        return _pointer(self).value[owner][spender];
    }

    function store(AllowanceStorage self, address owner, address spender, UFixed18 value) internal {
        _pointer(self).value[owner][spender] = value;
    }

    function _pointer(AllowanceStorage self) private pure returns (AllowanceStoragePointer storage pointer) {
        assembly { pointer.slot := self }
    }
}