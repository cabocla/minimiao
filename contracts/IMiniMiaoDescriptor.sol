// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMiniMiaoDescriptor {
    function tokenURI(uint256 _tokenId, string memory tokenHash)
        external
        view
        returns (string memory);
}
