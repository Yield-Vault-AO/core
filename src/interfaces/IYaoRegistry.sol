// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IYaoRegistry {
    event YaoVaultAdded(address indexed asset, address indexed vault);
    event YaoVaultRemoved(address indexed asset, address indexed vault);

    /// @notice Checks if an address is a valid YAO vault
    /// @param vaultAddress Vault address to be added
    function isYaoVault(address vaultAddress) external view returns (bool);

    /// @notice Registers a YAO vault
    /// @param vaultAddress YAO vault address to be added
    function addYaoVault(address vaultAddress) external;

    /// @notice Removes YAO vault registration
    /// @param vaultAddress YAO vault address to be removed
    function removeYaoVault(address vaultAddress) external;

    /// @notice Returns a list of all registered YAO vaults
    function listYaoVaults() external view returns (address[] memory);
}
