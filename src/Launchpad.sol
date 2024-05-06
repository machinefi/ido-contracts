// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/ILaunchpad.sol";

contract Launchpay is ILaunchpad {
    function ioIDFactory() external view override returns (address) {}

    function applyProject(
        uint256 _wsProjectId,
        address _nft,
        uint256 _amount,
        uint256 _price
    ) external override returns (address) {}

    function start(address _project) external override {}

    function stop(address _project) external override {}
}
