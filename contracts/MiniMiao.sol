// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./NonblockingReceiver.sol";
import "./AnonymiceLibrary.sol";
import "./IMiniMiaoTraitGen.sol";
import "./IMiniMiaoDescriptor.sol";

/*    
              _       _              _           
   ____ ___  (_)___  (_)  ____ ___  (_)___ _____ 
  / __ `__ \/ / __ \/ /  / __ `__ \/ / __ `/ __ \
 / / / / / / / / / / /  / / / / / / / /_/ / /_/ /
/_/ /_/ /_/_/_/ /_/_/  /_/ /_/ /_/_/\__,_/\____/ 
                                                 
   */

contract MiniMiao is ERC721Enumerable, NonblockingReceiver {
    using AnonymiceLibrary for uint8;
    IMiniMiaoTraitGen public traitGen;
    IMiniMiaoDescriptor public descriptor;

    mapping(uint256 => string) internal tokenIdToHash;

    uint256 public nextTokenId;
    uint256 public MAX_MINT_SUPPLY;
    uint256 gasForDestinationLzReceive = 350000;

    address _owner;

    bool public mintActive = false;

    constructor(
        address _layerZeroEndpoint,
        address _traitGenAddress,
        address descriptorAddress,
        uint256 _nexttokenId,
        uint256 _maxSupply
    ) ERC721("MiniMiao", "MIAO") {
        nextTokenId = _nexttokenId;
        MAX_MINT_SUPPLY = _maxSupply;
        traitGen = IMiniMiaoTraitGen(_traitGenAddress);
        descriptor = IMiniMiaoDescriptor(descriptorAddress);
        endpoint = ILayerZeroEndpoint(_layerZeroEndpoint);
        _owner = msg.sender;
    }

    /*
              _       __     ____                 __  _           
   ____ ___  (_)___  / /_   / __/_  ______  _____/ /_(_)___  ____ 
  / __ `__ \/ / __ \/ __/  / /_/ / / / __ \/ ___/ __/ / __ \/ __ \
 / / / / / / / / / / /_   / __/ /_/ / / / / /__/ /_/ / /_/ / / / /
/_/ /_/ /_/_/_/ /_/\__/  /_/  \__,_/_/ /_/\___/\__/_/\____/_/ /_/ 
                                                                  
   */

    /**
     * @dev Mints new tokens.
     */
    function mintMiao() public {
        require(mintActive, "Mint is not active");
        require(nextTokenId + 1 <= MAX_MINT_SUPPLY, "Mint exceeds supply");
        require(!AnonymiceLibrary.isContract(msg.sender));

        uint256 thisTokenId = ++nextTokenId;

        tokenIdToHash[thisTokenId] = traitGen.genHash(
            thisTokenId,
            msg.sender,
            0
        );

        _safeMint(msg.sender, thisTokenId);
    }

    /*
                        __   ____                 __  _           
   ________  ____ _____/ /  / __/_  ______  _____/ /_(_)___  ____ 
  / ___/ _ \/ __ `/ __  /  / /_/ / / / __ \/ ___/ __/ / __ \/ __ \
 / /  /  __/ /_/ / /_/ /  / __/ /_/ / / / / /__/ /_/ / /_/ / / / /
/_/   \___/\__,_/\__,_/  /_/  \__,_/_/ /_/\___/\__/_/\____/_/ /_/ 
                                                                                                                                                    
*/

    /**
     * @dev Returns the SVG and metadata for a token Id
     * @param _tokenId The tokenId to return the SVG and metadata for.
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId));
        return descriptor.tokenURI(_tokenId, _tokenIdToHash(_tokenId));
    }

    /**
     * @dev Returns a hash for a given tokenId
     * @param _tokenId The tokenId to return the hash for.
     */
    function _tokenIdToHash(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        return tokenIdToHash[_tokenId];
    }

    function donate() external payable {
        // thank you
    }

    /*
     * @dev Returns the wallet of a given wallet. Mainly for ease for frontend devs.
     * @param _wallet The wallet to get the tokens of.
     */
    function walletOfOwner(address _wallet)
        public
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_wallet);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_wallet, i);
        }
        return tokensId;
    }

    /*

                                    ____                 __  _           
  ____ _      ______  ___  _____   / __/_  ______  _____/ /_(_)___  ____ 
 / __ \ | /| / / __ \/ _ \/ ___/  / /_/ / / / __ \/ ___/ __/ / __ \/ __ \
/ /_/ / |/ |/ / / / /  __/ /     / __/ /_/ / / / / /__/ /_/ / /_/ / / / /
\____/|__/|__/_/ /_/\___/_/     /_/  \__,_/_/ /_/\___/\__/_/\____/_/ /_/ 
                                                                         

    */
    function toggleMint() public onlyOwner {
        mintActive = !mintActive;
    }

    // This allows the devs to receive kind donations
    function withdraw(uint256 amt) external onlyOwner {
        (bool sent, ) = payable(_owner).call{value: amt}("");
        require(sent, "Withdraw failed");
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        _owner = newOwner;
        super.transferOwnership(newOwner);
    }

    function updateDescriptor(address newDescriptor) public onlyOwner {
        descriptor = IMiniMiaoDescriptor(newDescriptor);
    }

    /*
   __                                          ____                 __  _           
  / /__________ __   _____  _____________     / __/_  ______  _____/ /_(_)___  ____ 
 / __/ ___/ __ `/ | / / _ \/ ___/ ___/ _ \   / /_/ / / / __ \/ ___/ __/ / __ \/ __ \
/ /_/ /  / /_/ /| |/ /  __/ /  (__  )  __/  / __/ /_/ / / / / /__/ /_/ / /_/ / / / /
\__/_/   \__,_/ |___/\___/_/  /____/\___/  /_/  \__,_/_/ /_/\___/\__/_/\____/_/ /_/ 
                                                                                    
*/
    // This function transfers the nft from your address on the
    // source chain to the same address on the destination chain
    function traverseChains(uint16 _chainId, uint256 tokenId) public payable {
        require(
            msg.sender == ownerOf(tokenId),
            "You must own the token to traverse"
        );
        require(
            trustedRemoteLookup[_chainId].length > 0,
            "This chain is currently unavailable for travel"
        );

        // burn NFT, eliminating it from circulation on src chain
        _burn(tokenId);

        // abi.encode() the payload with the values to send
        bytes memory payload = abi.encode(
            msg.sender,
            tokenId,
            tokenIdToHash[tokenId]
        );

        // encode adapterParams to specify more gas for the destination
        uint16 version = 1;
        bytes memory adapterParams = abi.encodePacked(
            version,
            gasForDestinationLzReceive
        );

        // get the fees we need to pay to LayerZero + Relayer to cover message delivery
        // you will be refunded for extra gas paid
        (uint256 messageFee, ) = endpoint.estimateFees(
            _chainId,
            address(this),
            payload,
            false,
            adapterParams
        );

        require(
            msg.value >= messageFee,
            "msg.value not enough to cover messageFee. Send gas for message fees"
        );

        endpoint.send{value: msg.value}(
            _chainId, // destination chainId
            trustedRemoteLookup[_chainId], // destination address of nft contract
            payload, // abi.encoded()'ed bytes
            payable(msg.sender), // refund address
            address(0x0), // 'zroPaymentAddress' unused for this
            adapterParams // txParameters
        );
    }

    // just in case this fixed variable limits us from future integrations
    function setGasForDestinationLzReceive(uint256 newVal) external onlyOwner {
        gasForDestinationLzReceive = newVal;
    }

    // ------------------
    // Internal Functions
    // ------------------

    function _LzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal override {
        // decode
        (address toAddr, uint256 tokenId, string memory traitHash) = abi.decode(
            _payload,
            (address, uint256, string)
        );

        // mint the tokens back into existence on destination chain
        tokenIdToHash[tokenId] = traitHash;
        _safeMint(toAddr, tokenId);
    }
}
