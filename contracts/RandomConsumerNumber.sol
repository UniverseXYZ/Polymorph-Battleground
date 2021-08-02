pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomNumberConsumer is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    uint256 internal poolsCount;

    mapping(uint256 => WagerPoolRandoms) public wagerPoolsRandomNumbers; // index => WagerPoolRandoms

    struct WagerPoolRandoms {
        uint256 randomNumber;
        uint256 wager;
    }

    /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Rinkeby
     * Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK token address:                0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */
     // TODO:: those should be moved into .env ??
    constructor(uint256[] memory pools)
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
        ) public
    {
        require(pools.length != 0, "You must pass wager pools");
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        poolsCount = pools.length;
        initPoolsRandomNumbers(pools);
    }

    /// @notice For every wager in the pools [] instantiate WagerPoolRandoms which will hold the random number for the particular wager pool
    /// @notice so that we can use those randoms later when we conduct the battles for particular wager pool
    /// @param pools An array with wagers in wei [1000000000000000, 2000000000000000, 3000000000000000]
    function initPoolsRandomNumbers(uint256[] memory pools) internal {
        for(uint256 i = 0; i <= pools.length - 1; i++) {
            uint256 poolWager = pools[i];
            WagerPoolRandoms memory randoms = WagerPoolRandoms({
                wager: poolWager,
                randomNumber: 0
            });
            wagerPoolsRandomNumbers[i] = randoms;
        }
    }


    /**
     * Requests randomness
     */
    function getRandomNumber() internal returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual override {
        randomResult = randomness;
        uint256[] memory randoms = expand(randomness, poolsCount);
        for (uint256 i = 0; i <= randoms.length - 1; i++) {
            WagerPoolRandoms storage wagerPoolRandom = wagerPoolsRandomNumbers[i];
            wagerPoolRandom.randomNumber = randoms[i];
        }
    }

    /**
     * Derives n more random numbers from that number
     */
    function expand(uint256 randomValue, uint256 n) internal pure returns (uint256[] memory expandedValues) {
        expandedValues = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
        }
        return expandedValues;
    }
}