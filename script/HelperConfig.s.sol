//deploy mocks(mock price feeds) when we are on a local anvil chain
// keep track of contract address across different chains

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
//if we are on a local anvil chain we deploy mocks
// otherwise grab the existing addresses from live networks


MockV3Aggregator mockPriceFeed;
NetworkConfig public activeNetworkConfig;

uint8 public constant DECIMALS = 8;
int256 public constant INITIAL_PRICE = 2000e8;

struct NetworkConfig{
    address priceFeed; //ETH/USD price feed address
}

constructor(){
    //block id ensures we are interacting with the correct network
    if(block.chainid == 11155111 ){
        activeNetworkConfig = getSepoliaEthConfig();

    }
    else {
        activeNetworkConfig = getOrCreateAnvilEthConfig();

}
}

function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
    NetworkConfig memory sepoliaConfig = NetworkConfig({
        priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    });
    return sepoliaConfig;
}

function getOrCreateAnvilEthConfig() public  returns (NetworkConfig memory){
    //to check if we already deployed the mockpricefeed before deploying it once more
if(activeNetworkConfig.priceFeed != address(0)){
    return activeNetworkConfig;
}
//deploy the mocks
//return the mock addresses
vm.startBroadcast();
mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
vm.stopBroadcast();

NetworkConfig memory anvilConfig = NetworkConfig({
    priceFeed: address(mockPriceFeed)
});
return anvilConfig;

}
}
