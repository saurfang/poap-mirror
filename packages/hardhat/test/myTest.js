const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const { CCIPReadProvider } = require("@chainlink/ethers-ccip-read-provider");

use(solidity);

describe("My Dapp", function () {
  let myContract;

  describe("YourContract", function () {
    it("Should deploy YourContract", async function () {
      const ERC721Mirror = await ethers.getContractFactory("ERC721Mirror");

      myContract = await ERC721Mirror.deploy("Token", "TOKEN");
      await myContract.setUrls(["https://DarkHalfProfile.saurfang1.repl.co"]);
      myContract = new ethers.Contract(
        myContract.address,
        myContract.interface,
        new CCIPReadProvider(myContract.provider)
      );
    });

    describe("balanceOf()", function () {
      it("Should be able to query owner off chain", async function () {
        const owner = await myContract.ownerOf(533809);
        expect(owner).to.equal("0xe459FCBA06Bb8210de26D20C328d49e687ACC34b");
      });
    });
  });
});
