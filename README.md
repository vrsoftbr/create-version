# Create Version Action

This action create/update the CHANGELOG.md file based on the last chages and makes a commit. Also it creates the tag for the last commits and push them all
Esta ação imprime "Hello World" ou "Hello" + o nome de uma pessoa a ser cumprimentada no log.

## Inputs

### `version`

**Required** The version to be created.

## Example of usage

uses: ricardosanfelice/create-version@v1
with:
  version: 'v1.2.3'
