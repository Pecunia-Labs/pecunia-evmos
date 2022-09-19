// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../base64-sol/base64.sol";

contract HeirToken is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => uint256) tokenIdToAmount;

    mapping(uint256 => string) tokenIdToUri;

    constructor() ERC721("Heir", "HEIR") {}

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function mint(address user, string memory _tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _mint(user, newItemId);
        _tokenIds.increment();
        return newItemId;
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }

    function svgToImageURI(string memory svg)
        public
        pure
        returns (string memory)
    {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(abi.encodePacked(svg))
        );
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function getImageURI(uint256 tokenId) internal view returns (string memory uri) {
        uint256 score = tokenIdToAmount[tokenId];
        string memory finalSvg = string(
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 500 500'><defs><linearGradient id='myGradient'><stop offset='10%' stop-color='#49ab81' /><stop offset='95%' stop-color='#317256' /></linearGradient><g stroke='black' fill=\"url('#myGradient')\" strokeWidth='10'><path d='M539,1 L1,1 L1,329 L463,329 L493,300 L539,300 Z'/></g><rect width='100%' height='100%' fill='none'/></defs><rect width='100%' height='100%' fill='none'/> <text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle' font-size='3em'> Your balance in Matics :",
                uint2str(score),
                "</text></svg>"
            )
        );

        uri = svgToImageURI(finalSvg);
    }

    function updateURI(uint256 tokenId) public {
        tokenIdToUri[tokenId] = getImageURI(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory imageURI = tokenIdToUri[tokenId];
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "Heir Token NFT", // You can add whatever name here
                                '", "description":"NFT showing your balance", "attributes":"", "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
