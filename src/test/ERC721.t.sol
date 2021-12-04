// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "ds-test/test.sol";
import "./User.sol";
import "./Receiver.sol";
import "../ERC721.sol";

contract ERC721Test is DSTest {
    ERC721 nft;
    address alice;
    address bob;
    address carol;
    Receiver receiver;

    function setUp() public {
        nft = new ERC721();
        alice = address(new User(address(nft)));
        bob = address(new User(address(nft)));
        carol = address(new User(address(nft)));

        nft.mint(alice, 1);

        receiver = new Receiver();
    }

    function testFail_balanceOf_zero_address() public view {
        nft.balanceOf(address(0));
    }

    function test_balanceOf() public {
        assertEq(nft.balanceOf(msg.sender), 0);
        assertEq(nft.balanceOf(alice), 1);
    }

    function testFail_ownerOf_does_not_exist() public view {
        nft.ownerOf(0);
    }

    function test_ownerOf() public {
        assertEq(nft.ownerOf(1), alice);
    }

    function test_setApprovalForAll() public {
        assertTrue(!nft.isApprovedForAll(alice, bob));

        ERC721(alice).setApprovalForAll(bob, true);
        assertTrue(nft.isApprovedForAll(alice, bob));

        ERC721(alice).setApprovalForAll(bob, false);
        assertTrue(!nft.isApprovedForAll(alice, bob));
    }

    function testFail_approve_not_authorized() public {
        ERC721(bob).approve(carol, 1);
    }

    function test_approve_owner() public {
        assertEq(nft.getApproved(1), address(0));
        ERC721(alice).approve(bob, 1);
        assertEq(nft.getApproved(1), bob);
    }

    function test_approve_operator() public {
        ERC721(alice).setApprovalForAll(bob, true);
        ERC721(bob).approve(carol, 1);
        assertEq(nft.getApproved(1), carol);
    }

    function testFail_getApproved() public view {
        nft.getApproved(0);
    }

    function testFail_transferFrom_token_does_not_exist() public {
        ERC721(alice).transferFrom(alice, bob, 0);
    }

    function test_transferFrom_owner() public {
        ERC721(alice).transferFrom(alice, bob, 1);

        assertEq(nft.balanceOf(alice), 0);
        assertEq(nft.balanceOf(bob), 1);
        assertEq(nft.ownerOf(1), bob);
        assertEq(nft.getApproved(1), address(0));
    }

    function test_transferFrom_approved() public {
        ERC721(alice).approve(bob, 1);
        ERC721(bob).transferFrom(alice, bob, 1);

        assertEq(nft.balanceOf(alice), 0);
        assertEq(nft.balanceOf(bob), 1);
        assertEq(nft.ownerOf(1), bob);
        assertEq(nft.getApproved(1), address(0));
    }

    function test_transferFrom_approved_for_all() public {
        ERC721(alice).setApprovalForAll(bob, true);
        ERC721(bob).transferFrom(alice, bob, 1);

        assertEq(nft.balanceOf(alice), 0);
        assertEq(nft.balanceOf(bob), 1);
        assertEq(nft.ownerOf(1), bob);
        assertEq(nft.getApproved(1), address(0));
    }

    function testFail_transferFrom_from_not_owner() public {
        ERC721(alice).transferFrom(bob, bob, 1);
    }

    function testFail_transferFrom_to_zero_address() public {
        ERC721(alice).transferFrom(alice, address(0), 1);
    }

    function test_safeTransferFrom() public {
        ERC721(alice).safeTransferFrom(
            alice,
            address(receiver),
            1,
            "test data"
        );

        assertEq(receiver.operator(), alice);
        assertEq(receiver.from(), alice);
        assertEq(receiver.tokenId(), 1);
        assertEq0(receiver.data(), bytes("test data"));
    }

    function testFail_safeTransferFrom() public {
        receiver.setFail(true);
        ERC721(alice).safeTransferFrom(
            alice,
            address(receiver),
            1,
            "test data"
        );
    }

    function invariant_isApprovedForAll() public {
        assertTrue(!nft.isApprovedForAll(address(0), alice));
    }

    function invariant_ownerOf() public {
        assertTrue(nft.ownerOf(1) != address(0));
    }
}
