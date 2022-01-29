# Set up an environment for programming assembly

I am following this tutorial:

https://www.tutorialspoint.com/assembly_programming/assembly_environment_setup.htm

The tutorial is for Linux. I do this on Windows using
[MSYS2](https://www.msys2.org/). See my setup notes
[here](https://github.com/sustainablelab/msys). (click to open my
GitHub repo for setting up MSYS2).

The tutorial uses `nasm`. First find the MSYS `nasm` package for 64-bit.

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

# Program in assembly

## Make docs

Create a `.man` file for reading the `nasm` documentation in Vim:

```
$ man nasm > ~/read-the-docs/nasm.man
```

And another `.man` file for reading the `nasm` help in Vim:

```
$ nasm -h > ~/read-the-docs/nasm-h.man
```

Refer to these docs to understand the flags I use in the `nasm`
commands below.

## Make a first program

### Plan

Create `hello.asm`. This won't print hello. I won't even produce
an executable with this.

The "program" writes one value to a register.

I build this to produce a binary file, convert the binary file
into human-readable hexadecimal. Then I change what value is
written to the register, rebuild that hexadecimal text file, and
use Vim to diff the two hexadecimal text files.

I expect Vim to highlight the difference. The only difference is
the value I write to the register.

### First program

This is it. Call it `first.asm`:

```asm
mov edx,1
```

The entire program is one line. I get away with this because I'm
not trying to build an executable. I'm not linking this, I'm just
making an object file. So I don't need an "entry point" into a
program. I can just start writing assembly code.

Build the binary:

```
$ nasm -O0 -f elf64 first.asm
```

That creates a `first.o` file. This file is binary, so it looks
like gibberish if I open it in Vim. Use `xxd` to make this file
human-readable:

```
$ xxd first.o
```

That will generate a lot of output. Redirect it to `first.oh` (I
made up the `oh` extension for
Object-file-that-is-Human-readable).

```
$ xxd first.o > first.oh
```

I can open this in Vim. It is one-line of assembly code, and the
`.o` file is one-line (whatever that means). But `xxd` generated
34 lines of text. So one-line of code became 34 instructions?

The point is it would be a lot of work to figure out what was
generated. Surely it's not all specific to my `.asm` code. I just
want to see what is relevant to what I wrote in `first.asm`.

Save `first.oh` as `first-1.oh`:

```
$ cp first.oh first-1.oh
```

Change `first.asm`:

```asm
mov edx,2
```

Rebuild:

```
$ nasm -O0 -f elf64 first.asm
$ xxd first.o > first.oh
```

Now Vim diff the two `.oh` files. There is only one difference.
Vim highlights the difference in red. It is on line 25.

I show the two lines below and indicate which came from which
`.asm` code:

```
mov edx,1 ───┐
             ↓
00000180: ba01 0000 0000 0000 0000 0000 0000 0000  ................

mov edx,2 ───┐
             ↓
00000180: ba02 0000 0000 0000 0000 0000 0000 0000  ................
```

## Make a Makefile

I'll be doing this a lot. Create a Makefile to make it easy to do
all this:

```make
first.o: first.asm
	nasm -O0 -f elf64 first.asm
	xxd first.o > first.oh
```

That's the entire Makefile. Run make with `-B`. The `-B` means
always run the recipes, even if the dependencies have not
changed.

```bash
$ make -B
```

### Generalize the Makefile

I'm going to leave `first.asm` and start on another file called
`hello.asm`.

I generalize the Makefile to work with both filenames like this:

```make
first: first.o
hello: hello.o

%.o: %.asm
	nasm -O0 -f elf64 $^
	xxd $@ > $*.oh
```

Now I can choose whether to build `first` or `hello` when I run make:

```bash
$ make first -rB
$ make hello -rB
```

### make -r

The `-r` flag tells `make` not to use any implicit rules. The
implicit `make` rule I need to avoid is using `cc` to build the
`.o` file.

`make` sees my target is a `.o`, so it assumes I'll want to use
the `cc` compiler (this is an environment variable that points to
the compiler `make` should use by default, usually `gcc`: do `cc
-v` to find out what executable `cc` is). Anyway, to avoid `make`
running `gcc` without me telling it to, I add the `-r` flag.

Use the `-n` flag to see what `make` will do (what values `make`
substitutes and what implicit rules it runs) without actually
doing the recipe.

```bash
$ make -nrB
nasm -O0 -f elf64 first.asm
xxd first.o > first.oh
```

Without the `-r`, make also does a `cc`:

```bash
$ make -nB
nasm -O0 -f elf64 first.asm
xxd first.o > first.oh
cc   first.o   -o first
```

And that is going to fail miserably, so eliminate the `cc` rule
(and all implicit rules) with `-r`. It is worth noting that this
`-r` does not usually come up because usually I am not writing
assembly and so I have a rule for working with `.o` files that
overrides the `cc` implicit rule. In fact, I learned about `-r`
while writing this!

### default target

Whichever target is listed first in the Makefile is the default
target, so if I want to build `first` I can just do:

```bash
$ make -rB
```

Point of all this is that I only need to change the first line of
the Makefile, or specify the target name when I call `make`, and
there is nothing else I have to change in the Makefile.

### Makefile syntax

How does this generalized Makefile work?

- `%` is pattern matching
- `$@`, `$^`, and `$*` are automatic variables

#### Makefile pattern matching

The `%` is a pattern matching rule. It takes the target and
matches to it. So if the target is `bob.o`, then `%.o` matches
`%` to `bob`.

The way I'm using it, `%` is the file stem: the file name without
its extension. Actually more than just the file name, it will
include directories too if that is part of the match.

So I can `%` to define the prerequisite. If the target is `bob.o`
and the pattern match is `%.o`, then `%.asm` turns into
`bob.asm`.

#### Makefile automatic variables

The `$^` is a space-separated list of all the prerequisites.
There is only one prerequisite. So if the target is `bob.o`, then
the prerequisite is `bob.asm` and `$^` is simply `bob.asm`.

`$@` is the target, so `bob.o`.

`$*` is the stem which the implicit rule matches. It is just like
`%`. So if the target is `bob.o` then `$*.oh` is `bob.oh`.

I cannot put `%.oh` in the recipe because `make` does not
interpret `%` as a file stem in the recipe. `make` will think
I'm outputting to a file named `%.oh`. In the recipe, I use `$*`
for this purpose.

And there is no fancy string combining function I have to use. If
I want to output to `first-1.oh` I can simply edit the recipe to
read `$*-1.oh`:


```make
first: first.o
hello: hello.o

%.o: %.asm
	nasm -O0 -f elf64 $^
	xxd $@ > $*-1.oh
```
