// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./BusinessProcesses.sol";
import "./Organizations.sol";

abstract contract Specialists is Organizations, BusinessProcesses {
    mapping(uint256 => mapping(uint256 => uint256)) public specRole;

    function addSpecRole(
        uint256 bpId,
        uint256 specId,
        uint256 roleId
    ) public onlyOwner returns (bool success) {
        checkSpecialist(specId);
        checkBP(bpId);
        checkRole(roleId);

        if (specRole[bpId][specId] > 0) return false;
        else {
            specRole[bpId][specId] = roleId;
            return true;
        }
    }

    function checkSpecAction(
        uint256 bpId,
        uint256 specId,
        uint256 actionId
    ) internal view returns (bool success) {
        uint256 roleId;
        roleId = specRole[bpId][specId];
        if (roleId == 0) return false;
        if (roleAction[bpId][roleId][actionId]) return true;
        else return false;
    }
}
