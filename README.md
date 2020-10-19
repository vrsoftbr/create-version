# Create Version Action

![Release](https://github.com/ricardosanfelice/create-version/workflows/Release/badge.svg)

This action create/update the CHANGELOG.md file based on the last chages and makes a commit. Also it creates the tag for the last commits and push them all

## Inputs

### `script`

**Required** The script that will increase version number and update version file. The script have to return the tag name so it will be used to create the tag.

## Example of usage

```yaml
uses: ricardosanfelice/create-version@v1
with:
  script: './build.sh'
env:
  TOKEN: $GITHUB_TOKEN
```
