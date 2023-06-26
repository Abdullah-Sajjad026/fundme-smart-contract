// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/*
    This is a FundMe contract. It is used to raise funds for a project. The project owner can
    withdraw the funds raised once the goal is reached.

    So, the flow of the contract is gonna be like this:
    - We shall set a mininum amount in usd that the end user can contribute.
    - We'll have a contract owner, a mapping of addresses to amounts funded, an
      array of addresses that have funded for the project.
    - After that we are gonna have a fund function that will first check the amount if that
      is above minimum amount that we have set and we shall revert if it is not.
    - If the amount is above the minimum amount then we shall add the address to the array of addresses
      and also map the amount funded with the address.
    - We'll have getter functions to allow public to see the amount funded by a particular address,
      the array of addresses that have funded and the total amount funded.
    - Then, we'll have withdraw function that will implement a modifier to only allow the contract owner
      to withdraw the funds. It shall remove all addresses from funders array and also reset the mapping.

      We'll use chainlink to get the price of ether in usd and then we'll use that to calculate the amount
        of ether that is required to reach the goal.
    Also, we can separate the logic getting price and converting ether to usd in a library and then import
      that library in our contract.
*/

// importing libraries
import "./PriceConverter.sol";

// custom errors
error FundMe__InsufficientAmount(uint256 amount, uint256 minimum);
error FundMe__WithdrawFailed();

/**
 * @title FundMe
 * @author Abdullah-Sajjad026
 * @notice A contract to raise funds for a project.
 * @dev It uses Chainlink Price Feeds to get the price of ether in usd and then uses that to calculate the amount of ether required to reach the goal.
 */
contract FundMe {
    // Type declarations
    using PriceConverter for uint256;

    // The minimum amount that the end user can contribute
    uint256 public constant MINIMUM_USD = 50 * (1 ** 18);

    // The contract owner
    address private immutable owner;

    // Mapping of addresses to amounts funded
    mapping(address => uint256) private addressToAmountFunded;

    // Array of addresses that have funded
    address[] private funders;

    // The price feed address for each blockchain is different, so we'll have to set it manually
    address private immutable priceFeedAddress;

    // Events
    event FundMe__Funded(address indexed funder, uint256 amount);

    // a modifier to only allow the contract owner to execute a function
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can withdraw");
        _;
    }

    // The constructor
    constructor(address _priceFeedAddress) {
        owner = msg.sender;
        priceFeedAddress = _priceFeedAddress;
    }

    // Special Functions
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        // check if the amount is above the minimum amount
        if (msg.value.convertEthToUsd(priceFeedAddress) < MINIMUM_USD) {
            revert FundMe__InsufficientAmount({
                amount: msg.value,
                minimum: MINIMUM_USD
            });
        }

        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;

        emit FundMe__Funded(msg.sender, msg.value);
    }

    /**
     * Withdraw the funds raised. Only the contract owner can withdraw the funds.
     * @dev It will reset the funders array and also the addressToAmountFunded mapping.
     * @dev It will revert if the withdraw fails.
     */
    function withdraw() public payable onlyOwner {
        // transfer the funds to the contract owner
        bool withdrawStatus = payable(owner).send(address(this).balance);
        if (!withdrawStatus) {
            revert FundMe__WithdrawFailed();
        }

        // if the withdraw was successful, reset funders and addressToAmountFunded
        for (uint256 i = 0; i < funders.length; i++) {
            addressToAmountFunded[funders[i]] = 0;
        }
        funders = new address[](0);
    }

    // Getter functions

    /**
     * Get the amount funded by a particular address.
     * @param _address The address of the funder.
     * @return The amount funded by the address.
     */
    function getAddressToAmountFunded(
        address _address
    ) public view returns (uint256) {
        return addressToAmountFunded[_address];
    }

    /**
     * Get the array of addresses that have funded.
     * @return The array of addresses that have funded.
     */
    function getFunders() public view returns (address[] memory) {
        return funders;
    }

    /**
     * Get a specific funder.
     * @param number The number of the funder.
     */
    function getSpecificFunder(
        uint256 number
    ) public view returns (address funder) {
        return funders[number - 1];
    }

    /**
     * Get the total amount funded.
     * @return The total amount funded.
     */
    function getTotalAmountFunded() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * Get the contract owner.
     * @return The contract owner.
     */
    function getOwner() public view returns (address) {
        return owner;
    }

    /**
     * Get the minimum amount that the end user can contribute.
     * @return The minimum amount that the end user can contribute.
     */
    function getMinimumWei() public pure returns (uint256) {
        return MINIMUM_USD;
    }

    /**
     * Get latest price of ether in usd.
     */
    function getLatestPrice() public view returns (uint256) {
        return PriceConverter.getEthPriceInUsd(priceFeedAddress);
    }
}
