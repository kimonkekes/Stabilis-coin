<div align="center">
  
# 🪙 Stabilis 🪙
</div>
<br>

**Stabilis** is a *DeFi stablecoin* implementation with a reserve asset stabilization mechanism.
<br><br>

Its base is an *ERC20 smart contract* for a stablecoin named `Stabilis`, which is **pegged to the US Dollar** at a 1:1 ratio. It is connected to a smart contract named `DepositorCoin`, which issues another token to the **providers of a collateral buffer** to the Stabilis contract.
<br><br>

## 📜 Smart contract details
<br>

The `contracts` folder contains 4 files:
<br><br>

➡️ **`Stabilis.sol`** is the *main stablecoin contract*. It includes funtions that allow to:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - **mint and burn** Stabilis (the stablecoin) in exchange for ETH.
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - **view the transaction fee** for minting or burning Stabilis tokens.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - **deposit collateral buffer** in ETH and mint DepositorCoin tokens. The DepositorCoin tokens are minted to the users who overcollateralize &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(put extra ETH in) the contract, in order for it to have a a safety margin. These users do not receive the Stabilis coin, but DepositorCoin &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tokens instead. The price of those depends on the amount of surplus ETH in the contract, provided that is has achieved a 1:1 price ratio &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;to USD.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If the inital collateral ratio is not met (ETH in reserve is less than the USD value of minted Stabilis tokens), extra ETH must be deposited. &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;After the ratio is met, the remainder of the ETH value will be minted aas DepositorCoin tokens.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- **withdraw collateral buffer** in ETH and burn DepositorCoin tokens. If there is an ETH deficit in the contract, the DepositorCoin tokens are &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destroyed (due to their ETH equivalent being used towards maintaining the collateral ratio). Every time the contract is deployed, it &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;remains locked for a period of time defined during contract deployment. This offers to the first depositor the benefit of being the only &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;one for that amount of time. It also prevents from withdrawing the collateral funds immediately and potentially de-pegging the &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;stablecoin. 

➡️ **`Oracle.sol`** is a contract to set and view the ETH/USD price. In its current state, the price is set by the deployer of the contract. The contract &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;can also be easily modified to accept external data feed on the price from a trusted oracle provider, such as Chainlink. Click [here](https://docs.chain.link/data-feeds) for &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;more info.

➡️ **`DepositorCoin.sol`** is the token contract for the surplus collateral providers. It includes functions to mint and burn DepositorCoin tokens. &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The functions to deposit and withdraw collateral are handled by the Stabilis.sol contract, as mentioned above. The DepositorCoin &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;contract is deployed from inside the Stabilis contract the first time anyone send ETH as collateral and if the contract ever has a collateral &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;deficit. 

➡️ **`FixedPointMath.sol`** is a contract that includes math formulas. It ensures the correctness of the calculations between positive and negative &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;integer numbers, as well as preserves decimal integrity in multiplication and division.
<br><br>

## 🚀 Deployment
<br>

⚠️ Coming soon ⚠️
