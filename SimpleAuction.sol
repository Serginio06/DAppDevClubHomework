pragma solidity ^0.4.20;

import "browser/SimpleAuctionInterface.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract SimpleAuction is AuctionInterface {

    using strings for *;
    uint minBidAmount;
    uint minPriceAmount;

    event Logger(string);

    struct OwnerExt {
        address ownerSender;
        uint _rating;
    }

    mapping (uint => OwnerExt) internal owners;
    uint ownersLength; //  max index in owners array

    struct lot {
        string _name; // lot name
        uint _price; //Amount (in Wei) needed to buy the lot immediately
        uint _minBid; // Amount (in Wei) needed to place a bid.
        OwnerExt owner;
        address lastBidder;
        uint bidAmount;
        bool isEnded;
        uint start;
        uint end;
    }

    mapping (uint => lot) internal lots;
    uint lotsLength; //  max index in lots array

    function SimpleAuction() internal {
        minBidAmount = 5;  // 5 wei will be min amount to place bid
        minPriceAmount = 5; // minimal price is 5 wei
    }



    // modifier isLotOwner (address lotOwner) {
    //     require(lotOwner == msg.sender);
    //     _;
    // }

    // modifier isBidAmountCorrect {
    //     require (minBidAmount <= msg.value);
    //     _;
    // }

    // modifier isPriceAmountCorrect {
    //     require (minPriceAmount <= msg.value);
    //     _;
    // }



    function createLot(string _name, uint _price, uint _minBid) public {
        require(_name.toSlice().len() >= 5); // name of lot should be more then 5 charaters
        require (_minBid >= minBidAmount ); // 5 wei will be step to place next bid
        require (_price >= minPriceAmount ); // minimal price is 5 wei

        if (!isLotExist(_name)) {

            if(indexOfOwner(msg.sender) == 0) {
                ownersLength++;
                owners[ownersLength].ownerSender = msg.sender;
                owners[ownersLength]._rating = 0;
            }


            lotsLength++;
            uint _lotID = lotsLength;


            lots[_lotID]._name = _name;
            lots[_lotID]._price = _price;
            lots[_lotID]._minBid = _minBid;
            lots[_lotID].owner.ownerSender = msg.sender;
            lots[_lotID].lastBidder = lots[_lotID].owner.ownerSender; // when we create lot lastBidder will be lotOwner
            lots[_lotID].bidAmount = _minBid;
            lots[_lotID].isEnded = false;
            lots[_lotID].start = now;
            lots[_lotID].end = now + 10 days; // auctions duration 10 days

            Logger("lot was created");
        }

        Logger("lot with this name exist");

    }


    function removeLot(uint _lotID) public {

        require (lots[_lotID].owner.ownerSender == msg.sender); //only lotOwner can delete lot
        require(lots[_lotID].lastBidder == lots[_lotID].owner.ownerSender); // no bids
        require(exists(_lotID));

        delete lots[_lotID];

    }

    function bid(uint _lotID) payable {
        // check if the lot is not ended (due to time limit)
        // and is not Prcessed due to bid was higher then price
        require(!isEnded(_lotID) && !isProcessed(_lotID));

        // lotOwner can not place a bid
        require (lots[_lotID].owner.ownerSender != msg.sender);
        require(exists(_lotID));

        require(lots[_lotID]._price <= lots[_lotID]._minBid + msg.value);

        // bid is higher then price => lot is ended with price amount
        if (lots[_lotID]._price <= msg.value) {
            processLot (lots[_lotID]._price);
        }


        // return wei to previouse bidder (lastBidder) and change  bid and minBid for current lot
        assert(refund(_lotID));

        Logger("amount successfuly refunded to last bider and new Bid placed");

        //update curetn lot with new bidder
        lots[_lotID].lastBidder = msg.sender;
        lots[_lotID].bidAmount = msg.value;
        lots[_lotID]._minBid = msg.value + lots[_lotID]._minBid;
    }


    function processLot(uint _lotID) {
        require(exists(_lotID));

        assert (lots[_lotID].owner.ownerSender.send(lots[_lotID].bidAmount) );

        // if send return true, change lot status
        lots[_lotID].isEnded = true;
    }

    function getBidder(uint _lotID) constant returns (address) {
        return lots[_lotID].lastBidder;
    }


    function isEnded(uint _lotID) constant returns (bool) {
        require(exists(_lotID));

        if (now >= lots[_lotID].end) {
            processLot(_lotID);
            return true;
        }

        return false;

    }

    function isProcessed(uint _lotID) constant returns (bool) {
        return lots[_lotID].isEnded;
    }

    function exists(uint _lotID) constant returns (bool){
        return _lotID <= lotsLength;
    }

    // =======
    // Rating:
    // =======
    function rate(uint _lotID, bool _option) {

        uint lotOwnerIndex = indexOfOwner(lots[_lotID].owner.ownerSender);
        // unit lotOwnerRating = owners[lotOwnerIndex]._rating;

        assert(lotOwnerIndex >0);

        if (_option) {
            owners[lotOwnerIndex]._rating++;
        }
        else {
            assert(owners[lotOwnerIndex]._rating > 0);
            owners[lotOwnerIndex]._rating--;
        }

    }


    function getRating(address _owner) constant returns (uint) {
        uint ownerIndex = indexOfOwner(_owner);

        return owners[ownerIndex]._rating;
    }


    // ================ additional functions =============

    function isLotExist (string _searchName) private returns (bool) {
        for (uint i = 0; i <= lotsLength;i++) {
            if (_searchName.toSlice().equals( lots[i]._name.toSlice() )) {
                return true;
            }
            return false;
        }
    }


    function indexOfOwner (address owner) private returns (uint) {
        for (uint n = 0; n <= ownersLength;n++) {
            if (owner == owners[n].ownerSender) {
                return n;
            }
            return 0;
        }
    }


    function refund (uint _lotID) private returns (bool) {
        uint _amountToRefund = lots[_lotID].bidAmount;
        address lastBidder = lots[_lotID].lastBidder;

        assert (lastBidder.send( _amountToRefund));

        Logger("Refund successfull");
    }
}
