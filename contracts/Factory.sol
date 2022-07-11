//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Pool.sol";

contract Factory {

    struct Pools {
        IERC20 poolToken;
        address poolOwner;
        address poolAddress;
        uint256 royaltyFee;
    }

    mapping(address => Pools) public pools;

    function createPool(
        IERC20 _token,
        uint256 _royaltyFee
        ) public returns (address) {

        address _msgSender = msg.sender;   
        require(address(_token) != address(0), "Wrong token address");
        require(
            _royaltyFee >= 1,
            "Please use royaly percent in integers"
        );
        require(
            pools[_msgSender].poolOwner != _msgSender,
            "You can create just one pool"
        );

        Pool pool = new Pool(_token, _royaltyFee);
        pools[_msgSender].poolToken = _token;
        pools[_msgSender].poolOwner = _msgSender;
        pools[_msgSender].poolAddress = address(pool);
        pools[_msgSender].royaltyFee = _royaltyFee;
        return address(pool);
    }

    // function getFee(address _poolOwner) public view returns(uint256){
    //     return pools[_poolOwner].royaltyFee;
    // }

    // function changeFee(
    //     address _pool,
    //     uint256 _royaltyFee
    //     ) public returns(uint256){

    //     require(
    //         pools[address(_pool)].owner == msg.sender,
    //         "You are not owner of this pool"
    //     );
    //     require(_royaltyFee >= 1, "Please use royaly percent in integers");

    //     pools[address(_pool)].royaltyFee = _royaltyFee;
    //     return pools[address(_pool)].royaltyFee;
    // }
}
