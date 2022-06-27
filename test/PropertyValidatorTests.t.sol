// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PropertyValidatorTests is Test, HookCallOption, PropertyValidator {
    using Counters for Counters.Counter;
    address testAddress = address(0);
    uint256 testTokenId = 1;

    function setUp() public {}

    function testStrikePriceValidation() public {
        uint256 testStrikePrice = 100;
        uint256 optionId = createOption(
            testAddress,
            testTokenId,
            testStrikePrice,
            0
        );

        // abi encode data
        // bytes propertyData = abi.encode(arg);

        // ValidateProperty(testAddress, testTokenId, propertyData);
    }
}
