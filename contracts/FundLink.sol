//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IUniswapV3Router.sol";

contract FundLink is ReentrancyGuard {
    address private linkAddress;
    address private wethAddress;
    uint256 private rngChainlinkCost;
    IUniswapV3Router private uniswapV3Router;

    event LogLinkExchanged(
        uint256 amount,
        uint256 time,
        address initiator
    );

    constructor(address _uniswapV3Router, address _linkAddress, address _wethAddress, uint256 _rngChainlinkCost) {
        linkAddress = _linkAddress;
        wethAddress = _wethAddress;
        uniswapV3Router = IUniswapV3Router(_uniswapV3Router);
        rngChainlinkCost = _rngChainlinkCost;
    }

    /// @notice converts it to LINK, so costs can be coverd for RNG generation
    /// @param ethAmount ETH amount to swap for link - difference is refunded
    function getLinkForRNGCosts(uint256 ethAmount) internal nonReentrant {
        require(ethAmount > 0, "Must pass non 0 ETH amount");
        uint256 linkAmount = rngChainlinkCost;

        // TODO:: Should we add check if address has enough ETH to be sent for a swap ?

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

        uniswapV3Router.exactOutputSingle{ value: ethAmount }(params);
        // In case the user sends more ETH, refund leftover ETH to user
        uniswapV3Router.refundETH();

        emit LogLinkExchanged(linkAmount, block.timestamp, msg.sender);
    }
}