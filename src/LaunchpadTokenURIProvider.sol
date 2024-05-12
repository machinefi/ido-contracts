// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/ITokenURIProvider.sol";
import "./interfaces/ILaunchpad.sol";

contract LaunchpadTokenURIProvider is ITokenURIProvider {
    event SetBaseURI(address indexed pod, string baseURI);

    mapping(address => string) base;
    address public launchpad;

    constructor() {
        launchpad = msg.sender;
    }

    function setBase(address _pod, string calldata _baseURI) external {
        require(msg.sender == launchpad, "only launchpad");
        require(ILaunchpad(launchpad).status(_pod) != ILaunchpad.Status.None, "invalid pod");

        base[_pod] = _baseURI;
        emit SetBaseURI(_pod, _baseURI);
    }

    function tokenURI(uint256) external view override returns (string memory) {
        return base[msg.sender];
    }
}
