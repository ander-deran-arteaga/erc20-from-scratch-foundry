// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyHelloToken {

    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply = 1000;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    error MyHelloToken__ADDRESS_0();
    error MyHelloToken__AMOUNT_0();

    constructor (string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function _mint(address to, uint256 amount) internal virtual {
        if (address (0) == to)
            revert MyHelloToken__ADDRESS_0();
        if (amount == 0)
            revert MyHelloToken__AMOUNT_0();
        balanceOf[to] = amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }
}