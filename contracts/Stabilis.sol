// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {DepositorCoin} from "./DepositorCoin.sol";
import {Oracle} from "./Oracle.sol";

contract Stabilis is ERC20 {
    DepositorCoin public depositorCoin;
    Oracle public oracle;
    uint256 public feeRatePercentage;
    uint256 public initialCollateralRatioPercentage;

    constructor(
        Oracle _oracle,
        uint256 _feeRatePercentage,
        uint256 _initialCollateralRatioPercentage
    ) ERC20("Stabilis", "STA") {
        oracle = _oracle;
        feeRatePercentage = _feeRatePercentage;
        initialCollateralRatioPercentage = _initialCollateralRatioPercentage;
    }

    function mintStabilis() external payable {
        uint256 fee = _getFee(msg.value);
        uint256 mintStabilisAmount = (msg.value - fee) * oracle.getPrice();
        _mint(msg.sender, mintStabilisAmount);
    }

    function burnStabilis(uint256 burnStabilisAmount) external {
        _burn(msg.sender, burnStabilisAmount);

        uint256 refundEth = burnStabilisAmount / oracle.getPrice();
        uint256 fee = _getFee(refundEth);

        (bool success, ) = msg.sender.call{value: refundEth - fee}("");
        require(success, "Stabilis: Burn and refund transaction failed");
    }

    function _getFee(uint256 ethAmount) private view returns (uint256){
        return (ethAmount * feeRatePercentage) / 100;
    }

    function depositCollateralBuffer() external payable {
        int256 surplusOrDeficitInUsd = _getSurplusOrDeficitInContractInUsd();

        uint256 usdInDepositorCoinPrice;
        uint256 addedSurplusEth;

        if (surplusOrDeficitInUsd <= 0) {
            uint256 deficitInUsd = uint256(surplusOrDeficitInUsd * -1);
            uint256 deficitInEth = deficitInUsd / oracle.getPrice();

            addedSurplusEth = msg.value - deficitInEth;

            uint256 requiredInitialSurplusInUsd = initialCollateralRatioPercentage * totalSupply() / 100;
            uint256 requiredInitialSurplusInEth = requiredInitialSurplusInUsd / oracle.getPrice();

            require(addedSurplusEth >= requiredInitialSurplusInEth, "Stabilis: Initial collateral ratio not met");

            depositorCoin = new DepositorCoin();

            usdInDepositorCoinPrice = 1;
        } else {
            uint256 surplusInUsd =  uint256(surplusOrDeficitInUsd);

            usdInDepositorCoinPrice = depositorCoin.totalSupply() / surplusInUsd;
            addedSurplusEth = msg.value;
        }

        uint256 mintDepositorCoinAmount = addedSurplusEth * oracle.getPrice() * usdInDepositorCoinPrice;
        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
    }

    
    function withdrawCollateralBuffer(uint256 burnDepositorCoinamount) external {
        int256 surplusOrDeficitInUsd = _getSurplusOrDeficitInContractInUsd();
        require (surplusOrDeficitInUsd > 0, "Stabilis: No depositor funds available to withdraw");
        uint256 surplusInUsd = uint256(surplusOrDeficitInUsd);
        depositorCoin.burn(msg.sender, burnDepositorCoinamount);

        uint256 usdInDepositorCoinPrice = depositorCoin.totalSupply() / surplusInUsd;
        uint256 refundUsd = burnDepositorCoinamount / usdInDepositorCoinPrice;
        uint256 refundEth = refundUsd / oracle.getPrice();

        (bool success, ) = msg.sender.call{value: refundEth}("");
        require(success, "Stabilis: Withdraw ETH collateral transaction failed");
    }

    function _getSurplusOrDeficitInContractInUsd() private view returns (int256) {
        uint256 ethContractBalanceInUsd = (address(this).balance - msg.value) * oracle.getPrice();

        uint256 totalStabilisBalanceInUsd = totalSupply();

        int256 surplusOrDeficit = int256(ethContractBalanceInUsd) - int256(totalStabilisBalanceInUsd);
        return surplusOrDeficit;
    }
}
