// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../../control/unstructured/UInitializable.sol";
import "../../storage/UStorage.sol";
import "../IToken.sol";

/**
 * @title UToken
 * @notice
 * @dev
 */
abstract contract UToken is IToken, UInitializable {
    StringStorage private constant _name =
        StringStorage.wrap(keccak256("equilibria.root.UToken.name"));
    StringStorage private constant _symbol =
        StringStorage.wrap(keccak256("equilibria.root.UToken.symbol"));

    UFixed18Storage private constant _totalSupply =
        UFixed18Storage.wrap(keccak256("equilibria.root.UToken.totalSupply"));
    BalanceStorage private constant _balances =
        BalanceStorage.wrap(keccak256("equilibria.root.UToken.balances"));
    AllowanceStorage private constant _allowances =
        AllowanceStorage.wrap(keccak256("equilibria.root.UToken.allowances"));

    function __UToken__initialize(string memory name_, string memory symbol_) internal onlyInitializer {
        _name.store(name_);
        _symbol.store(symbol_);
    }

    function name() public view virtual override returns (string memory) {
        return _name.read();
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol.read();
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (UFixed18) {
        return _totalSupply.read();
    }

    function balanceOf(address account) public view virtual override returns (UFixed18) {
        return _balances.read(account);
    }

    function transfer(address to, UFixed18 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (UFixed18) {
        return _allowances.read(owner, spender);
    }

    function approve(address spender, UFixed18 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, UFixed18 amount) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, UFixed18 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender).add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, UFixed18 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        UFixed18 currentAllowance = allowance(owner, spender);
        require(currentAllowance.gte(subtractedValue), "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance.sub(subtractedValue));
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        UFixed18 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        UFixed18 fromBalance = _balances.read(from);
        require(fromBalance.gte(amount), "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances.store(from, fromBalance.sub(amount));
        }
        _balances.store(to, _balances.read(to).add(amount));

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, UFixed18 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply.store(totalSupply().add(amount));
        _balances.store(account, _balances.read(account).add(amount));
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, UFixed18 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        UFixed18 accountBalance = _balances.read(account);
        require(accountBalance.gte(amount), "ERC20: burn amount exceeds balance");
        unchecked {
            _balances.store(account, accountBalance.sub(amount));
        }
        _totalSupply.store(totalSupply().sub(amount));

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        UFixed18 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances.store(owner, spender, amount);
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        UFixed18 amount
    ) internal virtual {
        UFixed18 currentAllowance = allowance(owner, spender);
        if (!currentAllowance.eq(UFixed18Lib.MAX)) {
            require(currentAllowance.gte(amount), "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance.sub(amount));
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        UFixed18 amount
    ) internal virtual { }

    function _afterTokenTransfer(
        address from,
        address to,
        UFixed18 amount
    ) internal virtual { }
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