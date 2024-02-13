// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract EdgelessReceiver is Initializable, Ownable2StepUpgradeable {
    address public stableReceiver;
    IERC20 public usdlr;
    uint256 public minAmount; // The minimum amount of USDLR to forward

    event SetStableReceiver(address indexed stableReceiver);
    event ForwardFrom(address indexed sender, address indexed stableReceiver, address indexed to, uint256 amount);

    error NotEnoughAmount(uint256 amount, uint256 minAmount);

    function initialize(
        address _owner,
        address _stableReceiver,
        IERC20 _usdlr,
        uint256 _minAmount
    )
        external
        initializer
    {
        stableReceiver = _stableReceiver;
        usdlr = _usdlr;
        minAmount = _minAmount;
        __Ownable_init(_owner);
    }

    /**
     * @dev User approves USDLR to this contract, then calls this function to forward the USDLR to the
     * stableReceiver
     * @param sender The address that sent the USDC, usually the 4337 wallet
     * @param amount The amount of USDC to forward
     * @param to The address to send the USDC to
     */
    function forwardFrom(address sender, uint256 amount, address to) external {
        if (amount < minAmount) {
            revert NotEnoughAmount({ amount: amount, minAmount: minAmount });
        }
        usdlr.transferFrom(sender, address(this), amount);
        usdlr.transfer(stableReceiver, amount);
        emit ForwardFrom(sender, stableReceiver, to, amount);
    }

    function setStableReceiver(address _stableReceiver) external onlyOwner {
        stableReceiver = _stableReceiver;
        emit SetStableReceiver(_stableReceiver);
    }

    function setMinAmount(uint256 _minAmount) external onlyOwner {
        minAmount = _minAmount;
    }
}
