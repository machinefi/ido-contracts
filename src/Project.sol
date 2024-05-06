// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IProject.sol";
import "./interfaces/ILaunchpad.sol";

interface IMintableNFT {
    function mint(address _to) external returns (uint256);
}

contract Project is IProject {
    address public override launchpad;
    uint256 public override wsProjectId;
    address public override nft;
    uint256 public override price;
    uint256 public override total;
    address public override operator;
    uint256 public override soldAmount;

    constructor() {
        launchpad = msg.sender;
    }

    function initialize(uint256 _wsProjectId, address _nft, uint256 _price, uint256 _total, address _operator)
        external
    {
        require(launchpad == msg.sender, "only launchpad");

        wsProjectId = _wsProjectId;
        nft = _nft;
        price = _price;
        total = _total;
        operator = _operator;
    }

    function changeOperator(address _operator) external override {
        require(_operator != address(0), "zero address");
        require(operator == msg.sender, "only operator");

        operator = _operator;
        emit ChangeOperator(_operator);
    }

    function withdraw(address _recipient, uint256 _amount) external {
        require(launchpad == msg.sender, "only launchpad");

        (bool success,) = _recipient.call{value: _amount}("");
        require(success, "withdraw fail");

        emit Withdrawn(_recipient, _amount);
    }

    function buy(address _account, uint256 _amount) external payable override {
        require(_amount > 0, "zero amount");
        require(_account != address(0), "zero address");
        require(soldAmount + _amount <= total, "insufficient nft");
        require(ILaunchpad(launchpad).status(address(this)) == ILaunchpad.Status.Selling, "invalid status");
        require(msg.value >= _amount * price, "insufficient fund");

        for (uint256 i = 0; i < _amount; i++) {
            uint256 _tokenId = IMintableNFT(nft).mint(_account);

            emit Bought(_tokenId);
        }
        soldAmount += _amount;
    }
}
