// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "ds-test/test.sol";
import "../ERC721.sol";

contract ERC721Test is DSTest {
    ERC721 erc;

    function setUp() public {
        erc = new ERC721();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
