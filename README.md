# Random services and programs

Collection of various small services that I use but are too small for separate repositories.

## Structure

##### [`pkgs`](./pkgs/)

Each subfolder inside the [`pkgs`](./pkgs/) folder is a fully distinct and independent service.

They each contain their own instructions (if needed).

##### [`common`](./common/)

Files and scripts shared across services.

##### [`dist`](./dist/)

Where binaries usually end up (if not changed by build parameters).

## Building

Each service has its own set of scripts:
  - `build.sh` should build the service from the source.
  - [optional] `build-docker.sh` should build a docker image for the service. It may take some options, but it should tell you about them on first run.

All scripts should support a `--help` flag to get help.

