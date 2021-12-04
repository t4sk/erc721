// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "../IERC721.sol";

contract Receiver is IERC721Receiver {
    address public operator;
    address public from;
    uint public tokenId;
    bytes public data;

    bool public fail;

    function setFail(bool _fail) external {
        fail = _fail;
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint _tokenId,
        bytes calldata _data
    ) external override returns (bytes4) {
        operator = _operator;
        from = _from;
        tokenId = _tokenId;
        data = _data;

        if (fail) {
            return bytes4(0);
        }

        return IERC721Receiver.onERC721Received.selector;
    }
}
