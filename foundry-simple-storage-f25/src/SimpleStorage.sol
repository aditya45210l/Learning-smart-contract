// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleStorage {
    uint256 public myFavoriteNum;

    struct Person {
        uint256 favNum;
        string name;
    }

    mapping(string => uint256) public getFavNumberByName;
    Person[] public listFavNum;

    function setMyFavNumber(uint256 _FavNumber) public virtual {
        myFavoriteNum = _FavNumber;
    }

    function getFavNumber() public view returns (uint256) {
        return myFavoriteNum;
    }

    function addFriendFavNum(string memory _name, uint256 _FavNum) public {
        listFavNum.push(Person({favNum: _FavNum, name: _name}));
        getFavNumberByName[_name] = _FavNum;
    }
}
