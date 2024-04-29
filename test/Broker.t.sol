// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {Broker} from "../src/Broker.sol";

contract BrokerTest is Test {
    Broker public broker;

    function setUp() public {
        broker = new Broker();
    }
}
