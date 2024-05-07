// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/ILaunchpad.sol";
import "./interfaces/IProject.sol";
import "./interfaces/IioIDStore.sol";
import {Pod} from "./Pod.sol";

contract Launchpad is ILaunchpad, Ownable {
    address public override project;
    address public override ioIDStore;

    mapping(uint256 => address) public override getPod;
    mapping(address => Status) _status;

    constructor(address _project, address _ioIDStore) {
        project = _project;
        ioIDStore = _ioIDStore;
    }

    function applyPod(uint256 _projectId, uint256 _amount, uint256 _price) external override returns (address pod_) {
        require(_amount > 0, "zero amount");
        require(getPod[_projectId] == address(0), "already applied");
        require(IProject(project).ownerOf(_projectId) == msg.sender, "only project owner");

        IioIDStore _ioIdStore = IioIDStore(ioIDStore);
        require(_ioIdStore.projectAppliedAmount(_projectId) >= _amount, "exceed bought ioIDs");

        address _nft = _ioIdStore.projectDeviceContract(_projectId);

        bytes memory bytecode = type(Pod).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_projectId, _nft));
        assembly {
            pod_ := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Pod(pod_).initialize(_projectId, _nft, _price, _amount, msg.sender);
        getPod[_projectId] = pod_;
        _status[pod_] = Status.Pending;

        emit ApplyPod(_projectId, _nft, pod_);
    }

    function status(address _pod) external view returns (Status) {
        Status _s = _status[_pod];
        if (_s == Status.Selling) {
            Pod _p = Pod(_pod);
            if (_p.soldAmount() == _p.total()) {
                return Status.Sold;
            }
        }
        return _s;
    }

    function start(address _pod) external override onlyOwner {
        Status _s = _status[_pod];
        require(_s == Status.Pending || _s == Status.Stopped, "only pending or stopped");
        _status[_pod] = Status.Selling;

        emit StartPod(_pod);
    }

    function stop(address _pod) external override onlyOwner {
        require(_status[_pod] == Status.Selling, "only selling");

        _status[_pod] = Status.Stopped;
        emit StopPod(_pod);
    }

    function withdraw(address _pod, address _recipient, uint256 _amount) external override onlyOwner {
        require(_status[_pod] != Status.Pending, "invalid status");

        Pod(_pod).withdraw(_recipient, _amount);
    }
}
