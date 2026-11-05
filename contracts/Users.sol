// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

library Users {
    struct User {
        address userAddress;
        uint256 amount;
    }

    function getTotalPayout(User[] calldata winners) internal pure returns (uint256) {
        uint256 totalPayout;
        for(uint i = 0; i < winners.length; i++){
            totalPayout += winners[i].amount;
        }

        return totalPayout;
    }
}