pragma solidity >=0.4.21 <0.6.0;

contract BlockDice {

    struct BetInfo {
        address payable bettor; // payable 특정블럭에 돈을 보내야함
        uint8 challenge1;
        uint8 challenge2;
        uint256 rotate;
    }

    struct BetResult {
        uint8 dice1;
        uint8 dice2;
        uint256 rotate;
    }

    uint256 private _tail;
    uint256 private _head;
    mapping (uint256 => BetInfo) private _bets;

    uint256 private _atail;
    uint256 private _ahead;
    mapping (uint256 => BetResult) private _answers;

    address payable public owner;

    uint256 constant internal BET_AMOUNT = 10 * 10 ** 15;//0.01 ETH
    uint256 private _pot; //pot머니
    uint256 private _rotate = 1;//회차

    enum BettingResult {Fail, Win}
    event BET(uint256 index, address bettor, uint256 amount, uint8 challenge1, uint8 challenge2, uint256 rotate);
    event WIN(uint256 index, address bettor, uint256 amount, uint8 challenge1, uint8 challenge2,  uint256 rotate , uint8 dice1, uint8 dice2);
    event FAIL(uint256 index, address bettor, uint256 amount, uint8 challenge1, uint8 challenge2,  uint256 rotate , uint8 dice1, uint8 dice2);

    constructor() public { 
        owner = msg.sender;
    }

    function getPot() public view returns (uint256 pot) {
        return _pot;
    }

     function getRotate() public view returns (uint256 rotate) {
        return _rotate;
    }


    // Bet
    /**
    * @dev 베팅을 한다. 유저는 0.01eth를 보내야하고 베팅용 1byte 글자를 보낸다.
    * 큐에 저장된 베팅 정보는 이후 distyribute 함수에서 해결된다.
    * @param challenge1 dice1 베팅값
    * @param challenge2 dice2 베팅값
    * @return 함수가 잘 수행되었는지 확인하는 bool값
    */
    function bet(uint8 challenge1, uint8 challenge2, uint256 rotate) public payable returns (bool result) {
        //check the proper ether is sent
        require(msg.value == BET_AMOUNT, "Not enough ETH");
        //push bet to the queue
        require(pushBet(challenge1, challenge2, rotate), "Fail to add a new Bet Info");
        //emit event
        emit BET(_tail-1, msg.sender, msg.value, challenge1, challenge2, rotate);
        _pot = _pot + BET_AMOUNT;

        return true;
    }

    //Distribute
    /**
     * @dev 베팅 결과값을 확인 하고 팟머니를 분배한다.
     * 정답 실패 : 팟머니 축적, 정답 : 팟머니 획득
     */
    function distribute(uint8 dice1, uint8 dice2, uint256 rotate) public payable {
        //head 3 4 5 6 7 8 9 10 11 12 tail
        uint256 cur;
        uint256 transferAmount;

        require(pushAnswers(dice1, dice2, rotate), "Fail to add a new Answer Info");

        BetInfo memory b;
        BetResult memory r;
        BettingResult currentBettingResult;
        r = _answers[_atail - 1];

        for(cur = _head; cur<_tail ; cur++) {
            b = _bets[cur];

            require(r.rotate == b.rotate, "Not this rotate");
            currentBettingResult = isMatch(b.challenge1, b.challenge2, r.dice1, r.dice2);
            //if win, bettor gets pot
            if(currentBettingResult == BettingResult.Win) {
                //transfer pot
                transferAmount = transfetAfterPayingFee(b.bettor, BET_AMOUNT);
                // pot = pot - BET_AMOUNT* 1.9
                _pot = _pot - transferAmount;
                //emiit WIN
                emit WIN(cur, b.bettor, transferAmount, b.challenge1, b.challenge2, b.rotate, r.dice1, r.dice2);
            }
            //if fail, bettor's money goes pot
            if(currentBettingResult == BettingResult.Fail) {
                //pot = pot + BET_AMOUNT
                //_pot = _pot + BET_AMOUNT;
                emit FAIL (cur, b.bettor, 0, b.challenge1, b.challenge2, b.rotate, r.dice1, r.dice2);
            }

            popBet(cur);
        }
        _head = cur;
        _rotate++;
    }

    // 수수료 0.001 eth , amountwithoutfee 0.019 eth
        function transfetAfterPayingFee(address payable addr, uint256 amount) internal returns(uint256) {

        uint256 fee = amount / 10; //0.001eth
        uint256 amountWithoutFee = 2 * amount - fee; // 2*0.01 - 0.001 = 0.019 eth

        //transfer to addr
        addr.transfer(amountWithoutFee);
        //transfer to owner
        owner.transfer(fee);

        return amountWithoutFee;
    }

    /**
     * @dev 베팅한값과 정답을 확인한다.
     * @param challenge1 dice1베팅값
     * @param challenge2 dice2베팅값
     * @param dice1 정답값1
     * @param dice2 정답값2
     * @return 정답결과
     */
    function isMatch(uint8 challenge1, uint8 challenge2, uint8 dice1, uint8 dice2) public pure returns(BettingResult) {
      
        if(challenge1 == dice1 && challenge2 == dice2) {
            return BettingResult.Win;
        }

        return BettingResult.Fail;
    }

    function getBetInfo(uint256 index) public view returns (address bettor, uint8 challenge1, uint8 challenge2, uint256 rotate) {
        BetInfo memory b = _bets[index];
        bettor = b.bettor;
        challenge1 = b.challenge1;
        challenge2 = b.challenge2;
        rotate = b.rotate;
    }

    function pushBet(uint8 challenge1, uint8 challenge2, uint256 rotate) internal returns (bool) {

        BetInfo memory b;
        b.bettor = msg.sender;
        b.challenge1 = challenge1;
        b.challenge2 = challenge2;
        b.rotate = rotate;

        _bets[_tail] = b;
        _tail++;

        return true;
    }

    function pushAnswers(uint8 dice1, uint8 dice2, uint256 rotate) internal returns (bool) {

        BetResult memory r;
        r.dice1 = dice1;
        r.dice2 = dice2;
        r.rotate = rotate;

        _answers[_atail] = r;
        _atail++;

        return true;
    }

    function popBet(uint256 index) internal returns (bool) {
        delete _bets[index];
        return true;
    }
}