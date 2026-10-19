// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseTamagotchi {
    struct Pet {
        string name;
        uint256 birthTime;
        uint256 lastFed;
        uint256 level;
        uint256 xp;
        bool isSleeping;
        uint256 lastSleepToggle;
        bool exists;
    }

    // Привязка: один кошелек = один питомец
    mapping(address => Pet) public pets;

    event PetCreated(address indexed owner, string name);
    event PetFed(address indexed owner, uint256 newXp, uint256 newLevel);
    event PetSleepToggled(address indexed owner, bool isSleeping);

    // Создать своего питомца
    function createPet(string calldata _name) external {
        require(!pets[msg.sender].exists, unicode"У вас уже есть питомец!");
        require(bytes(_name).length > 0 && bytes(_name).length <= 20, unicode"Имя от 1 до 20 символов");

        pets[msg.sender] = Pet({
            name: _name,
            birthTime: block.timestamp,
            lastFed: block.timestamp,
            level: 1,
            xp: 0,
            isSleeping: false,
            lastSleepToggle: block.timestamp,
            exists: true
        });

        emit PetCreated(msg.sender, _name);
    }

    // Рассчитать текущий уровень сытости (0 - 100)
    function getHunger(address _owner) public view returns (uint256) {
        Pet memory pet = pets[_owner];
        if (!pet.exists) return 0;

        uint256 timePassed = block.timestamp - pet.lastFed;
        // Скорость голодания: если спит — 1% за 3600 сек (1 час), если нет — 1% за 1800 сек (30 мин)
        uint256 burnRate = pet.isSleeping ? 3600 : 1800;
        uint256 hungerLost = timePassed / burnRate;

        if (hungerLost >= 100) {
            return 0; // Очень голоден
        }
        return 100 - hungerLost;
    }

    // Покормить питомца
    function feed() external {
        require(pets[msg.sender].exists, unicode"Сначала создайте питомца!");
        Pet storage pet = pets[msg.sender];
        require(!pet.isSleeping, unicode"Питомец спит! Разбудите его перед едой.");

        uint256 currentHunger = getHunger(msg.sender);
        require(currentHunger < 95, unicode"Питомец сыт, покормите позже!");

        pet.lastFed = block.timestamp;
        pet.xp += 25;

        // Повышение уровня каждые 100 XP
        if (pet.xp >= pet.level * 100) {
            pet.level += 1;
        }

        emit PetFed(msg.sender, pet.xp, pet.level);
    }

    // Уложить спать или разбудить
    function toggleSleep() external {
        require(pets[msg.sender].exists, unicode"Сначала создайте питомца!");
        Pet storage pet = pets[msg.sender];

        // Фиксируем сытость перед сном
        uint256 currentHunger = getHunger(msg.sender);
        pet.lastFed = block.timestamp - ((100 - currentHunger) * (pet.isSleeping ? 3600 : 1800));

        pet.isSleeping = !pet.isSleeping;
        pet.lastSleepToggle = block.timestamp;

        emit PetSleepToggled(msg.sender, pet.isSleeping);
    }

    // Получить полную инфу о питомце
    function getPet(address _owner) external view returns (
        string memory name,
        uint256 level,
        uint256 xp,
        uint256 hunger,
        bool isSleeping,
        uint256 ageSeconds,
        bool exists
    ) {
        Pet memory pet = pets[_owner];
        if (!pet.exists) {
            return ("", 0, 0, 0, false, 0, false);
        }
        return (
            pet.name,
            pet.level,
            pet.xp,
            getHunger(_owner),
            pet.isSleeping,
            block.timestamp - pet.birthTime,
            true
        );
    }
}