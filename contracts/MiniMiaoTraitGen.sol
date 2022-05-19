// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AnonymiceLibrary.sol";
import "./IMiniMiaoTraitGen.sol";
import "./IMiniMiaoDescriptor.sol";

contract MiniMiaoTraitGen is IMiniMiaoTraitGen {
    using AnonymiceLibrary for uint8;

    uint16[][5] internal TIERS;
    uint256 internal SEED_NONCE = 0;
    mapping(string => bool) internal hashToMinted;
    uint8 chainIndex;

    constructor(uint8 index) {
        chainIndex = index;
        //Face
        TIERS[0] = [50, 100, 100, 721, 847, 1155, 1230, 1355, 1442, 3000];

        //Misc
        TIERS[1] = [100, 100, 200, 500, 721, 1155, 7224];

        //Eyes
        TIERS[2] = [50, 150, 420, 500, 721, 600, 1559, 2000, 2000, 2000];

        //Toes
        TIERS[3] = [230, 400, 500, 721, 721, 1155, 1155, 1559, 1559, 2000];

        //Fur
        TIERS[4] = [50, 150, 150, 721, 1115, 1155, 1559, 1700, 1700, 1700];
    }

    /*
     * @dev Converts a digit from 0 - 10000 into its corresponding rarity based on the given rarity tier.
     * @param _randinput The input from 0 - 10000 to use for rarity gen.
     * @param _rarityTier The tier to use.
     */
    function rarityGen(uint256 _randinput, uint8 _traitTier)
        internal
        view
        returns (string memory)
    {
        uint16 currentLowerBound = 0;
        for (uint8 i = 0; i < TIERS[_traitTier].length; i++) {
            uint16 thisPercentage = TIERS[_traitTier][i];
            if (
                _randinput >= currentLowerBound &&
                _randinput < currentLowerBound + thisPercentage
            ) return i.toString();
            currentLowerBound = currentLowerBound + thisPercentage;
        }

        revert();
    }

    function genHash(
        uint256 _t,
        address _a,
        uint256 _c
    ) external override returns (string memory) {
        return hash(_t, _a, _c);
    }

    /**
     * @dev Generates a 7 digit hash from a tokenId, address, and random number.
     * @param _t The token id to be used within the hash.
     * @param _a The address to be used within the hash.
     * @param _c The custom nonce to be used within the hash.
     */
    function hash(
        uint256 _t,
        address _a,
        uint256 _c
    ) internal returns (string memory) {
        require(_c < 10);

        // This will generate a 6 character string.
        string memory currentHash;

        for (uint8 i = 0; i < 5; i++) {
            SEED_NONCE++;
            uint16 _randinput = uint16(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            block.timestamp,
                            block.difficulty,
                            _t,
                            _a,
                            _c,
                            SEED_NONCE
                        )
                    )
                ) % 10000
            );

            currentHash = string(
                abi.encodePacked(currentHash, rarityGen(_randinput, i))
            );
        }

        //bg hash
        currentHash = string(
            abi.encodePacked(currentHash, chainIndex.toString())
        );
        if (hashToMinted[currentHash]) return hash(_t, _a, _c + 1);

        hashToMinted[currentHash] = true;
        return currentHash;
    }
}
