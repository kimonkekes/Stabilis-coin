// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DepositorCoin is ERC20 {
    address public owner;

    constructor() ERC20("DepositorCoin", "DEC") {
        owner = msg.sender;
    }

    function mint(address to, uint256 value) external {
        require(
            msg.sender == owner,
            "DepositorCoin: Only the owner can mint tokens"
        );
        _mint(to, value);
    }

    function burn(address from, uint256 value) external {
        require(
            msg.sender == owner,
            "DepositorCoin: Only the owner can burn tokens"
        );
        _burn(from, value);
    }
}
