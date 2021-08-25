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


Upon initialization of the contract we need to call initItems() and pass as an array with the following structure the items. We have separated the items into two arrays in order to fit in 2 transactions:

```
const items = [
    [ genePosition: 0, itemIndex: 0, aMin: 1, aMax: 50, dMin: 1, dMax: 50 ]
    [ genePosition: 1, itemIndex: 0, aMin: 1, aMax: 50, dMin: 1, dMax: 50 ]
    [ genePosition: 2, itemIndex: 0, aMin: 1, aMax: 50, dMin: 1, dMax: 50 ]
    [ genePosition: 3, itemIndex: 0, aMin: 1, aMax: 50, dMin: 1, dMax: 50 ]
    [ genePosition: 4, itemIndex: 0, aMin: 1, aMax: 50, dMin: 1, dMax: 50 ]
    [ genePosition: 5, itemIndex: 0, aMin: 1, aMax: 50, dMin: 1, dMax: 50 ]
    [ genePosition: 6, itemIndex: 0, aMin: 1, aMax: 50, dMin: 1, dMax: 50 ]
]

PolymorphBattleground.initItems(items);

```

# Architecture Diagram
![Alt text](./images/BattleGroundDiagram.png?raw=true "Title")

# Game Design Description: 

## Entering the pool enterBattle()
- The user will be able to enter battle pools with his Polymorph. A battle pool can consist of up to N(to be considered based on the Gas) players and a minimum of N(to be considered based on the Gas) players. The user cannot enter a pool twice with the same polymorph. The user must be the owner of the polymorph. If the pool overflows the next pool is created. The contract keeps track of the battle pool indexes in order to know where to put the incoming players.
- Upon entering a battle pool the user chooses his desired Battle Stance (Attack or Defence). Polymorph stats will be calculated based on the Polymorph specific Gene. The current version of the Polymorphs has 9 Genes: character, background, pants, torso, footwear, eyewear, head, weapon_right, weapon_left. 
- Each Gene is corresponding to a specific Item. Each item has attack and defence points, based on the desired Battle Stance the minimum and maximum stats will be calculated for the specific Polymorph.
- We store the current user participatedBattlePoolIndex In order to keep track if the user is scheduled for a fight and prevent him from claiming rewards.
- After entering the pool the user will be scheduled to fight against a random opponent. When the minimum number of participants is reached the round can be started. 

## Starting the round startRound() 
- In order to start the round method the contract needs to make a call to UNISWAP to buy LINK for the VRF Chainlink RNG request.
- After buying the LINK the contract calculate the round Fees per player with the following formula: fees  = DAO_FEE + RNG_FEE + START_ROUND_INCENTIVE + FINISH_ROUND_INCENTIVE;
- After that the contract makes the actual RNG call. (This procedure may take up to a few blocks)
- In order to stimulate the players to call startRound() method the contract will incentivise the caller based on the following formula: START_ROUND_INCENTIVE * pool participants.
- When the contract receives the random number the actual battles can start. In order to start them the finishRound() method should be called.

## Finishing the round finishRound()
- The contract keeps track of the current round index
- Based on the round index we select the current battle pool
- Based on the random number from Chainlink we will derive two more random numbers in order to pick two random polymorphs from the battle pool.
- After we pick polymorphs they are removed from the pool, so they cannot be chosen again.
- Based on the last generated random number from the step above we will derive two more random numbers in order to calculate the polymorphs battle stats for the current fight based on their min and max stats.
- Based on those stats we will determine who is the winner. If the stats are equal, we compare the random numbers used for their current battle stats calculations.
- After the fight we update the players balances and update the initial random number used for starting the fight to be the last derived random number from the current loop sequence.
- The same steps are repeated until there are no more polymorphs in the battle pool. If the number of participants is odd the polymorph which hasn’t fought in the current round is scheduled for a fight in the next available battle pool and removed from the current one.
- After all the polymorphs have fought we reset the round fees, the randomNumber and increase the round index
- In order to stimulate the players to call the finishRound() method we will incentivise the caller based on the following formula: END_ROUND_INCENTIVE * pool participants.

## Claiming the rewards claimRewards()
- The user can claim his rewards if he has not been scheduled to fight in an upcoming pool. (participatedBattlePoolIndex < roundIndex)
