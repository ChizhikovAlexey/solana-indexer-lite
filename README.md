# solana-clickhouse
Sink SPL Token and Raydium events into a Clickhouse database.

## Usage
1. [Download `substream-sink-sql` v4.2.0](https://github.com/streamingfast/substreams-sink-sql/releases/tag/v4.2.0).
2. Setup `DSN` and `STREAMINGFAST_KEY` environment variables.
3. Run `make setup_db` to setup the necessary tables.
4. Run `. ./token.sh` to setup the `SUBSTREAMS_API_TOKEN` environment variable.
5. Run the sink with `make sink START=<slot>`.

Please note that setting up `DSN` involves creating a clickhouse database and making it available by some combination of connection and credentials, both of which are described by the `DSN` variable.

Another important point is that if you start the indexing (step 5 of usage) on not so recent blocks, this will be done by batchs of a thousand, so you will have to wait a little while until you start seeing changes being pushed to the database. Once the indexer reaches the head though, new blocks are inserted as soon as they're ready (15-20 seconds of delay for me).
