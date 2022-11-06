pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

interface Gateway {
  function getBalance(address addr) external view returns(uint256 balance);
  function getOwner(uint256 id) external view returns(address addr);
  function getTokenUri(uint256 id) external view returns(string memory uri);
}

error OffchainLookup(address sender, string[] urls, bytes callData, bytes4 callbackFunction, bytes extraData);

contract ERC721Mirror is Context, ERC165, IERC721, IERC721Metadata, Ownable {
    using Address for address;
    using Strings for uint256;

    // Gateway urls
    string[] public urls;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function setUrls(string[] memory urls_) external {
        // FIXME: figure out why owner is not being set // onlyOwner{
        urls = urls_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        revert OffchainLookup(
            address(this),
            urls,
            abi.encodeWithSelector(Gateway.getBalance.selector, owner),
            ERC721Mirror.balanceOfCallback.selector,
            abi.encode()
        );
    }

    function balanceOfCallback(bytes calldata result, bytes calldata extraData) external pure returns(uint256) {
        (uint256 balance) = abi.decode(result, (uint256));
        // TODO: unpack and validate storage proof

        return balance;
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        revert OffchainLookup(
            address(this),
            urls,
            abi.encodeWithSelector(Gateway.getOwner.selector, tokenId),
            ERC721Mirror.ownerOfCallback.selector,
            abi.encode()
        );
    }

    function ownerOfCallback(bytes calldata result, bytes calldata extraData) external pure returns(address) {
        (address owner) = abi.decode(result, (address));
        // TODO: unpack and validate inclusion proof

        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        revert OffchainLookup(
            address(this),
            urls,
            abi.encodeWithSelector(Gateway.getTokenUri.selector, tokenId),
            ERC721Mirror.tokenURICallback.selector,
            abi.encode()
        );
    }

    function tokenURICallback(bytes calldata result, bytes calldata extraData) external pure returns(string memory) {
        (string memory tokenUri) = abi.decode(result, (string));
        // TODO: unpack and validate storage proof

        return tokenUri;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        revert("This contract is read-only");
    }

    /**
     * Always return null because token is read-only
     *
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        return address(0);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        revert("This contract is read-only");
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return false;
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        revert("This contract is read-only");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        revert("This contract is read-only");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        revert("This contract is read-only");
    }
}
