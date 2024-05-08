// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DummyERC20 is ERC20 {
    constructor() ERC20("Dummy ERC20", "DERC") {}

    function claim(uint256 _amount) external {
        _mint(msg.sender, _amount);
    }
}
