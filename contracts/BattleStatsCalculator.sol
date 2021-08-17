//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
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
        uint256 genePos;
        uint256 itemIndex;
    }

    address private daoAddress;
    mapping(uint8 => uint8) private itemsCountByTypeMap;
    mapping(uint256 => mapping(uint256 => Item)) private items; // GeneIndex => ItemIndex => Item
    uint256 private genePairsCount = 9; // To be configurable

    constructor(address _daoAddress) {
        itemsCountByTypeMap[0] = 11;
        itemsCountByTypeMap[1] = 12;
        itemsCountByTypeMap[2] = 33;
        itemsCountByTypeMap[3] = 34;
        itemsCountByTypeMap[4] = 25;
        itemsCountByTypeMap[5] = 13;
        itemsCountByTypeMap[6] = 31;
        itemsCountByTypeMap[7] = 32;
        itemsCountByTypeMap[8] = 32;
        daoAddress = _daoAddress;
    }

    function getStats(uint256 gene, uint256 skillType) public view returns (uint256, uint256) {
        uint256[] memory genePairs = PolymorphGeneParser.splitGeneToPairs(gene, genePairsCount);
        uint256 min;
        uint256 max;

        for (uint8 geneIndex = 0; geneIndex <= genePairs.length - 1; geneIndex++) {
            uint256 genePair = genePairs[geneIndex];
            uint256 itemIndex = genePair % itemsCountByTypeMap[geneIndex];

            Item memory i = items[geneIndex][itemIndex];

            max = max.add(skillType == uint(BattleStances.ATTACK) ? i.aMax : i.dMax);
            min = min.add(skillType == uint(BattleStances.ATTACK) ? i.aMin : i.dMin);
        }

        return (min, max);
    }

    /// @notice initialize items mapping
    /// @param _itemsArr Item[]
    /// @param _itemsArr Item.genePosition
    /// @param _itemsArr Item.itemIndex
    /// @param _itemsArr Item.aMin
    /// @param _itemsArr Item.aMax
    /// @param _itemsArr Item.dMin
    /// @param _itemsArr Item.dMax
    function initItems(Item[]memory _itemsArr) public {
        require(msg.sender == daoAddress, "Not called from the dao");

        for(uint256 index = 0; index < _itemsArr.length; index ++) {
            Item memory i = _itemsArr[index];
            items[i.genePos][i.itemIndex] = i;
        }
    }
}