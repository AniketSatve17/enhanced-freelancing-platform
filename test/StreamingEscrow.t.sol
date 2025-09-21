// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract StreamingEscrow {

    struct Project {
        address client;
        address freelancer;
        uint256 totalAmount;
        uint256[] milestoneAmounts;
        bool[] milestonesCompleted;
        bool[] milestonesPaid;
        uint256 insurancePolicyId;
        bool hasInsurance;
    }

    mapping(uint256 => Project) public projects;
    uint256 public projectCount;

    event ProjectCreated(uint256 indexed projectId, address indexed client, address indexed freelancer);
    event MilestoneCompleted(uint256 indexed projectId, uint256 milestone);
    event MilestonePaymentReleased(uint256 indexed projectId, uint256 milestone, uint256 amount);

    function createProjectWithMilestones(
        address _freelancer,
        uint256[] memory _milestoneAmounts,
        uint256 _insurancePolicyId
    ) external payable returns (uint256) {
        require(_freelancer != address(0), "Invalid freelancer");

        uint256 totalRequired = 0;
        for (uint i = 0; i < _milestoneAmounts.length; i++) {
            totalRequired += _milestoneAmounts[i];
        }
        require(msg.value >= totalRequired, "Insufficient payment");

        uint256 projectId = ++projectCount;
        projects[projectId] = Project({
            client: msg.sender,
            freelancer: _freelancer,
            totalAmount: msg.value,
            milestoneAmounts: _milestoneAmounts,
            milestonesCompleted: new bool[](_milestoneAmounts.length),
            milestonesPaid: new bool[](_milestoneAmounts.length),
            insurancePolicyId: _insurancePolicyId,
            hasInsurance: _insurancePolicyId > 0
        });

        emit ProjectCreated(projectId, msg.sender, _freelancer);
        return projectId;
    }

    function completeMilestone(uint256 _projectId, uint256 _milestone) external {
        Project storage project = projects[_projectId];
        require(project.freelancer == msg.sender, "Only freelancer can complete");
        require(_milestone < project.milestoneAmounts.length, "Invalid milestone");
        require(!project.milestonesCompleted[_milestone], "Already completed");

        project.milestonesCompleted[_milestone] = true;
        emit MilestoneCompleted(_projectId, _milestone);
    }

    function releaseMilestonePayment(uint256 _projectId, uint256 _milestone) external {
        Project storage project = projects[_projectId];
        require(project.client == msg.sender, "Only client can release");
        require(project.milestonesCompleted[_milestone], "Milestone not completed");
        require(!project.milestonesPaid[_milestone], "Already paid");

        project.milestonesPaid[_milestone] = true;
        uint256 amount = project.milestoneAmounts[_milestone];
        
        payable(project.freelancer).transfer(amount);
        emit MilestonePaymentReleased(_projectId, _milestone, amount);
    }

    // --- NEW GETTER FUNCTION ADDED HERE ---
    // This function returns the full Project struct for a given ID.
    function getProject(uint256 _projectId) external view returns (Project memory) {
        return projects[_projectId];
    }
}