// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CrowdFunding {
    //errors
    error CrowdFunding__ProjectNotFound(uint256 projectId); //checked done
    error CrowdFunding__ProjectIsNotActive(); //checked done
    error CrowdFunding__InsufficentFund(); //checked done
    error CrowdFunding__NotOwner();
    // this specifies error if for createProject function
    error CrowdFunding__MinFundingAmountIsHigherThenTotalFundingAmount(); //
    error CrowdFunding__EndingDateIsLessThanStartDate();
    // this error is for withdrawal function which check pool must be full!
    error CrowdFunding__FundedBalanceIsLowerThanTotalBalanceSetByOwner();

    //state variables
    address public _systemOwner;
    uint256 private _projectsCount = 1;

    struct Projects {
        string protocolName;
        string title;
        string description;
        uint256 totalFundingAmount;
        uint256 currentBalance;
        uint256 minAmountToFund;
        address payable projectOwner;
        uint256 startDate;
        uint256 endDate;
        bool isActive;
        bool exists;
        // this is the address of the funders
        address[] funders;
    }

    //mappings
    mapping(uint256 => Projects) public projectIdToProject;
    // this mapping is for tract the amount funded by user to a project using their address
    mapping(uint256 => mapping(address => uint256)) public userFundingAmount;

    constructor() {
        _systemOwner = msg.sender;
    }

    function CreateProject(
        string memory _protocolName,
        string memory _title,
        string memory _description,
        uint256 _totalFundingAmount,
        uint256 _minAmountToFund,
        uint256 _startDate,
        uint256 _endDate
    ) public returns (uint256) {
        if (_totalFundingAmount < _minAmountToFund) {
            revert CrowdFunding__MinFundingAmountIsHigherThenTotalFundingAmount();
        } else if (_endDate < _startDate) {
            revert CrowdFunding__EndingDateIsLessThanStartDate();
        }
        uint256 projectId = _projectsCount;
        projectIdToProject[_projectsCount] = Projects({
            protocolName: _protocolName,
            title: _title,
            description: _description,
            totalFundingAmount: _totalFundingAmount,
            currentBalance: 0,
            minAmountToFund: _minAmountToFund,
            projectOwner: payable(msg.sender),
            startDate: _startDate,
            endDate: _endDate,
            isActive: _startDate <= block.timestamp ? true : false,
            exists: true,
            funders: new address[](0)
        });
        _projectsCount++;
        return projectId;
    }

    function fundToProject(uint256 projectId) public payable {
        // logic to fund a project
        //checks
        if (projectIdToProject[projectId].exists != true) {
            revert CrowdFunding__ProjectNotFound(projectId);
        } else if (projectIdToProject[projectId].isActive == false) {
            revert CrowdFunding__ProjectIsNotActive();
        }
        if (block.timestamp >= projectIdToProject[projectId].endDate) {
            revert CrowdFunding__ProjectIsNotActive();
        }
        // }else if(msg.value > projectIdToProject[projectId].totalFundingAmount){
        //     revert FundingAmountIsTooMuch();
        // }
        else if (msg.value < projectIdToProject[projectId].minAmountToFund) {
            revert CrowdFunding__InsufficentFund();
        }
        projectIdToProject[projectId].currentBalance += msg.value;
        if (userFundingAmount[projectId][msg.sender] == 0) {
            projectIdToProject[projectId].funders.push(msg.sender);
        }

        userFundingAmount[projectId][msg.sender] += msg.value;
    }

    function withdrawalFund(uint256 projectId) public payable {
        Projects storage project = projectIdToProject[projectId];
        if (msg.sender != project.projectOwner) {
            revert CrowdFunding__NotOwner();
        } else if (project.currentBalance < project.totalFundingAmount) {
            revert CrowdFunding__FundedBalanceIsLowerThanTotalBalanceSetByOwner();
        }
        (bool sucess, ) = payable(project.projectOwner).call{
            value: project.currentBalance
        }("");
        require(sucess, "withdrawal failed");
        projectIdToProject[projectId].isActive = false;
        project.currentBalance = 0;
    }

    // Getters functions
    function getProjectDetails(
        uint256 projectId
    ) public view returns (Projects memory) {
        return projectIdToProject[projectId];
    }

    function getAmountFundedByUser(
        uint256 projectsId,
        address userAddress
    ) public view returns (uint256) {
        return userFundingAmount[projectsId][userAddress];
    }

    // function get_systemOwner() public view returns(address){
    //     return _systemOwner;
    // }
}
