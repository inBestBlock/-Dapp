pragma solidity ^0.4.24;

contract Shop {
    mapping (address=>uint16) myMoney;

    function buyApple() payable  external {
        myMoney[msg.sender]++;
    }

    function getMoney() view external returns(uint16) {
        return myMoney[msg.sender];
    }

    function sellMoney(uint _Price) payable external {
        uint refund = (myMoney[msg.sender] * _Price);
        myMoney[msg.sender] = 0;
        msg.sender.transfer(refund);
    }
}
