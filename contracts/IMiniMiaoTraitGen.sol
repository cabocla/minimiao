// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMiniMiaoTraitGen {
    function genHash(
        uint256 _t,
        address _a,
        uint256 _c
    ) external returns (string memory);
}
