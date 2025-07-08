# BUILD_ROOT=_build/tdlib
# BUILD_DIRECTORY=$(BUILD_ROOT)/rel
# BUILD_ARTIFACT=$(BUILD_DIRECTORY)/bin/tdlib_json_cli
# PRIV_DIR=priv
# BIN_TARGET=$(PRIV_DIR)/tdlib-json-cli

# JOBS=2
# VERBOSE=0

# TDLIB_SRC=priv/tdlib_v1.8.0.tar.gz
# TDLIBJSONCLI_SRC=priv/tdlib-json-cli-1.8.0.tar.gz

# all:
# 	if [ ! -f $(BIN_TARGET) ]; then \
# 		make extract build import; \
# 	fi

# clean:
# 	rm -f $(BIN_TARGET)
# 	rm -r $(BUILD_ROOT)

# extract:
# 	mkdir -p $(BUILD_ROOT);  \
# 	tar xvf $(TDLIBJSONCLI_SRC) --directory $(BUILD_ROOT) --strip-components 1; \
# 	tar xvf $(TDLIB_SRC) --directory $(BUILD_ROOT)/td --strip-components 1; \
# 	patch $(BUILD_ROOT)/td/CMakeLists.txt $(PRIV_DIR)/disable-lto.patch

# build:
# 	mkdir $(BUILD_DIRECTORY); \
# 	cd $(BUILD_DIRECTORY); \
# 	cmake -DCMAKE_BUILD_TYPE=Release ..; \
# 	make -j$(JOBS) VERBOSE=$(VERBOSE)

# import:
# 	cp $(BUILD_ARTIFACT) $(BIN_TARGET)
# 	cp $(BUILD_ROOT)/types.json $(PRIV_DIR)/types.json

# Директорії
BUILD_ROOT=_build/tdlib
BUILD_DIRECTORY=$(BUILD_ROOT)/rel
TDLIB_SRC_DIR=$(BUILD_ROOT)/td
CLI_SRC_DIR=$(BUILD_ROOT)/cli
CLI_BUILD_DIR=$(BUILD_ROOT)/cli_build
PRIV_DIR=priv
BIN_TARGET=$(PRIV_DIR)/tdlib-json-cli

# Кількість потоків
JOBS=2
VERBOSE=0

all:
	if [ ! -f $(BIN_TARGET) ]; then \
		make clean clone build build-cli import; \
	fi

clean:
	rm -f $(BIN_TARGET)
	rm -rf $(BUILD_ROOT)

clone:
	@echo "🔽 Клонування TDLib..."
	mkdir -p $(BUILD_ROOT)
	git clone --depth=1 https://github.com/tdlib/td.git $(TDLIB_SRC_DIR)

	@echo "🔽 Клонування tdlib-json-cli..."
	git clone --depth=1 https://github.com/oott123/tdlib-json-cli.git $(CLI_SRC_DIR)

	@echo "🔗 Створення симлінку td -> ../td у cli"
	ln -sf ../td $(CLI_SRC_DIR)/td

build:
	@echo "🔨 Компіляція TDLib..."
	mkdir -p $(BUILD_DIRECTORY)
	cd $(BUILD_DIRECTORY) && cmake -DCMAKE_BUILD_TYPE=Release ../td
	cd $(BUILD_DIRECTORY) && make -j$(JOBS) VERBOSE=$(VERBOSE)

build-cli:
	@echo "📁 Копіювання TDLib у cli/td (для add_subdirectory)"
	rm -rf $(CLI_SRC_DIR)/td
	cp -r $(TDLIB_SRC_DIR) $(CLI_SRC_DIR)/td
	@echo "🔨 Компіляція tdlib-json-cli окремо..."
	mkdir -p $(CLI_BUILD_DIR)
	cd $(CLI_BUILD_DIR) && cmake -DCMAKE_BUILD_TYPE=Release ../cli
	cd $(CLI_BUILD_DIR) && make -j$(JOBS)

import:
	@echo "📥 Копіювання tdlib-json-cli до priv/"
	cp $(CLI_BUILD_DIR)/bin/tdlib_json_cli $(BIN_TARGET)
	@echo "✅ tdlib-json-cli готовий до використання!"

