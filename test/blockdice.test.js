const BlockDice = artifacts.require("BlockDice");
const assertRevert = require('./assertRevert');
const expectEvent = require('./expectEvent');

contract ('BlockDice', function([deployer, user1, user2]){//0,1,2 주소
    let blockdice;
    let betAmount = 10*10**15;
    beforeEach(async () => {
        console.log('Before each')
        blockdice = await BlockDice.new(); //스마트 컨트랙트 배포
    })


    it('getPot should return current pot', async () => {      
        let pot = await blockdice.getPot();
        assert.equal(pot,0)
    })

    describe('Bet', function () {
        it('should fail when the bet money is not 0.005 ETH', async () => {
           // Fail transaction
           await assertRevert(blockdice.bet(1,1,0, {from : user1, value: 4000000000000000}));
           // transaction object {chainId, value, to, from, gas(Limit), gasPrice}
        })
        it('should put the bet to the bet queue with 1 bet', async () => {
           // bet
           let receipt = await blockdice.bet(1,1,0, {from : user1, value: betAmount})
           //console.log(receipt);
           
           let pot = await blockdice.getPot();
           assert.equal(pot,0);
           // check contract balance == 0.01ETH
           let contractBalance = await web3.eth.getBalance(blockdice.address);
           assert.equal(contractBalance, betAmount);

           // check bet info
            let bet = await blockdice.getBetInfo(0);

            assert.equal(bet.bettor, user1);
            assert.equal(bet.challenge1,1);
            assert.equal(bet.challenge2,1);

           // check log
           //console.log(receipt);
           await expectEvent.inLogs(receipt.logs, 'BET')

        })
    })

    describe.only('isMatch', function () {
      
        it('should be BettingResult.Win when two nums match', async () => {
            let matchingResult = await blockdice.isMatch(1,1,1,1);
            console.log("win");
            console.log(matchingResult);
            assert.equal(matchingResult, 1);
        })

        it('should be BettingResult.Fail when two nums match', async () => {
            let matchingResult = await blockdice.isMatch(2,2,1,1);
            console.log("fail");
            console.log(matchingResult);
            assert.equal(matchingResult, 0);
        })
    })

    
});