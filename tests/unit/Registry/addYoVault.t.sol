// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Registry_Base_Test } from "./Base.t.sol";
import { Errors } from "src/libraries/Errors.sol";
import { IYaoRegistry } from "src/interfaces/IYaoRegistry.sol";

contract AddYaoVault_Test is Registry_Base_Test {
    address internal mockAsset;
    address internal mockVault;

    function setUp() public override {
        super.setUp();

        // Create a mock asset (USDC)
        mockAsset = makeAddr("MockAsset");
        mockVault = createMockVault(mockAsset);
    }

    // ========================================= SUCCESS TESTS =========================================

    function test_addYaoVault_Success() public {
        vm.startPrank({ msgSender: users.admin });

        vm.expectEmit({ emitter: address(registry) });
        emit IYaoRegistry.YaoVaultAdded(mockAsset, mockVault);

        registry.addYaoVault(mockVault);

        assertTrue(registry.isYaoVault(mockVault), "Vault should be registered");
        vm.stopPrank();
    }

    function test_addYaoVault_MultipleVaults() public {
        vm.startPrank({ msgSender: users.admin });

        address mockAsset2 = makeAddr("MockAsset2");
        address mockVault2 = createMockVault(mockAsset2);

        // Add first vault
        registry.addYaoVault(mockVault);
        assertTrue(registry.isYaoVault(mockVault), "First vault should be registered");

        // Add second vault
        registry.addYaoVault(mockVault2);
        assertTrue(registry.isYaoVault(mockVault2), "Second vault should be registered");

        // Check both are in the list
        address[] memory vaults = registry.listYaoVaults();
        assertEq(vaults.length, 2, "Should have 2 vaults");
        assertEq(vaults[0], mockVault, "First vault should be in list");
        assertEq(vaults[1], mockVault2, "Second vault should be in list");

        vm.stopPrank();
    }

    // ========================================= FAILURE TESTS =========================================

    function test_addYaoVault_ZeroAddress() public {
        vm.startPrank({ msgSender: users.admin });

        vm.expectRevert(Errors.Registry__VaultAddressZero.selector);
        registry.addYaoVault(address(0));

        vm.stopPrank();
    }

    function test_addYaoVault_VaultAlreadyExists() public {
        vm.startPrank({ msgSender: users.admin });

        // Add vault first time
        registry.addYaoVault(mockVault);
        assertTrue(registry.isYaoVault(mockVault), "Vault should be registered");

        // Try to add the same vault again
        vm.expectRevert(abi.encodeWithSelector(Errors.Registry__VaultAlreadyExists.selector, mockVault));
        registry.addYaoVault(mockVault);

        vm.stopPrank();
    }

    function test_addYaoVault_Unauthorized() public {
        vm.startPrank({ msgSender: users.bob });

        vm.expectRevert();
        registry.addYaoVault(mockVault);

        vm.stopPrank();
    }

    // ========================================= EDGE CASES =========================================

    function test_addYaoVault_AfterRemoval() public {
        vm.startPrank({ msgSender: users.admin });

        // Add vault
        registry.addYaoVault(mockVault);
        assertTrue(registry.isYaoVault(mockVault), "Vault should be registered");

        // Remove vault
        registry.removeYaoVault(mockVault);
        assertFalse(registry.isYaoVault(mockVault), "Vault should not be registered");

        // Add vault again
        vm.expectEmit({ emitter: address(registry) });
        emit IYaoRegistry.YaoVaultAdded(mockAsset, mockVault);
        registry.addYaoVault(mockVault);
        assertTrue(registry.isYaoVault(mockVault), "Vault should be registered again");

        vm.stopPrank();
    }

    function test_addYaoVault_EventEmission() public {
        vm.startPrank({ msgSender: users.admin });

        vm.expectEmit({ emitter: address(registry) });
        emit IYaoRegistry.YaoVaultAdded(mockAsset, mockVault);

        registry.addYaoVault(mockVault);

        vm.stopPrank();
    }
}
