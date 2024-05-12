// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IPod.sol";
import "./interfaces/ILaunchpad.sol";
import "./interfaces/IioIDStore.sol";
import "./interfaces/ITokenURIProvider.sol";
import "./ERC721.sol";

contract Pod is IPod, ERC721 {
    uint256 nextTokenId;
    address public override launchpad;
    uint256 public override projectId;
    uint256 public override price;
    uint256 public override total;
    uint256 public override endTime;
    address public override operator;
    uint256 public override soldAmount;
    address public override tokenURIProvider;

    constructor() {
        launchpad = msg.sender;
    }

    function initialize(
        string calldata _name,
        string calldata _symbol,
        uint256 _projectId,
        uint256 _price,
        uint256 _total,
        address _operator
    ) external {
        require(launchpad == msg.sender, "only launchpad");

        ERC721.initialize(_name, _symbol);
        projectId = _projectId;
        price = _price;
        total = _total;
        operator = _operator;
        emit Initialize(_projectId, _price, _total, _operator);
    }

    function changeOperator(address _operator) external override {
        require(_operator != address(0), "zero address");
        require(operator == msg.sender, "only operator");

        operator = _operator;
        emit ChangeOperator(_operator);
    }

    function extend(uint256 _amount) external {
        require(_amount > 0, "zero amount");
        require(operator == msg.sender, "only operator");
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
        require(_amount > 0, "zero amount");
        require(_account != address(0), "zero address");
        require(soldAmount + _amount <= total, "insufficient nft");
        require(ILaunchpad(launchpad).status(address(this)) == ILaunchpad.Status.Selling, "invalid status");
        require(msg.value >= _amount * price, "insufficient fund");

        for (uint256 i = 0; i < _amount; i++) {
            uint256 _tokenId = ++nextTokenId;
            _mint(_account, _tokenId);

            emit Bought(_tokenId);
        }
        soldAmount += _amount;
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return ITokenURIProvider(tokenURIProvider).tokenURI(id);
    }
}
