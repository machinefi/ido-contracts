// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IPodProxy.sol";
import "./interfaces/IPod.sol";

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

interface UniswapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface UniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract PodProxy is IPodProxy {
    using SafeERC20 for IERC20;

    UniswapV2Router public router;

    constructor(address _router) {
        router = UniswapV2Router(_router);
    }

    function buy(address _token, address _pod, address _account, uint256 _amount) external payable override {
        if (_token == address(0)) {
            IPod(_pod).buy{value: msg.value}(_account, _amount);
            return;
        }
        IPod pod = IPod(_pod);
        address weth = router.WETH();
        uint256 fee = pod.price() * _amount;

        if (_token == weth) {
            IERC20(weth).safeTransferFrom(msg.sender, address(this), fee);
            IWETH(weth).withdraw(fee);
            IPod(_pod).buy{value: fee}(_account, _amount);
            return;
        }
        require(UniswapFactory(router.factory()).getPair(_token, weth) != address(0), "no pair");

        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = weth;
        uint256[] memory amounts = router.getAmountsIn(fee, path);
        IERC20(_token).safeTransferFrom(msg.sender, address(this), amounts[0]);
        IERC20(_token).approve(address(router), amounts[0]);
        router.swapTokensForExactETH(fee, amounts[0], path, address(this), block.timestamp);

        IPod(_pod).buy{value: fee}(_account, _amount);
    }

    receive() external payable {}
}
