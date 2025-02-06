-- FUNCTIONS

-- BLOCKS

CREATE TABLE blocks
(
    slot UInt64,
    parent_slot UInt64,
    block_height UInt64,
    blockhash String,
    previous_blockhash String,
    block_time DateTime,
    insertion_time DateTime MATERIALIZED now(),
)
ENGINE = MergeTree
PRIMARY KEY slot
ORDER BY slot;

-- TRANSACTIONS

CREATE TABLE transactions
(
    slot UInt64,
    transaction_index UInt64,
    signature String,
    number_of_signers UInt8,
    signer0 String,
    signer1 String DEFAULT '',
    signer2 String DEFAULT '',
    signer3 String DEFAULT '',
    signer4 String DEFAULT '',
    signer5 String DEFAULT '',
    signer6 String DEFAULT '',
    signer7 String DEFAULT '',
    -- signers Array(String),
    PROJECTION projection_signature (SELECT * ORDER BY signature) -- RECOMMENDED
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 1e6)
PRIMARY KEY (slot, transaction_index)
ORDER BY (slot, transaction_index);

-- RAYDIUM AMM EVENTS

CREATE TABLE raydium_amm_swap_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    amm LowCardinality(String) CODEC(LZ4),
    user LowCardinality(String) CODEC(LZ4),
    amount_in UInt64,
    amount_out UInt64,
    mint_in LowCardinality(String) CODEC(LZ4),
    mint_out LowCardinality(String) CODEC(LZ4),
    direction LowCardinality(String) CODEC(LZ4),
    pool_pc_amount UInt64,
    pool_coin_amount UInt64,
    user_pre_balance_in UInt64,
    user_pre_balance_out UInt64,
    PROJECTION projection_amm (SELECT * ORDER BY amm, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_user (SELECT * ORDER BY user, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_mint_in (SELECT * ORDER BY mint_in, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_mint_out (SELECT * ORDER BY mint_out, slot, transaction_index, instruction_index), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 1e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

CREATE TABLE spl_token_mint_to_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    destination_address LowCardinality(String) CODEC(LZ4),
    destination_owner LowCardinality(String) CODEC(LZ4),
    destination_pre_balance UInt64,
    mint LowCardinality(String) CODEC(LZ4),
    mint_authority LowCardinality(String) CODEC(LZ4),
    amount UInt64,
    PROJECTION projection_mint (SELECT * ORDER BY mint, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_destination (SELECT * ORDER BY destination_owner, slot, transaction_index, instruction_index), -- RECOMMENDED
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PARTITION BY toInt64(slot / 32e6)
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);

-- -- PUMPFUN EVENTS

CREATE TABLE pumpfun_create_events
(
    slot UInt64,
    transaction_index UInt64,
    instruction_index UInt64,
    partial_signature String,
    partial_blockhash String,
    user LowCardinality(String) CODEC(LZ4),
    name String CODEC(LZ4),
    symbol String CODEC(LZ4),
    uri String CODEC(LZ4),
    mint LowCardinality(String) CODEC(LZ4),
    bonding_curve LowCardinality(String) CODEC(LZ4),
    associated_bonding_curve LowCardinality(String) CODEC(LZ4),
    metadata LowCardinality(String) CODEC(LZ4),
    PROJECTION projection_user (SELECT * ORDER BY user, slot, transaction_index, instruction_index), -- RECOMMENDED
    PROJECTION projection_mint (SELECT * ORDER BY mint, slot, transaction_index, instruction_index), -- RECOMMENDED
    -- PROJECTION projection_bonding_curve (SELECT * ORDER BY bonding_curve),
    parent_instruction_index Int64 DEFAULT -1,
    top_instruction_index Int64 DEFAULT -1,
    parent_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
    top_instruction_program_id LowCardinality(String) DEFAULT '' CODEC(LZ4),
)
ENGINE = MergeTree
PRIMARY KEY (slot, transaction_index, instruction_index)
ORDER BY (slot, transaction_index, instruction_index);