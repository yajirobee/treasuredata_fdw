RUSTLIBDIR = bridge_td_client_rust/target/release
RUSTLIB = $(RUSTLIBDIR)/libbridge_td_client.a

MODULE_big = treasuredata_fdw
OBJS = treasuredata_fdw.o bridge.o query.o $(RUSTLIB)
PGFILEDESC = "treasuredata_fdw - foreign data wrapper for Treasure Data"

ifdef DEBUG
ADDRESS_SANITIZE = -fsanitize=address
else
ADDRESS_SANITIZE = 
endif

EXTRA_CLEAN = $(RUSTLIBDIR)

all: bridge_td_client_rust

bridge_td_client_rust:
	cd bridge_td_client_rust && cargo build --release

test_bridge: $(RUSTLIB) bridge.c test_bridge.c
	cc -DWITHOUT_PG -o $@ $(RUSTLIB) bridge.c test_bridge.c

code-format:
	astyle --style=bsd --indent=tab -n *.c *.h

.PHONY: all bridge_td_client_rust code-format

SHLIB_LINK = $(libpq) $(ADDRESS_SANITIZE)
LDFLAGS = $(ADDRESS_SANITIZE)

EXTENSION = treasuredata_fdw
DATA = treasuredata_fdw--0.9.sql

REGRESS = treasuredata_fdw

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
