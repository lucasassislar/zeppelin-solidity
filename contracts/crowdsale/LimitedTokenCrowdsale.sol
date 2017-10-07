pragma solidity ^0.4.15;

import '../token/StandardToken.sol';
import '../math/SafeMath.sol';

contract LimitedTokenCrowdSale {
    // safemath for the .add, .mul used everywhere that deals with tokens/eth
    using SafeMath for uint256;

    // The token being sold
    StandardToken public token;

    // safe mode (if an integrity check failed, we give control to the organization)
    //bool public safeMode;

    // address where tokens balances are stored (for user withdrawal)
    mapping(address => uint256) public tokenBalance;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;

    // amount of total tokens sold
    uint256 public tokensSold;

    /**
    * event for token purchase logging
    * @param purchaser who paid for the tokens
    * @param beneficiary who got the tokens
    * @param value weis paid for purchase
    * @param amount amount of tokens purchased
    */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function LimitedTokenCrowdSale(uint256 _rate, address _tokenAddress, address _wallet) {
      require(_rate > 0);
      require(_tokenAddress != 0x0);

      rate = _rate;
      token = StandardToken(_tokenAddress);
      wallet = _wallet;
  }

  function () payable {
    buyToken();
  }

  // Saves how much the user bought in tokens
  function buyToken() payable {
    require(msg.sender != 0x0);
    require(msg.value != 0);

    uint256 weiAmount = msg.value;
    address sender = msg.sender;

    // calculate token amount to be sold
    uint256 tokens = weiAmount / rate;

    // must have enough tokens to sell
    require(token.balanceOf(this) > tokens); 
    
    tokenBalance[sender] = tokenBalance[sender].add(tokens);

    // update how much wei we have raised
    weiRaised = weiAmount.add(weiRaised);
    tokensSold = tokensSold.add(tokens);

    TokenPurchase(msg.sender, sender, weiAmount, tokens);
  }

  // Withdraws the tokens that the sender owns
  function withdrawTokens() public {
    uint256 balance = tokenBalance[msg.sender];
    require(balance > 0);

    tokenBalance[msg.sender] = 0;
    if (!token.transfer(msg.sender, balance))
    {
      tokenBalance[msg.sender] = balance;
    }
  }

  // Send all the funds currently in the wallet to 
  // the organization wallet provided at the contract creation
  function withdrawFunds() public {
    require(this.balance > 0);

    wallet.transfer(this.balance);
  }
}