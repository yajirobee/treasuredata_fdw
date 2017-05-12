# treasuredata_fdw
[<img src="https://travis-ci.org/komamitsu/treasuredata_fdw.svg?branch=master"/>](https://travis-ci.org/komamitsu/treasuredata_fdw)

PostgreSQL Foreign Data Wrapper for Treasure Data

## Installation
This FDW uses [td-client-rust](https://github.com/komamitsu/td-client-rust). So you need to install [Rust](https://www.rust-lang.org/) first.

With [PGXN client](http://pgxnclient.projects.pgfoundry.org/):

```
$ pgxn install treasuredata_fdw
```

From source:

```
$ git clone https://github.com/komamitsu/treasuredata_fdw.git
$ cd treasuredata_fdw
$ make && sudo make install
```

When building this FDW on macOS, you may fail to build due to missing OpenSSL header files (https://github.com/sfackler/rust-openssl/issues/255). The following commands would solve the error.
```
export OPENSSL_INCLUDE_DIR=/usr/local/opt/openssl/include
export DEP_OPENSSL_INCLUDE=/usr/local/opt/openssl/include
```

## Setup
Connect to your PostgreSQL and create an extension and foreign server

```
CREATE EXTENSION treasuredata_fdw;

CREATE SERVER treasuredata_server FOREIGN DATA WRAPPER treasuredata_fdw;
```

## Update version

To update an existing treasuredata_fdw installation from versions earlier than 1.1 you can take the following steps:

- Download and install treasuredata_fdw version 1.1 using instructions from the "Instllation" section
- Restart the PostgreSQL server
- Run

```
ALTER EXTENSION treasuredata_fdw UPDATE;
```

## Usage
Specify your API key, database, query engine type ('presto' or 'hive') in CREATE FOREIGN TABLE statement. You can specify either your table name or query for Treasure Data directly.

```
CREATE FOREIGN TABLE sample_datasets (
    time integer,
    "user" varchar,
    host varchar,
    path varchar,
    referer varchar,
    code integer,
    agent varchar,
    size integer,
    method varchar
)
SERVER treasuredata_server OPTIONS (
    apikey 'your_api_key',
    database 'sample_datasets',
    query_engine 'presto',
    table 'www_access'
);

SELECT code, count(1)
FROM sample_datasets
WHERE time BETWEEN 1412121600 AND 1414800000
GROUP BY code;

 code | count
------+-------
  404 |    17
  200 |  4981
  500 |     2
(3 rows)

```

Also, you can specify other API endpoint.

```
SERVER treasuredata_fdw OPTIONS (
    endpoint 'https://ybi.jp-east.idcfcloud.com'
    apikey 'your_api_key',
        :
```

## Prepare Linux development environment

```
$ docker/build.sh
$ docker/run.sh
```
And then, follow the instructions from `run.sh`.

## Regression test

```
$ TD_TEST_APIKEY=<your_api_key> ./setup_regress <hive|presto>
$ make installcheck
```
