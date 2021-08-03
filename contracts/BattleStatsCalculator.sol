//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";
import { PolymorphGeneParser } from "./PolymorphGeneParser.sol";

contract BattleStatsCalculator {
    using SafeMath for uint256;

    enum GenePairsIndexes {
        CHARACTER,
        BACKGROUND,
        PANTS,
        TORSO,
        FOOTWEAR,
        EYEWEAR,
        HEAD,
        WEAPON_RIGHT,
        WEAPON_LEFT
    }

    enum BattleStances {
        ATTACK,
        DEFENCE
    }

    struct Item {
        uint256 aMin;
        uint256 aMax;
        uint256 dMin;
        uint256 dMax;
    }

    mapping(uint8 => uint8) private itemsCountByTypeMap;
    mapping(uint256 => mapping(uint256 => Item)) private items; // GeneIndex => ItemIndex => Item
    uint256 private genePairsCount = 9; // To be configurable

    constructor() {
        initItems();
    }

    function getStats(uint256 gene, uint256 skillType) public view returns (uint256, uint256) {
        uint256[] memory genePairs = PolymorphGeneParser.splitGeneToPairs(gene, genePairsCount);
        uint256 min;
        uint256 max;

        for (uint8 geneIndex = 0; geneIndex <= genePairs.length - 1; geneIndex++) {
            uint256 genePair = genePairs[geneIndex];
            uint256 itemIndex = genePair % itemsCountByTypeMap[geneIndex];

            if (skillType == uint(BattleStances.ATTACK)) {
                max = max.add(items[geneIndex][itemIndex].aMax);
                min = min.add(items[geneIndex][itemIndex].aMin);
            }

            if (skillType == uint(BattleStances.DEFENCE)) {
                max = max.add(items[geneIndex][itemIndex].dMax);
                min = min.add(items[geneIndex][itemIndex].dMin);
            }
        }

        return (min, max);
    }

    //TODO:: implement the following methods
    /// @notice Should be able to add new geneIndex in the items mapping (for example if we add an gene for the neck and items (necklace etc..))
    function addItemToMapping(uint8 geneIndex, uint8 itemIndex, uint256 aMin, uint256 aMax, uint256 dMin, uint256 dMax) internal {}

    /// @notice in the future we may want to increase the gene pairs count in order to add include new parts from the body (for example neck)
    function setGenesPairsCount() internal {}

    function initItems() internal {
        // Footwear
        items[uint(GenePairsIndexes.FOOTWEAR)][0] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][1] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][2] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][3] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][4] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][5] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][6] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][7] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][8] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][9] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][10] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][11] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][12] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][13] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][14] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][15] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][16] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][17] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][18] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][19] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][20] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][21] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][22] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][23] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.FOOTWEAR)][24] = Item(2, 5, 2, 5);

        // Character
        items[uint(GenePairsIndexes.CHARACTER)][0] = Item(2, 10, 2, 10);
        items[uint(GenePairsIndexes.CHARACTER)][1] = Item(2, 10, 2, 10);
        items[uint(GenePairsIndexes.CHARACTER)][2] = Item(2, 10, 2, 10);
        items[uint(GenePairsIndexes.CHARACTER)][3] = Item(2, 10, 2, 10);
        items[uint(GenePairsIndexes.CHARACTER)][4] = Item(2, 10, 2, 10);
        items[uint(GenePairsIndexes.CHARACTER)][5] = Item(2, 10, 2, 10);
        items[uint(GenePairsIndexes.CHARACTER)][6] = Item(2, 10, 2, 10);
        items[uint(GenePairsIndexes.CHARACTER)][7] = Item(2, 10, 2, 10);
        items[uint(GenePairsIndexes.CHARACTER)][8] = Item(2, 10, 2, 10);
        items[uint(GenePairsIndexes.CHARACTER)][9] = Item(2, 10, 2, 10);
        items[uint(GenePairsIndexes.CHARACTER)][1] = Item(2, 10, 2, 10);

        // Pants
        items[uint(GenePairsIndexes.PANTS)][0] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][1] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][2] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][3] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][4] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][5] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][6] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][7] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][8] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][9] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][10] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][11] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][12] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][13] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][14] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][15] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][16] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][17] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][18] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][19] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][20] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][21] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][22] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][23] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][24] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][25] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][26] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][27] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][28] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][29] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][30] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][31] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.PANTS)][32] = Item(2, 5, 2, 5);

        // TORSO
        items[uint(GenePairsIndexes.TORSO)][0] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][1] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][2] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][3] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][4] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][5] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][6] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][7] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][8] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][9] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][10] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][11] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][12] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][13] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][14] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][15] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][16] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][17] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][18] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][19] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][20] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][21] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][22] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][23] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][24] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][25] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][26] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][27] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][28] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][29] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][30] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][31] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][32] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.TORSO)][33] = Item(2, 5, 2, 5);

        // Eyewear
        items[uint(GenePairsIndexes.EYEWEAR)][0] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.EYEWEAR)][1] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.EYEWEAR)][2] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.EYEWEAR)][3] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.EYEWEAR)][4] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.EYEWEAR)][5] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.EYEWEAR)][6] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.EYEWEAR)][7] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.EYEWEAR)][8] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.EYEWEAR)][9] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.EYEWEAR)][10] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.EYEWEAR)][11] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.EYEWEAR)][12] = Item(2, 5, 2, 5);

        // HEAD
        items[uint(GenePairsIndexes.HEAD)][0] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][1] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][2] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][3] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][4] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][5] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][6] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][7] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][8] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][9] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][10] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][11] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][12] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][13] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][14] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][15] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][16] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][17] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][18] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][19] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][20] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][21] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][22] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][23] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][24] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][25] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][26] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][27] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][28] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][29] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.HEAD)][30] = Item(2, 5, 2, 5);

        // weapon right
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][0] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][1] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][2] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][3] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][4] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][5] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][6] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][7] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][8] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][9] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][10] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][11] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][12] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][13] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][14] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][15] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][16] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][17] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][18] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][19] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][20] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][21] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][22] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][23] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][24] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][25] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][26] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][27] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][28] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][29] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][30] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_RIGHT)][31] = Item(2, 5, 2, 5);

        // weapon left
        items[uint(GenePairsIndexes.WEAPON_LEFT)][0] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][1] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][2] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][3] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][4] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][5] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][6] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][7] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][8] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][9] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][10] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][11] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][12] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][13] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][14] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][15] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][16] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][17] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][18] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][19] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][20] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][21] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][22] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][23] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][24] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][25] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][26] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][27] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][28] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][29] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][30] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.WEAPON_LEFT)][31] = Item(2, 5, 2, 5);

        // Background
        items[uint(GenePairsIndexes.BACKGROUND)][0] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.BACKGROUND)][1] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.BACKGROUND)][2] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.BACKGROUND)][3] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.BACKGROUND)][4] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.BACKGROUND)][5] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.BACKGROUND)][6] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.BACKGROUND)][7] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.BACKGROUND)][8] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.BACKGROUND)][9] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.BACKGROUND)][10] = Item(2, 5, 2, 5);
        items[uint(GenePairsIndexes.BACKGROUND)][11] = Item(2, 5, 2, 5);

        // itemsCountByTypeMap
        itemsCountByTypeMap[0] = 11;
        itemsCountByTypeMap[1] = 12;
        itemsCountByTypeMap[2] =  33;
        itemsCountByTypeMap[3] = 34;
        itemsCountByTypeMap[4] = 25;
        itemsCountByTypeMap[5] = 13;
        itemsCountByTypeMap[6] = 31;
        itemsCountByTypeMap[7] = 32;
        itemsCountByTypeMap[8] = 32;
    }
}