// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//authentication for user as well as for company 
contract Auth {
    struct User {
        string username;
        bytes32 passwordHash;
    }

    mapping(address => User) private users;

    function register(string memory username, string memory password) public {
        require(bytes(users[msg.sender].username).length == 0, "User already exists");
        users[msg.sender] = User(username, keccak256(abi.encodePacked(password)));
    }

    function login(string memory username, string memory password) public view returns (bool) {
        if (keccak256(abi.encodePacked(username)) == keccak256(abi.encodePacked(users[msg.sender].username)) &&
            keccak256(abi.encodePacked(password)) == users[msg.sender].passwordHash) {
            return true;
        }
        return false;
    }

    function getUsername() public view returns (string memory) {
        require(bytes(users[msg.sender].username).length != 0, "User not found");
        return users[msg.sender].username;
    }
}
