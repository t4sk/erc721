// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "forge-std/Test.sol";
import "./Receiver.sol";
import "../src/ERC721.sol";

contract ERC721Test is Test {
    MyNFT nft;
    Receiver receiver;
    address private alice = address(1);
    address private bob = address(2);
    address private carol = address(3);

    function setUp() public {
        nft = new MyNFT();
        receiver = new Receiver();

        nft.mint(alice, 1);
    }

    function testFail_ownerOf_does_not_exist() public view {
        nft.ownerOf(0);
    }

    function test_ownerOf() public {
        assertEq(nft.ownerOf(1), alice);
    }

    function testFail_balanceOf_zero_address() public view {
        nft.balanceOf(address(0));
    }

    function test_balanceOf() public {
        assertEq(nft.balanceOf(msg.sender), 0);
        assertEq(nft.balanceOf(alice), 1);
    }

    function test_setApprovalForAll() public {
        assertTrue(!nft.isApprovedForAll(alice, bob));

        vm.prank(alice);
        nft.setApprovalForAll(bob, true);
        assertTrue(nft.isApprovedForAll(alice, bob));

        vm.prank(alice);
        nft.setApprovalForAll(bob, false);
        assertTrue(!nft.isApprovedForAll(alice, bob));
    }

    function testFail_approve_not_authorized() public {
        vm.prank(bob);
        nft.approve(carol, 1);
    }

    function test_approve_owner() public {
        assertEq(nft.getApproved(1), address(0));
        vm.prank(alice);
        nft.approve(bob, 1);
        assertEq(nft.getApproved(1), bob);
    }

    function test_approve_operator() public {
        vm.prank(alice);
        nft.setApprovalForAll(bob, true);

        vm.prank(bob);
        nft.approve(carol, 1);

        assertEq(nft.getApproved(1), carol);
    }

    function testFail_getApproved() public view {
        nft.getApproved(0);
    }

    function testFail_transferFrom_token_does_not_exist() public {
        vm.prank(alice);
        nft.transferFrom(alice, bob, 0);
    }

    function test_transferFrom_owner() public {
        vm.prank(alice);
        nft.transferFrom(alice, bob, 1);

        assertEq(nft.balanceOf(alice), 0);
        assertEq(nft.balanceOf(bob), 1);
        assertEq(nft.ownerOf(1), bob);
        assertEq(nft.getApproved(1), address(0));
    }

    function test_transferFrom_approved() public {
        vm.prank(alice);
        nft.approve(bob, 1);

        vm.prank(bob);
        nft.transferFrom(alice, bob, 1);

        assertEq(nft.balanceOf(alice), 0);
        assertEq(nft.balanceOf(bob), 1);
        assertEq(nft.ownerOf(1), bob);
        assertEq(nft.getApproved(1), address(0));
    }

    function test_transferFrom_approved_for_all() public {
        vm.prank(alice);
        nft.setApprovalForAll(bob, true);

        vm.prank(bob);
        nft.transferFrom(alice, bob, 1);

        assertEq(nft.balanceOf(alice), 0);
        assertEq(nft.balanceOf(bob), 1);
        assertEq(nft.ownerOf(1), bob);
        assertEq(nft.getApproved(1), address(0));
    }

    function testFail_transferFrom_from_not_owner() public {
        vm.prank(alice);
        nft.transferFrom(bob, bob, 1);
    }

    function testFail_transferFrom_to_zero_address() public {
        vm.prank(alice);
        nft.transferFrom(alice, address(0), 1);
    }

    function test_safeTransferFrom() public {
        vm.prank(alice);
        nft.safeTransferFrom(alice, address(receiver), 1, "test data");

        assertEq(receiver.operator(), alice);
        assertEq(receiver.from(), alice);
        assertEq(receiver.tokenId(), 1);
        assertEq0(receiver.data(), bytes("test data"));
    }

    function testFail_safeTransferFrom() public {
        receiver.setFail(true);

        vm.prank(alice);
        nft.safeTransferFrom(alice, address(receiver), 1, "test data");
    }
}
