// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ILaunchpad {
    enum Status {
        None,
        Normal,
        Stopped
    }

    event ApplyPod(uint256 indexed projectId, address indexed pod);
    event StopPod(address indexed pod);
    event ResumePod(address indexed pod);

    function project() external view returns (address);
    function ioIDStore() external view returns (address);
    function getPod(uint256 _projectId) external view returns (address);
    function status(address _pod) external view returns (Status);

    function applyPod(
        uint256 _projectId,
        string calldata name,
        string calldata symbol,
        uint256 _amount,
        uint256 _price,
        uint256 _startTime
    ) external returns (address);
    function stop(address _pod) external;
    function resume(address _pod) external;
    function setPodBaseURI(address _pod, string calldata _baseURI) external;

    function withdraw(address _pod, address _recipient, uint256 _amount) external;
}
