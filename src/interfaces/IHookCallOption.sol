// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

interface IHookCallOption {
    /// @notice getter for the option strike price
    function getStrikePrice(uint256 optionId) external view returns (uint256);

    /// @notice getter for the options expiration. After this time the
    /// option is invalid
    function getExpiration(uint256 optionId) external view returns (uint256);
}