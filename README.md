# Base Tamagotchi App

A fully on-chain virtual pet simulation deployed on the Base network. This protocol gamifies smart contract interactions by requiring users to perform periodic state updates (feeding, playing) to maintain their digital companion's health metrics.

## Core Gameplay Loop
* **State Decay Mechanics:** Utilizes timestamp differentials to calculate dynamic hunger and happiness decay, accurately simulating a living digital entity.
* **Interaction Constraints:** Implements block-time cooldowns on feeding and playing to prevent spamming and gamify user retention.
* **Immutability & Persistence:** All pet states, naming, and life-cycle events are permanently recorded on the Base ledger.

## Architecture
The contract leverages optimized `uint256` math for decay calculations and tightly packed storage variables to minimize gas costs during routine pet maintenance calls.
