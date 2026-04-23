// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MyHelloToken} from "../src/ScratchERC20.sol";
import {Test} from "forge-std/Test.sol";

contract Handler is Test {
    MyHelloToken public token;
    address[] public actors;
    uint256 public sumOfBalances;

    constructor(MyHelloToken _token) {
        token = _token;
        actors.push(makeAddr("alice"));
        actors.push(makeAddr("bob"));
        actors.push(makeAddr("charlie"));
    }

    function mint(uint256 actorIndex, uint256 amount) public {
        address victim = actors[bound(actorIndex, 0, actors.length - 1)];
        amount = bound(amount, 0, 1e28);
        token.mint(victim, amount);
        sumOfBalances += amount;
    }

    function transfer(uint256 actorIndex, uint256 toIndex, uint256 amount) public {
        address from = actors[bound(actorIndex, 0, actors.length - 1)];
        address to = actors[bound(toIndex, 0, actors.length - 1)];

        amount = bound(amount, 0, token.balanceOf(from));

        vm.prank(from);
        token.transfer(to, amount);
    }

    function getActorsCount() public view returns (uint256) {
        return actors.length;
    }
}
