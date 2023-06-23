// SPDX-License-Identifier: GPL

pragma solidity >=0.7.0 <0.9.0;

contract CoinFlip {
    uint256 betAmount;
    address owner;
    uint256 houseFee = 2; // House fee in percent
    
    enum Coin { HEADS, TAILS }
    
    struct Bet {
        address payable bettor; // The address placing the bet
        uint256 amount; // The amount of the bet
        Coin coin; // The selected coin
    }

    Bet[] public bets; // Array of bets

    constructor() {
        owner = msg.sender; // Set the contract deployer as the owner
    }
    
    //UI will allow bettor to select betting amount and coin head
    function placeBet(Coin _coin) public payable {
        require(msg.value == 0.1 ether || msg.value == 0.25 ether || msg.value == 0.5 ether || msg.value == 1 ether, "Invalid bet amount");
        Bet memory newBet = Bet({
            bettor: payable(msg.sender),
            amount: msg.value,
            coin: _coin
        });
        
        bets.push(newBet);
    }
    
    function resolveBet(uint256 betIndex) public {
        Bet storage bet = bets[betIndex];
        require(msg.sender == bet.bettor, "You are not the bettor");
        
        // Mimic coin flip (Intend to use oracle services to provide the random number in the future)
        Coin flipResult = (block.difficulty + block.timestamp) % 2 == 0 ? Coin.HEADS : Coin.TAILS;
        
        // Check bet
        if (bet.coin == flipResult) {
            // Bettor won, transfer the amount (after taking house fee)
            uint256 payout = bet.amount * 2;
            // Here the 2% will be taken from the payout, however, depending on userbase feedback, house fee can be deducted from the bet amount as well
            uint256 houseCut = (payout * houseFee) / 100;
            payout -= houseCut;

            bet.bettor.transfer(payout);
        }
        
        // Remove the bet
        bets[betIndex] = bets[bets.length - 1];
        bets.pop();
    }
}



