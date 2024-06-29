pragma solidity ^0.4.17;

contract Lottery {
    address public manager;
    address[] public players;

    // Default Constructor
    function Lottery() public {
        manager = msg.sender;
    }

    // Entering the player to the lottery
    function enter() public payable {
        require(msg.value > .01 ether);
        players.push(msg.sender);
    }

    // Random Winner Generation algorithm
    function random() private view returns (uint) {
        return uint(keccak256(block.difficulty, now, players));
    }

    function pickWinners(uint numberOfWinners) public restricted {
    require(numberOfWinners > 0 && numberOfWinners <= players.length, "Invalid number of winners");

    address[] memory winners = new address[](numberOfWinners);

    for (uint i = 0; i < numberOfWinners; i++) {
        uint index = random(i) % players.length;
        
        // Select the winner
        winners[i] = players[index];
        
        // Remove the selected player from the players array
        players[index] = players[players.length - 1];
        players.pop(); // Remove the last element from the array
    }

    // Distribute prizes equally
    uint prizeAmount = address(this).balance / numberOfWinners;
    for (i = 0; i < numberOfWinners; i++) {
        winners[i].transfer(prizeAmount);
    }
}
    // Restricting  modifier added as sender only calling
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    // Return Players Array
    function getPlayers() public view returns (address[]){
        return players;
    }
}
