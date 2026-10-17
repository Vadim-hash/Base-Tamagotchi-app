// SPDX-License-Identifier: MIT
pragma solidity 0.8.37;

interface ITamagotchi {
    function feedPet(uint256 petId) external;
    function playWithPet(uint256 petId) external;
    function getPetStats(uint256 petId) external view returns (uint256 hunger, uint256 happiness, uint256 level);
}
