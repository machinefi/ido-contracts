// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ILaunchpad {
    enum Status {
        Pending,
        Selling,
        Stopped,
        Sold
    }

    event ApplyProject(uint256 indexed wsProjectId, address indexed nft, address indexed project);
    event StartProject(address indexed project);
    event StopProject(address indexed project);

    function wsProject() external view returns (address);
    function ioIDFactory() external view returns (address);
    function getProject(uint256 _wsProjectId) external view returns (address);
    function status(address _project) external view returns (Status);

    function applyProject(uint256 _wsProjectId, address _nft, uint256 _amount, uint256 _price)
        external
        returns (address);
    function start(address _project) external;
    function stop(address _project) external;

    function withdraw(address _project, address _recipient, uint256 _amoun) external;
}
