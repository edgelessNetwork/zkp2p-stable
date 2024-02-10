// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import "forge-std/src/Vm.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { StdUtils } from "forge-std/src/StdUtils.sol";
import { BaseReceiver } from "../src/BaseReceiver.sol";
import { FiatTokenV2 } from "../src/FiatTokenV2.sol";

contract BaseReceiverTest is PRBTest, StdCheats, StdUtils {
    event Forward(address indexed sender, address indexed stableReceiver, address indexed to, uint256 amount);

    address public owner = makeAddr("Edgeless non-US KYCed entity");
    address public stableReceiver = makeAddr("Stable Receiver");
    address public zkp2p4337Wallet = makeAddr("zkp-p2p 4337 Wallet");
    address public edgelessUserWallet = makeAddr("Edgeless User Wallet");

    BaseReceiver public baseReceiver;
    FiatTokenV2 public USDC;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        vm.createSelectFork({
            urlOrAlias: "https://sepolia.base.org"
        });
        vm.prank(owner);
        USDC = new FiatTokenV2();
        baseReceiver = new BaseReceiver(stableReceiver, USDC);
    }

    function test_Forwarding(uint256 amount) external {
        amount = bound(amount, 0, 1e40);
        USDC.mint(zkp2p4337Wallet, amount);
        vm.startPrank(zkp2p4337Wallet);
        USDC.approve(address(baseReceiver), amount);
        vm.expectEmit(address(baseReceiver));
        emit Forward(zkp2p4337Wallet, stableReceiver, edgelessUserWallet, amount);
        baseReceiver.forward(zkp2p4337Wallet, amount, edgelessUserWallet);
        assertEq(USDC.balanceOf(address(baseReceiver)), 0, "BaseReceiver should have 0 USDC after forwarding");
        assertEq(
            USDC.balanceOf(stableReceiver), amount, "Edgeless User Wallet should have `amount` of USDC after forwarding"
        );
    }
}
