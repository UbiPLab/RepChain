pragma solidity >=0.4.22 <0.7.0;
pragma experimental ABIEncoderV2;
contract RepChain{
    enum State{
        RatingRequest,
        ShareProcessing,
        SumComputing,
        ReputationUpdating,
        Completed
    }
    State currentstate;
    
    struct requestStruct{
        string sj;
        string ctij;
        string rci;
    }
    
    
    requestStruct[] rsl;
    string[] sdl;
    mapping(bytes32=>bytes32) RTP;
    mapping(bytes32=>uint256) shareNum;
    mapping(bytes32=>uint256) newRatings;
    
    function Request(string memory Sj,string memory ctij,string memory rci,bytes32 htxpk,bytes32 msgh,uint8 v,bytes32 r,bytes32 s) public{//txpk as a given argument
        require(
            ecrecover(msgh, v, r, s)==msg.sender,
            "Incorrect"
        );
        currentstate=State.RatingRequest;
        requestStruct memory rs=requestStruct(Sj,ctij,rci);
        rsl.push(rs);
        RTP[htxpk]=htxpk;
        shareNum[htxpk]=0;
        require(currentstate==State.RatingRequest,"oops");
        currentstate=State.ShareProcessing;
        emit Broadcast("A rating request has been created.");
    }
    
    function CollectStepS(string memory sdkj,bytes32 txpk,uint256 N,bytes32 msgh,uint8 v,bytes32 r,bytes32 s) public{//after outside procedure
        require(
            ecrecover(msgh, v, r, s)==msg.sender,
            "Incorrect"
        );
        shareNum[txpk]=N;
        sdl.push(sdkj);
        require(currentstate==State.ShareProcessing,"oops");
        currentstate=State.SumComputing;
        emit Broadcast("Enough share decryptions have been collected.");
    }
    
    function Update(uint256 sum,bytes32 txpk,bytes32 msgh,uint8 v,bytes32 r,bytes32 s) public{
        require(
            ecrecover(msgh, v, r, s)==msg.sender,
            "Incorrect"
        );
        newRatings[txpk]=sum;
        require(currentstate==State.SumComputing,"oops");
        currentstate=State.ReputationUpdating;
        emit Broadcast("The sum of new ratings has been calculated.");
    }
    
    function Reject(bytes32 txpk) public{
        //require(currentstate==State.RatingRequest,"oops");
        delete RTP[txpk];
        delete shareNum[txpk];
        delete newRatings[txpk];
        //The rating process has been rejected
        currentstate=State.Completed;
        emit Broadcast("The rating process has been rejected.");
    }
    
    function Complete(bytes32 txpk,bytes32 msgh,uint8 v,bytes32 r,bytes32 s) public{//txpk?
        require(
            ecrecover(msgh, v, r, s)==msg.sender,
            "Incorrect"
        );
        require(currentstate==State.ReputationUpdating,"oops");
        //The rating process has been rejected
        currentstate=State.Completed;
        emit Broadcast("A rating request has been completed.");
    }
    
    event Broadcast(string);
}
