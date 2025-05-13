// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

contract MerkleProof1 {
    uint256 public constant totalUsers = 8;
    bytes32 public constant airdropRoot = 0xa2941b99a2102eb2d7cff5f18f275b265b0ecdf0083ea4de5f4b1539ffb30b8e;

    bytes32[3][8] public airdropUserProofs = [
        [
            bytes32(0xf9fbf9ce6c3e746bc2f4939f2bdb6e9ed91db04a5e6b3b2fbf8cbc8897ea9c77),
            bytes32(0x4b93250c793147e83c506a9ccf76f9123236087d527be95f388e27fa74b21fd7),
            bytes32(0x798436fe97b856d1b101e6528b7b00d48b156360c31b17773c0644cf64dce363)
        ],
        [
            bytes32(0x565102529d277e73d3f158b212e687ae48b85c8310ed875943093ed11ef05726),
            bytes32(0x0dc8104de8facfa678c059094665b27d66cb48a53b63d16b37bb2326f06a6429),
            bytes32(0x983a3923909f805de32768bb4ea846777de1248beaf6184a35f97fd6c64d3d51)
        ],
        [
            bytes32(0x58e0aba8e7aa31335a900aea7eaf09c780b2b7cbcf88be0ff325dd3be2c7cfac),
            bytes32(0x86c0e913cb296a2132866111a2abf70ddaba74adf008239eb07a418725b9c6b9),
            bytes32(0x983a3923909f805de32768bb4ea846777de1248beaf6184a35f97fd6c64d3d51)
        ],
        [
            bytes32(0x96470072ac3d895fe2493d3474e75db4333fd852978c5aa515e21fb13c1ed3c9),
            bytes32(0x25a08e7b9a880ce557c233dddf1daa8dc2a7a6d208e406aae3d3c01f5f57cb4c),
            bytes32(0x798436fe97b856d1b101e6528b7b00d48b156360c31b17773c0644cf64dce363)
        ],
        [
            bytes32(0xc79a4ccb60406ea3578976296940c2836e74301bfcfcebc25bd5b6a501bfdab2),
            bytes32(0x25a08e7b9a880ce557c233dddf1daa8dc2a7a6d208e406aae3d3c01f5f57cb4c),
            bytes32(0x798436fe97b856d1b101e6528b7b00d48b156360c31b17773c0644cf64dce363)
        ],
        [
            bytes32(0xe6edc19b3279346ae44e1ed5957ef82b4f1323186d26e10caad8b5a7a034e203),
            bytes32(0x4b93250c793147e83c506a9ccf76f9123236087d527be95f388e27fa74b21fd7),
            bytes32(0x798436fe97b856d1b101e6528b7b00d48b156360c31b17773c0644cf64dce363)
        ],
        [
            bytes32(0x1e825faf0a8c7e2096c7ad9ee21bae13f747c2a26da175b8bf57c9058871108b),
            bytes32(0x0dc8104de8facfa678c059094665b27d66cb48a53b63d16b37bb2326f06a6429),
            bytes32(0x983a3923909f805de32768bb4ea846777de1248beaf6184a35f97fd6c64d3d51)
        ],
        [
            bytes32(0x75709648dd29e48e399aa06b07d304608cdf53458e5d42aa5debed54841b3069),
            bytes32(0x86c0e913cb296a2132866111a2abf70ddaba74adf008239eb07a418725b9c6b9),
            bytes32(0x983a3923909f805de32768bb4ea846777de1248beaf6184a35f97fd6c64d3d51)
        ]
    ];

    // ["index", "user address", "airdrop amount"]
    string[3][8] public airdropLeafs = [
        ["2", "0x550Dcf68e072dA0bA2dA43Ef2aF30e9F7fB0192C", "157000000000000000000"],
        ["0", "0x19793F8A568fe0018812E386900386D56Bc9e468", "342000000000000000000"],
        ["5", "0x94B85E73ed62AC877AdaBFE2881491D4e433233F", "289000000000000000000"],
        ["6", "0xf706b10ef2eAEA8e638e9Eb3b31CbE52f68fe143", "134000000000000000000"],
        ["1", "0x20Dd7F50211333f0A0C72250dF57579fFc5555b5", "398000000000000000000"],
        ["4", "0x8C0E2472Dd9F579389A5339caF6072318Ae633DE", "299000000000000000000"],
        ["7", "0xfCb1F8B141cE9c033f448c159E970309E839C7dB", "276000000000000000000"],
        ["3", "0x7B21918B2CfE612fd2cF25820DCFa24B1bE3c1f8", "193000000000000000000"]
    ];
}

