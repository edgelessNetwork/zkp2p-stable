// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import "forge-std/src/Vm.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { StdUtils } from "forge-std/src/StdUtils.sol";
import { EdgelessReceiver } from "../src/EdgelessReceiver.sol";
import { FiatTokenV2 } from "../src/FiatTokenV2.sol";

contract EdgelessMinterTest is PRBTest, StdCheats, StdUtils {
    event ForwardFrom(address indexed sender, address indexed stableReceiver, address indexed to, uint256 amount);

    address public owner = makeAddr("Edgeless non-US KYCed entity");
    address public stableMinter = makeAddr("Stable Minter");
    address public stableReceiver = makeAddr("Stable Receiver");
    address public edgelessUserWallet = makeAddr("Edgeless User Wallet");

    EdgelessReceiver public edgelessReceiver;
    FiatTokenV2 public USDLR;
    uint256 public minAmount = 1000e18;

    function setUp() public virtual {
        vm.createSelectFork({ urlOrAlias: "https://edgeless-testnet.rpc.caldera.xyz/http" });
        edgelessReceiver = new EdgelessReceiver();
        USDLR = new FiatTokenV2();
        vm.prank(owner);
        edgelessReceiver.initialize(owner, stableReceiver, USDLR, minAmount);
    }

    function test_Forwarding(uint256 amount) external {
        amount = bound(amount, minAmount, 1e40);
        USDLR.mint(edgelessUserWallet, amount);
        vm.startPrank(edgelessUserWallet);
        USDLR.approve(address(edgelessReceiver), amount);
        vm.expectEmit(address(edgelessReceiver));
        emit ForwardFrom(edgelessUserWallet, stableReceiver, edgelessUserWallet, amount);
        edgelessReceiver.forwardFrom(edgelessUserWallet, amount, edgelessUserWallet);
        assertEq(USDLR.balanceOf(address(edgelessReceiver)), 0, "EdgelessReceiver should have 0 USDLR after forwarding");
        assertEq(
            USDLR.balanceOf(address(stableReceiver)),
            amount,
            "StableReceiver should have `amount` of USDLR after forwarding"
        );
    }

    function test_SetStableReceiver() external {
        vm.startPrank(owner);
        address newStableReceiver = makeAddr("New Stable Receiver");
        edgelessReceiver.setStableReceiver(newStableReceiver);
        assertEq(edgelessReceiver.stableReceiver(), newStableReceiver, "Stable receiver should be newStableReceiver");
    }

    function test_UnauthorizedSetStableReceiver() external {
        address newStableReceiver = makeAddr("New Stable Receiver");
        vm.expectRevert();
        edgelessReceiver.setStableReceiver(newStableReceiver);
    }

    function test_SetMinAmount() external {
        vm.startPrank(owner);
        uint256 newMinAmount = 1000e18;
        edgelessReceiver.setMinAmount(newMinAmount);
        assertEq(edgelessReceiver.minAmount(), newMinAmount, "Min amount should be newMinAmount");
    }

    function test_UnauthorizedSetMinAmount() external {
        uint256 newMinAmount = 1000e18;
        vm.expectRevert();
        edgelessReceiver.setMinAmount(newMinAmount);
    }
}
