// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IYaoGateway {
    // ========= Events =========
    event YaoGatewayDeposit(
        uint32 indexed partnerId,
        address indexed yoVault,
        address indexed sender,
        address receiver,
        uint256 assets,
        uint256 shares
    );

    event YaoGatewayRedeem(
        uint32 indexed partnerId,
        address indexed yoVault,
        address indexed receiver,
        uint256 shares,
        uint256 assetsOrRequestId,
        bool instant
    );
}
