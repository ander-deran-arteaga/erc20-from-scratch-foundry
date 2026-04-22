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

    error MyHelloToken__ADDRESS_0();
    error MyHelloToken__AMOUNT_0();

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function _mint(address to, uint256 amount) internal virtual {
        if (address(0) == to) {
            revert MyHelloToken__ADDRESS_0();
        }
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address to, uint256 amount) public {
        if (to == address(0)) {
            revert MyHelloToken__ADDRESS_0();
        }
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function approve(address spender, uint256 amount) public {
        if (address(0) == spender) {
            revert MyHelloToken__ADDRESS_0();
        }
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public {
        if (from == address(0) || to == address(0)) {
            revert MyHelloToken__ADDRESS_0();
        }
        allowance[from][to] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
}
