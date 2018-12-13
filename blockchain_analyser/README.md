# BitcoinSim 

## Project 4.1

### Description 

Blockchain, Mining Modules for Bitcoin Simulator 

## Group Members 

- Rachit Ranjan 
- Aditya Vashist 

## Prerequisites 

  - Elixir 1.7+ Installation  

## Functioning Features 

- Blockchain creation
  - All blocks are stored in ets cache
    - Key: Block Hash, Value: Block
    - Key: `:tail`, Value: Block Hash of last block  
-  Transactions
-  Wallets
-  Mining

## Execution Instructions

  - Main Function
    - Straight up execution covering the following flows  
      - Initialization of Blockchain with Coinbase transaction in ets cache 
      - Creation of Wallets for two participants with initial Bitcoin
      - Transactions between the two participants
        - Addition and Mining of Blocks 
      - Get Balance after each transaction
        - Mining for a User  
    - Execute the following
      - `mix compile`
      - `mix run`
      - `mix escript.build`
      - `./bitcoin_sim`
  - Execute `mix test` to execute the following tests 
  - Unit Tests
    - Tests Convergence of Calculating Hashes 
      - `calculating hashes`
    - Links in the Block Chain from the Tail stored in ets cache
      -  `Links in Blockchain`
  - Functional Tests (Cover the entire flow described above separately)
    - `Aditya buys 7 coins`
    - `Rachit buys 10 coins`
    - `Rachit sends Aditya 6 coins` 
    - `Aditya sends Rachit 2 coins`
    - `Rachit sends Aditya 3 coins`
