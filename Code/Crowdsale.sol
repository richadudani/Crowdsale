pragma solidity ^0.5.0;

import "./PupperCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

// @TODO: Inherit the crowdsale contracts
contract PupperCoinSale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, RefundablePostDeliveryCrowdsale {

    constructor(
        // Here are the the constructor parameters!
        uint rate, // rate in TKNbits
        address payable wallet, // sale beneficiary
        PupperCoin token, // the PupperCoin itself that the PupperCoinSale will work with
        uint256 openingTime,     // opening time in unix epoch seconds
        uint256 closingTime,      // closing time in unix epoch seconds
        uint256 goal             // the minimum goal, in wei
    )
        // Passing the constructor parameters to the crowdsale contracts.
        Crowdsale(rate, wallet, token)
        MintedCrowdsale()
        CappedCrowdsale(goal)
        TimedCrowdsale(openingTime, closingTime)
        RefundableCrowdsale(goal)
        public
    {
        // constructor can stay empty
    }
}

contract PupperCoinSaleDeployer {

    address public token_sale_address;
    address public token_address;

    constructor(
        // Filling in the constructor parameters!
        string memory name,
        string memory symbol,
        address payable wallet, // this address will receive all Ether raised by the sale
        uint256 goal
    )
        public
    {
        // Creating the PupperCoin and keeping its address handy
        PupperCoin token = new PupperCoin(name, symbol, 0);
        token_address = address(token);

        // Creating the PupperCoinSale and passing the token, setting the goal, and setting the open and close times to now and now + 24 weeks.
        PupperCoinSale pupper_sale = new PupperCoinSale(1, wallet, token, now, now + 24 weeks, goal);
        token_sale_address = address(pupper_sale);

        //Making the PupperCoinSale contract a minter, then have the PupperCoinSaleDeployer renounce its minter role
        token.addMinter(token_sale_address);
        token.renounceMinter();
    }
}