contract MerkleProof2 {
    uint256 public constant totalUsers = 20;
    bytes32 public constant airdropRoot = 0x15ab5aaf0766152bafdfc4c73509ed3e6fb2815264014c16697e5f30059a38ed;

    bytes32[][] public airdropUserProofs;

    /// @dev hacky way to store different size merkle proof arrays
    ///      Generated using merkle distributor package.
    ///      Command: npx ts-node lib/merkle-distributor/scripts/generate-merkle-root.ts --input airdrop.json
    constructor() {
        bytes32[] memory proof = new bytes32[](5);
        proof[0] = bytes32(0x04ccec6d8c598b69eea9662b35b58025aaff6b4e8ce4c2dcfeb8e60a19ee61fa);
        proof[1] = bytes32(0x293500eb0eed3d448143db3ea11f1cef3771343c0292a6a6c9cf21d183800c39);
        proof[2] = bytes32(0x9756bd6453d32009558dd450b827164ef5ccdc20bbe3aeae0213101a0e622f2a);
        proof[3] = bytes32(0xe175a75c9b6adafd1e36cb628954bcd4f7300b5c4ba42c2380d7de9043002214);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0xa61d7ae39ceb8fceb002bf5ea577851b2867ff6defbc1a4c8813413d9975cc5d);
        proof[1] = bytes32(0x9746cf2cccf28dc9e0f9116e9e95b2a29a5f81c3b13341a72503be4f1f5a3aa0);
        proof[2] = bytes32(0xc0e7d2c6e112b90efbbb5168cc9ea65be5f14fecbb7aaa9968ab97b65861bfd8);
        proof[3] = bytes32(0xedddae31d764353e12995f9bd560b3f986b4e9937184c31db734b1bdb5d34f79);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0x8ed5c23b4449f255e1da962e7557e1addac150450fff292ca70dd3971ee05283);
        proof[1] = bytes32(0x71d4f97c8f8afe2cbeed2905661c11ddb9b4e4cedf5ab0822ff9f9c5ee35c2c8);
        proof[2] = bytes32(0x4fe05b4d0d6e285276c0db2b5a22dd103a3a69a1e8b4b0518f70fb9115139881);
        proof[3] = bytes32(0xedddae31d764353e12995f9bd560b3f986b4e9937184c31db734b1bdb5d34f79);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](3);
        proof[0] = bytes32(0xb15198c6762e65cd376893a00fde1ad347ba954fb40e536e5fff88822bb1f76a);
        proof[1] = bytes32(0x09a188474b158e057e73037e34e6f7478fb1f664fdaea10aadef4db05b57196f);
        proof[2] = bytes32(0x62f87bb8a301357974e7017667c5f0497fe3f966696d0b13cfecda72035e02a8);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0x0a1ed9f061fdbce40f50af775cf72f87492145518a5d4f2169bceef476afc207);
        proof[1] = bytes32(0x293500eb0eed3d448143db3ea11f1cef3771343c0292a6a6c9cf21d183800c39);
        proof[2] = bytes32(0x9756bd6453d32009558dd450b827164ef5ccdc20bbe3aeae0213101a0e622f2a);
        proof[3] = bytes32(0xe175a75c9b6adafd1e36cb628954bcd4f7300b5c4ba42c2380d7de9043002214);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0x30b98dd29ad8b5fd7e222db0583c51c01ec41ee9b0d0b2316604283277861f56);
        proof[1] = bytes32(0xa1587a0ba45566624c6bc9466ce0c9aec790bca8e2033851fa7c2195348d77cc);
        proof[2] = bytes32(0x9756bd6453d32009558dd450b827164ef5ccdc20bbe3aeae0213101a0e622f2a);
        proof[3] = bytes32(0xe175a75c9b6adafd1e36cb628954bcd4f7300b5c4ba42c2380d7de9043002214);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](3);
        proof[0] = bytes32(0xe25f5c8e4ae77177752a7441c04b0062a3d02a066d2478294947ace22863b85a);
        proof[1] = bytes32(0x3117b73fa675b484d278bf6b7004051e4eb7e74dea3ff7072723ca54311cdd0a);
        proof[2] = bytes32(0x62f87bb8a301357974e7017667c5f0497fe3f966696d0b13cfecda72035e02a8);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0x547413e5215f03d805c8f3ac0fe1de3de5bf9be7b1c106bdf2037e7c5afd1467);
        proof[1] = bytes32(0xbbc2b4984e707564eb3d7e553082a03f520ec144f2bd227c59766e2468b80771);
        proof[2] = bytes32(0x4fe05b4d0d6e285276c0db2b5a22dd103a3a69a1e8b4b0518f70fb9115139881);
        proof[3] = bytes32(0xedddae31d764353e12995f9bd560b3f986b4e9937184c31db734b1bdb5d34f79);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](3);
        proof[0] = bytes32(0xffd2e6ff4e156af71e0b3558f78b7e452ccb5cc278dd5eb9389f4606588ab7f4);
        proof[1] = bytes32(0x3117b73fa675b484d278bf6b7004051e4eb7e74dea3ff7072723ca54311cdd0a);
        proof[2] = bytes32(0x62f87bb8a301357974e7017667c5f0497fe3f966696d0b13cfecda72035e02a8);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0x333318c89933c830b0eaa9e4fce955ecdfd5b1f1fae007a05eef51d3b582f1f5);
        proof[1] = bytes32(0xe607ff95b108c80410deb00878d0c5f365bb8336d7e0e9807b8faf95c207c48e);
        proof[2] = bytes32(0xe6b3c477af00fd2acf84cc586d238717fdd014c47bc111db7ccae30c961b7228);
        proof[3] = bytes32(0xe175a75c9b6adafd1e36cb628954bcd4f7300b5c4ba42c2380d7de9043002214);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0x64bb66dec2befe168e9eb2b40f2cf28b79b7a47cf55d5842ad5d3c672047647e);
        proof[1] = bytes32(0x71d4f97c8f8afe2cbeed2905661c11ddb9b4e4cedf5ab0822ff9f9c5ee35c2c8);
        proof[2] = bytes32(0x4fe05b4d0d6e285276c0db2b5a22dd103a3a69a1e8b4b0518f70fb9115139881);
        proof[3] = bytes32(0xedddae31d764353e12995f9bd560b3f986b4e9937184c31db734b1bdb5d34f79);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0x945cffdc26223ad27210c52834305c72359adb881289523290fabb074cf523bc);
        proof[1] = bytes32(0x9746cf2cccf28dc9e0f9116e9e95b2a29a5f81c3b13341a72503be4f1f5a3aa0);
        proof[2] = bytes32(0xc0e7d2c6e112b90efbbb5168cc9ea65be5f14fecbb7aaa9968ab97b65861bfd8);
        proof[3] = bytes32(0xedddae31d764353e12995f9bd560b3f986b4e9937184c31db734b1bdb5d34f79);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0x546079893850b3bfa06e31036e56dafe24ae164bcd658810bbff78c2fab3b27e);
        proof[1] = bytes32(0xbbc2b4984e707564eb3d7e553082a03f520ec144f2bd227c59766e2468b80771);
        proof[2] = bytes32(0x4fe05b4d0d6e285276c0db2b5a22dd103a3a69a1e8b4b0518f70fb9115139881);
        proof[3] = bytes32(0xedddae31d764353e12995f9bd560b3f986b4e9937184c31db734b1bdb5d34f79);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0xa9adb1773e1b5020b91a323cc61b6c10daf0a6e077da94ce4e28033902ff7309);
        proof[1] = bytes32(0xb823b88633758db66a316a69f85c5e5a0429caedbb05ff6a4f0d3a00f78504f1);
        proof[2] = bytes32(0xc0e7d2c6e112b90efbbb5168cc9ea65be5f14fecbb7aaa9968ab97b65861bfd8);
        proof[3] = bytes32(0xedddae31d764353e12995f9bd560b3f986b4e9937184c31db734b1bdb5d34f79);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0x368b5cab23d6425ffc9cbaf929ae7c1e663830b73d537dd564530bb6b6b22df2);
        proof[1] = bytes32(0xe607ff95b108c80410deb00878d0c5f365bb8336d7e0e9807b8faf95c207c48e);
        proof[2] = bytes32(0xe6b3c477af00fd2acf84cc586d238717fdd014c47bc111db7ccae30c961b7228);
        proof[3] = bytes32(0xe175a75c9b6adafd1e36cb628954bcd4f7300b5c4ba42c2380d7de9043002214);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0x3cb4fa0ca2e3d77e30e53b41ae197fd4b22de2c1f10c45bd4c9be779dfff9278);
        proof[1] = bytes32(0xfdf5cf32fd51d0894793490e5e3f29318fa549dd315157cd914b969a977e004a);
        proof[2] = bytes32(0xe6b3c477af00fd2acf84cc586d238717fdd014c47bc111db7ccae30c961b7228);
        proof[3] = bytes32(0xe175a75c9b6adafd1e36cb628954bcd4f7300b5c4ba42c2380d7de9043002214);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0x4e25f5cc82c663ef27e157e082ef19bc41e7cc5bbc4ccaae1a41d22e861126ac);
        proof[1] = bytes32(0xfdf5cf32fd51d0894793490e5e3f29318fa549dd315157cd914b969a977e004a);
        proof[2] = bytes32(0xe6b3c477af00fd2acf84cc586d238717fdd014c47bc111db7ccae30c961b7228);
        proof[3] = bytes32(0xe175a75c9b6adafd1e36cb628954bcd4f7300b5c4ba42c2380d7de9043002214);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](3);
        proof[0] = bytes32(0xc0e9b6531290066976c5174f9f2716b9c2bc76ecb63b121b762f7f9169627433);
        proof[1] = bytes32(0x09a188474b158e057e73037e34e6f7478fb1f664fdaea10aadef4db05b57196f);
        proof[2] = bytes32(0x62f87bb8a301357974e7017667c5f0497fe3f966696d0b13cfecda72035e02a8);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0xac2c8dc18e111c0bc905397453cb43205b5b949da017b6819cd3678bd8a1e12e);
        proof[1] = bytes32(0xb823b88633758db66a316a69f85c5e5a0429caedbb05ff6a4f0d3a00f78504f1);
        proof[2] = bytes32(0xc0e7d2c6e112b90efbbb5168cc9ea65be5f14fecbb7aaa9968ab97b65861bfd8);
        proof[3] = bytes32(0xedddae31d764353e12995f9bd560b3f986b4e9937184c31db734b1bdb5d34f79);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
        proof = new bytes32[](5);
        proof[0] = bytes32(0x2b6f2e891e40f63a8f787af020f03797e1213b2c38e04df90543135b2fb0440d);
        proof[1] = bytes32(0xa1587a0ba45566624c6bc9466ce0c9aec790bca8e2033851fa7c2195348d77cc);
        proof[2] = bytes32(0x9756bd6453d32009558dd450b827164ef5ccdc20bbe3aeae0213101a0e622f2a);
        proof[3] = bytes32(0xe175a75c9b6adafd1e36cb628954bcd4f7300b5c4ba42c2380d7de9043002214);
        proof[4] = bytes32(0xb31bbdf06aff260865624510c57dda1f8aa62bed6b01dad15e9408f187d0af7e);
        airdropUserProofs.push(proof);
    }

    // ["index", "user address", "airdrop amount"]
    string[3][20] public airdropLeafs = [
        ["0", "0x00c40FE2095423509B9fd9B754323158Af2310f3", "167000000000000000000"],
        ["1", "0x10A1c1CB95c92EC31D3f22C66Eef1d9f3F258c6B", "267000000000000000000"],
        ["2", "0x13cBB8D99C6C4e0f2728C7d72606e78A29C4E224", "287000000000000000000"],
        ["3", "0x1427f29745e5B8eBE70aFB6646E73fD194Da7A7A", "195000000000000000000"],
        ["4", "0x1817465453315A39D62dE436e8Ae8134e4d9C2Cd", "301000000000000000000"],
        ["5", "0x24143873e0E0815fdCBcfFDbe09C979CbF9Ad013", "345000000000000000000"],
        ["6", "0x3DCbA25AA14104C477D9583A0E436e3D94C39Dd2", "289000000000000000000"],
        ["7", "0x4793f29b9CfFF4906d6c44bAa1F3802e572d4b11", "321000000000000000000"],
        ["8", "0x598443F1880Ef585B21f1d7585Bd0577402861E5", "156000000000000000000"],
        ["9", "0x77dB2BEBBA79Db42a978F896968f4afCE746ea1F", "198000000000000000000"],
        ["10", "0x7AA22a1A0672A54A819659dFfC1c4Ca5383114dc", "254000000000000000000"],
        ["11", "0x7d577a597B2742b498Cb5Cf0C26cDCD726d39E6e", "178000000000000000000"],
        ["12", "0x82A978B3f5962A5b0957d9ee9eEf472EE55B42F1", "245000000000000000000"],
        ["13", "0x8643D6c2E40F1A3A8d77a4021397E9f0DfBA3eAf", "213000000000000000000"],
        ["14", "0x90F0B1EBbbA1C1936aFF7AAf20a7878FF9e04B6c", "223000000000000000000"],
        ["15", "0xC4D178249D840F548B09AD8269E8A3165ce2c170", "176000000000000000000"],
        ["16", "0xDAB02Ef1A1995F329Cffe05b3AC863f9a3835046", "234000000000000000000"],
        ["17", "0xDCEceAF3fc5C0a63d195d69b1A90011B7B19650D", "312000000000000000000"],
        ["18", "0xdFb3960613aDF1A89Da2172994ECDB6434079dC0", "278000000000000000000"],
        ["19", "0xe0FC04FA2d34a66B779fd5CEe748268032a146c0", "189000000000000000000"]
    ];

    function getUserProofs(uint256 index) public view returns (bytes32[] memory) {
        return airdropUserProofs[index];
    }
}
