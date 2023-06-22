-include .env

build:; forge build

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast 


#forge verify-contract --chain-id 11155111 --constructor-args "$(cast abi-encode 'constructor(address)' 0x694AA1769357215DE4FAC081bf1f309aDC325306)" --etherscan-api-key $ETHERSCAN_API_KEY 0x4082B5C5f519B42Ff4ec95024082665f680b78Fd src/FundMe.sol:FundMe
