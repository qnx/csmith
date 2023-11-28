# Compile the port for QNX

**NOTE**: QNX ports are only supported from a Linux host operating system

- Setup your QNX SDP environment
- Install dependencies
    - `sudo apt install g++ cmake m4`
    - `sudo apt install csmith`
- From the root folder, type:
	- `OSLIST=nto make -C qnx/build install`
