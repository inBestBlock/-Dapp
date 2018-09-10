pragma solidity ^0.4.24;

contract CrowdFunder {
    address public creator;
    address public fundRecipient; 
    uint public minimumToRaise; 
    uint maximumToRaise;
    string campaignUrl;
    bool public test;
    uint revenue;
    
    enum State {
        Fundraising,
        ExpiredRefund,
        Successful
    }
    struct Contribution {
        uint amount;
        address contributor;
    }

    State public state = State.Fundraising; 
    uint public totalRaised;
    uint public raiseBy;
    uint public completeAt;
    Contribution[] contributions;

    event LogFundingReceived(address addr, uint amount, uint currentTotal);
    event LogWinnerPaid(address winnerAddress);
    
    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    modifier atEndOfLifecycle() {
    require(((state == State.ExpiredRefund || state == State.Successful) && completeAt + 24 weeks < now));
        _;
    }

    function CrowdFunder(uint timeInHoursForFundraising, string _campaignUrl, address _fundRecipient, uint _minimumToRaise, uint _maximunToRaise) public {
        creator = msg.sender;
        fundRecipient = _fundRecipient;
        campaignUrl = _campaignUrl;
        minimumToRaise = _minimumToRaise * 1000000000000000000;
        maximumToRaise = _maximunToRaise * 1000000000000000000;
        raiseBy = now + (timeInHoursForFundraising * 1 days);
    }

    function contribute() public payable inState(State.Fundraising) returns(uint256 id) {
        contributions.push(
            Contribution({
                amount: msg.value,
                contributor: msg.sender
            }) 
        );
        totalRaised += msg.value;

        LogFundingReceived(msg.sender, msg.value, totalRaised);
        checkIfFundingCompleteOrExpired();
        return (contributions.length - 1);
    }

    function checkIfFundingCompleteOrExpired() public returns (bool){
        if (totalRaised >= maximumToRaise) {
            state = State.Successful;
        
        }else if (totalRaised >=minimumToRaise && totalRaised <= maximumToRaise && now < raiseBy)
        {
            
        }
        else if (totalRaised >=minimumToRaise && totalRaised <= maximumToRaise && now > raiseBy)
        {
            state = State.Successful;
        }
        else if ( now > raiseBy && totalRaised < minimumToRaise)  {
            state = State.ExpiredRefund;
            for(uint id = 0; id <= contributions.length -1; id ++){
            getRefund(id);
            }
            totalRaised = 0;
        }
        
        completeAt = now;
        return test;
    }

    function payOut() public inState(State.Successful){
        fundRecipient.transfer(this.balance);
        LogWinnerPaid(fundRecipient);
    }

    function getRefund(uint256 id) inState(State.ExpiredRefund) public {
        uint256 amountToRefund = contributions[id].amount;
        
        contributions[id].contributor.transfer(amountToRefund);
        contributions[id].amount = 0;
    }
    
    function payback() public payable {
        require(msg.sender == creator);
        uint amountpayback = msg.value;
        
        for (uint num = 0; num <= contributions.length -1; num ++)
        {
        uint money = contributions[num].amount + (revenue);
        contributions[num].contributor.transfer(money);
        contributions[num].amount = 0;
        }
        totalRaised = 0;
    }

    function removeContract() public isCreator() atEndOfLifecycle(){
        selfdestruct(msg.sender);
    }
    

}
