// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IPod.sol";
import "./interfaces/ILaunchpad.sol";
import "./interfaces/IioIDStore.sol";
import "./interfaces/ITokenURIProvider.sol";
import "./ERC721.sol";

contract Pod is IPod, ERC721 {
    uint256 public constant DEFAULT_PERIOD = 30 days;
    uint256 public constant DEFAULT_LIMIT = 5;

    uint256 nextTokenId;
    address public override launchpad;
    uint256 public override projectId;
    uint256 public override price;
    uint256 public override total;
    uint256 public override startTime;
    uint256 public override endTime;
    address public override operator;
    uint256 public override soldAmount;
    uint256 public override purchaseLimit;
    address public override tokenURIProvider;
    mapping(address => uint256) public override userBuyAmount;

    constructor() {
        launchpad = msg.sender;
    }

    function initialize(
        string calldata _name,
        string calldata _symbol,
        uint256 _projectId,
        uint256 _price,
        uint256 _total,
        address _operator,
        uint256 _startTime
    ) external {
        require(launchpad == msg.sender, "only launchpad");

        ERC721.initialize(_name, _symbol);
        projectId = _projectId;
        price = _price;
        total = _total;
        operator = _operator;
        startTime = _startTime;
        endTime = _startTime + DEFAULT_PERIOD;
        purchaseLimit = DEFAULT_LIMIT;
        emit Initialize(_projectId, _price, _total, _operator, _startTime, endTime);
    }

    function changeOperator(address _operator) external override {
        require(_operator != address(0), "zero address");
        require(operator == msg.sender, "only operator");

        operator = _operator;
        emit ChangeOperator(_operator);
    }

    function adjustTime(uint256 _startTime, uint256 _endTime) external override {
        require(operator == msg.sender, "only operator");
        require(_endTime > _startTime && _endTime > block.timestamp, "invalid end time");

        if (_startTime >= block.timestamp && _startTime < startTime) {
            startTime = _startTime;
        }
        endTime = _endTime;
        emit AdjustTime(startTime, _endTime);
    }

    function adjustLimit(uint256 _limit) external override {
        require(operator == msg.sender, "only operator");
        require(_limit > 0, "invalid limit");

        purchaseLimit = _limit;
        emit AdjustLimit(_limit);
    }

    function extend(uint256 _amount) external {
        require(operator == msg.sender, "only operator");
        require(_amount > 0, "zero amount");
        require(
            IioIDStore(ILaunchpad(launchpad).ioIDStore()).projectAppliedAmount(projectId) >= total + _amount,
            "exceed bought ioIDs"
        );

        unchecked {
            total += _amount;
        }
        emit ExtendPod(_amount);
    }

    function withdraw(address _recipient, uint256 _amount) external {
        require(launchpad == msg.sender, "only launchpad");

        (bool success,) = _recipient.call{value: _amount}("");
        require(success, "withdraw fail");

        emit Withdrawn(_recipient, _amount);
    }

    function setTokenURIProvider(address _provider) external {
        require(_provider != address(0), "zero address");
        require(launchpad == msg.sender || operator == msg.sender, "only launchpad or operator");

        tokenURIProvider = _provider;
        emit SetTokenURIProvider(_provider);
    }

    function buy(address _account, uint256 _amount) external payable override {
        require(startTime <= block.timestamp, "unstarted");
        require(block.timestamp <= endTime, "stopped");
        require(_amount > 0, "zero amount");
        require(_account != address(0), "zero address");
        require(userBuyAmount[_account] + _amount <= purchaseLimit, "exceed purchase limit");
        require(soldAmount + _amount <= total, "insufficient pod");
        require(ILaunchpad(launchpad).status(address(this)) == ILaunchpad.Status.Normal, "invalid status");
        require(msg.value >= _amount * price, "insufficient fund");

        for (uint256 i = 0; i < _amount; i++) {
            uint256 _tokenId = ++nextTokenId;
            _mint(_account, _tokenId);

            emit Bought(_tokenId);
        }
        soldAmount += _amount;
        userBuyAmount[_account] += _amount;
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return ITokenURIProvider(tokenURIProvider).tokenURI(id);
    }
}
