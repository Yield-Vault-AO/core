// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.28 <0.9.0;

import "forge-std/Script.sol";
import {YaoGateway} from "src/YaoGateway.sol";
import {YaoRegistry} from "src/YaoRegistry.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {BaseScript} from "./Base.s.sol";

import {RolesAuthority} from "@solmate/auth/authorities/RolesAuthority.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (YaoGateway gateway, YaoRegistry registry) {
        YaoRegistry registryImpl = new YaoRegistry();
        console.log("Registry implementation address", address(registryImpl));

        bytes memory data = abi.encodeWithSelector(
            YaoRegistry.initialize.selector,
            broadcaster,
            RolesAuthority(address(0))
        );
        registry = YaoRegistry(payable(new TransparentUpgradeableProxy(address(registryImpl), broadcaster, data)));

        YaoGateway gatewayImpl = new YaoGateway();
        data = abi.encodeWithSelector(YaoGateway.initialize.selector, address(registry));
        console.log("Gateway implementation address", address(gatewayImpl));
        gateway = YaoGateway(payable(new TransparentUpgradeableProxy(address(gatewayImpl), broadcaster, data)));

        console.log("Gateway address", address(gateway));
        console.log("Registry address", address(registry));
    }
}
