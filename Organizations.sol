// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ownable.sol";

abstract contract Organizations is Ownable {
    struct Organization {
        string name;
        string description;
    }

    mapping(uint256 => Organization) public org;

    struct Specialist {
        uint256 orgId;
        string name;
        string email;
    }

    mapping(uint256 => Specialist) public spec;

    event AddOrgEvent(uint256 orgId, string orgName);

    event AddSpecEvent(uint256 specId, uint256 orgId, string name);

    function addOrganization(
        uint256 id,
        string memory name,
        string memory description
    ) public onlyOwner returns (bool success) {
        if (bytes(org[id].name).length > 0) return false;
        else {
            org[id].name = name;
            org[id].description = description;
            emit AddOrgEvent(id, name);
            return true;
        }
    }

    function addSpecialist(
        uint256 specId,
        uint256 orgId,
        string memory name,
        string memory email
    ) public onlyOwner returns (bool success) {
        if (bytes(spec[specId].name).length > 0) return false;
        else {
            spec[specId].orgId = orgId;
            spec[specId].name = name;
            spec[specId].email = email;
            emit AddSpecEvent(specId, orgId, name);
            return true;
        }
    }

    function checkOrganization(uint256 orgId) internal view {
        require(
            bytes(org[orgId].name).length > 0,
            unicode"Организация не существует"
        );
    }

    function checkSpecialist(uint256 specId) internal view {
        require(
            bytes(spec[specId].name).length > 0,
            unicode"Сотрудник не существует"
        );
    }
}
