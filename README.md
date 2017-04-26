# lorc

Reference local meta-scripts from any directory in your project.  `PATH="$PATH:$PWD/bin"` on steroids.

```
~/proj
|-- bin/
|   |-- test.sh
|   `-- lorc
`-- src/
```

## Installation

```bash
curl http://cdn.rawgit.com/rweda/lorc/v1.0.0/lorc -o bin/lorc
```

Replace `v1.0.0` with a previous [version number](https://github.com/rweda/lorc/releases) or `master` to get the
absolute latest code.
Replace `bin/lorc` to specify an output location for the script.

Edit the downloaded script to customize to your specific needs.

## Usage

```bash
cd ~/proj
source bin/lorc
cd src/
test.sh # equivalent to ../bin/test.sh
```
