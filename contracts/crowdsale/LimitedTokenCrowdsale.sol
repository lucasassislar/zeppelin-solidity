pragma solidity ^0.4.15;

import '../token/StandardToken.sol';
import '../math/SafeMath.sol';

contract LimitedTokenCrowdSale {
    using SafeMath for uint256;

    // The token being sold
    StandardToken public token;

    // safe mode (if an integrity check failed, we give control to the organization)
    //bool public safeMode;

    // the total amount of tokens we have to supply
    //uint256 public tokenSupply;

    // start and end timestamps where investments are allowed (both inclusive)
    //uint256 public startTime;
    //uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;

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
    require(msg.sender != 0x0);
    require(msg.value != 0);

    uint256 weiAmount = msg.value;
    address sender = msg.sender;

    // calculate token amount to be sold
    uint256 tokens = weiAmount.mul(rate);

    // must have enough tokens to sell
    require(token.balanceOf(this) > tokens); 
    forwardTokens(tokens, msg.sender);
    forwardFunds(weiAmount);
    TokenPurchase(msg.sender, sender, weiAmount, tokens);

    // update state
    weiRaised = weiRaised.add(weiAmount);
  }

  function forwardTokens(uint256 tokenAmount, address sender) internal {
    token.transfer(sender, tokenAmount);
  }

  function forwardFunds(uint256 weiAmount) internal {
    wallet.transfer(weiAmount);
  }
}