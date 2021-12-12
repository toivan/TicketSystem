// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ownable.sol";

abstract contract BusinessProcesses is Ownable {
    mapping(uint256 => string) public bp;
    mapping(uint256 => string) public role;
    mapping(uint256 => string) public action;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => bool)))
        public roleAction;

    event AddBPEvent(uint256 bpId, string bpName);
    event AddRoleEvent(uint256 roleId, string roleName);
    event AddActionEvent(uint256 actionId, string actionName);

    function addBP(uint256 id, string memory name)
        public
        onlyOwner
        returns (bool success)
    {
        if (bytes(bp[id]).length > 0) return false;
        else {
            bp[id] = name;
            emit AddBPEvent(id, name);
            return true;
        }
    }

    function addRole(uint256 id, string memory name)
        public
        onlyOwner
        returns (bool success)
    {
        if (bytes(role[id]).length > 0) return false;
        else {
            role[id] = name;
            emit AddRoleEvent(id, name);
            return true;
        }
    }

    function addAction(uint256 id, string memory name)
        public
        onlyOwner
        returns (bool success)
    {
        if (bytes(action[id]).length > 0) return false;
        else {
            action[id] = name;
            emit AddActionEvent(id, name);
            return true;
        }
    }

    function checkBP(uint256 bpId) internal view {
        require(
            bytes(bp[bpId]).length > 0,
            unicode"Бизнес-процесс не существует"
        );
    }

    function checkRole(uint256 roleId) internal view {
        require(bytes(role[roleId]).length > 0, unicode"Роль не существует");
    }

    function checkAction(uint256 actionId) internal view {
        require(
            bytes(action[actionId]).length > 0,
            unicode"Действие роли не существует"
        );
    }

    function addRoleAction(
        uint256 bpId,
        uint256 roleId,
        uint256 actionId
    ) public onlyOwner returns (bool success) {
        checkBP(bpId);
        checkRole(roleId);
        checkAction(actionId);
        if (roleAction[bpId][roleId][actionId]) return false;
        roleAction[bpId][roleId][actionId] = true;
        return true;
    }
}
