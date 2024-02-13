// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract EthereumMinter is Initializable, Ownable2StepUpgradeable {
    IERC20 public usdc;
    address public stableMinter;

    event SetStableMinter(address indexed stableMinter);
    event Mint(address indexed stableMinter, address indexed to, uint256 amount);

    error OnlyStableMinter();

    modifier onlyStableMinter() {
        if (msg.sender != stableMinter) {
            revert OnlyStableMinter();
        }
        _;
    }

    /**
     * @notice Initialize the contract
     * @param _owner The owner of the contract
     * @param _usdc The USDLR token
     * @param _stableMinter The stable minter contract
     */
    function initialize(address _owner, IERC20 _usdc, address _stableMinter) external initializer {
        usdc = _usdc;
        stableMinter = _stableMinter;
        __Ownable_init(_owner);
    }

    /**
     * @dev Stable Minter mints USDLR, calls approve on USDLR to this contract, then calls this function to send the
     * USDLR to the user. We need this second minter contract here for legal reasons?
     * @param to The address to send the USDLR to
     * @param amount The amount of USDLR to mint
     */
    function mint(address to, uint256 amount) external onlyStableMinter {
        usdc.transferFrom(stableMinter, address(this), amount);
        usdc.transfer(to, amount);
        emit Mint(stableMinter, to, amount);
    }

    /**
     * @notice Set the stable minter contract
     * @param _stableMinter The new stable minter contract
     */
    function setStableMinter(address _stableMinter) external onlyOwner {
        stableMinter = _stableMinter;
        emit SetStableMinter(_stableMinter);
    }
}
