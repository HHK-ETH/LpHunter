// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import "ds-test/test.sol";
import "../LpHunter.sol";

interface Vm {
    function prank(address) external;
}

contract ContractTest is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);
    LpHunter lpHunter;

    function setUp() public {
        lpHunter = new LpHunter(address(this), 10);
    }

    function testUpdateTip() public {
        uint256 oldTip = lpHunter.tip();
        lpHunter.updateTip(oldTip + 1);
        assert(oldTip + 1 == lpHunter.tip());
    }

    function testFailUpdateTip() public {
        vm.prank(address(0));
        lpHunter.updateTip(0);
    }

    function testTransferOwnership() public {
        lpHunter.transferOwnership(address(0));
        assert(address(0) == lpHunter.owner());
    }

    function testFailTransferOwnership() public {
        vm.prank(address(0));
        lpHunter.transferOwnership(address(0));
        assert(address(0) == lpHunter.owner());
    }
}
