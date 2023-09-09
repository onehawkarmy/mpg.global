// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Verifier.sol";  // Import the Verifier contract (this should be the contract generated by ZoKrates)

contract IdentityVerification is Verifier {
    // Event to log verification results
    event VerificationResult(address indexed verifier, bool success, string message);

    // Role-based access control
    mapping(address => bool) public admins;

    // Constructor to set the initial admins
    constructor() {
        admins[msg.sender] = true;
    }

    // Modifier to restrict functions to admins only
    modifier onlyAdmin() {
        require(admins[msg.sender], "Not an admin");
        _;
    }

    // Function to add a new admin
    function addAdmin(address newAdmin) public onlyAdmin {
        admins[newAdmin] = true;
    }

    // Function to remove an admin
    function removeAdmin(address admin) public onlyAdmin {
        admins[admin] = false;
    }

    // Function to verify a single proof
    function verifyIdentity(
        bytes memory proof,
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public {
        bool isValid = verifyTx(proof, a, b, c, input);
        if (isValid) {
            emit VerificationResult(msg.sender, true, "The proof is valid!");
        } else {
            emit VerificationResult(msg.sender, false, "The proof is invalid!");
        }
    }

    // Function to verify multiple proofs in a batch (this is just a simple example, optimizations can be made for batch verification)
    function batchVerifyIdentities(
        bytes[] memory proofs,
        uint[2][] memory as,
        uint[2][2][] memory bs,
        uint[2][] memory cs,
        uint[1][] memory inputs
    ) public onlyAdmin {
        require(
            proofs.length == as.length &&
            as.length == bs.length &&
            bs.length == cs.length &&
            cs.length == inputs.length,
            "Input lengths do not match"
        );

        for (uint i = 0; i < proofs.length; i++) {
            bool isValid = verifyTx(proofs[i], as[i], bs[i], cs[i], inputs[i]);
            if (isValid) {
                emit VerificationResult(msg.sender, true, "The proof is valid!");
            } else {
                emit VerificationResult(msg.sender, false, "The proof is invalid!");
            }
        }
    }
}
