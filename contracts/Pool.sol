//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFactory {
    function getFee(address _pool) external view returns(uint256);

    function changeFee(address _pool, uint256 _royaltyFee) external returns(uint256);
}

contract Pool {

    struct UserPool {
        uint256 amount; // Amount of LP tokens
        uint startBlockIndex; // Block index when farming started
        uint lastHarvestBlock; // Block number of last harvest
        uint storedReward; // Harvested reward delayed until the transaction is unlocked
        uint depositTimestamp; // Timestamp of deposit
        uint harvestTimestamp; // Timestamp of last harvest
    }

    struct Stakers{
        uint256 stakingBalance;
        uint256 approvedRoyalty;
    }

    IERC20 public tokenAddress;
    address public factoryAddress;
    uint256 public royaltyFee;

    mapping(address => Stakers) stakers;

    constructor(IERC20 _token, uint256 _royaltyFee) {
        tokenAddress = _token;
        factoryAddress = msg.sender;
        royaltyFee = _royaltyFee;
  }

    function addLiquidity(uint256 _tokenAmount) public {
        require(_tokenAmount > 0, "You should add ROYAL tokens");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _tokenAmount);
        stakers[msg.sender].stakingBalance += _tokenAmount;
    }

    function getReserve() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getRoyaltyFee() public view returns(uint256){
        uint256 stakersRoyalty = IFactory(factoryAddress).getFee(address(this));
        return stakersRoyalty;
    }

    // for royalty interface 
    function getPoolAddress() private view returns(address){
        return address(this);
    }

    function getAmountRoyalty() public view returns(uint256){
        return address(this).balance;
    }

    function calculateRoyalty(uint256 _royaltyFee) private returns(uint256){
        stakers[msg.sender].approvedRoyalty = getAmountRoyalty() * ((_royaltyFee * stakers[msg.sender].stakingBalance) / (getReserve() * 100));
        return stakers[msg.sender].approvedRoyalty;
    }

    function withdrawRoyalty() public payable {
        royaltyFee = 0;
        if (msg.sender == factoryAddress) {
            royaltyFee = 100 - getRoyaltyFee();
        } else {
            require(
                stakers[msg.sender].stakingBalance != 0,
                "You don't have staking balance"
            );
            royaltyFee = getRoyaltyFee();
            IERC20(tokenAddress).transferFrom(address(this), msg.sender, stakers[msg.sender].stakingBalance);
        }
        payable(msg.sender).transfer(calculateRoyalty(royaltyFee));
    }
}
