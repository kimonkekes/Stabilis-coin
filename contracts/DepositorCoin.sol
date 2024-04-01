// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DepositorCoin is ERC20 {
    address public owner;
    uint256 public unlockTime;

    constructor(
        uint256 _lockTime,
        address _initialOwner,
        uint256 _initialSupply
    ) ERC20("DepositorCoin", "DEC") {
        owner = msg.sender;
        unlockTime = block.timestamp + _lockTime;

        _mint(_initialOwner, _initialSupply);
    }

    function mint(address to, uint256 value) external {
        require(msg.sender == owner, "DepositorCoin: Only the owner can mint tokens");
        require(block.timestamp >= unlockTime, "DepositorCoin: Minting function is still locked");

        _mint(to, value);
    }

    function burn(address from, uint256 value) external {
        require(msg.sender == owner, "DepositorCoin: Only the owner can burn tokens");
        require(block.timestamp >= unlockTime, "DepositorCoin: Burning function is still locked");

        _burn(from, value);
    }
}
