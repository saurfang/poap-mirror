const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const { CCIPReadProvider } = require("@chainlink/ethers-ccip-read-provider");

use(solidity);

describe("My Dapp", function () {
  let myContract;

  describe("ERC721Mirror", function () {
    it("Should deploy ERC721Mirror", async function () {
      const ERC721Mirror = await ethers.getContractFactory("ERC721Mirror");

      myContract = await ERC721Mirror.deploy("Token", "TOKEN");
      // await myContract.setUrls(["https://DarkHalfProfile.saurfang1.repl.co"]);
      await myContract.setUrls([
        "https://fabuloussnowapplicationstack.ericzhang98.repl.co",
      ]);
      myContract = new ethers.Contract(
        myContract.address,
        myContract.interface,
        new CCIPReadProvider(myContract.provider)
      );
    });

    it("Should be able to query owner off chain", async function () {
      const owner = await myContract.ownerOf(559572);
      expect(owner).to.equal("0x501783E585936116220b5028C4C22DC9fdB991Bc");
    });
    it("Should be able to query balance off chain", async function () {
      const balance = await myContract.balanceOf(
        "0x501783E585936116220b5028C4C22DC9fdB991Bc"
      );
      expect(balance).to.equal(1255);
    });
    it("Should be able to query tokenUri off chain", async function () {
      const url = await myContract.tokenURI(559572);
      expect(url).to.equal("https://api.poap.xyz/metadata/3671/559572");
    });
  });
});
