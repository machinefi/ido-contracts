// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPod {
    event Initialize(uint256 indexed projectId, uint256 price, uint256 total, address operator);
    event ExtendPod(uint256 indexed amount);
    event ChangeOperator(address indexed operator);
    event Withdrawn(address indexed account, uint256 amount);
    event Bought(uint256 indexed tokenId);
    event SetTokenURIProvider(address indexed tokenURIProvider);

    function launchpad() external view returns (address);
    function projectId() external view returns (uint256);
    function price() external view returns (uint256);
    function total() external view returns (uint256);
    function endTime() external view returns (uint256);
    function operator() external view returns (address);
    function soldAmount() external view returns (uint256);
    function tokenURIProvider() external view returns (address);

    function initialize(
        string calldata _name,
        string calldata _symbol,
        uint256 _projectId,
        uint256 _price,
        uint256 _total,
        address _operator
    ) external;

    function changeOperator(address _operator) external;
    function extend(uint256 _amount) external;
    function withdraw(address _recipient, uint256 _amount) external;
    function setTokenURIProvider(address _provider) external;

    function buy(address _account, uint256 _amount) external payable;
}
