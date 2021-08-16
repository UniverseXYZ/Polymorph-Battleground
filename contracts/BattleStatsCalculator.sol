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
    /// @param _itemsArr uint256[][] array
    /// @param _itemsArr uint256[][0] genePosition
    /// @param _itemsArr uint256[][1] itemIndex
    /// @param _itemsArr uint256[][2] aMin
    /// @param _itemsArr uint256[][3] aMax
    /// @param _itemsArr uint256[][4] dMin
    /// @param _itemsArr uint256[][5] dMax
    function initItems(uint256[][] memory _itemsArr) public {
        require(msg.sender == daoAddress, "Not called from the dao");

        for(uint256 index = 0; index < _itemsArr.length; index ++) {
            uint256[] memory i = _itemsArr[index];
            items[i[0]][i[1]] = Item(i[2], i[3], i[4], i[5]);
        }
    }
}