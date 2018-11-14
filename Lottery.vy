
userPicks: public(address[bytes32])
owed: public(address[bytes32])

jackpot: public(uint256)
minimumBet: public(uint256)
lotteryLength: public(uint256)
resultBlock: public(uint256)
lastNumbers: public(uint256)

owner: public(address)

@public
def __init__(uint256 _minimumBet, uint256 _lotteryLength):
  owner = msg.sender
  minimumBet = _minimumBet
  lotteryLength = _lotteryLength


@public
@payable
def play(bytes1 _pick):
  assert _pick != bytes1(0)
  assert msg.value == minimumBet
  thisPick: bytes32 = sha3(concat(resultBlock, _pick))
  assert userPicks[thisPick] == address(0)
  jackpot += msg.value
  userPicks[thisPick] = msg.sender

@public
def startLottery() -> bool:
  blockHash: bytes32 = blockhash(resultBlock)
  lastNumbers = blockHash[31]
  winner: address = userPicks[sha3(concat(resultBlock, lastNumbers))]
  if winner != address(0):
    playerWinnings: uint256 = (jackpot * 99) / 100
    delete jackpot
    owed[winner] += playerWinnings
    owner.transfer(address(this).balance)
  resultBlock = block.number + lotteryLength
  return True


  // --------------------------------------------------------------------------------------------------------------------------
  //                                            View Functions
  // --------------------------------------------------------------------------------------------------------------------------

@constant
def isPickAvailable(bytes1 _pick) -> bool:
  return userPicks[sha3(concat(resultBlock, _pick))] == address(0)

@constant
def currentBlock() -> uint256:
  return block.number

@constant
def isLotteryLive():
  return block.number < resultBlock



}
