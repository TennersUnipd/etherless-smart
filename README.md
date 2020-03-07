# Etherless-Smart

This is the smart contract component of the Etherless project that you can find [here](https://github.com/TennersUnipd/etherless)

## Requirements
To make it work you need to install:
- [Nodejs-lts](https://nodejs.org/it/download/) (12.16.1 as today).
- Truffle  ``` npm install -g truffle ```
- ganache-cli ``` npm install -g ganache-cli ```

## How to run it 

This component cannot work alone you need the other component of the porject Etherless.

After cloning this repository you need to install the dependencies ``` npm install --dotenv-extended```
To run the unit test you need to spin-up a ganache-cli instance after done that you can run in this order:

- ```truffle build``` To compile the smart contract.
- ```truffle deploy --network local``` To deploy the contract on a local network. At the end of this operation, you need to retrieve the contract address needed to make it work in a local environment.
- ```truffle test --network local```  To test the contracts methods in the local Ethereum network.

If the unit test is successful the component is ready to work.