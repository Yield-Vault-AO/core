// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Registry_Base_Test } from "./Base.t.sol";
import { Errors } from "src/libraries/Errors.sol";
import { IYaoRegistry } from "src/interfaces/IYaoRegistry.sol";

contract RemoveYaoVault_Test is Registry_Base_Test {
    address internal mockAsset;
    address internal mockVault;

    function setUp() public override {
        super.setUp();

        // Create a mock asset (USDC)
        mockAsset = makeAddr("MockAsset");
        mockVault = createMockVault(mockAsset);
    }

    // ========================================= SUCCESS TESTS =========================================

    function test_removeYaoVault_Success() public {
        vm.startPrank({ msgSender: users.admin });

        // First add the vault
        registry.addYaoVault(mockVault);
        assertTrue(registry.isYaoVault(mockVault), "Vault should be registered");

        // Then remove it
        vm.expectEmit({ emitter: address(registry) });
        emit IYaoRegistry.YaoVaultRemoved(mockAsset, mockVault);

        registry.removeYaoVault(mockVault);

        assertFalse(registry.isYaoVault(mockVault), "Vault should not be registered");
        vm.stopPrank();
    }

    function test_removeYaoVault_MultipleVaults() public {
        vm.startPrank({ msgSender: users.admin });

        address mockAsset2 = makeAddr("MockAsset2");
        address mockVault2 = createMockVault(mockAsset2);

        // Add both vaults
        registry.addYaoVault(mockVault);
        registry.addYaoVault(mockVault2);

        // Remove first vault
        registry.removeYaoVault(mockVault);
        assertFalse(registry.isYaoVault(mockVault), "First vault should not be registered");
        assertTrue(registry.isYaoVault(mockVault2), "Second vault should still be registered");

        // Check list
        address[] memory vaults = registry.listYaoVaults();
        assertEq(vaults.length, 1, "Should have 1 vault");
        assertEq(vaults[0], mockVault2, "Second vault should be in list");

        // Remove second vault
        registry.removeYaoVault(mockVault2);
        assertFalse(registry.isYaoVault(mockVault2), "Second vault should not be registered");

        // Check empty list
        vaults = registry.listYaoVaults();
        assertEq(vaults.length, 0, "Should have 0 vaults");

        vm.stopPrank();
    }

    // ========================================= FAILURE TESTS =========================================

    function test_removeYaoVault_ZeroAddress() public {
        vm.startPrank({ msgSender: users.admin });

        vm.expectRevert(Errors.Registry__VaultAddressZero.selector);
        registry.removeYaoVault(address(0));

        vm.stopPrank();
    }

    function test_removeYaoVault_VaultNotExists() public {
        vm.startPrank({ msgSender: users.admin });

        vm.expectRevert(abi.encodeWithSelector(Errors.Registry__VaultNotExists.selector, mockVault));
        registry.removeYaoVault(mockVault);

        vm.stopPrank();
    }

    function test_removeYaoVault_Unauthorized() public {
        vm.startPrank({ msgSender: users.admin });
        registry.addYaoVault(mockVault);
        vm.stopPrank();

        vm.startPrank({ msgSender: users.bob });

        vm.expectRevert();
        registry.removeYaoVault(mockVault);

        vm.stopPrank();
    }

    // ========================================= EDGE CASES =========================================

    function test_removeYaoVault_AlreadyRemoved() public {
        vm.startPrank({ msgSender: users.admin });

        // Add vault
        registry.addYaoVault(mockVault);
        assertTrue(registry.isYaoVault(mockVault), "Vault should be registered");

        // Remove vault
        registry.removeYaoVault(mockVault);
        assertFalse(registry.isYaoVault(mockVault), "Vault should not be registered");

        // Try to remove again
        vm.expectRevert(abi.encodeWithSelector(Errors.Registry__VaultNotExists.selector, mockVault));
        registry.removeYaoVault(mockVault);

        vm.stopPrank();
    }

    function test_removeYaoVault_EventEmission() public {
        vm.startPrank({ msgSender: users.admin });

        // Add vault first
        registry.addYaoVault(mockVault);

        // Remove vault and check event
        vm.expectEmit({ emitter: address(registry) });
        emit IYaoRegistry.YaoVaultRemoved(mockAsset, mockVault);

        registry.removeYaoVault(mockVault);

        vm.stopPrank();
    }
}
