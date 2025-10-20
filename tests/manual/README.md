# Manual Tests Directory

Scripts for manual integration testing and validation.

## Available Test Scripts

- **test-vrf-creation.sh** - Test VRF creation with Fabric Composer
- **test-hybrid-afc.sh** - Test Hybrid VRF creation (Fabric Composer mode)
- **test-hybrid-aoscx.sh** - Test Hybrid VRF creation (AOS-CX mode)
- **test-script.sh** - Simple Hello World test script

## Usage

These scripts are meant for manual testing and validation during development.

```bash
cd tests/manual
./test-vrf-creation.sh
./test-hybrid-afc.sh
./test-hybrid-aoscx.sh
```

## Automated Tests

For automated unit/integration tests, see the `.bats` files in the parent `tests/` directory:

```bash
cd tests
./run-tests.sh
```

All manual test scripts use the central library: `../../lib/commons.sh`
