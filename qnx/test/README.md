# Testing csmith on QNX

## Build the project

    - Go under the build folder and run build command
        JLEVEL=4 make install

## Use Csmith

### Compile on host machine and run on target

e.g: for RPI4 (aarch64)

    - Generate a test case
        csmith > random1.c
    - Compile on desired architecture and run 
      - Make sure to have all the .h files needed in the same directory
        qcc -Vgcc_ntoaarch64le -o random1 random1.c
    - Copy random1 binary to you your target
        scp random1 root@<target-ip-address>
    - Run the binary on target
        random1

## Compile and run on target

TBD: for test team
