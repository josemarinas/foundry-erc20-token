// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {ERC20} from "../src/ERC20.sol";

contract ERC20Test is Test {
    ERC20 public erc20;
    string public name = "Test Token";
    string public symbol = "TT";

    function setUp() public {
        erc20 = new ERC20(name, symbol);
    }

    function testName() public {
        assertEq(erc20.name(), name);
    }

    function testSymbol() public {
        assertEq(erc20.symbol(), symbol);
    }

    function testDecimals() public {
        assertEq(erc20.decimals(), 18);
    }

    function testFuzzMint(uint256 amount) public {
        assertEq(erc20.totalSupply(), 0);
        erc20.mint(address(1), amount);
        assertEq(erc20.totalSupply(), amount);
    }

    function testMintSenderIsNotDeployerError(uint256 amount) public {
        vm.prank(address(1));
        vm.expectRevert(
            abi.encodeWithSelector(ERC20.SenderIsNotDeployer.selector)
        );
        erc20.mint(address(1), amount);
    }

    function testMintInvalidReceiverError(uint256 amount) public {
        address receiver = address(0);
        vm.expectRevert(
            abi.encodeWithSelector(ERC20.InvalidReceiver.selector, receiver)
        );
        erc20.mint(receiver, amount);
    }

    function test_BalanceOf(uint256 amount) public {
        erc20.mint(address(1), amount);
        assertEq(erc20.balanceOf(address(1)), amount);
    }

    function testAllowance(uint256 amount) public {
        assertEq(erc20.allowance(address(1), address(this)), 0);
        erc20.approve(address(1), amount);
        assertEq(erc20.allowance(address(this), address(1)), amount);
    }

    function testFuzzTransfer(uint256 fromBalance, uint256 toBalance, uint256 amount) public {
        vm.assume(fromBalance > amount);
        address from = address(this);
        address to = address(1);
        erc20.mint(from, fromBalance);
        erc20.mint(to, toBalance);
        // vm.expectEmit();
        // emit ERC20.Transfer(from, to, amount);
        erc20.transfer(to, amount);
        assertEq(erc20.balanceOf(from), amount);
        assertEq(erc20.balanceOf(to), toBalance + amount);
    }

    function testTransferInsuficientFounds() public {
        address sender = address(1);
        address receiver = address(2);
        erc20.mint(sender, 1 ether);
        vm.prank(sender);
        vm.expectRevert(
            abi.encodeWithSelector(ERC20.InsufficientFounds.selector)
        );
        erc20.transfer(receiver, 2 ether);
    }

    function testTransferFrom() public {
        erc20.mint(address(1), 1 ether);
        assertEq(erc20.balanceOf(address(1)), 1 ether);
        vm.prank(address(1));
        erc20.approve(address(this), 0.6 ether);
        erc20.transferFrom(address(1), address(2), 0.5 ether);
        assertEq(erc20.balanceOf(address(1)), 0.5 ether);
        assertEq(erc20.balanceOf(address(2)), 0.5 ether);
        assertEq(erc20.allowance(address(1), address(this)), 0.1 ether);
    }

    function testTransferFromInvalidReceiver() public {

    }

    function testTransferFromInsuficientFounds() public {
        address sender = address(1);
        address receiver = address(2);
        erc20.mint(sender, 1 ether);
        vm.prank(sender);
        vm.expectRevert(
            abi.encodeWithSelector(ERC20.InsufficientFounds.selector)
        );
        erc20.transfer(receiver, 2 ether);
    }
}
