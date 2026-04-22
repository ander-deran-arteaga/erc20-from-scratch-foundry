// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyHelloToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply = 1000;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    error MyHelloToken__ZeroAddress();

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function _mint(address to, uint256 amount) internal virtual {
        if (address(0) == to) {
            revert MyHelloToken__ZeroAddress();
        }
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        if (address(0) == from) {
            revert MyHelloToken__ZeroAddress();
        }
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        if (to == address(0)) {
            revert MyHelloToken__ZeroAddress();
        }
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        if (address(0) == spender) {
            revert MyHelloToken__ZeroAddress();
        }
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        if (from == address(0) || to == address(0)) {
            revert MyHelloToken__ZeroAddress();
        }
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= amount;
        }
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        if (spender == address(0)) {
            revert MyHelloToken__ZeroAddress();
        }
        allowance[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
    }

    function decreaseAllowance(address spender, uint256 substractValue) public returns (bool) {
        if (spender == address(0)) {
            revert MyHelloToken__ZeroAddress();
        }
        allowance[msg.sender][spender] -= substractValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
    }
}
