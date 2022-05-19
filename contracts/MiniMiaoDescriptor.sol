// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AnonymiceLibrary.sol";
import "./IMiniMiaoDescriptor.sol";

contract MiniMiaoDescriptor is IMiniMiaoDescriptor {
    function tokenURI(uint256 _tokenId, string memory tokenHash)
        external
        view
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    AnonymiceLibrary.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    '{"name": "Mini Miao #',
                                    AnonymiceLibrary.toString(_tokenId),
                                    '", "description": "Mini Miao is a collection of 10,000 unique smol cats. Omnichain NFT so you can pspsps your cat accross chains. All the metadata and images are generated and stored 100% on-chain. No IPFS, no API.","image": "data:image/svg+xml;base64, ',
                                    AnonymiceLibrary.encode(
                                        bytes(hashToSVG(tokenHash))
                                    ),
                                    '","attributes":',
                                    hashToMetadata(tokenHash),
                                    "}"
                                )
                            )
                        )
                    )
                )
            );
    }

    /**
     * @dev Hash to SVG function
     */
    function hashToSVG(string memory _hash)
        internal
        view
        returns (string memory)
    {
        string[6] memory parts;
        //face
        parts[0] = faceSVGs[
            AnonymiceLibrary.parseInt(AnonymiceLibrary.substring(_hash, 0, 1))
        ];
        // misc
        parts[1] = getMiscgSVG(
            AnonymiceLibrary.parseInt(AnonymiceLibrary.substring(_hash, 1, 2))
        );
        //eyes
        parts[2] = getEyesSVG(
            AnonymiceLibrary.parseInt(AnonymiceLibrary.substring(_hash, 2, 3))
        );
        //toes
        parts[3] = string(
            abi.encodePacked(
                '<path style="fill:',
                toeColors[
                    AnonymiceLibrary.parseInt(
                        AnonymiceLibrary.substring(_hash, 3, 4)
                    )
                ],
                '" d="M8 16h1v1H8zm2 0h1v1h-1zm4 0h1v1h-1zm2 0h1v1h-1z"/>'
            )
        );
        //body
        parts[4] = getBodySVG(
            AnonymiceLibrary.parseInt(AnonymiceLibrary.substring(_hash, 4, 5))
        );
        //bg
        parts[5] = string(
            abi.encodePacked(
                '<path style="fill:',
                bgColors[
                    AnonymiceLibrary.parseInt(
                        AnonymiceLibrary.substring(_hash, 5, 6)
                    )
                ],
                '" d="M0 17h24v7H0ZM0 0h24v17H0Z"/>'
            )
        );

        return
            string(
                abi.encodePacked(
                    '<svg  xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 24 24" style="shape-rendering:crispedges"> ',
                    parts[5],
                    parts[4],
                    parts[3],
                    parts[2],
                    parts[1],
                    parts[0],
                    "<style>rect{width:1px;height:1px;}</style></svg>"
                )
            );
    }

    /**
     * @dev Hash to metadata function
     */
    function hashToMetadata(string memory _hash)
        internal
        view
        returns (string memory)
    {
        string memory metadataString;

        for (uint8 i = 0; i < 6; i++) {
            uint8 thisTraitIndex = AnonymiceLibrary.parseInt(
                AnonymiceLibrary.substring(_hash, i, i + 1)
            );
            string memory traitType;
            string memory traitName;

            //Face
            if (i == 0) {
                traitType = "Face";
                traitName = faceNames[thisTraitIndex];
            }
            //Misc
            if (i == 1) {
                traitType = "Misc";
                traitName = miscNames[thisTraitIndex];
            }
            //Eyes
            if (i == 2) {
                traitType = "Eyes";
                traitName = eyeNames[thisTraitIndex];
            }
            //Toes
            if (i == 3) {
                traitType = "Toes";
                traitName = toeNames[thisTraitIndex];
            }
            //Fur
            if (i == 4) {
                traitType = "Fur";
                traitName = furNames[thisTraitIndex];
            }
            if (i == 5) {
                traitType = "Birth chain";
                traitName = bgNames[thisTraitIndex];
            }
            metadataString = string(
                abi.encodePacked(
                    metadataString,
                    '{"trait_type":"',
                    traitType,
                    '","value":"',
                    traitName,
                    '"}'
                )
            );

            if (i != 5)
                metadataString = string(abi.encodePacked(metadataString, ","));
        }
        return string(abi.encodePacked("[", metadataString, "]"));
    }

    function getBodySVG(uint8 traitIndex)
        internal
        view
        returns (string memory)
    {
        string memory outlineColor;
        string memory furColor;
        string memory earColor;

        if (traitIndex == 0) {
            earColor = "#3cff00";
        } else {
            earColor = "#f66cb0";
        }
        outlineColor = outlineColors[traitIndex];
        furColor = furColors[traitIndex];
        return
            string(
                abi.encodePacked(
                    string(
                        abi.encodePacked(
                            '<path style="fill:',
                            outlineColor,
                            '" d="M5 8h1v1H5Zm0 1h1v1H5Zm0 1h1v1H5Zm0 1h1v1H5Zm0 1h1v1H5Zm1 1h1v1H6Zm1 3h1v1H7Zm0-1h1v1H7Zm0-1h1v1H7Zm1 0h1v1H8Zm1 0h1v1H9Zm1 0h1v1h-1zm1 0h1v1h-1zm1 0h1v1h-1zm-5 3h1v1H7Zm1 0h1v1H8Zm1-1h1v1H9Zm0 1h1v1H9Zm1 0h1v1h-1zm1 0h1v1h-1zm0-1h1v1h-1zm1 0h1v1h-1zm1 0h1v1h-1zm0 1h1v1h-1zm2-1h1v1h-1zm-1 1h1v1h-1zm1 0h1v1h-1zm1 0h1v1h-1zm1 0h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1zm1-1h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1Zm-1-1h1v1h-1zm-1 0h1v1h-1zm-1 0h1v1h-1zm0 1h1v1h-1zm1 1h1v1h-1zm0 1h1v1h-1zm-1 1h1v1h-1zm-1 0h1v1h-1zm-1 0h1v1h-1zm1-1h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1Zm-1-1h1v1h-1zm-1 1h1v1h-1zm-1 1h1v1h-1zm-1 0h1v1h-1ZM9 8h1v1H9ZM8 8h1v1H8ZM7 7h1v1H7ZM6 6h1v1H6ZM5 7h1v1H5Z"/>'
                        )
                    ),
                    string(
                        abi.encodePacked(
                            '<path style="fill:',
                            furColor,
                            '" d="M8 15h1v1H8Zm1 0h1v1H9Zm1 0h1v1h-1zm1 0h1v1h-1zm1 0h1v1h-1zm1 0h1v1h-1zm0-1h1v1h-1zm1 0h1v1h-1zm0 1h1v1h-1zm1 0h1v1h-1zm0-1h1v1h-1zm1 1h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1zm1 0h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1zm-1 0h1v1h-1zm-8 1h1v1H8Zm2 0h1v1h-1zm-1 0h1v1H9Zm3 0h1v1h-1zm0-1h1v1h-1zm-1 0h1v1h-1zm-1 0h1v1h-1zm-1 0h1v1H9Zm-1 0h1v1H8Zm3 2h1v1h-1zm-1 0h1v1h-1zm-2 0h1v1H8Zm-1 0h1v1H7Zm0-2h1v1H7Zm-1 0h1v1H6Zm0 1h1v1H6Zm0 1h1v1H6Zm1 1h1v1H7Zm1 0h1v1H8Zm1 0h1v1H9Zm1 0h1v1h-1zm1 0h1v1h-1zm1-1h1v1h-1zm0 1h1v1h-1zm1-1h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1zm0-1h1v1h-1zm0-2h1v1h-1zm-1 1h1v1h-1zm0 1h1v1h-1zm-1 0h1v1h-1zm-1 0h1v1h-1ZM9 9h1v1H9ZM8 9h1v1H8ZM7 9h1v1H7ZM6 9h1v1H6Zm1-1h1v1H7ZM6 7h1v1H6Z"/>'
                        )
                    ),
                    '<path style="fill:',
                    earColor,
                    '" d="M6 8h1v1H6Zm7 0h1v1h-1zm-4 4h1v1H9Z"/>'
                )
            );
    }

    function getEyesSVG(uint8 traitIndex)
        internal
        view
        returns (string memory)
    {
        return
            traitIndex == 0
                ? '<rect style="fill:##ffff00" x="7" y="11"/><rect style="fill:##00ffff" x="11" y="11"/>'
                : string(
                    abi.encodePacked(
                        '<path style="fill:',
                        eyeColors[traitIndex],
                        '"  d="M11 11h1v1h-1zm-4 0h1v1H7Z"/>'
                    )
                );
    }

    function getMiscgSVG(uint8 traitIndex)
        internal
        view
        returns (string memory)
    {
        string memory svgString;
        if (traitIndex == 0) {
            svgString = string(abi.encodePacked(miscSVGs[0], miscSVGs[1]));
        } else if (traitIndex == 1) {
            svgString = string(abi.encodePacked(miscSVGs[0], miscSVGs[2]));
        } else {
            svgString = miscSVGs[traitIndex - 2];
        }
        return svgString;
    }

    //string arrays
    string[] LETTERS = [
        "a",
        "b",
        "c",
        "d",
        "e",
        "f",
        "g",
        "h",
        "i",
        "j",
        "k",
        "l",
        "m",
        "n",
        "o",
        "p",
        "q",
        "r",
        "s",
        "t",
        "u",
        "v",
        "w",
        "x",
        "y",
        "z"
    ];

    string[7] bgNames = ["ETH", "POLY", "BNB", "AVAX", "ARB", "FTM", "OPT"];
    string[10] furNames = [
        "Ghost",
        "Gold",
        "Green",
        "Blue",
        "Spinx",
        "Orange",
        "Brown",
        "Black",
        "White",
        "Grey"
    ];
    string[10] eyeNames = [
        "Heterochromia",
        "Cyan",
        "Purple",
        "Red",
        "Teal",
        "Blue",
        "Orange",
        "Green",
        "Yellow",
        "Black"
    ];
    string[10] toeNames = [
        "Cyan",
        "Lime",
        "Purple",
        "Blue",
        "Violet",
        "Green",
        "Red",
        "Brown",
        "Yellow",
        "Grey"
    ];
    string[10] faceNames = [
        "Noun",
        "Halo",
        "Crown",
        "Laser",
        "3D",
        "Flower",
        "Headphone",
        "Ribbon",
        "Hat",
        "None"
    ];

    string[7] miscNames = [
        "Hoverboard + Rainbow",
        "Skateboard + Rainbow",
        "Rainbow",
        "Hoverboard",
        "Skateboard",
        "Cigarette",
        "None"
    ];

    string[7] bgColors = [
        "#767676", //ETH
        "#f54dff", //POLY
        "#ffec00", //BNB
        "#ff5d70", //AVAX
        "#0072d2", //ARB
        "#6cc3f6", //FTM
        "#ff9c6d" //OPT
    ];

    string[10] outlineColors = [
        "#d8d6d5",
        "#e7d600",
        "#2dbf00",
        "#00a1ff",
        "#f66cb0",
        "#ff9300",
        "#7c5020",
        "#000000",
        "#d8d6d5",
        "#a1a1a1"
    ];

    string[10] furColors = [
        "#ffffff",
        "#ffff00",
        "#3cff00",
        "#6cc3f6",
        "#ffa5c3",
        "#ffac3a",
        "#bb7d34",
        "#434343",
        "#ffffff",
        "#d5d5d5"
    ];

    string[10] eyeColors = [
        "#ff00ff",
        "#00ffff",
        "#ff00ff",
        "#00ffbf",
        "#0000ff",
        "#ff0000",
        "#ff8000",
        "#00ff00",
        "#ffff00",
        "#000000"
    ];

    string[10] toeColors = [
        "#00cccc",
        "#99cc00",
        "#cc00cc",
        "#0000cc",
        "#6600cc",
        "#00cc00",
        "#cc0000",
        "#cc6600",
        "#cc9900",
        "#767676"
    ];
    string[10] faceSVGs = [
        '<path style="fill:red" d="M13 11h2v1h-2zm-2 1h1v1h-1zm1-1h1v2h-1zm-2 0h1v2h-1zm0-1h3v1h-3zm-1 1h1v1H9Zm-2 1h1v1H7Zm1-1h1v2H8Zm-2 0h1v2H6Zm0-1h3v1H6Zm-1 1h1v1H5Z"/>',
        '<path style="fill:#ff0" d="M12 5h1v1h-1ZM7 5h1v1H7Zm1 1h4v1H8Zm0-2h4v1H8Z"/>',
        '<path style="fill:#ff0" d="M10 5h1v1h-1ZM8 5h1v1H8Zm0 1h5v1H8Zm0 1h4v1H8Zm4-2h1v1h-1z"/>',
        '<path style="fill:red" d="M0 11h11v1H0Zm11 0h1v1h-1z"/>',
        '<path style="fill:#ededed;fill-opacity:1" d="M10 12h3v1h-3zm2-1h3v1h-3Zm-3-1h6v1H9Zm-1 1h3v1H8Zm-1-1h2v1H7Zm0 2h2v1H7Zm-1-1h1v2H6Zm-1-1h1v2H5Zm1 0h1v1H6Z"/><path style="fill:red" d="M7 11h1v1H7z"/><path style="fill:#00f" d="M11 11h1v1h-1z"/>',
        '<path style="fill:#c800ff" d="M11 9h1v1h-1zm1-1h1v1h-1Zm-1-1h1v1h-1zm-1 1h1v1h-1z"/> <path style="fill:#ff0" d="M11 8h1v1h-1z"/>',
        '<path style="fill:#000" d="M7 6h6v1H7ZM5 7h2v3H5Zm8 0h2v3h-2z"/>',
        '<path style="fill:red" d="M11 7h1v1h-1zm1 1h1v1h-1z"/>',
        '<path style="fill:#00f;stroke-width:1.00157" d="M9 6h2v1H9ZM8 7h4v1H8ZM7 8h5v1H7ZM6 8h1v1H6Z"/>',
        ""
    ];

    string[5] miscSVGs = [
        '<path style="fill:#0f0" d="M22 16h2v1h-2zm-2-1h2v1h-2zm-2 1h2v1h-2z"/> <path style="fill:#ff0" d="M22 15h2v1h-2zm-2-1h2v1h-2zm-2 1h2v1h-2z"/><path style="fill:red" d="M22 14h2v1h-2zm-2-1h2v1h-2zm-2 1h2v1h-2z"/>',
        '<path style="fill:#f0f" d="M19 17h1v1h-1ZM6 18h13v1H6Zm-1-1h1v1H5Z"/>',
        '<path style="fill:#803300" d="M19 17h1v1h-1ZM6 18h13v1H6Zm-1-1h1v1H5Z"/><path style="fill:#ccc" d="M15 19h2v2h-2zm-7 0h2v2H8Z"/>',
        '<path style="fill:#000" d="M3 13h6v1H3z"/><path style="fill:#b3b3b3" d="M3 8h1v4H3z"/>',
        ""
    ];
}
