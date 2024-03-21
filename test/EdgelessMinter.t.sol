// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import "forge-std/src/Vm.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { StdUtils } from "forge-std/src/StdUtils.sol";
import { EdgelessMinter } from "../src/EdgelessMinter.sol";
import { FiatTokenV2 } from "../src/FiatTokenV2.sol";

contract EdgelessMinterTest is PRBTest, StdCheats, StdUtils {

    address public owner = makeAddr("Edgeless non-US KYCed entity");
    address public stableMinter = makeAddr("Stable Minter");
    address public edgelessUserWallet = makeAddr("Edgeless User Wallet");

    EdgelessMinter public edgelessMinter;
    FiatTokenV2 public USDLR;

    function setUp() public virtual {
        vm.createSelectFork({ urlOrAlias: "https://edgeless-testnet.rpc.caldera.xyz/http" });
        vm.startPrank(stableMinter);
        USDLR = new FiatTokenV2();
        edgelessMinter = new EdgelessMinter();
        edgelessMinter.initialize(owner, IERC20(USDLR), stableMinter);
        vm.stopPrank();
    }

    function test_Minting(uint256 amount) external {
        amount = bound(amount, 0, 1e40);
        vm.startPrank(stableMinter);
        USDLR.mint(stableMinter, amount);
        USDLR.approve(address(edgelessMinter), amount);
        edgelessMinter.mint(edgelessUserWallet, amount);
        assertEq(USDLR.balanceOf(edgelessUserWallet), amount, "USDLR balance of edgelessUserWallet should be amount");
        assertEq(USDLR.balanceOf(stableMinter), 0, "USDLR balance of stableMinter should be 0");
    }

    function test_UnauthorizedMinting(uint256 amount) external {
        amount = bound(amount, 0, 1e40);
        vm.startPrank(stableMinter);
        USDLR.mint(stableMinter, amount);
        USDLR.approve(address(edgelessMinter), amount);
        vm.stopPrank();
        address unauthorized = makeAddr("Unauthorized");
        vm.startPrank(unauthorized);
        vm.expectRevert();
        edgelessMinter.mint(edgelessUserWallet, amount);
    }

    function test_SetStableMinter() external {
        vm.startPrank(owner);
        address newStableMinter = makeAddr("New Stable Minter");
        edgelessMinter.setStableMinter(newStableMinter);
        assertEq(edgelessMinter.stableMinter(), newStableMinter, "Stable minter should be newStableMinter");
    }
}
