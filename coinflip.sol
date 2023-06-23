// SPDX-License-Identifier: GPL

pragma solidity >=0.7.0 <0.9.0;

contract CoinFlip {
    uint256 betAmount;
    address payable owner; // Make sure the owner is a payable address
    uint256 houseFee = 2; // House fee in percent
    
    enum Coin { HEADS, TAILS }
    
    struct Bet {
        address payable bettor; // The address placing the bet
        uint256 amount; // The amount of the bet
        Coin coin; // The selected coin
    }

    Bet[] public bets; // Array of bets

    constructor() {
        owner = payable(msg.sender); // Set the contract deployer as the owner
    }
    
    //UI will allow bettor to select betting amount and coin head
    function placeBet(Coin _coin) public payable {        
        // Ether amounts are 1.02 x Betting Amount since we need to collect house fees.
        require(msg.value == 0.102 ether|| msg.value == 0.255 ether || msg.value == 0.51 ether || msg.value == 1.02 ether, "Invalid bet amount");
        
        // Calculate the house fee
        uint256 houseCut = (msg.value * houseFee) / 100;
        // Calculate the actual bet amount (minus house fee)
        uint256 betValue = msg.value - houseCut;

        // Create a new bet
        Bet memory newBet = Bet({
            bettor: payable(msg.sender),
            amount: betValue,
            coin: _coin
        });
        
        // Add the new bet to the array of bets
        bets.push(newBet);
        
        // Transfer the house fee to the house
        owner.transfer(houseCut);
    }
    
    function resolveBet(uint256 betIndex) public {
        Bet storage bet = bets[betIndex];
        require(msg.sender == bet.bettor, "You are not the bettor");
        
        // Mimic coin flip (Intend to use oracle services to provide the random number in the future)
        Coin flipResult = (block.difficulty + block.timestamp) % 2 == 0 ? Coin.HEADS : Coin.TAILS;
        
        // Check the result of the bet
        if (bet.coin == flipResult) {
            // Bettor won, transfer the amount 
            uint256 payout = bet.amount * 2;
            bet.bettor.transfer(payout);
        } else {
            // Bettor lost, transfer the lost bet amount to the house
            owner.transfer(bet.amount);
        }
        
        // Remove the bet from the array of bets
        bets[betIndex] = bets[bets.length - 1];
        bets.pop();
    }
}
