// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IProject {
    function launchpad() external view returns (address);
    function nft() external view returns (address);
    function operator() external view returns (address);

    function changeOperator(address _operator) external;

    function soldAmount() external view returns (uint256);
    function buy(uint256 _amount) external payable;
}
