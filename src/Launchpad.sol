// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/ILaunchpad.sol";
import "./interfaces/IProject.sol";
import "./interfaces/IioIDStore.sol";
import "./LaunchpadTokenURIProvider.sol";
import {Pod} from "./Pod.sol";

contract Launchpad is ILaunchpad, Ownable {
    address public override project;
    address public override ioIDStore;
    LaunchpadTokenURIProvider public tokenURIProvider;

    mapping(uint256 => address) public override getPod;
    mapping(address => Status) public override status;

    constructor(address _project, address _ioIDStore) {
        project = _project;
        ioIDStore = _ioIDStore;
        tokenURIProvider = new LaunchpadTokenURIProvider();
    }

    function applyPod(
        uint256 _projectId,
        string calldata _name,
        string calldata _symbol,
        uint256 _amount,
        uint256 _price,
        uint256 _startTime
    ) external override returns (address pod_) {
        require(_amount > 0, "zero amount");
        require(_startTime > block.timestamp, "invalid startTime");
        require(getPod[_projectId] == address(0), "already applied");
        require(IProject(project).ownerOf(_projectId) == msg.sender, "only project owner");

        IioIDStore _ioIdStore = IioIDStore(ioIDStore);
        require(_ioIdStore.projectAppliedAmount(_projectId) >= _amount, "exceed bought ioIDs");

        {
            bytes memory bytecode = type(Pod).creationCode;
            bytes32 salt = keccak256(abi.encodePacked(_projectId));
            assembly {
                pod_ := create2(0, add(bytecode, 32), mload(bytecode), salt)
            }
        }
        Pod(pod_).initialize(_name, _symbol, _projectId, _price, _amount, msg.sender, _startTime);
        getPod[_projectId] = pod_;
        status[pod_] = Status.Normal;

        emit ApplyPod(_projectId, pod_);
    }

    function setPodBaseURI(address _pod, string calldata _baseURI) external override onlyOwner {
        require(status[_pod] != Status.None, "invalid pod");

        tokenURIProvider.setBase(_pod, _baseURI);
        Pod(_pod).setTokenURIProvider(address(tokenURIProvider));
    }

    function stop(address _pod) external override onlyOwner {
        require(status[_pod] == Status.Normal, "invalid pod");

        status[_pod] = Status.Stopped;
        emit StopPod(_pod);
    }

    function resume(address _pod) external override onlyOwner {
        require(status[_pod] == Status.Stopped, "invalid pod");

        status[_pod] = Status.Normal;
        emit ResumePod(_pod);
    }

    function withdraw(address _pod, address _recipient, uint256 _amount) external override onlyOwner {
        Pod(_pod).withdraw(_recipient, _amount);
    }
}
