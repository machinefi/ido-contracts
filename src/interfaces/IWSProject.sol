// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IWSProject {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function count() external view returns (uint256);
}
