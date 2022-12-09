// SPDX-License-Identifier : MIT

 pragma solidity ^0.8.17;

  import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

  contract Crowdfunding{

 struct Campaign{
     address beneficiary;
     uint target;
     uint give;
     uint32 startAt;
     uint32 endAt;
     bool withdrawn;
 }
  
  IERC20 public immutable token;
  mapping(uint => Campaign) campaigns;
  uint public count;
  mapping(uint => mapping(address => uint)) MoneyRaised;

  constructor(address _token) {
    token = IERC20(_token);
  }

    function Begin(
        uint _target,
        uint32 _startAt,
        uint32 _endAt
    ) external {

    require(_startAt >= block.timestamp, "it has not started yet");
    require(_endAt >= _startAt, "can only end after it has started");
    require(_endAt <= block.timestamp + 30 days, "the duration is 30 days");

        // incrementation by 1
        count += 1;
        // setting the struct
     campaigns[count] = Campaign({
      beneficiary: msg.sender,
      target: _target,
      give: 0,
      startAt: _startAt,
      endAt: _endAt,
      withdrawn: false
     });

    }

    function Cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.beneficiary == msg.sender, "only the owner can cancel");
        require(block.timestamp <= campaign.startAt, "canceling should have been before it started");

        //deleting an array
        delete campaigns[_id];
    }

    function Give(uint _id, uint _amount) external {
      Campaign memory campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "canceling should have been before it started");
        require(block.timestamp <= campaign.endAt, "it has ended");
     campaign.give += _amount;
     MoneyRaised[_id][msg.sender] += _amount;
     token.transferFrom(msg.sender, address(this), _amount);
    }

    function TakeMoneyBack(uint _id, uint _amount) external {
         Campaign memory campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "canceling should have been before it started");
        require(block.timestamp <= campaign.endAt, "it has ended");
     campaign.give -= _amount;
     MoneyRaised[_id][msg.sender] -= _amount;
     token.transferFrom(msg.sender, address(this), _amount);
    }

    function BeneficiaryClaim(uint _id) external {
        Campaign memory campaign = campaigns[_id];

    require(campaign.beneficiary == msg.sender, "only the beneficiary can call this function");
    require(block.timestamp > campaign.endAt, "it has ended");
    require(campaign.give >= campaign.target, "the money realized surpassed the target");
    require(!campaign.withdrawn, "it has been withdrawn, and you cannot withdraw");

    campaign.withdrawn = true;
    
    token.transfer(campaign.beneficiary, campaign.give);
    }
// token implementatio compliance functions
// without these functions in the contract, the IERC20 import will not work
    function totalSupply() external view returns (uint256){
    }

    function balanceOf(address account) external view returns (uint256){
    }

    function transfer(address to, uint256 amount) external returns (bool){
    }

    function allowance(address owner, address spender) external view returns (uint256){
    }

    function approve(address spender, uint256 amount) external returns (bool){
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool){
    }
}




  
