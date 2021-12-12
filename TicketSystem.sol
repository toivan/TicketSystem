// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Organizations.sol";
import "./BusinessProcesses.sol";
import "./Specialists.sol";

abstract contract TicketSystem is
    Organizations,
    BusinessProcesses,
    Specialists
{
    struct Ticket {
        uint256 number;
        uint256 regDate;
        uint256 bpId;
        uint256 regOrgId;
        uint256 regSpecId;
        uint256 solvOrgId;
        uint256 solvSpecId;
        uint256 solvDate;
    }

    struct Tickets {
        mapping(uint256 => Ticket) data;
        uint256[] numbers;
    }
    Tickets private tickets;

    struct TicketHistory {
        uint256 historyId;
        uint256 actionId;
        uint256 actionDate;
        uint256 regSpecId;
        uint256 solvSpecId;
        bytes32 fileId;
    }

    mapping(uint256 => TicketHistory[]) private ticketHistory;

    function ticketExists(uint256 ticketId) internal view returns (bool) {
        if (tickets.data[ticketId].number == 0) return false;
        else return true;
    }

    function ticketHistoryInsert(
        uint256 ticketId,
        uint256 actionId,
        uint256 actionDate,
        uint256 regSpecId,
        uint256 solvSpecId,
        bytes32 fileId
    ) internal returns (uint256 historyId, bool success) {
        TicketHistory storage hist = ticketHistory[ticketId].push();
        hist.historyId = ticketHistory[ticketId].length;
        hist.actionId = actionId;
        hist.actionDate = actionDate;
        hist.regSpecId = regSpecId;
        hist.solvSpecId = solvSpecId;
        hist.fileId = fileId;
        return (hist.historyId, true);
    }

    function regTicket(
        uint256 ticketId,
        uint256 regDate,
        uint256 bpId,
        uint256 regActionId,
        uint256 regOrgId,
        uint256 regSpecId,
        uint256 solvOrgId,
        uint256 solvSpecId,
        bytes32 fileId
    ) public onlyOwner returns (uint256 historyId, bool success) {
        checkBP(bpId);
        checkOrganization(regOrgId);
        checkOrganization(solvOrgId);
        checkSpecialist(regSpecId);
        checkSpecialist(solvSpecId);
        checkAction(regActionId);
        if (ticketExists(ticketId)) revert(unicode"Тикет уже существует");

        if (!checkSpecAction(bpId, regSpecId, regActionId))
            revert(unicode"У сотрудника нет прав для создания Тикета");

        uint256 number;
        number = tickets.numbers.length;
        tickets.numbers.push(ticketId);
        Ticket storage ticket = tickets.data[ticketId];
        ticket.number = number + 1;
        ticket.regDate = regDate;
        ticket.bpId = bpId;
        ticket.regOrgId = regOrgId;
        ticket.regSpecId = regSpecId;
        ticket.solvOrgId = solvOrgId;
        ticket.solvSpecId = solvSpecId;
        (historyId, success) = ticketHistoryInsert(
            ticketId,
            regActionId,
            regDate,
            regSpecId,
            solvSpecId,
            fileId
        );
    }

    function addTicketHistory(
        uint256 ticketId,
        uint256 actionId,
        uint256 actionDate,
        uint256 regSpecId,
        uint256 solvSpecId,
        bytes32 fileId
    ) public returns (uint256 historyId, bool success) {
        checkSpecialist(regSpecId);
        checkSpecialist(solvSpecId);
        checkAction(actionId);
        if (!ticketExists(ticketId)) revert(unicode"Тикета не существует");

        Ticket storage ticket = tickets.data[ticketId];
        if (ticket.solvDate > 0) revert(unicode"Тикет закрыт");

        if (!checkSpecAction(ticket.bpId, regSpecId, actionId))
            revert(unicode"У сотрудника нет прав для выполнения действия");

        // Занесём новую запись в историю
        (historyId, success) = ticketHistoryInsert(
            ticketId,
            actionId,
            actionDate,
            regSpecId,
            regSpecId,
            fileId
        );
    }

    function solvTicket(
        uint256 ticketId,
        uint256 solvActionId,
        uint256 solvDate,
        uint256 regSpecId,
        uint256 solvSpecId,
        bytes32 fileId
    ) public onlyOwner returns (uint256 historyId, bool success) {
        checkSpecialist(regSpecId);
        checkAction(solvActionId);
        if (!ticketExists(ticketId)) revert(unicode"Тикета не существует");
        Ticket storage ticket = tickets.data[ticketId];
        if (ticket.solvDate > 0) revert(unicode"Тикет закрыт");
        if (!checkSpecAction(ticket.bpId, regSpecId, solvActionId))
            revert(unicode"У сотрудника нет прав для выполнения действия");
        ticket.solvDate = solvDate;

        (historyId, success) = ticketHistoryInsert(
            ticketId,
            solvActionId,
            solvDate,
            regSpecId,
            solvSpecId,
            fileId
        );
    }

    function getTicket(uint256 ticketId)
        external
        view
        returns (
            uint256 regDate,
            uint256 bpId,
            uint256 regOrgId,
            uint256 regSpecId,
            uint256 solvOrgId,
            uint256 solvSpecId,
            uint256 solvDate,
            bool success
        )
    {
        if (!ticketExists(ticketId)) return (0, 0, 0, 0, 0, 0, 0, false);

        Ticket storage ticket = tickets.data[ticketId];

        regDate = ticket.regDate;
        bpId = ticket.bpId;
        regOrgId = ticket.regOrgId;
        regSpecId = ticket.regSpecId;
        solvOrgId = ticket.solvOrgId;
        solvSpecId = ticket.solvSpecId;
        solvDate = ticket.solvDate;
        success = true;
    }

    function getTicketHistoryIds(uint256 ticketId)
        external
        view
        returns (uint256[] memory ids, bool success)
    {
        if (!ticketExists(ticketId)) {
            return (new uint256[](0), false);
        }

        TicketHistory[] storage histArray = ticketHistory[ticketId];
        uint256[] memory historyIds = new uint256[](histArray.length);
        for (uint256 i = 0; i < histArray.length; i++)
            historyIds[i] = histArray[i].historyId;
        return (historyIds, true);
    }

    function getTicketHistoryLength(uint256 ticketId)
        external
        view
        returns (uint256)
    {
        if (ticketExists(ticketId)) {
            TicketHistory[] storage histArray = ticketHistory[ticketId];
            return histArray.length;
        } else return 0;
    }

    function getTicketAction(
        uint256 ticketId,
        uint256 ticketHistoryId,
        uint256 querySpecId
    )
        external
        view
        returns (
            uint256 actionId,
            uint256 actionDate,
            uint256 regSpecId,
            uint256 splvSpecId,
            bytes32 fileId,
            bool success
        )
    {
        if (!ticketExists(ticketId)) return (0, 0, 0, 0, 0, false);
        TicketHistory[] storage histArray = ticketHistory[ticketId];
        TicketHistory memory hist;
        for (uint256 i = 0; i < histArray.length; i++) {
            if (histArray[i].historyId == ticketHistoryId) {
                hist = histArray[i];
                break;
            }
        }
        uint256 bpId = tickets.data[ticketId].bpId;
        if (
            specRole[bpId][hist.regSpecId] == specRole[bpId][querySpecId] ||
            specRole[bpId][hist.solvSpecId] == specRole[bpId][querySpecId]
        ) {
            return (
                hist.actionId,
                hist.actionDate,
                hist.regSpecId,
                hist.solvSpecId,
                hist.fileId,
                true
            );
        }
    }
}
