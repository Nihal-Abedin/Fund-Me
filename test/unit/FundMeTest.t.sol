// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";

import {FundMe} from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        // giving our user a fake balance
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMINIMUM_USDIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdateState() public {
        vm.prank(USER); // setting a dummy user for send eth or a request
        console.log(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 ammountFunded = fundMe.getAddressToAmmountFunded(USER);

        console.log(ammountFunded, SEND_VALUE);

        assertEq(ammountFunded, SEND_VALUE);
    }

    function testAddFundersToArrayofFunders() public {
        vm.prank(USER); // setting a dummy user for send eth or a request
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);

        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();

        fundMe.withdraw();
    }

    function testWithrawWithaSingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        uint256 startingFundMEBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());

        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        uint256 endingFundMEBalance = address(fundMe).balance;

        assertEq(endingFundMEBalance, 0);
        assertEq(
            startingFundMEBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawForMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // address[] memory funderArray;

        for (
            uint160 funder = startingFunderIndex;
            funder < numberOfFunders;
            funder++
        ) {
            hoax(address(funder), SEND_VALUE); //do both of vm.prank() & vm.deal()
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMEBalance = address(fundMe).balance;

        address owner = fundMe.getOwner();

        vm.startPrank(owner);

        fundMe.withdraw();

        vm.stopPrank();
        uint256 ownerCurrentBalance = owner.balance;

        assertEq(
            startingFundMEBalance + startingOwnerBalance,
            ownerCurrentBalance
        );
    }
}
