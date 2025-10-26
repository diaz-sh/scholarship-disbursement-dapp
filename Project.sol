// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
  Project.sol - Scholarship Disbursement DApp (first part)
  - Roles via AccessControl
  - Scholarship & Application structs
  - Events and basic admin function to add scholarships
*/

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Project is AccessControl, ReentrancyGuard {
    // Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    // Counters
    uint256 private _scholarshipIds;
    uint256 private _applicationIds;

    // Scholarship definition
    struct Scholarship {
        uint256 id;  
        string name;
        uint256 amount;    // in wei (or smallest token unit)
        bool active;
        string metadataURI; // off-chain metadata (IPFS hash / URL)
    }

    // Application definition (minimal)
    struct Application {
        uint256 id;
        address student;
        uint256 scholarshipId;
        string docsURI;   // IPFS hash for documents
        bool approved;
        bool paid;
        uint256 appliedAt;
    }

    // Storage
    mapping(uint256 => Scholarship) public scholarships;
    mapping(uint256 => Application) public applications;
    mapping(address => uint256[]) public applicationsByStudent;

    // Events
    event ScholarshipAdded(uint256 indexed id, string name, uint256 amount);
    event ScholarshipUpdated(uint256 indexed id, bool active);
    event ApplicationSubmitted(uint256 indexed appId, uint256 indexed scholarshipId, address indexed student);
    event ApplicationApproved(uint256 indexed appId, uint256 indexed scholarshipId);
    event ScholarshipDisbursed(uint256 indexed appId, address indexed student, uint256 amount);

    // Constructor: grant deployer admin role
    constructor(address admin) {
        require(admin != address(0), "admin-zero-address");
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(ADMIN_ROLE, admin);
    }

    // Modifiers
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "not-admin");
        _;
    }

    // ---------- Basic admin functions ----------
    /// @notice Add a new scholarship program
    function addScholarship(
        string calldata name,
        uint256 amount,
        string calldata metadataURI
    ) external onlyAdmin returns (uint256) {
        require(amount > 0, "amount-0");

        _scholarshipIds += 1;
        uint256 id = _scholarshipIds;

        scholarships[id] = Scholarship({
            id: id,
            name: name,
            amount: amount,
            active: true,
            metadataURI: metadataURI
        });

        emit ScholarshipAdded(id, name, amount);
        return id;
    }

    /// @notice Toggle active state for a scholarship
    function setScholarshipActive(uint256 id, bool active) external onlyAdmin {
        require(scholarships[id].id != 0, "sch-not-found");
        scholarships[id].active = active;
        emit ScholarshipUpdated(id, active);
    }

    // Further functions (apply, approve, disburse, deposit, withdraw) to be added next...
}

