// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {DepositorCoin} from "./DepositorCoin.sol";
import {Oracle} from "./Oracle.sol";
import {FixedPoint, fromFraction, mulFixedPoint, divFixedPoint} from "./FixedPointMath.sol";

contract Stabilis is ERC20 {
    DepositorCoin public depositorCoin;
    Oracle public oracle;
    uint256 public feeRatePercentage;
    uint256 public initialCollateralRatioPercentage;
    uint256 public depositorCoinLockTime;

    constructor(
        Oracle _oracle,
        uint256 _feeRatePercentage,
        uint256 _initialCollateralRatioPercentage,
        uint256 _depositorCoinLockTime
    ) ERC20("Stabilis", "STA") {
        oracle = _oracle;
        feeRatePercentage = _feeRatePercentage;
        initialCollateralRatioPercentage = _initialCollateralRatioPercentage;
        depositorCoinLockTime = _depositorCoinLockTime;
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

        if (surplusOrDeficitInUsd <= 0) {
            uint256 deficitInUsd = uint256(surplusOrDeficitInUsd * -1);
            uint256 deficitInEth = deficitInUsd / oracle.getPrice();

            uint256 addedSurplusEth = msg.value - deficitInEth;

            uint256 requiredInitialSurplusInUsd = initialCollateralRatioPercentage * totalSupply() / 100;
            uint256 requiredInitialSurplusInEth = requiredInitialSurplusInUsd / oracle.getPrice();

            require(addedSurplusEth >= requiredInitialSurplusInEth, "Stabilis: Initial collateral ratio not met");

            uint256 initialDepositorSupply = addedSurplusEth * oracle.getPrice();

            depositorCoin = new DepositorCoin(
                depositorCoinLockTime,
                msg.sender,
                initialDepositorSupply);

            return;
        } 

        uint256 surplusInUsd =  uint256(surplusOrDeficitInUsd);
        FixedPoint usdInDepositorCoinPrice = fromFraction(depositorCoin.totalSupply(), surplusInUsd);

        uint256 mintDepositorCoinAmount = mulFixedPoint(msg.value * oracle.getPrice(), usdInDepositorCoinPrice);
        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
    }

    function withdrawCollateralBuffer(uint256 burnDepositorCoinamount) external {
        int256 surplusOrDeficitInUsd = _getSurplusOrDeficitInContractInUsd();
        require (surplusOrDeficitInUsd > 0, "Stabilis: No depositor funds available to withdraw");
        uint256 surplusInUsd = uint256(surplusOrDeficitInUsd);
        depositorCoin.burn(msg.sender, burnDepositorCoinamount);

        FixedPoint usdInDepositorCoinPrice = fromFraction(depositorCoin.totalSupply(), surplusInUsd);
        uint256 refundUsd = divFixedPoint(burnDepositorCoinamount, usdInDepositorCoinPrice);
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
