// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "openzeppelin-contracts/utils/Counters.sol";
import {HookCallOption} from "../src/HookCallOption.sol";
import {PropertyValidator, Types} from "../src/PropertyValidator.sol";

contract PropertyValidatorTests is Test {
    using Counters for Counters.Counter;

    HookCallOption calls;
    PropertyValidator propertyValidator;

    // Option setup values
    uint256 optionId;
    uint256 optionId2;
    uint256 optionTokenId = 1;
    uint128 optionStrikePrice = 100;
    uint32 optionExpiry = uint32(block.timestamp) + 3 days;

    // Test data
    bytes propertyData;
    uint256 comparisonStrikePrice;
    uint256 comparisonExpiry;

    function setUp() public {
        calls = new HookCallOption();
        propertyValidator = new PropertyValidator();

        optionId = calls.createOption(
            address(calls),
            optionTokenId,
            optionStrikePrice,
            optionExpiry,
            false
        );

        optionId2 = calls.createOption(
            address(calls),
            optionTokenId + 1,
            optionStrikePrice,
            optionExpiry,
            true
        );
    }

    function testStrikePriceValidationIgnore() public {
        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Ignore,
            comparisonExpiry,
            Types.Operation.Ignore,
            false,
            0,
            0
        );

        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testStrikePriceValidationRange() public {
        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Ignore,
            comparisonExpiry,
            Types.Operation.Ignore,
            true,
            0,
            10
        );

        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testStrikePriceValidationSoloVault() public {
        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Ignore,
            comparisonExpiry,
            Types.Operation.Ignore,
            true,
            20,
            20
        );

        propertyValidator.validateProperty(
            address(calls),
            optionId2,
            propertyData
        );
    }

    function testStrikePriceValidationExact() public {
        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Ignore,
            comparisonExpiry,
            Types.Operation.Ignore,
            true,
            optionTokenId,
            optionTokenId
        );

        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testStrikePriceValidationOutOfRange() public {
        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Ignore,
            comparisonExpiry,
            Types.Operation.Ignore,
            true,
            100,
            100000
        );

        vm.expectRevert("tokenId must be above the lower bound");
        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testStrikePriceValidationEqual() public {
        comparisonStrikePrice = optionStrikePrice;

        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Equal,
            comparisonExpiry,
            Types.Operation.Ignore,
            false,
            0,
            0
        );

        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testStrikePriceValidationNotEqual() public {
        comparisonStrikePrice = 0;

        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Equal,
            comparisonExpiry,
            Types.Operation.Ignore,
            false,
            0,
            0
        );

        vm.expectRevert("values are not equal");
        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testStrikePriceValidationLessThan() public {
        comparisonStrikePrice = 101;

        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.LessThanOrEqualTo,
            comparisonExpiry,
            Types.Operation.Ignore,
            false,
            0,
            0
        );

        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testStrikePriceValidationNotLessThan() public {
        comparisonStrikePrice = 0;

        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.LessThanOrEqualTo,
            comparisonExpiry,
            Types.Operation.Ignore,
            false,
            0,
            0
        );

        vm.expectRevert("actual value is not <= comparison value");
        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testStrikePriceValidationGreaterThan() public {
        comparisonStrikePrice = 99;

        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.GreaterThanOrEqualTo,
            comparisonExpiry,
            Types.Operation.Ignore,
            false,
            0,
            0
        );

        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testStrikePriceValidationNotGreaterThan() public {
        comparisonStrikePrice = 101;

        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.GreaterThanOrEqualTo,
            comparisonExpiry,
            Types.Operation.Ignore,
            false,
            0,
            0
        );

        vm.expectRevert("actual value is not >= comparison value");
        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testExpiryValidationIgnore() public {
        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Ignore,
            comparisonExpiry,
            Types.Operation.Ignore,
            false,
            0,
            0
        );

        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testExpiryValidationEqual() public {
        comparisonExpiry = optionExpiry;

        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Ignore,
            comparisonExpiry,
            Types.Operation.Equal,
            false,
            0,
            0
        );

        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testExpiryValidationNotEqual() public {
        comparisonExpiry = optionExpiry + 1 days;

        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Ignore,
            comparisonExpiry,
            Types.Operation.Equal,
            false,
            0,
            0
        );

        vm.expectRevert("values are not equal");
        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testExpiryValidationLessThan() public {
        comparisonExpiry = optionExpiry + 3 days;

        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Ignore,
            comparisonExpiry,
            Types.Operation.LessThanOrEqualTo,
            false,
            0,
            0
        );

        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testExpiryValidationNotLessThan() public {
        comparisonExpiry = optionExpiry - 1 days;

        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Ignore,
            comparisonExpiry,
            Types.Operation.LessThanOrEqualTo,
            false,
            0,
            0
        );

        vm.expectRevert("actual value is not <= comparison value");
        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testExpiryValidationGreaterThan() public {
        comparisonExpiry = optionExpiry - 3 days;

        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Ignore,
            comparisonExpiry,
            Types.Operation.GreaterThanOrEqualTo,
            false,
            0,
            0
        );

        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }

    function testExpiryValidationNotGreaterThan() public {
        comparisonExpiry = optionExpiry + 3 days;

        propertyData = propertyValidator.encode(
            comparisonStrikePrice,
            Types.Operation.Ignore,
            comparisonExpiry,
            Types.Operation.GreaterThanOrEqualTo,
            false,
            0,
            0
        );

        vm.expectRevert("actual value is not >= comparison value");
        propertyValidator.validateProperty(
            address(calls),
            optionId,
            propertyData
        );
    }
}
