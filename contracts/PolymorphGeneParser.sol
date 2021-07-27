//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract PolymorphGeneParser {
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
        string name;
    }

    struct PolymorphStats {
        uint256 min;
        uint256 max;
    }

    mapping(uint256 => Item) private footwearMap;
    mapping(uint256 => Item) private characterMap;
    mapping(uint256 => Item) private pantsMap;
    mapping(uint256 => Item) private torsoMap;
    mapping(uint256 => Item) private eyewearMap;
    mapping(uint256 => Item) private headMap;
    mapping(uint256 => Item) private weaponRightMap;
    mapping(uint256 => Item) private weaponLeftMap;
    mapping(uint256 => Item) private backgroundMap;
    mapping(string => uint256) private geneIndexByGeneTypeMap;
    mapping(string => uint256) private itemsCountByTypeMap;

    uint256 internal genePairsCount = 9; // each position is 2 digits so its 18 in total

    constructor() {
        initMappings();
    }

    function splitGeneToPairs(uint256 gene) public view returns (uint256[] memory) {
        uint256 genes = gene.mod(10**(genePairsCount * 2)); // => 061151489786639768
        uint256[] memory genePairs = new uint256[](9);
        uint256 index = 0;

        while (genes != 0) {
            uint256 lastDigits = uint256(genes - (genes / 100) * 100); // returns the last 2 digits
            genePairs[index] = lastDigits;
            genes /= 100;
            index = index + 1;
        }
        return genePairs;
    }

    function getStats(uint256 gene, uint256 skillType)
    internal
    view
    returns (uint256 min, uint256 max)
    {
        uint256[] memory genePairs = splitGeneToPairs(gene);
        PolymorphStats memory s = getItemsStats(genePairs, skillType);
        return (s.min, s.max);
    }

    function getItemsStats(uint256[] memory genePairs, uint256 skillType)
    internal
    view
    returns (PolymorphStats memory)
    {
        // Split them to avoid stack too deep
        PolymorphStats memory top = getTopItemStats(genePairs, skillType);
        PolymorphStats memory bottom = getBottomItemStats(genePairs, skillType);

        PolymorphStats memory s = PolymorphStats(0, 0);
        s.min = top.min + bottom.min;
        s.max = top.max + bottom.max;

        return s;
    }

    function getTopItemStats(uint256[] memory genePairs, uint256 skillType)
    internal
    view
    returns (PolymorphStats memory)
    {
        Item memory e = getItem(genePairs, "EYEWEAR");
        Item memory h = getItem(genePairs, "HEAD");
        Item memory wr = getItem(genePairs, "WEAPON_RIGHT");
        Item memory wl = getItem(genePairs, "WEAPON_RIGHT");

        PolymorphStats memory s = PolymorphStats(0, 0);

        if (skillType == uint(BattleStances.ATTACK)) {
            s.max = e.aMax + h.aMax + wr.aMax + wl.aMax;
            s.min = e.aMin + h.aMin + wr.aMin + wl.aMin;
        }

        if (skillType == uint(BattleStances.DEFENCE)) {
            s.max = e.dMax + h.dMax + wr.dMax + wl.dMax;
            s.min = e.dMin + h.dMin + wr.dMin + wl.dMin;
        }

        return s;
    }

    function getBottomItemStats(uint256[] memory genePairs, uint256 skillType)
    internal
    view
    returns (PolymorphStats memory)
    {
        Item memory c = getItem(genePairs, "CHARACTER"); // 10
        Item memory b = getItem(genePairs, "BACKGROUND"); // 5
        Item memory p = getItem(genePairs, "PANTS"); // 5
        Item memory t = getItem(genePairs, "TORSO"); // 5
        Item memory f = getItem(genePairs, "FOOTWEAR"); // 5

        PolymorphStats memory s = PolymorphStats(0, 0);

        if (skillType == uint(BattleStances.ATTACK)) {
            s.max = c.aMax + b.aMax + p.aMax + t.aMax + f.aMax;
            s.min = c.aMin + b.aMin + p.aMin + t.aMin + f.aMin;
        }

        if (skillType == uint(BattleStances.DEFENCE)) {
            s.max = c.dMax + b.dMax + p.dMax + t.dMax + f.dMax;
            s.min = c.dMin + b.dMin + p.dMin + t.dMin + f.dMin;
        }

        return s;
    }

    // Getters
    function getItem(uint256[] memory genePairs, string memory geneType)
    internal
    view
    returns (Item memory)
    {
        uint256 gene = genePairs[geneIndexByGeneTypeMap[geneType]];
        uint256 itemIndex = gene % itemsCountByTypeMap[geneType];
        uint256 geneIndex = geneIndexByGeneTypeMap[geneType];

        Item memory item;
        if (geneIndex == uint(GenePairsIndexes.CHARACTER)) item = characterMap[itemIndex];
        if (geneIndex == uint(GenePairsIndexes.BACKGROUND)) item = backgroundMap[itemIndex];
        if (geneIndex == uint(GenePairsIndexes.PANTS)) item = pantsMap[itemIndex];
        if (geneIndex == uint(GenePairsIndexes.TORSO)) item = torsoMap[itemIndex];
        if (geneIndex == uint(GenePairsIndexes.FOOTWEAR)) item = footwearMap[itemIndex];
        if (geneIndex == uint(GenePairsIndexes.EYEWEAR)) item = eyewearMap[itemIndex];
        if (geneIndex == uint(GenePairsIndexes.HEAD)) item = headMap[itemIndex];
        if (geneIndex == uint(GenePairsIndexes.WEAPON_RIGHT)) item = weaponRightMap[itemIndex];
        if (geneIndex == uint(GenePairsIndexes.WEAPON_LEFT)) item = weaponLeftMap[itemIndex];

        return item;
    }

    // Initializers
    function initMappings() internal {
        // Footwear
        footwearMap[0] = Item(0, 5, 0, 5, "No shoes");
        footwearMap[1] = Item(0, 5, 0, 5, "Amish Shoes");
        footwearMap[2] = Item(0, 5, 0, 5, "Astronaut Footwear");
        footwearMap[3] = Item(0, 5, 0, 5, "Basketball Shoes");
        footwearMap[4] = Item(0, 5, 0, 5, "Black Dress Shoes");
        footwearMap[5] = Item(0, 5, 0, 5, "Black Ninja Boots");
        footwearMap[6] = Item(0, 5, 0, 5, "Brown Dress Shoes");
        footwearMap[7] = Item(0, 5, 0, 5, "Brown Spartan Sandals");
        footwearMap[8] = Item(0, 5, 0, 5, "Chemical Protection Boots");
        footwearMap[9] = Item(0, 5, 0, 5, "Clown Boots");
        footwearMap[10] = Item(0, 5, 0, 5, "Golden Knight Boots");
        footwearMap[11] = Item(0, 5, 0, 5, "Golden Shoes");
        footwearMap[12] = Item(0, 5, 0, 5, "Golf Shoes");
        footwearMap[13] = Item(0, 5, 0, 5, "Ice Skates");
        footwearMap[14] = Item(0, 5, 0, 5, "Loafers");
        footwearMap[15] = Item(0, 5, 0, 5, "Marine Boots");
        footwearMap[16] = Item(0, 5, 0, 5, "Platinum Spartan Sandals");
        footwearMap[17] = Item(0, 5, 0, 5, "Red Football Cleats");
        footwearMap[18] = Item(0, 5, 0, 5, "Red Soccer Cleats");
        footwearMap[19] = Item(0, 5, 0, 5, "Samurai Boots");
        footwearMap[20] = Item(0, 5, 0, 5, "Silver Knight Boots");
        footwearMap[21] = Item(0, 5, 0, 5, "Sneakers");
        footwearMap[22] = Item(0, 5, 0, 5, "Sushi Chef Shoes");
        footwearMap[23] = Item(0, 5, 0, 5, "Tennis Socks & Shoes");
        footwearMap[24] = Item(0, 5, 0, 5, "White-Yellow Football Cleats");

        // Character
        characterMap[0] = Item(0, 10, 0, 10, "Diamond Paws");
        characterMap[1] = Item(0, 10, 0, 10, "Escrow");
        characterMap[2] = Item(0, 10, 0, 10, "Frankie");
        characterMap[3] = Item(0, 10, 0, 10, "Glenn");
        characterMap[4] = Item(0, 10, 0, 10, "Goldtooth");
        characterMap[5] = Item(0, 10, 0, 10, "Troll God");
        characterMap[6] = Item(0, 10, 0, 10, "Charles");
        characterMap[7] = Item(0, 10, 0, 10, "Mariguana");
        characterMap[8] = Item(0, 10, 0, 10, "Vitalik");
        characterMap[9] = Item(0, 10, 0, 10, "Ragnar");
        characterMap[1] = Item(0, 10, 0, 10, "X-YZ");

        // Pants
        pantsMap[0] = Item(0, 5, 0, 5, "Underwear");
        pantsMap[1] = Item(0, 5, 0, 5, "Amish Pants");
        pantsMap[2] = Item(0, 5, 0, 5, "Argentina Pants");
        pantsMap[3] = Item(0, 5, 0, 5, "Astronaut Pants");
        pantsMap[4] = Item(0, 5, 0, 5, "Black Dress Pants");
        pantsMap[5] = Item(0, 5, 0, 5, "Black Ninja Pants");
        pantsMap[6] = Item(0, 5, 0, 5, "Black Pants");
        pantsMap[7] = Item(0, 5, 0, 5, "Black Soccer Pants");
        pantsMap[8] = Item(0, 5, 0, 5, "Blue Hockey Pants");
        pantsMap[9] = Item(0, 5, 0, 5, "Blue Jeans");
        pantsMap[10] = Item(0, 5, 0, 5, "Brazil Pants");
        pantsMap[11] = Item(0, 5, 0, 5, "Cargo Shorts");
        pantsMap[12] = Item(0, 5, 0, 5, "Chemical Protection Pants");
        pantsMap[13] = Item(0, 5, 0, 5, "Classic Plaid Pants");
        pantsMap[14] = Item(0, 5, 0, 5, "Clown Pants");
        pantsMap[15] = Item(0, 5, 0, 5, "Golden Grieves");
        pantsMap[16] = Item(0, 5, 0, 5, "Golden Pants");
        pantsMap[17] = Item(0, 5, 0, 5, "Gray Jeans");
        pantsMap[18] = Item(0, 5, 0, 5, "Grey Dress Pants");
        pantsMap[19] = Item(0, 5, 0, 5, "Grey Football Pants");
        pantsMap[20] = Item(0, 5, 0, 5, "Grey Pants");
        pantsMap[21] = Item(0, 5, 0, 5, "Marine Pants");
        pantsMap[22] = Item(0, 5, 0, 5, "Rainbow Pants");
        pantsMap[23] = Item(0, 5, 0, 5, "Red Basketball Pants");
        pantsMap[24] = Item(0, 5, 0, 5, "Red Football Pants");
        pantsMap[25] = Item(0, 5, 0, 5, "Ribbed Zombie Pants");
        pantsMap[26] = Item(0, 5, 0, 5, "Samurai Pants");
        pantsMap[27] = Item(0, 5, 0, 5, "Silver Grieves");
        pantsMap[28] = Item(0, 5, 0, 5, "Spartan Pants");
        pantsMap[29] = Item(0, 5, 0, 5, "Sushi Chef Pants");
        pantsMap[30] = Item(0, 5, 0, 5, "Taekwondo Pants");
        pantsMap[31] = Item(0, 5, 0, 5, "Tennis Pants");
        pantsMap[32] = Item(0, 5, 0, 5, "Tuxedo Pants");

        // TORSO
        torsoMap[0] = Item(0, 5, 0, 5, "No Torso");
        torsoMap[1] = Item(0, 5, 0, 5, "Amish Shirt");
        torsoMap[2] = Item(0, 5, 0, 5, "Argentina Jersey");
        torsoMap[3] = Item(0, 5, 0, 5, "Astronaut Torso");
        torsoMap[4] = Item(0, 5, 0, 5, "Beer Mug Tshirt");
        torsoMap[5] = Item(0, 5, 0, 5, "Black Ninja Robe");
        torsoMap[6] = Item(0, 5, 0, 5, "Blue Hockey Jersey");
        torsoMap[7] = Item(0, 5, 0, 5, "Bow Tie & Suit");
        torsoMap[8] = Item(0, 5, 0, 5, "Brazil Jersey");
        torsoMap[9] = Item(0, 5, 0, 5, "Chemical Protection Robe");
        torsoMap[10] = Item(0, 5, 0, 5, "Clown Jacket");
        torsoMap[11] = Item(0, 5, 0, 5, "Golden Armor");
        torsoMap[12] = Item(0, 5, 0, 5, "Golden Jacket");
        torsoMap[13] = Item(0, 5, 0, 5, "Golden Spartan Armor");
        torsoMap[14] = Item(0, 5, 0, 5, "Grey Jacket");
        torsoMap[15] = Item(0, 5, 0, 5, "Marine Shirt");
        torsoMap[16] = Item(0, 5, 0, 5, "Platinum Spartan Armor");
        torsoMap[17] = Item(0, 5, 0, 5, "Rainbow Jacket");
        torsoMap[18] = Item(0, 5, 0, 5, "Red Basketball Jersey");
        torsoMap[19] = Item(0, 5, 0, 5, "Red Collared Shirt");
        torsoMap[20] = Item(0, 5, 0, 5, "Red Football Jersey");
        torsoMap[21] = Item(0, 5, 0, 5, "Ribbed Zombie Shirt");
        torsoMap[22] = Item(0, 5, 0, 5, "Samurai Armor");
        torsoMap[23] = Item(0, 5, 0, 5, "Silver Armor");
        torsoMap[24] = Item(0, 5, 0, 5, "Silver Spartan Armor");
        torsoMap[25] = Item(0, 5, 0, 5, "Striped Soccer Jersey");
        torsoMap[26] = Item(0, 5, 0, 5, "Suit & Tie");
        torsoMap[27] = Item(0, 5, 0, 5, "Suit");
        torsoMap[28] = Item(0, 5, 0, 5, "Sushi Chef Shirt");
        torsoMap[29] = Item(0, 5, 0, 5, "Taekwondo Robe");
        torsoMap[30] = Item(0, 5, 0, 5, "Tennis Shirt");
        torsoMap[31] = Item(0, 5, 0, 5, "Tuxedo Jacket");
        torsoMap[32] = Item(0, 5, 0, 5, "Weed Plant Tshirt");
        torsoMap[33] = Item(0, 5, 0, 5, "White Football Jersey");

        // Eyewear
        eyewearMap[0] = Item(0, 5, 0, 5, "No Eyewear");
        eyewearMap[1] = Item(0, 5, 0, 5, "3D Glasses");
        eyewearMap[2] = Item(0, 5, 0, 5, "Bar Shades");
        eyewearMap[3] = Item(0, 5, 0, 5, "Eye Paint");
        eyewearMap[4] = Item(0, 5, 0, 5, "Golden Sunglasses");
        eyewearMap[5] = Item(0, 5, 0, 5, "Monocle");
        eyewearMap[6] = Item(0, 5, 0, 5, "Orange Sunglasses");
        eyewearMap[7] = Item(0, 5, 0, 5, "Purple Sunglasses");
        eyewearMap[8] = Item(0, 5, 0, 5, "Respirator");
        eyewearMap[9] = Item(0, 5, 0, 5, "Retro Glasses");
        eyewearMap[10] = Item(0, 5, 0, 5, "Round Glasses");
        eyewearMap[11] = Item(0, 5, 0, 5, "Sunglasses");
        eyewearMap[12] = Item(0, 5, 0, 5, "VR Set");

        // HEAD
        headMap[0] = Item(0, 5, 0, 5, "No Headwear");
        headMap[1] = Item(0, 5, 0, 5, "Amish Hat");
        headMap[2] = Item(0, 5, 0, 5, "Astronnaut Helmet");
        headMap[3] = Item(0, 5, 0, 5, "Party Hat");
        headMap[4] = Item(0, 5, 0, 5, "Black Golf Hat");
        headMap[5] = Item(0, 5, 0, 5, "Black Ninja Headband");
        headMap[6] = Item(0, 5, 0, 5, "Black Ushanka");
        headMap[7] = Item(0, 5, 0, 5, "Blue Beanie");
        headMap[8] = Item(0, 5, 0, 5, "Brown Ushanka");
        headMap[9] = Item(0, 5, 0, 5, "Caesar Hat");
        headMap[10] = Item(0, 5, 0, 5, "Clown Hat");
        headMap[11] = Item(0, 5, 0, 5, "Copter Hat");
        headMap[12] = Item(0, 5, 0, 5, "Golden Hat");
        headMap[13] = Item(0, 5, 0, 5, "Golden Knight Helmet");
        headMap[14] = Item(0, 5, 0, 5, "Golden Spartan Helmet");
        headMap[15] = Item(0, 5, 0, 5, "Green Beanie");
        headMap[16] = Item(0, 5, 0, 5, "Grey Football Helmet");
        headMap[17] = Item(0, 5, 0, 5, "Marine Helmet");
        headMap[18] = Item(0, 5, 0, 5, "Old Hat");
        headMap[19] = Item(0, 5, 0, 5, "Platinum Spartan Helmet");
        headMap[20] = Item(0, 5, 0, 5, "Purple Ushanka");
        headMap[21] = Item(0, 5, 0, 5, "Rainbow Cap");
        headMap[22] = Item(0, 5, 0, 5, "Red Beanie");
        headMap[23] = Item(0, 5, 0, 5, "Red Football Helmet");
        headMap[24] = Item(0, 5, 0, 5, "Silver Knight Helmet");
        headMap[25] = Item(0, 5, 0, 5, "Silver Spartan Helmet");
        headMap[26] = Item(0, 5, 0, 5, "Straw Hat");
        headMap[27] = Item(0, 5, 0, 5, "Sushi Chef Hat");
        headMap[28] = Item(0, 5, 0, 5, "Traffic Cone");
        headMap[29] = Item(0, 5, 0, 5, "Tuxedo Hat");
        headMap[30] = Item(0, 5, 0, 5, "Violet Beanie");

        // weapon right
        weaponRightMap[0] = Item(0, 5, 0, 5, "No Right Hand Accesories");
        weaponRightMap[1] = Item(0, 5, 0, 5, "American Football");
        weaponRightMap[2] = Item(0, 5, 0, 5, "Amish Pitch Fork");
        weaponRightMap[3] = Item(0, 5, 0, 5, "Banana");
        weaponRightMap[4] = Item(0, 5, 0, 5, "Basketball");
        weaponRightMap[5] = Item(0, 5, 0, 5, "Beer");
        weaponRightMap[6] = Item(0, 5, 0, 5, "Big Gun");
        weaponRightMap[7] = Item(0, 5, 0, 5, "Black Gun");
        weaponRightMap[8] = Item(0, 5, 0, 5, "Blue Degen Sword");
        weaponRightMap[9] = Item(0, 5, 0, 5, "Bong");
        weaponRightMap[10] = Item(0, 5, 0, 5, "Bow & Arrow");
        weaponRightMap[11] = Item(0, 5, 0, 5, "Corn Gun");
        weaponRightMap[12] = Item(0, 5, 0, 5, "Diamond");
        weaponRightMap[13] = Item(0, 5, 0, 5, "Double Degen Sword Blue");
        weaponRightMap[14] = Item(0, 5, 0, 5, "Double Degen Sword Red");
        weaponRightMap[15] = Item(0, 5, 0, 5, "Double Degen Sword Yellow");
        weaponRightMap[16] = Item(0, 5, 0, 5, "Football");
        weaponRightMap[17] = Item(0, 5, 0, 5, "Golden Gun");
        weaponRightMap[18] = Item(0, 5, 0, 5, "Golden Spartan Sword");
        weaponRightMap[19] = Item(0, 5, 0, 5, "Golf Club");
        weaponRightMap[20] = Item(0, 5, 0, 5, "Green Degen Sword");
        weaponRightMap[21] = Item(0, 5, 0, 5, "Grenade");
        weaponRightMap[22] = Item(0, 5, 0, 5, "Hockey Stick");
        weaponRightMap[23] = Item(0, 5, 0, 5, "Katana");
        weaponRightMap[24] = Item(0, 5, 0, 5, "Platinum Spartan Sword");
        weaponRightMap[25] = Item(0, 5, 0, 5, "Purple Degen Sword");
        weaponRightMap[26] = Item(0, 5, 0, 5, "Red Degen Sword");
        weaponRightMap[27] = Item(0, 5, 0, 5, "Shield");
        weaponRightMap[28] = Item(0, 5, 0, 5, "Silver Spartan Sword");
        weaponRightMap[29] = Item(0, 5, 0, 5, "Sushi Knife");
        weaponRightMap[30] = Item(0, 5, 0, 5, "Sword");
        weaponRightMap[31] = Item(0, 5, 0, 5, "Tennis Racket");

        // weapon left
        weaponLeftMap[0] = Item(0, 5, 0, 5, "No Left Hand Accesories");
        weaponLeftMap[1] = Item(0, 5, 0, 5, "American Football");
        weaponLeftMap[2] = Item(0, 5, 0, 5, "Amish Pitch Fork");
        weaponLeftMap[3] = Item(0, 5, 0, 5, "Banana");
        weaponLeftMap[4] = Item(0, 5, 0, 5, "Basketball");
        weaponLeftMap[5] = Item(0, 5, 0, 5, "Beer");
        weaponLeftMap[6] = Item(0, 5, 0, 5, "Big Gun");
        weaponLeftMap[7] = Item(0, 5, 0, 5, "Black Gun");
        weaponLeftMap[8] = Item(0, 5, 0, 5, "Blue Degen Sword");
        weaponLeftMap[9] = Item(0, 5, 0, 5, "Bong");
        weaponLeftMap[10] = Item(0, 5, 0, 5, "Bow & Arrow");
        weaponLeftMap[11] = Item(0, 5, 0, 5, "Corn Gun");
        weaponLeftMap[12] = Item(0, 5, 0, 5, "Diamond");
        weaponLeftMap[13] = Item(0, 5, 0, 5, "Double Degen Sword Blue");
        weaponLeftMap[14] = Item(0, 5, 0, 5, "Double Degen Sword Red");
        weaponLeftMap[15] = Item(0, 5, 0, 5, "Double Degen Sword Yellow");
        weaponLeftMap[16] = Item(0, 5, 0, 5, "Football");
        weaponLeftMap[17] = Item(0, 5, 0, 5, "Golden Gun");
        weaponLeftMap[18] = Item(0, 5, 0, 5, "Golden Spartan Sword");
        weaponLeftMap[19] = Item(0, 5, 0, 5, "Golf Club");
        weaponLeftMap[20] = Item(0, 5, 0, 5, "Green Degen Sword");
        weaponLeftMap[21] = Item(0, 5, 0, 5, "Grenade");
        weaponLeftMap[22] = Item(0, 5, 0, 5, "Hockey Stick");
        weaponLeftMap[23] = Item(0, 5, 0, 5, "Katana");
        weaponLeftMap[24] = Item(0, 5, 0, 5, "Platinum Spartan Sword");
        weaponLeftMap[25] = Item(0, 5, 0, 5, "Purple Degen Sword");
        weaponLeftMap[26] = Item(0, 5, 0, 5, "Red Degen Sword");
        weaponLeftMap[27] = Item(0, 5, 0, 5, "Shield");
        weaponLeftMap[28] = Item(0, 5, 0, 5, "Silver Spartan Sword");
        weaponLeftMap[29] = Item(0, 5, 0, 5, "Sushi Knife");
        weaponLeftMap[30] = Item(0, 5, 0, 5, "Sword");
        weaponLeftMap[31] = Item(0, 5, 0, 5, "Tennis Racket");

        // Background
        backgroundMap[0] = Item(0, 5, 0, 5, "Angel Tears");
        backgroundMap[1] = Item(0, 5, 0, 5, "Aqua Splash");
        backgroundMap[2] = Item(0, 5, 0, 5, "Crimson Blush");
        backgroundMap[3] = Item(0, 5, 0, 5, "Deep Relief");
        backgroundMap[4] = Item(0, 5, 0, 5, "Desert Hump");
        backgroundMap[5] = Item(0, 5, 0, 5, "Eternal Constance");
        backgroundMap[6] = Item(0, 5, 0, 5, "Flying High");
        backgroundMap[7] = Item(0, 5, 0, 5, "Happy Fisher");
        backgroundMap[8] = Item(0, 5, 0, 5, "Plum Plate");
        backgroundMap[9] = Item(0, 5, 0, 5, "Squeaky Clean");
        backgroundMap[10] = Item(0, 5, 0, 5, "Strong Bliss");
        backgroundMap[11] = Item(0, 5, 0, 5, "Summer Salad");

        // geneIndexByGeneTypeMap
        geneIndexByGeneTypeMap["CHARACTER"] = 0;
        geneIndexByGeneTypeMap["BACKGROUND"] = 1;
        geneIndexByGeneTypeMap["PANTS"] = 2;
        geneIndexByGeneTypeMap["TORSO"] = 3;
        geneIndexByGeneTypeMap["FOOTWEAR"] = 4;
        geneIndexByGeneTypeMap["EYEWEAR"] = 5;
        geneIndexByGeneTypeMap["HEAD"] = 6;
        geneIndexByGeneTypeMap["WEAPON_RIGHT"] = 7;
        geneIndexByGeneTypeMap["WEAPON_LEFT"] = 8;

        // itemsCountByTypeMap
        itemsCountByTypeMap["CHARACTER"] = 11;
        itemsCountByTypeMap["BACKGROUND"] = 12;
        itemsCountByTypeMap["PANTS"] =  33;
        itemsCountByTypeMap["TORSO"] = 34;
        itemsCountByTypeMap["FOOTWEAR"] =25;
        itemsCountByTypeMap["EYEWEAR"] = 13;
        itemsCountByTypeMap["HEAD"] = 31;
        itemsCountByTypeMap["WEAPON_RIGHT"] = 32;
        itemsCountByTypeMap["WEAPON_LEFT"] = 32;
    }

    /// @notice Updates specific map item stats
    function updateItemStats() public {}
}