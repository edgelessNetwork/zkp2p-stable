// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FiatTokenV2 is ERC20 {
    constructor() ERC20("USDLR", "USDLR") { }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
