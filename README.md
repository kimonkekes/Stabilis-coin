<div align="center">
  
![stabilis-banner](https://github.com/kimonkekes/Stabilis-coin/assets/126149828/8c44b012-151f-4b10-af20-38fd226d09b6)
<br>

## 🪙 a reserve asset stablecoin 🪙
</div>


**Stabilis** is a *DeFi stablecoin* implementation with a reserve asset stabilization mechanism.
<br><br>

Its base is an *ERC20 smart contract* for a stablecoin named `Stabilis`, which is **pegged to the US Dollar** at a 1:1 ratio. It is connected to a smart contract named `DepositorCoin`, which issues another token to the **providers of a collateral buffer** to the Stabilis smart contract.
<br><br>

## 📜 Smart contract details
<br>

The `contracts` folder contains 4 files:
<br><br>

➡️ **`Stabilis.sol`** is the *main stablecoin contract*. It includes functions that allow to:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - **mint and burn** Stabilis (the stablecoin) in exchange for ETH.
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - **view the transaction fee** for minting or burning Stabilis tokens.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - **deposit collateral buffer** in ETH and mint DepositorCoin tokens. The DepositorCoin tokens are minted to the users who **overcollateralize** (put extra ETH in) the contract, in order for it to have a safety margin. These users do not receive the Stabilis coin, but **DepositorCoin tokens** instead. The price of those depends on the amount of **surplus ETH in the contract**, provided that is has achieved a 1:1 price ratio to USD.

If the **inital collateral ratio** is not met (ETH in reserve is less than the USD value of minted Stabilis tokens), extra ETH must be deposited. After the ratio is met, the **remainder of the ETH value** will be minted as DepositorCoin tokens.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- **withdraw collateral buffer** in ETH and burn DepositorCoin tokens. If there is an **ETH deficit** in the contract, the DepositorCoin tokens are destroyed (due to their ETH equivalent being used towards maintaining the collateral ratio). Every time the DepositorCoin contract is deployed from within the Stabilis contract, it remains **locked for a period of time** defined during the initial Stabilis deployment. This offers to the first depositor the benefit of being the **only one** for that amount of time. It also prevents from withdrawing the collateral funds immediately and potentially de-pegging the stablecoin. 

➡️ **`Oracle.sol`** is a contract to set and view the ETH/USD price. In its current state, the price is set by the **deployer of the contract**. The contract can also be easily modified to accept **external data feed** on the price from a trusted oracle provider, such as **Chainlink**. Click [here](https://docs.chain.link/data-feeds) for more info.

➡️ **`DepositorCoin.sol`** is the token contract for the **surplus collateral providers**. It includes functions to mint and burn DepositorCoin tokens. The functions to deposit and withdraw collateral are handled by the Stabilis.sol contract, as mentioned above. The DepositorCoin contract is **deployed from inside the Stabilis contract** the first time anyone send ETH as collateral and if the contract ever has a collateral deficit. 

➡️ **`FixedPointMath.sol`** is a contract that includes **math formulas**. It ensures the correctness of the calculations between positive and negative integer numbers, as well as preserves decimal integrity in multiplication and division.
<br><br>

<div align="center">
🤖 Both the <a href="https://sepolia.etherscan.io/address/0xF46F0da4Fe3D8C87318F6b8940C44C42dc824291#code">Stabilis</a> and the <a href="https://sepolia.etherscan.io/address/0xe4Cbb0D2127e4fbbf157764cf09E995A69020a08#code">Oracle</a> <b>smart contracts</b> have been deployed on Sepolia testnet.
</div>

<br>

![sta2](https://github.com/kimonkekes/Stabilis-coin/assets/126149828/cee81f78-261d-4025-8167-bd404734279e)

<br>

>The **Oracle smart contract** has been deployed with the **predefined price** set as `2000` (1 ETH is equivalent to 2000 Stabilis tokens)<br>
>
>The **Stabilis smart contract** has been deployed with the following constructor parameters:<br>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- `0xe4Cbb0D2127e4fbbf157764cf09E995A69020a08` as the deployment address of the above **Oracle smart contract**<br>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- `2%` of the funds of every Stabilis *mint* or *burn* transaction are added as **transaction fee** in the contract balance<br>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- `20%` as the **collateral ratio percentage** (if there are **100 ETH in the contract** from minted *Stabilis tokens*, at least another **20 ETH extra** must be present from minted *Depositor Coin tokens*)<br>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- `10 minutes` is the **inital lock time** for the first minter of the Depositor Coin smart contract (during that time *no extra minting or burning is allowed*)
