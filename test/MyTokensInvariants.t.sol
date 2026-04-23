// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MyHelloToken} from "../src/ScratchERC20.sol";
import {Handler} from "./Handler.sol";

contract MyTokenInvariants is Test {
    MyHelloToken token;
    Handler handler;

    function setUp() public {
        token = new MyHelloToken("Test", "TST", 18);
        handler = new Handler(token);

        token.transferOwnership(address(handler));

        targetContract(address(handler));
    }

    // EL INVARIANTE: Debe empezar por "invariant_"
    function invariant_totalSupplyEqualsSumOfBalances() public {
        uint256 total = 0;

        for (uint256 i = 0; i < handler.getActorsCount(); i++) {
            total += token.balanceOf(handler.actors(i));
        }
        assertEq(token.totalSupply(), total + 1000);
    }
}
