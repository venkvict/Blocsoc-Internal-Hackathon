// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    address payable public immutable feeAccount; // the account that receives fees
    uint256 public immutable feePercent; // the fee percentage on sales
    uint256 public itemCount;

    struct Item {
        uint256 itemId;
        IERC721 nft; // instance of the NFT contract
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    }

    event Offered(
        uint256 indexed itemId,
        address nft,
        uint256 indexed tokenId,
        uint256 price,
        address indexed seller,
        uint256 offeredDateTime
    );

    event Bought(
        uint256 itemId,
        address nft,
        uint256 indexed tokenId,
        uint256 price,
        address indexed seller,
        address indexed buyer,
        uint256 boughtDateTime
    );

    mapping(uint256 => Item) public items;

    constructor(uint256 _feePercent) {
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }

    function makeItem(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _price,
        uint256 offeredDateTime
    ) external nonReentrant {
        require(_price > 0, "Price must be greater than zero");
        itemCount++;
        _nft.transferFrom(msg.sender, address(this), _tokenId);

        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );

        emit Offered(
            itemCount,
            address(_nft),
            _tokenId,
            _price,
            msg.sender,
            offeredDateTime
        );
    }

    function purchaseItem(uint256 _itemId, uint256 boughtDateTime)
        external
        payable
        nonReentrant
    {
        uint256 _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "item doesn't exist");
        require(
            msg.value >= _totalPrice,
            "not enough ether to cover the item price and market fee"
        );
        require(!item.sold, "item already sold");
        item.seller.transfer(item.price);
        feeAccount.transfer(_totalPrice - item.price);
        item.sold = true;
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
        emit Bought(
            _itemId,
            address(item.nft),
            item.tokenId,
            item.price,
            item.seller,
            msg.sender,
            boughtDateTime
        );
    }

    function getTotalPrice(uint256 _itemId) public view returns (uint256) {
        return ((items[_itemId].price * (100 + feePercent)) / 100);
    }

    // New functionality for trading

    struct Offer {
        uint256 offerId;
        uint256 itemId;
        address payable buyer;
        uint256 offerPrice;
        bool accepted;
    }

    uint256 public offerCount;
    mapping(uint256 => Offer) public offers;

    event OfferMade(
        uint256 indexed offerId,
        uint256 indexed itemId,
        address indexed buyer,
        uint256 offerPrice,
        uint256 offerDateTime
    );

    event OfferAccepted(
        uint256 indexed offerId,
        uint256 indexed itemId,
        address indexed buyer,
        uint256 offerPrice,
        uint256 acceptanceDateTime
    );

    function makeOffer(uint256 _itemId, uint256 _offerPrice, uint256 offerDateTime) external payable nonReentrant {
        require(_offerPrice > 0, "Offer price must be greater than zero");
        require(_itemId > 0 && _itemId <= itemCount, "Item doesn't exist");
        require(msg.value == _offerPrice, "Ether sent must match offer price");

        offerCount++;
        offers[offerCount] = Offer(
            offerCount,
            _itemId,
            payable(msg.sender),
            _offerPrice,
            false
        );

        emit OfferMade(offerCount, _itemId, msg.sender, _offerPrice, offerDateTime);
    }

    function acceptOffer(uint256 _offerId, uint256 acceptanceDateTime) external nonReentrant {
        Offer storage offer = offers[_offerId];
        Item storage item = items[offer.itemId];
        require(_offerId > 0 && _offerId <= offerCount, "Offer doesn't exist");
        require(!offer.accepted, "Offer already accepted");
        require(msg.sender == item.seller, "Only the item seller can accept offers");

        uint256 _totalPrice = getTotalPrice(item.itemId);
        require(offer.offerPrice >= _totalPrice, "Offer price is less than the total price");

        item.seller.transfer(item.price);
        feeAccount.transfer(_totalPrice - item.price);
        item.sold = true;
        item.nft.transferFrom(address(this), offer.buyer, item.tokenId);

        offer.accepted = true;

        emit OfferAccepted(_offerId, offer.itemId, offer.buyer, offer.offerPrice, acceptanceDateTime);
    }
}
