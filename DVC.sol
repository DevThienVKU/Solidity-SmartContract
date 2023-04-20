// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
pragma abicoder v2;

// import "./GovernanceToken.sol";

contract DVC{

    enum userRole {
        Developer,
        Co_Author,
        Partner
    }

    enum documentState {
        NotReady,
        WaitForApproved, //voting
        ApprovalSuccess,
        ApprovalFailed,
        CreatedSuccess //publish
    }

    struct PostOwner {
        address user;
        userRole role;
        uint32 point;
    }

    struct DocumentVersion {
        uint256 verionId;
        string DocumentVersionHash;
        address contributor;
        documentState state;
    }

    struct DocumentItem {
        string docTitle;
        string IPFSHashforDocument;
        address owner;
        PostOwner[] co_Owner;
        DocumentVersion[] doc_version;
        uint256 versionIdPublish;
        uint32 numberOfUploads;
    }

    DocumentItem[] public documentList;
    mapping(address => DocumentItem[]) public documentOwnerList;

    struct Vote {
        address approver;
        bool status;
    }

    struct VoteDoc {
        uint256 yes;
        uint256 no;
        Vote[] votes;
    }

    mapping(uint256 => VoteDoc[]) public voteVersion;

    event DocumentCreated(address owner, string info);
    event DocumentVersionUploaded(address, string info);
    event DraftDocumentCreated(address, string info);
    event VoteDraftDocument(address, string info);

    //create new Document
    function documentVersionController(
        string memory title,
        string memory ipfshashdoc
    ) public payable {
        DocumentVersion memory docVersion = DocumentVersion(
            0,
            ipfshashdoc,
            msg.sender,
            documentState.CreatedSuccess
        );

        DocumentItem storage docItem = documentOwnerList[msg.sender].push();
        docItem.docTitle = title;
        docItem.IPFSHashforDocument = ipfshashdoc;
        docItem.doc_version.push(docVersion);
        docItem.owner = msg.sender;
        docItem.numberOfUploads = 1;

        documentList.push(docItem);

        emit DocumentCreated(msg.sender, "Document created successfully");
    }

    //create new version
    function createDocumentVersion(uint256 doc_id, string memory ipfshashdoc)
        public
    {
        DocumentVersion memory versionItem = documentList[doc_id]
            .doc_version
            .push();

        uint256 version_length = documentList[doc_id].doc_version.length;

        versionItem.verionId = version_length++;
        versionItem.contributor = msg.sender;
        versionItem.DocumentVersionHash = ipfshashdoc;
        versionItem.state = documentState.ApprovalSuccess;

        emit DraftDocumentCreated(msg.sender, "Draft created successfully");
    }

    function voteApproveforDocument(uint256 doc_id, bool status) public {
        VoteDoc storage vote = voteVersion[doc_id].push();

        if (status) vote.yes++;
        else if (!status) vote.no++;
        vote.votes.push(Vote(msg.sender, status));

        emit VoteDraftDocument(msg.sender, "Vote Document successfully");
    }

    function _afterVotingProcess(uint256 doc_id) external {
        delete voteVersion[doc_id];
    }

    function _getListDocuments() public view returns (DocumentItem[] memory) {
        return documentList;
    }
}
