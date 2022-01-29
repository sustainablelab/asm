## ToC
[Back to README](README.md)

- [Follow this tutorial by tutorialspoint](setup-env.md#follow-this-tutorial-by-tutorialspoint)
- [PGP key: update MSYS keyring package](setup-env.md#pgp-key)
- [Install nasm on MSYS](setup-env.md#install-nasm-on-msys)
- [Check nasm installation](setup-env.md#check-nasm-installation)

# Set up an environment for programming assembly

## Follow this tutorial by tutorialspoint

I am following this tutorial:

https://www.tutorialspoint.com/assembly_programming/assembly_environment_setup.htm

The tutorial is for Linux. I do this on Windows using
[MSYS2](https://www.msys2.org/). See my setup notes
[here](https://github.com/sustainablelab/msys). (click to open my
GitHub repo for setting up MSYS2).

The tutorial uses `nasm`. First find the MSYS `nasm` package for 64-bit.

## Install nasm on MSYS

Search the MSYS2 packages on a browser:

https://packages.msys2.org/base/mingw-w64-nasm

Check that I can find the package with `pacman`:

```search-for-nasm
$ pacman -Ss nasm
mingw64/mingw-w64-x86_64-nasm 2.15.05-1
    An 80x86 assembler designed for portability and modularity (mingw-w64)
```

Install the package:

```install-mingw-w64-blah-nasm
$ pacman -S mingw-w64-x86_64-nasm
resolving dependencies...
looking for conflicting packages...

Packages (1) mingw-w64-x86_64-nasm-2.15.05-1
```

This works too, the "total installed size" is actually smaller.
I'm not sure what the difference is, but they are different
packages:

```install-nasm
$ pacman -S nasm
```

I installed them both. But I had to update my MSYS installation
first to get the latest PGP keyring.

## PGP key

MSYS complains about the PGP key. It is because my
`msys2-keyring` is out of date. Just update the MSYS installation
by running `pacman -Syu` a bunch of times. They keyring gets
updated and then I can install `nasm` without complaints.

### I forget how to do gpg stuff manually

I think I can just manually add the package author's key the way
I describe in my MSYS repo for checking the signature of the
msys2 executable installer.

This is how to import a public key:

```import-public-key
gpg --recv-key 0xf7a49b0ec
```

But use the key value for the package author, not the key in the
above example.

In this case the author is [David
Macek](https://keyserver.ubuntu.com/pks/lookup?op=vindex&fingerprint=on&search=0x628f528cf3053e04)
(click to open MSYS page showing author's gpg public key).

I'm fairly confident everything needed to do this manually is on
that page, but I forget the details of what to do.

There is no reason to do this manually. If I trust MSYS (which I
do), then I just update the MSYS keyring package.

### Just update the MSYS keyring package

Update my MSYS installation to update my keyring.

Close any other instances of MSYS, then run this:

```update-MSYS
$ pacman -Syu
```

The MSYS terminal will close. Open it again and run the command
again:


```update-MSYS
$ pacman -Syu
```

If there were updates, a lot of things get installed. The keyring
is an MSYS package as well, `msys2-keyring`. If the keyring was
out of date, this updates it.

## Check nasm installation

Use `whereis`. If `nasm` is **not installed**, this happens:

```bash
$ whereis nasm
nasm:
```

If `nasm` is installed, this happens:

```bash
$ whereis nasm
nasm: /usr/bin/nasm.exe /mingw64/bin/nasm.exe /usr/share/man/man1/nasm.1.gz

$ which nasm
/mingw64/bin/nasm

$ nasm
nasm: fatal: no input file specified
Type C:\msys64\mingw64\bin\nasm.exe -h for help.
```


