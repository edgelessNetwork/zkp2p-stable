// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BaseReceiver is Initializable, Ownable2StepUpgradeable {
    address public stableReceiver;
    IERC20 public usdc;

    event SetStableReceiver(address indexed stableReceiver);
    event Forward(address indexed sender, address indexed stableReceiver, address indexed to, uint256 amount);

    function initialize(address _owner, address _stableReceiver, IERC20 _usdc) external initializer {
        stableReceiver = _stableReceiver;
        usdc = _usdc;
        __Ownable_init(_owner);
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

    function setStableReceiver(address _stableReceiver) external onlyOwner {
        stableReceiver = _stableReceiver;
        emit SetStableReceiver(_stableReceiver);
    }
}
