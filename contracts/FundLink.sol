//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IUniswapV3Router.sol";

abstract contract FundLink is ReentrancyGuard {
    using SafeMath for uint256;

    address public linkAddress;
    address public wethAddress;
    uint256 public rngChainlinkCost;
    IUniswapV3Router public uniswapV3Router;

    event LogLinkExchanged(
        uint256 amount,
        uint256 time,
        address initiator
    );

    constructor(address[] memory addresses, uint256 _rngChainlinkCost) {
        linkAddress = addresses[2];
        wethAddress = addresses[3];
        uniswapV3Router = IUniswapV3Router(addresses[1]);
        rngChainlinkCost = _rngChainlinkCost;
    }

    /// @notice gets LINK, so costs can be coverd for RNG generation
    function getLinkForRNGCosts() internal nonReentrant {
        uint256 ethAmount = address(this).balance;
        uint256 linkAmount = rngChainlinkCost;

        uint256 deadline = block.timestamp + 60;
        address tokenIn = wethAddress;
        address tokenOut = linkAddress;
        uint24 fee = 3000;
        address recipient = address(this);
        uint256 amountOut = linkAmount;
        uint256 amountInMaximum = ethAmount;
        uint160 sqrtPriceLimitX96 = 0;

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams(
            tokenIn,
            tokenOut,
            fee,
            recipient,
            deadline,
            amountOut,
            amountInMaximum,
            sqrtPriceLimitX96
        );

        uint256 paidAmount = uniswapV3Router.exactOutputSingle{ value: ethAmount }(params);
        setPaidEthAmountForLinkSwap(paidAmount);
        // In case the user sends more ETH, refund leftover ETH to user
        uniswapV3Router.refundETH();

        emit LogLinkExchanged(linkAmount, block.timestamp, msg.sender);
    }

    // Abstract mehtod needs to be impleneted in order to save the paid amount
    function setPaidEthAmountForLinkSwap(uint256 amount) internal virtual {}
}