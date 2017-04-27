# lorc

Reference local meta-scripts from any directory in your project.  `PATH="$PATH:$PWD/bin"` on steroids.

```
~/proj
|-- bin/
|   |-- test.sh
|   `-- lorc
`-- src/
```

Got utilities in a `bin` directory local to your current project, such as build, lint, testing, or packaging scripts,
that you need to reference when you've `cd`'d into other directories in the project?

`lorc` will temporarily add the scripts you need from the `bin` directory to your `PATH`.

### Features

- `lorc` checks that scripts don't share a name with globally installed packages
  (e.g. `bin/test` shouldn't clobber the global `test` command in Unix)  
  Conflicts can be resolved in several ways:
  - `lorc` can ignore the conflict, and not clobber the global command
  - Each script can have their own alias (pass `test_ALIAS=local_test`)
  - A global prefix can be added to all commands (`SCRIPT_PREFIX=lo_` will add `lo_test` to the path)

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

## Concepts

### Paths and Project Directory

`lorc` uses file-system paths throughout the script to locate resources.  Most paths were designed to be relative, using
the location of the `lorc` script itself to find other resources.  This would allow `lorc` to be committed into a code
repository and work for any other user.

Most of the `lorc` configuration expects to be given relative paths.

```bash
local PROJECT_PATH="$SCRIPT_PATH${PROJECT_PATH:-"../"}"
```
(See the [Configuration][] section for Bash variable syntax, as well as the usage of this configuration variable)

`PROJECT_PATH` is based on `SCRIPT_PATH`, and expects to be a relative path from the location of the `lorc` script to
the root directory of the project.  However, the entire line could be rewritten for use in other situations, such as
using absolute paths:

```bash
local PROJECT_PATH="${PROJECT_PATH:-"~/Documents/my-project/"}"
```

### Alias Directories

On Unix systems, only directories containing scripts can be added to the path, not individual scripts themselves.

`lorc` supports adding a subset of the users scripts to `PATH`, or aliasing scripts under different names so they don't
conflict with other executables installed on the system.

To ensure that the correct scripts are added to `PATH`, `lorc` doesn't add directories from by the project directly to
the path.  Instead, `lorc` adds a temporary directory to `PATH` that contains links to the original script locations.

By default, `lorc` handles naming and creating random directories, as well as removing the temporary directories after
the user should be done with them, but that functionality can be disabled in `lorc`'s [configuration][Configuration].

## Configuration

`lorc` can be configured to match your project's structure.
The first section of the `lorc` script sets configuration variables and is intended to be customized by the end user.

Each variable is written as

```bash
local VARIABLE_NAME="${VARIABLE_NAME:-"DEFAULT_VALUE"}"
```

This allows `VARIABLE_NAME` to be overridden at run-time (see example below), and otherwise falls back on
`DEFAULT_VALUE`.

```bash
SCRIPT_NAME=secondary-test source bin/lorc
```

Several of the variables are very dependent on your repository's structure:

- **PROJECT_PATH**
  By default, `lorc` references resources by a parent "project directory".  `PROJECT_PATH` is normally the relative path
  from the `lorc` script's location to the project directory, but an absolute reference can be used with minor
  modifications.  See [Paths and Project Directory][] for more information.
- **SCRIPT_DIR**
  should be a directory containing the repository scripts that are being added to the path.  By default, `lorc` assumes
  that `SCRIPT_DIR` is the relative path from `PROJECT_PATH` to the script directory.
- **SINGLE_SCRIPT**
  `lorc` uses slightly different variables if only one script is being added to `PATH`.  Set `SINGLE_SCRIPT` to `true`
  for better performance if only one script is being added to the path.
  - *SINGLE_SCRIPT=true*
    - **SCRIPT_NAME**
      should be the name of the script that is being added to `PATH`, located in `SCRIPT_DIR`
    - **SCRIPT_ALIAS**
      is an optional alias to add to `PATH`, if the original script name is already in use on the system.
      In addition, an alias can be provided as an optional parameter to `lorc` when running in single-script mode:
      `source bin/lorc ALIAS`
  - *SINGLE_SCRIPT=false*
    - **SCRIPT_NAMES**
      should be an array of scripts located in `SCRIPT_DIR` that should be added to `PATH`.
    - **lorc_script_alias()**
      is a function that finds optional aliases for each script.  By default, `lorc_script_alias` looks up aliases for
      script `$1` under `$1_ALIAS`, or uses a prefix if one was given as `SCRIPT_PREFIX` (`$SCRIPT_PREFIX$1`)

Additional variables customize the behavior of `lorc`, but aren't very dependent on your repository's layout.

- **REMOVE_OLD**
  determines if old [alias directories][] should be automatically deleted.  Defaults to `true`.
- **REMOVE_OLD_AFTER**
  sets the oldest directories to keep, in days.  Defaults to `20`.
- **ALLOW_OVERLOAD**
  determines if `lorc` should fail when it detects that a global script shares the same name as a local script or alias
  that is being added.  Defaults to `true` (fails on shared name)
- **OUTPUT_SUFFIX**
  is a randomly generated string used to create unique [alias directories][].
  Defaults to 12 random alphanumeric characters.
- **OUTPUT_DIRECTORIES**
  determines a directory in which [alias directories][] are stored.  Should not contain any other files or folders.
  Defaults to `aliases` inside `SCRIPT_DIR`.
- **OUTPUT_DIRECTORY**
  is hardcoded to `$OUTPUT_DIRECTORIES/$OUTPUT_SUFFIX/`.  To completely replace the `OUTPUT_SUFFIX` and
  `OUTPUT_DIRECTORIES` functionality, manually set `OUTPUT_DIRECTORY` in the script.

[Configuration]: #configuration
[alias directories]: #alias-directories
[Paths and Project Directory]: #paths-and-project-directory
