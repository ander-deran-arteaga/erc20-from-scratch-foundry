// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MyHelloToken} from "../src/ScratchERC20.sol";
import {Test, console} from "forge-std/Test.sol";

contract MyHelloTokenTest is Test {
    MyHelloToken public token;

    uint8 public constant DECIMALS = 18;

    address alice = makeAddr("ALICE");
    address bob = makeAddr("BOB");

    function setUp() public {
        token = new MyHelloToken("TEMPERC20", "E20", 18);
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

    function testEx6() public {
        uint256 amount = 10;
        uint256 balanceAliceBef;
        uint256 balanceBobBef = token.balanceOf(bob);

        token.mint(alice, amount);
        balanceAliceBef = token.balanceOf(alice);
        vm.prank(alice);
        token.approve(bob, amount);
        assertEq(token.allowance(alice, bob), amount);
        vm.prank(bob);
        token.transferFrom(alice, bob, amount);
        assertEq(token.balanceOf(alice), balanceAliceBef - amount);
        assertEq(token.balanceOf(bob), balanceBobBef + amount);
    }

    function testEx7() public {
        uint256 maxAllowance = type(uint256).max;
        uint256 amount = 10;

        token.mint(alice, amount);
        vm.prank(alice);
        token.approve(bob, maxAllowance);
        vm.prank(bob);
        token.transferFrom(alice, bob, amount / 2);
        assertEq(token.allowance(alice, bob), maxAllowance);
        vm.prank(bob);
        token.transferFrom(alice, bob, amount / 2);
        assertEq(token.allowance(alice, bob), maxAllowance);
    }

    function testEx9() public {
        uint256 amount = 10;
        //increase
        token.mint(alice, amount);
        vm.prank(alice);
        token.approve(bob, amount);
        vm.expectEmit(true, true, true, true);
        emit MyHelloToken.Approval(alice, bob, amount * 2);
        vm.prank(alice);
        token.increaseAllowance(bob, amount);
        assertEq(token.allowance(alice, bob), amount * 2);
        //decrease
        vm.expectEmit(true, true, true, true);
        emit MyHelloToken.Approval(alice, bob, amount);
        vm.prank(alice);
        token.decreaseAllowance(bob, amount);
        assertEq(token.allowance(alice, bob), amount);
    }

    function testEx10() public {
        uint256 amountMint = 10;
        uint256 totalSupplyBef = token.totalSupply();
        uint256 amountBurned = 5;

        token.mint(alice, amountMint);
        vm.expectRevert();
        token.burn(alice, amountBurned * 10);
        token.burn(alice, amountBurned);
        assertEq(token.totalSupply(), (totalSupplyBef + amountMint) - amountBurned);
        assertEq(token.balanceOf(alice), amountMint - amountBurned);
    }

    function testEx11() public {
        uint256 amountMint = 10;

        vm.prank(alice);
        vm.expectRevert(MyHelloToken.MyHelloToken__NotOwner.selector);
        token.transferOwnership(alice);
        // I will be able to do this because I deployed the ERC20 in this contract and
        // I'm calling it with no prank so it means i am calling with the address of this contract
        token.mint(alice, amountMint);
        token.transferOwnership(alice);
        assertEq(token.owner(), alice);
    }

    function testEx12() public {
        uint256 amount = 10;

        token.mint(alice, amount);
        token.pause();
        vm.expectRevert(MyHelloToken.MyHelloToken__Paused.selector);
        vm.prank(alice);
        token.transfer(bob, amount);
        token.unpause();
        vm.prank(alice);
        token.transfer(bob, amount);
        assertEq(token.balanceOf(bob), amount);
        vm.prank(alice);
        vm.expectRevert(MyHelloToken.MyHelloToken__NotOwner.selector);
        token.pause();
    }

    function testEx13andEx14(uint256 feeBps, uint256 amount) public {
        amount = bound(amount, 0, token.balanceOf(alice));
        feeBps = bound(feeBps, 0, 1000);
        address feeRecipient = makeAddr("feeRecipient");

        token.setFeeConfig(feeRecipient, feeBps);
        assertEq(feeRecipient, token.feeRecipient());
        assertEq(feeBps, token.feeBps());
        token.mint(alice, amount);
        vm.prank(alice);
        token.transfer(bob, amount);
        uint256 expectedFee = (amount * feeBps) / 10000;
        assertEq(token.balanceOf(feeRecipient), expectedFee);
        assertEq(token.balanceOf(bob), amount - expectedFee);
        assertEq(token.balanceOf(alice), 0);
        // invariant
        uint256 maxFee = 10000;
        vm.expectRevert(MyHelloToken.MyHelloToken__InvalidFee.selector);
        token.setFeeConfig(feeRecipient, maxFee);
    }

    function testEx16() public {
        uint256 feeBps = 0;
        address feeRecipient;
        uint256 amount;

        token.setFeeConfig(feeRecipient, feeBps);

        token.transfer(alice, amount);
    }
}
