// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPodProxy {
    function buy(address _token, address _pod, address _account, uint256 _amount) external payable;
}
