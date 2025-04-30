// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    uint256 private s_counter;
    string public HAPPY_URI;
    string public SAD_URI;

    // error MoodNft__InfusufficientBalance();
    error MoodNft__NotOwner();

    enum Mood {
        HAPPY,
        SAD
    }

    mapping(uint256 => Mood) public s_tokenIdToMood;

    event MoodNftMinted(address indexed owner, uint256 tokenId);

    constructor(string memory _happyUri, string memory _sadUri) ERC721("MoodNft", "MNFT") {
        HAPPY_URI = _happyUri;
        SAD_URI = _sadUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_counter);
        s_tokenIdToMood[s_counter] = Mood.HAPPY;
        emit MoodNftMinted(msg.sender, s_counter);
        s_counter++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageUri;

        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            imageUri = HAPPY_URI;
        } else if (s_tokenIdToMood[tokenId] == Mood.SAD) {
            imageUri = SAD_URI;
        }

        bytes memory tokenUri =
            abi.encodePacked('{"name":"', name(), '","description":"MoodNft","image":"', imageUri, '"}');
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(tokenUri)));
    }

    function filpMood(uint256 tokenId) public {
        if (msg.sender != ownerOf(tokenId)) {
            revert MoodNft__NotOwner();
        }

        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else if (s_tokenIdToMood[tokenId] == Mood.SAD) {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }
}
