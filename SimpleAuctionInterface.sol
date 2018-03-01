pragma solidity ^0.4.20;

interface AuctionInterface {

    // ============
    // Marketplace:
    // ============

    /**
     * @notice  Creates a lot.
     * @param   _name The lot name.
     * @param   _price Amount (in Wei) needed to buy the lot immediately
     * @param   _minBid Amount (in Wei) needed to place a bid.
     */
    function createLot(string _name, uint _price, uint _minBid);

    /**
     * @notice  Removes lot, which has no bids.
     * @param   _lotID Integer identifier associated with target lot
     */
    function removeLot(uint _lotID);

    /**
     * @notice  Places a bid. Contract should return the wei value to previous
     *          bidder
     * @param  _lotID Integer identifier associated with target lot
     */
    function bid(uint _lotID) payable;

    /**
     * @notice  Resolves the lot status if it's time is passed. Anyone should
     *          call the function when the lot ends to explicitly mark the lot
     *          as completed and transfer bid amount to the lot owner.
     * @param   _lotID Integer identifier associated with target lot
     */
    function processLot(uint _lotID);

    /**
     * @notice  Shows the last bid owner (bidder) address.
     * @param   _lotID Integer identifier associated with target lot
     * @return  Bidder address
     */
    function getBidder(uint _lotID) constant returns (address);

    /**
     * @notice  Determines if lot is ended.
     * @param   _lotID Integer identifier associated with target lot
     * @return  Boolean indication of whether the lot is ended.
     */
    function isEnded(uint _lotID) constant returns (bool);

    /**
     * @notice  Determines if lot is processed.
     * @param   _lotID _lotID Integer identifier associated with target lot
     * @return  Boolean indication of whether the lot is processed.
     */
    function isProcessed(uint _lotID) constant returns (bool);

    /**
     * @notice  Determines if lot exists.
     * @param   _lotID Integer identifier associated with target lot
     * @return  Boolean indication of whether the lot exists.
     */
    function exists(uint _lotID) constant returns (bool);

    // =======
    // Rating:
    // =======

    /**
     * @notice  Uprate or downrate the lot owner. Can be called by the lot buyer. 
     * @param   _lotID Integer identifier associated with target lot
     * @param   _option Boolean value which indicates the option (false - downrate, true - uprate)
     */
    function rate(uint _lotID, bool _option);

    /**
     * @notice  Shows the rating for the provided user address.
     * @param   _owner User address.
     * @return  Amount of rating.
     */
    function getRating(address _owner) constant returns (uint);

}
