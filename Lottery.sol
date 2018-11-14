pragma solidity ^0.4.23;

// TODO: get gas refund for userPicks
contract Lottery {
    using SafeMath for *;

  mapping (bytes32 => address) public userPicks;      // Hash of users selections for current lottery
  mapping (address => uint) public owed;       // Amount WEI owed to user

  uint public jackpot;
  uint public minimumBet = 10**17;      // .1 Ether
  uint8 public lotteryLength = 10;     // Length of lottery in blocks

  uint public resultBlock;       // Block number where winning number will be selected from
  bytes1 public lastNumbers;     // Previous winning numbers

  address public owner;


  constructor()
  public {
    owner = msg.sender;
  }


  // @notice When Lottery is live, users can submit picks here
  function play(bytes1 _pick)
  public
  payable
  lotteryLive {
    require(_pick != bytes1(0), "Pick cannot be 0");
    require(msg.value == minimumBet, "minimum bet not sent");
    bytes32 thisPick = keccak256(abi.encodePacked(resultBlock, _pick));
    require(userPicks[thisPick] == address(0));
    jackpot = jackpot.add(msg.value);
    userPicks[thisPick] = msg.sender;
  }

  // @notice If lottery is finished + there is no winner, jackpot carries over to the next lottery
  function restartLottery()
  public 
  lotteryFinished
  returns (bool) {
    bytes32 blockHash = blockhash(resultBlock);
    lastNumbers = blockHash[31];
    address winner = userPicks[keccak256(abi.encodePacked(resultBlock,lastNumbers))]; 
    if (winner != address(0)) {
        uint playerWinnings = jackpot.mul(uint(99)).div(uint(100));
        delete jackpot;
        owed[winner] = owed[winner].add(playerWinnings);    // Give player 99%
        owner.transfer(address(this).balance);     // Give owner 1%
    }
    resultBlock = block.number.add(lotteryLength);    // Set a new resultBlock, restarting the lottery
    return true;
  }


  // --------------------------------------------------------------------------------------------------------------------------
  //                                            View Functions 
  // --------------------------------------------------------------------------------------------------------------------------

  // @notice returns true when the number is still available. 
  function isPickAvailable(bytes1 _pick)
  public
  view
  returns (bool) {
    bytes32 thisPick = keccak256(abi.encodePacked(resultBlock, _pick));
    return (userPicks[thisPick] == address(0));
  }


  function currentBlock()
  public
  view
  returns (uint){
      return block.number;
  }
  
  function isLotteryLive()
  public 
  view 
  returns (bool) { 
    return block.number < resultBlock; 
  }


  // --------------------------------------------------------------------------------------------------------------------------
  //                                             Modifiers
  // --------------------------------------------------------------------------------------------------------------------------

  modifier lotteryLive {
    require(block.number < resultBlock);
    _;
  }

  modifier lotteryFinished {
       require(block.number > resultBlock);
       _;
  }

}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
