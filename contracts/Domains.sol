// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "hardhat/console.sol";
import { StringUtils } from "./libraries/StringUtils.sol";
import { Base64 } from "./libraries/Base64.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

struct Record {
    string avatar;
    string twitterTag;
    string website;
    string email;
    string description;
}

enum RecordType {
    AVATAR,
    TWITTER,
    WEBSITE,
    EMAIL,
    DESCRIPTION
}

contract Domains is ERC721 {
    //mapping(string => address) public domains;
    //mapping(string => string) public avatars;

    mapping(string => Record) public records;
    mapping(uint => string) public names;
    mapping(string => uint) public ids;

    string public tld;
    address payable public owner;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public basePrice = 10000000000000000; //0.01

    string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"> <path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path class="st0" d="M270,270H0L0,13.7C0,6.1,6.1,0,13.7,0l242.6,0c7.6,0,13.7,6.1,13.7,13.7V270z"/><g><path class="st1" fill="#FFF" d="M41,33c0.1-0.1,0.2-0.2,0.3-0.3c2-1.7,4-3.2,6.2-4.5c1.3-0.8,2.6-1.5,4-2.1c0.9-0.4,1.9-0.8,2.9-1.1    c1-0.2,1.9-0.4,2.9-0.3c1,0.1,2,0.4,3,0.8c1.2,0.6,2.3,1.3,3.3,2.1c0.6,0.5,1.1,1,1.7,1.5c0.5,0.6,1.1,1.1,1.6,1.7    c1.3,1.5,2.3,3.1,3.2,4.9c0.9,1.8,1.6,3.6,2.1,5.5c0.5,1.7,0.8,3.4,0.9,5.2c0.1,1.3,0.2,2.6,0.1,3.9c-0.1,1.2-0.2,2.3-0.4,3.4    c-0.3,1.8-0.8,3.5-1.4,5.2c-0.8,2-1.7,3.9-2.9,5.7c-0.1,0.1-0.1,0.2-0.3,0.3c0-0.3,0.1-0.6,0.1-0.8c0.2-1.5,0.2-3,0.1-4.5    c-0.1-1.1-0.2-2.3-0.4-3.4c-0.2-1.2-0.5-2.4-0.9-3.5c-0.5-1.3-1-2.6-1.6-3.9c-1.4-2.8-3.3-5.2-5.5-7.4c-1.3-1.3-2.8-2.4-4.4-3.4    c-2.3-1.5-4.7-2.6-7.3-3.4c-1.3-0.4-2.6-0.8-3.9-1c-1-0.2-2-0.4-3-0.7C41.2,33,41.1,33,41,33z"/><path class="st1" fill="#FFF" d="M87.5,65.1c0,0.1,0.1,0.2,0.1,0.3c0.3,1.5,0.5,3,0.6,4.5c0.1,1.7,0.2,3.4,0.1,5.2c0,1.4-0.1,2.7-0.3,4.1    c-0.2,1.2-0.6,2.4-1.2,3.5c-0.4,0.7-0.9,1.3-1.5,1.9c-0.9,0.9-2,1.5-3.1,2c-1.7,0.8-3.4,1.3-5.3,1.7c-2.2,0.4-4.5,0.6-6.7,0.4    c-1.4-0.1-2.7-0.3-4.1-0.6c-1.8-0.4-3.6-0.9-5.3-1.7c-2.6-1.1-4.9-2.5-7-4.2c-1.9-1.6-3.6-3.4-5.1-5.4c-0.9-1.3-1.8-2.7-2.5-4.1    c0-0.1,0-0.1-0.1-0.2c0,0,0,0,0-0.1c0.1,0,0.2,0.1,0.2,0.1c0.7,0.6,1.5,1.1,2.3,1.6c0.9,0.5,1.8,1,2.8,1.5c1.3,0.6,2.6,1.1,4,1.5    c1.2,0.3,2.4,0.6,3.7,0.8c2.2,0.3,4.3,0.3,6.5,0.1c1.7-0.2,3.3-0.5,4.9-1c1.7-0.5,3.4-1.2,5-2c2.8-1.4,5.3-3.3,7.6-5.4    c1.3-1.3,2.6-2.6,3.8-4C87.1,65.5,87.3,65.3,87.5,65.1z"/><path class="st1" fill="#FFF" d="M41.1,60.2c0,0.1,0,0.2,0,0.3c-0.2,1.1-0.2,2.2-0.2,3.2c0,1.4,0.1,2.8,0.4,4.2c0.2,1.1,0.4,2.2,0.8,3.2    c0.4,1.3,0.9,2.5,1.4,3.7c0.8,1.6,1.7,3.2,2.8,4.6c1,1.3,2.1,2.6,3.3,3.7c1.3,1.2,2.7,2.3,4.3,3.3c1.5,1,3.2,1.8,4.9,2.5    c0.8,0.3,1.7,0.6,2.6,0.9c1.9,0.6,3.9,1,5.9,1.4c0.5,0.1,0.9,0.2,1.4,0.3c0.1,0.1,0,0.2-0.1,0.2c-0.5,0.5-1,0.9-1.6,1.4    c-1.8,1.4-3.6,2.7-5.6,3.9c-1.3,0.8-2.7,1.5-4.1,2.1c-0.9,0.4-1.8,0.7-2.8,0.9c-0.2,0-0.4,0-0.6,0c-0.4,0-0.7,0-1.1,0    c-0.7,0-1.4-0.1-2-0.3c-1.2-0.4-2.3-0.9-3.3-1.6c-1.9-1.3-3.5-2.9-5-4.6c-0.9-1.1-1.6-2.2-2.3-3.4c-0.7-1.1-1.2-2.3-1.7-3.6    c-0.5-1.2-0.9-2.4-1.2-3.7c-0.3-1.2-0.5-2.4-0.7-3.7c-0.2-1.6-0.3-3.3-0.2-5c0.1-1.3,0.2-2.5,0.5-3.8c0.4-2.3,1.1-4.4,2-6.5    c0.6-1.3,1.2-2.5,2-3.7C40.9,60.3,40.9,60.2,41.1,60.2C41,60.1,41,60.2,41.1,60.2z"/><path class="st1" fill="#FFF" d="M73.1,35.3c0.2,0,0.2,0,0.3,0c1,0.4,2,0.7,3,1.2c0.8,0.4,1.7,0.7,2.5,1.2c2.1,1.1,4.2,2.3,6.1,3.7    c1,0.7,1.8,1.5,2.6,2.4c0.7,1,1.2,2,1.4,3.2c0.2,1.1,0.3,2.3,0.2,3.4c-0.1,1.4-0.3,2.7-0.7,4.1c-0.4,1.7-1.1,3.3-1.9,4.9    c-0.6,1.2-1.3,2.3-2,3.3c-0.5,0.7-1,1.4-1.5,2c-1.1,1.4-2.4,2.6-3.7,3.7c-1.3,1.1-2.7,2.1-4.2,2.9c-1.7,1-3.5,1.7-5.3,2.3    c-1.6,0.5-3.3,0.9-5,1.1C63,75,61.2,75,59.5,75c-0.1,0-0.1,0-0.2,0c0-0.1,0-0.1,0.1-0.2c0.5-0.2,0.9-0.4,1.4-0.6    c1.1-0.5,2.1-1.1,3-1.7c3.1-2.1,5.7-4.8,7.8-8c1.1-1.8,2.1-3.7,2.8-5.7c0.5-1.4,0.9-2.8,1.1-4.2c0.2-0.9,0.3-1.8,0.4-2.8    c0.1-0.9,0.1-1.8,0.1-2.7c0-1.1-0.1-2.2-0.2-3.2c-0.2-1.9-0.6-3.8-1.2-5.7c-0.4-1.4-0.9-2.9-1.3-4.3    C73.2,35.7,73.1,35.5,73.1,35.3z"/><path class="st1" fill="#FFF" d="M22.1,60c-0.1-0.4-0.1-0.7-0.2-1c-0.4-2.3-0.6-4.7-0.6-7c0-1.6,0-3.2,0.2-4.8c0.1-1.1,0.3-2.1,0.6-3.2    c0.4-1.3,1.2-2.5,2.2-3.4c0.9-0.9,2-1.5,3.1-2c2.1-1,4.4-1.6,6.7-1.9c2.1-0.3,4.1-0.3,6.2-0.1c0.9,0.1,1.8,0.2,2.7,0.4    c1.7,0.3,3.4,0.8,5,1.4c1.6,0.6,3.2,1.4,4.7,2.3c2.1,1.3,4,2.8,5.7,4.6c1.3,1.3,2.4,2.8,3.4,4.3c0.6,0.9,1.1,1.8,1.5,2.7    c0,0.1,0.1,0.1,0.1,0.2c-0.1,0.1-0.2,0-0.2-0.1c-0.7-0.5-1.4-1-2.2-1.5c-1.2-0.8-2.5-1.4-3.9-2c-0.8-0.3-1.7-0.7-2.6-0.9    c-1-0.3-2.1-0.5-3.2-0.7c-1.3-0.2-2.6-0.3-4-0.4c-1.1,0-2.2,0-3.4,0.1c-2.2,0.2-4.3,0.7-6.4,1.4c-3.5,1.2-6.7,3.1-9.6,5.5    c-1.3,1.2-2.6,2.4-3.8,3.7c-0.6,0.7-1.3,1.4-1.9,2.1C22.3,59.8,22.2,59.8,22.1,60z"/><path class="st1" fill="#FFF" d="M36.2,89.2c-0.2,0.1-0.3,0-0.5-0.1c-0.8-0.3-1.6-0.6-2.4-1c-0.9-0.4-1.8-0.8-2.6-1.2c-1.7-0.9-3.4-1.9-5-2.9    c-0.8-0.5-1.6-1.1-2.3-1.8c-0.7-0.6-1.3-1.3-1.9-2.1c-0.6-1-1-2.1-1.2-3.3c-0.2-1.5-0.1-3,0.2-4.4c0.2-0.9,0.4-1.9,0.6-2.8    c0.5-1.7,1.2-3.3,2-4.8c0.6-1,1.2-2,1.8-3c0.5-0.7,1-1.4,1.6-2c1.3-1.5,2.7-2.8,4.2-4.1c1.6-1.2,3.2-2.3,5-3.1    c1.6-0.8,3.3-1.4,5-1.9c1.3-0.4,2.6-0.6,3.9-0.8c1.7-0.2,3.4-0.3,5.1-0.2c0.2,0,0.5,0,0.7,0c0,0.1,0,0.1-0.1,0.1    c-0.5,0.2-1.1,0.5-1.6,0.7c-1.5,0.7-3,1.6-4.3,2.7c-1.5,1.1-2.8,2.4-4.1,3.8c-1.5,1.7-2.8,3.6-3.9,5.7c-1.1,2.3-2,4.7-2.4,7.2    c-0.4,1.9-0.6,3.9-0.6,5.9c0,1.2,0.1,2.3,0.2,3.4c0.2,1.8,0.6,3.5,1.1,5.2c0.4,1.5,0.9,2.9,1.3,4.3C36.1,88.9,36.1,89,36.2,89.2z"/></g><defs><linearGradient id="B" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#00F9FF"/><stop offset="1" stop-color="#1F3B7E"" stop-opacity=".99"/></linearGradient></defs><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo = '</text></svg>';

    error Unauthorized();
    error AlreadyRegistered();
    error InvalidName(string name);

   constructor(string memory _tld) payable ERC721("HPB Name Service", "HNS") {
       owner = payable(msg.sender);
        tld = _tld;
        console.log("%s name service deployed", _tld);
        _tokenIds.increment();
    }

    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function withdraw() public onlyOwner {
        uint amount = address(this).balance;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw HPB");
    } 

    function getAllNames() public view returns (string[] memory) {
        console.log("Getting all names from contract");
        string[] memory allNames = new string[](_tokenIds.current()-1);
        for (uint i = 1; i < _tokenIds.current(); i++) {
            allNames[i-1] = names[i];
            console.log("Name for token %d is %s", i, allNames[i-1]);
        }

        return allNames;
    }

    function valid(string calldata name) public pure returns(bool) {
        return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 12;
    }

    function price(string calldata name) public pure returns(uint) {
        uint len = StringUtils.strlen(name);
        require(len > 0);
        if (len == 3) {
          return 5 * 10**16; // based on 0.05 // * 10**18
        } else if (len == 4) {
	        return 3 * 10**16; // * 10**18
        } else {
	        return 1 * 10**16; // * 10**18
        }
    }
  	
	function register(string calldata name) public payable {
        if (ids[name] != 0) revert AlreadyRegistered();
        if (!valid(name)) revert InvalidName(name);

        uint256 _price = this.price(name);
        require(msg.value >= _price, "Not enough HPB paid");
            
        uint256 newRecordId = _tokenIds.current();

        console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newRecordId);

        _safeMint(msg.sender, newRecordId);
        names[newRecordId] = name;
        ids[name] = newRecordId;

        _tokenIds.increment();
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(isSet(names[tokenId]), "Address unknown");

        string memory _name = string(abi.encodePacked(names[tokenId], ".", tld));

        uint256 length = StringUtils.strlen(_name);
        string memory strLen = Strings.toString(length);

        string memory avatar;

        // If using the basic avatar
        if(isSet(records[names[tokenId]].avatar)) {
            avatar = records[names[tokenId]].avatar;
        } else {
            string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));
            avatar = string(abi.encodePacked('data:image/svg+xml;base64,',Base64.encode(bytes(finalSvg))));
        }

        string memory json = Base64.encode(
            bytes(
                string(
                abi.encodePacked(
                    '{"name": "',
                    _name,
                    '", "description": "A domain on the HPB name service", "image": "',
                    avatar,
                    '","length":"',
                    strLen,
                    '"}'
                )
                )
            )
        );

        return string( abi.encodePacked("data:application/json;base64,", json));
    }

    function getId(string calldata name) public view returns(uint) {
        require(ids[name] != 0);
        return ids[name];
    }

	// This will give us the domain owners' address
    function getAddress(string calldata name) public view returns (address) {
       return ownerOf(getId(name));
    }

    function setRecord(string calldata name, string calldata record, RecordType recordType) public {
		// Check that the owner is the transaction sender
        if (msg.sender != getAddress(name)) revert Unauthorized();

        if(recordType == RecordType.AVATAR) {
            records[name].avatar = record;
        } else if(recordType == RecordType.TWITTER) {
            records[name].twitterTag = record;
        } else if(recordType == RecordType.WEBSITE) {
            records[name].website = record;
        } else if(recordType == RecordType.EMAIL) {
            records[name].email = record;
        } else if(recordType == RecordType.DESCRIPTION) {
            records[name].description = record;
        }
    }

    // One string is in memory cause https://forum.openzeppelin.com/t/stack-too-deep-when-compiling-inline-assembly/11391/4
    function setRecords(string calldata name, string memory _avatar, string calldata _twitterTag, string calldata _website, string calldata _email, string calldata _description) public {
        if (msg.sender != getAddress(name)) revert Unauthorized();

        records[name].avatar = _avatar;
        records[name].twitterTag = _twitterTag;
        records[name].website = _website;
        records[name].email = _email;
        records[name].description = _description;
    }

    function getRecord(string calldata name, RecordType recordType) public view returns(string memory) {
        if(recordType == RecordType.AVATAR) {
            return records[name].avatar;
        } else if(recordType == RecordType.TWITTER) {
            return records[name].twitterTag;
        } else if(recordType == RecordType.WEBSITE) {
            return records[name].website;
        } else if(recordType == RecordType.EMAIL) {
            return records[name].email;
        } else if(recordType == RecordType.DESCRIPTION) {
            return records[name].description;
        }

        revert("Record not found");
    }

    function getRecords(string calldata name) public view returns(string[] memory, address) {
        address addr = getAddress(name);
        string[] memory allRecords = new string[](5);

        allRecords[0] = records[name].avatar;
        allRecords[1] = records[name].twitterTag;
        allRecords[2] = records[name].website;
        allRecords[3] = records[name].email;
        allRecords[4] = records[name].description;

        return (allRecords, addr);
    }

    function isSet(string memory name) public pure returns(bool) {
        return StringUtils.strlen(name) != 0;
    }
}