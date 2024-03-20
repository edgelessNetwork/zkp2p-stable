// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import "forge-std/src/Vm.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { StdUtils } from "forge-std/src/StdUtils.sol";
import { BaseReceiver } from "../src/BaseReceiver.sol";
import { StableUsdcReceiver } from "../src/stable/StableUsdcReceiver.sol";

contract BaseReceiverTest is PRBTest, StdCheats, StdUtils {
    event ForwardFrom(
        address indexed sender, StableUsdcReceiver indexed stableReceiver, address indexed to, uint256 amount
    );

    uint32 public constant FORK_BLOCK_NUMBER = 10_378_806; // 2/9/2024

    address public owner = makeAddr("Edgeless non-US KYCed entity");
    StableUsdcReceiver public stableReceiver;
    address public zkp2p4337Wallet = makeAddr("zkp-p2p 4337 Wallet");
    address public edgelessUserWallet = makeAddr("Edgeless User Wallet");

    BaseReceiver public baseReceiver;
    IERC20 public USDC = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    address USDC_WHALE = 0x20FE51A9229EEf2cF8Ad9E89d91CAb9312cF3b7A;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        string memory alchemyApiKey = vm.envOr("API_KEY_ALCHEMY", string(""));
        vm.createSelectFork({ urlOrAlias: "https://mainnet.base.org", blockNumber: FORK_BLOCK_NUMBER });
        vm.startPrank(owner);
        baseReceiver = new BaseReceiver();
        stableReceiver = new StableUsdcReceiver();
        stableReceiver.initialize(owner, owner, USDC);
        stableReceiver.setEnabled(address(baseReceiver), true);
        baseReceiver.initialize(owner, stableReceiver, USDC);
        vm.stopPrank();
    }

    function test_Forwarding(uint256 amount) external {
        amount = bound(amount, 0, USDC.balanceOf(USDC_WHALE));
        vm.prank(USDC_WHALE);
        USDC.transfer(zkp2p4337Wallet, amount);
        vm.startPrank(zkp2p4337Wallet);
        USDC.approve(address(baseReceiver), amount);
        baseReceiver.forwardFrom(zkp2p4337Wallet, amount, edgelessUserWallet);
        assertEq(USDC.balanceOf(address(baseReceiver)), 0, "BaseReceiver should have 0 USDC after forwarding");
        assertEq(
            USDC.balanceOf(stableReceiver.reserve()),
            amount,
            "Edgeless User Wallet should have `amount` of USDC after forwarding"
        );
    }

    function test_SetStableReceiver() external {
        vm.startPrank(owner);
        StableUsdcReceiver newStableReceiver = StableUsdcReceiver(makeAddr("New Stable Receiver"));
        baseReceiver.setStableReceiver(newStableReceiver);
        assertEq(
            address(baseReceiver.stableReceiver()),
            address(newStableReceiver),
            "Stable receiver should be newStableReceiver"
        );
    }

    function test_UnauthorizedSetStableReceiver() external {
        StableUsdcReceiver newStableReceiver = StableUsdcReceiver(makeAddr("New Stable Receiver"));
        vm.expectRevert();
        baseReceiver.setStableReceiver(newStableReceiver);
    }
}
