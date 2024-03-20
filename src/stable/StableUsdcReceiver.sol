// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * Helper contract that allows Stable to forward USDC to a reserve address and pause
 *   the contract in the case that mints are disabled for some reason.
 */
contract StableUsdcReceiver is Initializable, Ownable2StepUpgradeable {
    address public reserve;
    IERC20 public usdc;

    mapping(address => bool) public enabled;

    event ForwardToReserve(address indexed sender, address indexed reserve, address indexed to, uint256 amount);

    function initialize(address owner, address _reserve, IERC20 _usdc) external initializer {
        reserve = _reserve;
        usdc = _usdc;
        __Ownable_init(owner);
    }

    modifier whenEnabled() {
        require(enabled[msg.sender], "whenEnabled");
        _;
    }

    /**
     * @dev BaseReceiver will call this function to forward a user's USDC to the reserve address and mint USDLR.
     * @param sender The address that sent the USDC, usually the 4337 wallet
     * @param amount The amount of USDC to forward
     * @param to The address to send the USDC to on Edgeless
     */
    function forwardToReserve(address sender, uint256 amount, address to) external whenEnabled {
        usdc.transferFrom(msg.sender, reserve, amount);
        emit ForwardToReserve(sender, reserve, to, amount);
    }

    function setEnabled(address _address, bool _enabled) external onlyOwner {
        enabled[_address] = _enabled;
    }

    function setReserve(address _reserve) external onlyOwner {
        reserve = _reserve;
    }
}
