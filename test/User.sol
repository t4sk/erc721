// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract User {
    address private nft;

    constructor(address _nft) {
        nft = _nft;
    }

    fallback() external {
        (bool ok, ) = nft.call(msg.data);
        require(ok, "failed");
    }
}
