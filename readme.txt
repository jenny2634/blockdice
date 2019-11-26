truffle init 트러플 프로젝트 기본 세팅 
truffle compile
-> build folder생김 

 
 ganache-cli -d -m bsj //mnemonic(powershell)

배포 truffle migrate
재배포 truffle migrate --reset

truffle migrate --network development // config에 있는 development

truffle console -> 스마트 컨트랙트 접근 가능 
web3 사용가능 
eth = web3.eth
eth.getAccounts()
eth.getBalance()

BlockDice.address
BlockDice.deployed
BlockDice.deployed().then(function(instance){lt=instance})
lt -> lt안에 배포된 거 들어옴

npm install chai

************************************************

webStrom 

truffle networks 
- 배포된 곳 알수있음 
truffle console --network development 연결
truffle console --network rinkeby
let hello = await HelloWord.at('컨트랙트주소')
hello.say() -> hello

단위테스트 test.js

it() -> 함수 호출
before에서 인스턴스 만들어주고 
it 단위테스트 코드 작성
const / await /async
assert.equal () 값, 비교하는값/맞음 , 틀림

실행은 truffle test -> test 디렉토리 안에있는 모든 테스트 실행

truffle unbox react -> 리액트 사용할때 편리
truffle compile -> contracts 생김 json 파일

npm run start -> 리액트 실행



@@@@@@@@@@@@@@@@@@@@@@@@@@

Lottery.address
Lottery.deployed
Lottery.deployed().then(function(instance){lt=instance})

lt
lt. tabtab키 누르기
lt.abi 
lt.owner
lt.getSomeValue()

truffle test -> 전체 테스트 파일 실행
truffle test test/lottery.test.js -> 단일 파일 실행

실행하지전에 가나쉬 켜기
    ganache-cli

------------------
dapp서비스 설계
1. 지갑관리
2. 아키텍쳐
    a. smart contract - front
    b. smart contract - server - front
3. code
    a. 코드를 실행하는데 돈이 든다
    b. 권한 관리
    c. 비즈니스 로직 업데이트
    d. 데이터 마이그레이션
4. 운영
    a. public
    b. private 


lottery 규칙
1. +3번째 블록해쉬의 첫 두 글자 맞추기 '0xab...'
    a. 유저가 던진 트랜잭션이 들어가는 블록 +3의 블록해쉬와 값을 비교
2. 팟머니
    a. 결과가 나왔을 때만 유저가 보낸 돈을 팟머니에 쌓기
    b. 여러 명이 맞추었을 때는 가장 먼저 맞춘 사람이 팟머니를 가져간다.
    c. 두 글자 중 하나만 맞추었을 때는 보낸 돈을 돌려준다. 0.005ETH : 10 **15 wei
    d. 결과값을 검증할 수 없을 때에는 보낸 돈을 돌려준다.



    ------------------------------
    openZeppelin - 잘 사용하는 라이브러리 소스 
    etherscan 

    -----------------------------
    이더리움 수수료
    - gas(gasLimit)
    - gasPrice
    - ETH
    - 수수료 = gas(21000) * gasPrice(100gwei = 10 ** 9wei)
    - 21000000000000 wei = 0.0021 ETH
    - 1ETH = 10 ** 18 wei 

    Gas 계산
    - 32 bytes 새로 저장 == 20000 gas
    - 32 bytes 기존 변수에 있는 값을 바꿀 때 = 5000 gas
    (기존 변수를 초기화해서 더 쓰지 않을 때 -> 10000 gas return)


    - bet 90846 -> 75846 
    // - bet 90736 -> 75736 (나)
    - 기본 21000 gas 사용 + 60000 gas + event(50000)= ~ 86000 gas

-----------------------

재배포 truffle migrate --reset

truffle console
Lottery.deployed().then(function(instance){lt=instance})
web3.eth.getAccounts()
let bettor = '0x6a23638897D4D0d01fC16F43688580C3F0ac8E23'
lt.bet("0xab", {from:bettor, value:5000000000000000, gas:300000})


let ac1 = '0x50519836281A5163A82A726971E7fb63CecD8d96'
web3.eth.sendTransaction({from:ac1, to:'0x4762e30D015f6D232D1A92A570E548Df460e27E2',value:10000000000000000000}) => 10eth 