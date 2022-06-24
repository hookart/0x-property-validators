// SPDX-License-Identifier: MIT
//
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        █████████████▌                                        ▐█████████████
//        ██████████████                                        ██████████████
//        ██████████████          ▄▄████████████████▄▄         ▐█████████████▌
//        ██████████████    ▄█████████████████████████████▄    ██████████████
//         ██████████▀   ▄█████████████████████████████████   ██████████████▌
//          ██████▀   ▄██████████████████████████████████▀  ▄███████████████
//           ███▀   ██████████████████████████████████▀   ▄████████████████
//            ▀▀  ████████████████████████████████▀▀   ▄█████████████████▌
//              █████████████████████▀▀▀▀▀▀▀      ▄▄███████████████████▀
//             ██████████████████▀    ▄▄▄█████████████████████████████▀
//            ████████████████▀   ▄█████████████████████████████████▀  ██▄
//          ▐███████████████▀  ▄██████████████████████████████████▀   █████▄
//          ██████████████▀  ▄█████████████████████████████████▀   ▄████████
//         ██████████████▀   ███████████████████████████████▀   ▄████████████
//        ▐█████████████▌     ▀▀▀▀████████████████████▀▀▀▀      █████████████▌
//        ██████████████                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████
//        █████████████▌                                        ██████████████

pragma solidity >=0.8.9;

import {IPropertyValidator} from "./interfaces/zeroex-v4/IPropertyValidator.sol";
import {IHookCallOption} from "./interfaces/IHookCallOption.sol";

contract PropertyValidator is IPropertyValidator {
    enum Operation {
        Ignore,
        LessThanOrEqualTo,
        GreaterThanOrEqualTo,
        Equal
    }

    function validateProperty(
        address tokenAddress,
        uint256 tokenId,
        bytes calldata propertyData
    ) external view override {
        (
            uint256 strikePrice,
            Operation strikePriceOperation,
            uint256 expiry,
            Operation expiryOperation
        ) = abi.decode(propertyData, (uint256, Operation, uint256, Operation));
        IHookCallOption optionContract = IHookCallOption(tokenAddress);
        compare(
            optionContract.getStrikePrice(tokenId),
            strikePrice,
            strikePriceOperation
        );
        compare(optionContract.getExpiration(tokenId), expiry, expiryOperation);
    }

    function compare(
        uint256 actual,
        uint256 comparingTo,
        Operation operation
    ) internal pure {
        if (operation == Operation.Equal) {
            require(actual == comparingTo, "values are not equal");
        } else if (operation == Operation.LessThanOrEqualTo) {
            require(
                actual <= comparingTo,
                "actual value is not <= comparison value"
            );
        } else if (operation == Operation.GreaterThanOrEqualTo) {
            require(
                actual >= comparingTo,
                "actual value is not >= comparison value"
            );
        } else {
            require(true);
        }
    }
}
