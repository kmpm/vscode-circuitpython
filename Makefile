CP_VERSION?=9.2.0

.PHONY: find-native
find-native:
	@find node_modules -type f -name "*.node" 2>/dev/null | grep -v "obj\.target"

.PHONY: all
all: npm stubs
	@npx @vscode/vsce package

.PHONY: npm
npm:
	@npm install
	@npm run electron-rebuild

.PHONY: stubs
stubs:
	@./scripts/build-stubs.sh $(CP_VERSION)

.PHONY: quick
quick:
	@npm install
	@npx @vscode/vsce package

.PHONY: clean
clean:
	@rm -rf circuitpython
	@rm -rf boards
	@rm -rf stubs
	# @rm -rf out
	# @rm -rf node_modules
	