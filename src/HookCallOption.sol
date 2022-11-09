// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "openzeppelin-contracts/utils/Counters.sol";
import "forge-std/Test.sol";
import {IHookCallOption} from "./interfaces/IHookCallOption.sol";

contract HookCallOption is IHookCallOption, Test {
    using Counters for Counters.Counter;

    struct CallOption {
        address writer;
        uint32 expiration;
        uint32 assetId;
        address vaultAddress;
        uint128 strike;
        uint128 bid;
        address highBidder;
        bool settled;
    }
    Counters.Counter private _optionIds;
    mapping(uint256 => CallOption) public optionParams;

    function getStrikePrice(uint256 optionId)
        public
        view
        override
        returns (uint256)
    {
        return optionParams[optionId].strike;
    }

    function getExpiration(uint256 optionId)
        public
        view
        override
        returns (uint256)
    {
        return optionParams[optionId].expiration;
    }

    function createOption(
        address tokenAddress,
        uint256 tokenId,
        uint128 strikePrice,
        uint32 expirationTime
    ) external returns (uint256) {
        // generate the next optionId
        _optionIds.increment();
        uint256 newOptionId = _optionIds.current();

        // save the option metadata
        optionParams[newOptionId] = CallOption({
            writer: tokenAddress,
            vaultAddress: address(0),
            assetId: uint32(tokenId),
            strike: strikePrice,
            expiration: expirationTime,
            bid: 0,
            highBidder: address(0),
            settled: false
        });

        return newOptionId;
    }

    function getAssetId(uint256 optionId) external view returns (uint32) {
        return optionParams[optionId].assetId;
    }

    function getVaultAddress(uint256 optionId) external view returns (address) {
        return optionParams[optionId].vaultAddress;
    }
}
