// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Registry_Base_Test } from "./Base.t.sol";

contract IsYaoVault_Test is Registry_Base_Test {
    address internal mockAsset;
    address internal mockVault;
    address internal mockAsset2;
    address internal mockVault2;

    function setUp() public override {
        super.setUp();

        // Create mock assets and vaults
        mockAsset = makeAddr("MockAsset");
        mockVault = createMockVault(mockAsset);
        mockAsset2 = makeAddr("MockAsset2");
        mockVault2 = createMockVault(mockAsset2);
    }

    // ========================================= SUCCESS TESTS =========================================

    function test_isYaoVault_RegisteredVault() public {
        vm.startPrank({ msgSender: users.admin });

        // Add vault
        registry.addYaoVault(mockVault);

        // Check if vault is registered
        assertTrue(registry.isYaoVault(mockVault), "Registered vault should return true");

        vm.stopPrank();
    }

    function test_isYaoVault_UnregisteredVault() public view {
        // Check if unregistered vault returns false
        assertFalse(registry.isYaoVault(mockVault), "Unregistered vault should return false");
    }

    function test_isYaoVault_ZeroAddress() public view {
        // Check if zero address returns false
        assertFalse(registry.isYaoVault(address(0)), "Zero address should return false");
    }

    function test_isYaoVault_MultipleVaults() public {
        vm.startPrank({ msgSender: users.admin });

        // Add both vaults
        registry.addYaoVault(mockVault);
        registry.addYaoVault(mockVault2);

        // Check both are registered
        assertTrue(registry.isYaoVault(mockVault), "First vault should be registered");
        assertTrue(registry.isYaoVault(mockVault2), "Second vault should be registered");

        // Check random address is not registered
        address randomAddress = makeAddr("RandomAddress");
        assertFalse(registry.isYaoVault(randomAddress), "Random address should not be registered");

        vm.stopPrank();
    }

    // ========================================= EDGE CASES =========================================

    function test_isYaoVault_AfterRemoval() public {
        vm.startPrank({ msgSender: users.admin });

        // Add vault
        registry.addYaoVault(mockVault);
        assertTrue(registry.isYaoVault(mockVault), "Vault should be registered");

        // Remove vault
        registry.removeYaoVault(mockVault);
        assertFalse(registry.isYaoVault(mockVault), "Vault should not be registered after removal");

        vm.stopPrank();
    }

    function test_isYaoVault_ReAddAfterRemoval() public {
        vm.startPrank({ msgSender: users.admin });

        // Add vault
        registry.addYaoVault(mockVault);
        assertTrue(registry.isYaoVault(mockVault), "Vault should be registered");

        // Remove vault
        registry.removeYaoVault(mockVault);
        assertFalse(registry.isYaoVault(mockVault), "Vault should not be registered after removal");

        // Add vault again
        registry.addYaoVault(mockVault);
        assertTrue(registry.isYaoVault(mockVault), "Vault should be registered again");

        vm.stopPrank();
    }

    function test_isYaoVault_NonExistentContract() public view {
        // Check if non-existent contract address returns false
        address nonExistentContract = address(0x1234567890123456789012345678901234567890);
        assertFalse(registry.isYaoVault(nonExistentContract), "Non-existent contract should return false");
    }

    function test_isYaoVault_AnyUserCanCall() public {
        vm.startPrank({ msgSender: users.admin });
        registry.addYaoVault(mockVault);
        vm.stopPrank();

        // Bob should be able to call isYaoVault
        vm.startPrank({ msgSender: users.bob });
        assertTrue(registry.isYaoVault(mockVault), "Bob should be able to check if vault is registered");
        vm.stopPrank();

        // Alice should be able to call isYaoVault
        vm.startPrank({ msgSender: users.alice });
        assertTrue(registry.isYaoVault(mockVault), "Alice should be able to check if vault is registered");
        vm.stopPrank();
    }
}
