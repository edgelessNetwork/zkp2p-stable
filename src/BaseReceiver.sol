// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BaseReceiver {
    address public stableReceiver;
    IERC20 public usdc;

    event Forward(address indexed sender, address indexed stableReceiver, address indexed to, uint256 amount);

    /**
     * @notice The owner of WrappedToken is the EdgelessDeposit contract
     */
    constructor(address _stableReceiver, IERC20 _usdc) {
        stableReceiver = _stableReceiver;
        usdc = _usdc;
    }

    /**
     * @dev 4337 wallet approves USDC to this contract, then calls this function to forward the USDC to the
     * stableReceiver
     * @param sender The address that sent the USDC, usually the 4337 wallet
     * @param amount The amount of USDC to forward
     * @param to The address to send the USDC to
     */
    function forward(address sender, uint256 amount, address to) external {
        usdc.transferFrom(sender, address(this), amount);
        usdc.transfer(stableReceiver, amount);
        emit Forward(sender, stableReceiver, to, amount);
    }
}
