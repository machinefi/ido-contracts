// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/ILaunchpad.sol";
import "./interfaces/IWSProject.sol";
import "./interfaces/IioIDFactory.sol";
import {Project} from "./Project.sol";

contract Launchpad is ILaunchpad, Ownable {
    address public override wsProject;
    address public override ioIDFactory;

    mapping(uint256 => address) public override getProject;
    mapping(address => Status) _status;

    constructor(address _wsProject, address _ioIDFactory) {
        wsProject = _wsProject;
        ioIDFactory = _ioIDFactory;
    }

    function applyProject(uint256 _wsProjectId, address _nft, uint256 _amount, uint256 _price)
        external
        override
        returns (address project_)
    {
        require(_nft != address(0), "zero address");
        require(_amount > 0, "zero amount");
        require(getProject[_wsProjectId] == address(0), "already applied");
        require(IWSProject(wsProject).ownerOf(_wsProjectId) == msg.sender, "only project owner");
        require(IioIDFactory(ioIDFactory).projectAppliedAmount(_wsProjectId) >= _amount, "exceed bought ioIDs");

        bytes memory bytecode = type(Project).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_wsProjectId, _nft));
        assembly {
            project_ := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Project(project_).initialize(_wsProjectId, _nft, _price, _amount, msg.sender);
        getProject[_wsProjectId] = project_;
        _status[project_] = Status.Pending;

        emit ApplyProject(_wsProjectId, _nft, project_);
    }

    function status(address _project) external view returns (Status) {
        Status _s = _status[_project];
        if (_s == Status.Selling) {
            Project _p = Project(_project);
            if (_p.soldAmount() == _p.total()) {
                return Status.Sold;
            }
        }
        return _s;
    }

    function start(address _project) external override onlyOwner {
        Status _s = _status[_project];
        require(_s == Status.Pending || _s == Status.Stopped, "only pending or stopped");
        _status[_project] = Status.Selling;

        emit StartProject(_project);
    }

    function stop(address _project) external override onlyOwner {
        require(_status[_project] == Status.Selling, "only selling");

        _status[_project] = Status.Stopped;
        emit StopProject(_project);
    }

    function withdraw(address _project, address _recipient, uint256 _amount) external override onlyOwner {
        require(_status[_project] != Status.Pending, "invalid status");

        Project(_project).withdraw(_recipient, _amount);
    }
}
