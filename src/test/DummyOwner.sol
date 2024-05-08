// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ILaunchpad {
    function transferOwnership(address newOwner) external;
    function start(address _pod) external;
    function stop(address _pod) external;
}

contract DummyOwner is ILaunchpad {
    ILaunchpad public launchpad;

    constructor(address _launchpad) {
        launchpad = ILaunchpad(_launchpad);
    }

    function transferOwnership(address newOwner) external override {
        launchpad.transferOwnership(newOwner);
    }

    function start(address _pod) external override {
        launchpad.start(_pod);
    }

    function stop(address _pod) external override {
        launchpad.stop(_pod);
    }
}
