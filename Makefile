# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# avoid folder clash with 'test' folder and target
.PHONY: coverage test

# excludes test artificats from coverage reports
CONTRACT_EXCLUDES="Mock"
COVERAGE_EXCLUDES="\.t\.sol|(m|M)ock|(t|T)est"

all: clean install build

# Clean the repo
clean    :; forge clean

# Install the modules
install  :; forge install

# Lint
lint     :; solhint 'src/**/*.sol' && solhint -c './.solhint-test.json' 'test/**/*.sol'

# Builds
build    :; forge clean && forge build

# Unit Tests
test     :; forge test --nmc ${CONTRACT_EXCLUDES}
coverage :; forge coverage --nmc ${CONTRACT_EXCLUDES} --nmco ${COVERAGE_EXCLUDES}
lcov     :; forge coverage --nmc ${CONTRACT_EXCLUDES} --nmco ${COVERAGE_EXCLUDES} --report lcov --report-file coverage/lcov.info
