// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// MultiSig wallet is a special wallet where multiple addresses approve a transcation before you spend an ether
contract Wallet{
    address[] public approvers;
    // numbers of approvers needed to approve to a transfer
    uint public quorum; 

    struct Transfer {
        uint amount;
        uint id;
        uint approvals;
        address payable to;
        bool sent;
    }

    Transfer[] public transfers;
    mapping(address => mapping(uint => bool)) approvals;

    constructor(address[] memory _approvers, uint _quorum){
        approvers = _approvers;
        quorum = _quorum;
    }

    // Function to return the list of approvers
    function getApprovers()external view returns(address[] memory){
        return approvers;
    }

     // Function to return the list of approvers
    function getTransfers()external view returns(Transfer [] memory){
        return transfers;
    }

    function createTransfer(uint amount, address payable to) external onlyApprove{
    transfers.push(Transfer(
        amount,
        transfers.length,
        0,
         to,
        false
        ));

    // transfers.push(Transfer({
    //     amount: amount,
    //     to: to,
    //     sent: false,
    //     approvals: 0,
    //     id: transfers.length+1
    // }));
    }

    function approveTransfers(uint id) external onlyApprove{
        require(transfers[id].sent == false, "Transfer has alreay been sent");
        require(approvals[msg.sender][id] == false, "cannot approve transfer twice");

        approvals[msg.sender][id] == true;
        transfers[id].approvals ++;
        
        if(transfers[id].approvals >= quorum){
            transfers[id].sent == true;
            address payable to = transfers[id].to; 
            uint amount = transfers[id].amount;
            to.transfer(amount);
        }
    }

    receive() external payable{}

    modifier onlyApprove() {
        bool allowed = false;
        for(uint i = 0; i < approvers.length; i++){
            if(approvers[i] == msg.sender){
                allowed = true;
            }
        }
        require(allowed == true, "only approvers allowed");
        _;
    }
}

