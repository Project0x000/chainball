// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PlayerFactory is ERC1155, Ownable {
    address private contractOwner;
    uint256 private nextPlayerId;

    struct PlayerAttributes {
        uint8 attacking;
        uint8 defending;
        uint8 passing;
        uint8 shooting;
        uint8 speed;
        uint8 dribbling;
    }

    struct FootballPlayer {
        string name;
        string imageURI;
        uint8 age;
        PlayerAttributes attributes;
    }

    mapping(uint256 => FootballPlayer) private players;

    event PlayerCreated(
        uint256 indexed playerId,
        string name,
        uint8 age,
        string imageURI,
        uint8 overallRating
    );
    event AttributesUpdated(
        uint256 indexed playerId,
        PlayerAttributes attributes
    );
    event ImageUpdated(uint256 indexed playerId, string imageURI);

    constructor() ERC1155("") {
        contractOwner = msg.sender;
        nextPlayerId = 1;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        _setURI(baseURI);
    }

    function createFootballPlayer(
        string memory name,
        string memory imageURI,
        uint8 age,
        PlayerAttributes memory attributes
    ) external onlyOwner returns (uint256) {
        uint256 playerId = nextPlayerId;

        players[playerId] = FootballPlayer(name, imageURI, age, attributes);

        _mint(msg.sender, playerId, 1, "");

        uint8 overallRating = computeOverallRating(attributes);
        emit PlayerCreated(playerId, name, age, imageURI, overallRating);

        nextPlayerId++;

        return playerId;
    }

    function getFootballPlayer(
        uint256 playerId
    )
        external
        view
        returns (
            string memory name,
            string memory imageURI,
            uint age,
            PlayerAttributes memory attributes,
            uint8 overallRating
        )
    {
        FootballPlayer memory player = players[playerId];
        uint8 rating = computeOverallRating(player.attributes);
        return (
            player.name,
            player.imageURI,
            player.age,
            player.attributes,
            rating
        );
    }

    function updateAttributes(
        uint256 playerId,
        PlayerAttributes memory newAttributes
    ) external onlyOwner {
        FootballPlayer storage player = players[playerId];
        player.attributes = newAttributes;

        emit AttributesUpdated(playerId, newAttributes);
    }

    function updateImage(
        uint256 playerId,
        string memory newImageURI
    ) external onlyOwner {
        FootballPlayer storage player = players[playerId];
        player.imageURI = newImageURI;

        emit ImageUpdated(playerId, newImageURI);
    }

    function computeOverallRating(
        PlayerAttributes memory attributes
    ) private pure returns (uint8) {
        uint256 sum = uint256(attributes.attacking) +
            attributes.defending +
            attributes.passing +
            attributes.shooting +
            attributes.speed +
            attributes.dribbling;
        return uint8(sum / 6);
    }
}
