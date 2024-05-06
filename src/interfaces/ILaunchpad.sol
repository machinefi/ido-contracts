// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ILaunchpad {
    function ioIDFactory() external view returns (address);

    function applyProject(uint256 _wsProjectId, address _nft, uint256 _amount, uint256 _price)
        external
        returns (address);
    function start(address _project) external;
    function stop(address _project) external;
}
