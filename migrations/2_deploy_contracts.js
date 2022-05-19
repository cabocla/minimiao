const MiniMiao = artifacts.require("MiniMiao");
const MiniMiaoTraitGen = artifacts.require("MiniMiaoTraitGen");
const MiniMiaoDescriptor = artifacts.require("MiniMiaoDescriptor");

module.exports = function (deployer) {
    /*
    chain IDs:
    0 = rinkeby/ethereum
    1 = mumbai/polygon
    2 = bsc tesnet/mainnet
    3 = fuji/avax
    4 = fantom
    5 = optimism
    6 = arbitrum
    */
    
    var chainId=3; //TODO CHANGE ACCORDING TO CHAIN
    
    //TODO change to mainnet when production launch
    const lzEndpoints = [
    "0x79a63d6d8BBD5c6dfc774dA79bCcD948EAcb53FA", //rinkeby
    "0xf69186dfBa60DdB133E91E9A4B5673624293d8F8", //mumbai
    "0x6Fcb97553D41516Cb228ac03FdC8B9a0a9df04A1", //bsc testnet
    "0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706", //fuji
    "0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf", //ftm testnet
    "0x72aB53a133b27Fa428ca7Dc263080807AfEc91b5", //opt testnet
    "0x4D747149A57923Beb89f22E6B7B97f7D8c087A00", //arb testnet
    ];

    const nextTokenId = 
    [
        7000,
        4600,
        2800,
        1600,
        900,
        400,
        0,
    ];
    const maxSupply = [
        10000,
        7000,
        4600,
        2800,
        1600,
        900,
        400,
    ];

    if (chainId > lzEndpoints.length) {
        console.log("chain ID out of bounds")
        return;
    }
    deployer.deploy(MiniMiaoDescriptor).then(function () {
        return deployer.deploy(MiniMiaoTraitGen,
            chainId, //TODO change according to chain
        )
        .then(function () {
                          return deployer.deploy(MiniMiao,
                            lzEndpoints[chainId], //TODO change according to chain
            MiniMiaoTraitGen.address,
                              MiniMiaoDescriptor.address,
                              nextTokenId[chainId], //change to next token ID according chain
                          maxSupply[chainId] //change to max mint supply of chain
                          )
    });
    });
    
  
}