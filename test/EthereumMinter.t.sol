// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import "forge-std/src/Vm.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { StdUtils } from "forge-std/src/StdUtils.sol";
import { EthereumMinter } from "../src/EthereumMinter.sol";
import { FiatTokenV2 } from "../src/FiatTokenV2.sol";

contract EthereumMinterTest is PRBTest, StdCheats, StdUtils {
    event Forward(address indexed sender, address indexed stableReceiver, address indexed to, uint256 amount);

    uint32 public constant FORK_BLOCK_NUMBER = 19_216_985; // 2/12/2024

    address public owner = makeAddr("Edgeless non-US KYCed entity");
    address public stableMinter = makeAddr("Stable Minter");
    address public edgelessUserWallet = makeAddr("Edgeless User Wallet");

    EthereumMinter public ethereumMinter;
    IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address USDC_WHALE = 0xD6153F5af5679a75cC85D8974463545181f48772;

    function setUp() public virtual {
        string memory alchemyApiKey = vm.envOr("API_KEY_ALCHEMY", string(""));
        vm.createSelectFork({
            urlOrAlias: string(abi.encodePacked("https://eth-mainnet.g.alchemy.com/v2/", alchemyApiKey)),
            blockNumber: FORK_BLOCK_NUMBER
        });
        vm.startPrank(stableMinter);
        ethereumMinter = new EthereumMinter();
        ethereumMinter.initialize(owner, IERC20(USDC), stableMinter);
        vm.stopPrank();
    }

    function test_Minting(uint256 amount) external {
        amount = bound(amount, 0, USDC.balanceOf(USDC_WHALE));
        vm.prank(USDC_WHALE);
        USDC.transfer(address(stableMinter), amount);
        vm.startPrank(stableMinter);
        USDC.approve(address(ethereumMinter), amount);
        ethereumMinter.mint(edgelessUserWallet, amount);
        assertEq(USDC.balanceOf(edgelessUserWallet), amount, "USDC balance of edgelessUserWallet should be amount");
        assertEq(USDC.balanceOf(stableMinter), 0, "USDC balance of stableMinter should be 0");
    }

    function test_UnauthorizedMinting(uint256 amount) external {
        amount = bound(amount, 0, USDC.balanceOf(USDC_WHALE));
        vm.prank(USDC_WHALE);
        USDC.transfer(address(stableMinter), amount);
        vm.startPrank(stableMinter);
        USDC.approve(address(ethereumMinter), amount);
        vm.stopPrank();
        address unauthorized = makeAddr("Unauthorized");
        vm.startPrank(unauthorized);
        vm.expectRevert();
        ethereumMinter.mint(edgelessUserWallet, amount);
    }

    function test_SetStableMinter() external {
        vm.startPrank(owner);
        address newStableMinter = makeAddr("New Stable Minter");
        ethereumMinter.setStableMinter(newStableMinter);
        assertEq(ethereumMinter.stableMinter(), newStableMinter, "Stable minter should be newStableMinter");
    }

    function test_UnauthorizedSetStableMinter() external {
        address newStableMinter = makeAddr("New Stable Minter");
        vm.expectRevert();
        ethereumMinter.setStableMinter(newStableMinter);
    }
}
