# Set up an environment

I am following this tutorial:

https://www.tutorialspoint.com/assembly_programming/assembly_environment_setup.htm

The tutorial is for Linux. I do this on Windows using
[MSYS2](https://www.msys2.org/). See my setup notes [here]().
(click to open my GitHub repo for setting up MSYS2).

Find the MSYS `nasm` package for 64-bit:

Search the MSYS2 packages on a browser: https://packages.msys2.org/base/mingw-w64-nasm

Check that I can find the package with `pacman`:

```search-for-nasm
$ pacman -Ss nasm
mingw64/mingw-w64-x86_64-nasm 2.15.05-1
    An 80x86 assembler designed for portability and modularity (mingw-w64)
```

Install the package:

```install-nasm
$ pacman -S mingw-w64-x86_64-nasm
resolving dependencies...
looking for conflicting packages...

Packages (1) mingw-w64-x86_64-nasm-2.15.05-1
```

If MSYS complains about the PGP key, the keyring is out of date.
I think I can just manually add the package author's key the way
I describe in my MSYS repo. But first try updating my MSYS
installation.

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
