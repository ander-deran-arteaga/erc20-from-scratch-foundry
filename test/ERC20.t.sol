// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MyHelloToken} from "../src/ScratchERC20.sol";
import {Test, console} from "forge-std/Test.sol";

contract ScratchERC20Harness is MyHelloToken {
    constructor(string memory n, string memory s, uint8 d) MyHelloToken(n, s, d) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract MyHelloTokenTest is Test {
    ScratchERC20Harness public token;

    uint8 public constant DECIMALS = 9;

    address alice = makeAddr("ALICE");
    address bob = makeAddr("BOB");

    function setUp() public {
        token = new ScratchERC20Harness("TEMPERC20", "E20", 9);
    }

    function testEx1() public view {
        assert(keccak256(abi.encodePacked(token.name())) == keccak256(abi.encodePacked("TEMPERC20")));
        assert(keccak256(abi.encodePacked(token.symbol())) == keccak256(abi.encodePacked("E20")));
        assert(token.decimals() == DECIMALS);
    }

    function testEx2() public {
        uint256 amount = 5;
        uint256 totalSupplyBef = token.totalSupply();

        vm.expectEmit(true, true, false, true);
        emit MyHelloToken.Transfer(address(0), alice, amount);
        token.mint(alice, amount);
        assertEq(token.totalSupply(), totalSupplyBef + amount);
        assertEq(token.balanceOf(alice), amount);
        vm.expectRevert();
        token.mint(address(0), amount);
    }

    function testEx3() public {
        uint256 amount = 5;
        uint256 totalSupplyBef = token.totalSupply();
        uint256 balanceAliceBef;
        uint256 balanceBobBef = token.balanceOf(bob);

        token.mint(alice, amount);
        balanceAliceBef = token.balanceOf(alice);
        vm.expectEmit(true, true, false, true);
        emit MyHelloToken.Transfer(alice, bob, amount);
        vm.prank(alice);
        token.transfer(bob, amount);
        assertEq(token.balanceOf(bob), balanceBobBef + amount);
        assertEq(token.balanceOf(alice), balanceAliceBef - amount);
    }

    function testEx5() public {
        uint256 amount = 5;

        vm.prank(alice);
        token.approve(bob, amount);
        assertEq(token.allowance(alice, bob), amount);
        // to prove it doesn't stack
        vm.prank(alice);
        token.approve(bob, amount);
        assertEq(token.allowance(alice, bob), amount);
    }
}
