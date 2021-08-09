# Polymorph-Battleground Game

The Polymorphs will be able to fight against each other. The owner of the polymorph will enter a battle pool with his
polymorph and selected Battle Stance(Attack or Defense). It's stats will be calculated based on its GENE. Each item of the Gene will give different range of points for example:

Character => Vitalik => Attack 1-100 / Defense 1-100

Headwear => Party Hat => Attack 1-100 / Defense 1-50

Eyewear => Eye Paint => Attack 1-100 / Defense 1-50

Left Hand => Banana => Attack 1-50 / Defense 1-50

Right Hand => Beer => Attack 1-150 / Defense 1-50

Torso => Grey Jacket => Attack 1-50 / Defense 1- 100

Pants => Austronaut Pants => Attack 1-100 / Defense 1- 50

Footwear => Clown Boots => Attack 1-50 / Defense 1-100

Each participant in the pool must pay Fees:
1. Dao Fee
2. RNG cost Fee
3. Start round Incentive fee
4. Finish round Incentive fee


Upont startRound() call the game will:
1. Swap ETH for LINK
2. Calculate Fees
3. Request random Number
4. Incentivise the caller

Upon finishRound() call the game will:
1. Start the battles between all polymorphs
2. Update balances of all participants
3. Incentivise the caller


# Architecture Diagram
![Alt text](./images/BattleGroundDiagram.png?raw=true "Title")
