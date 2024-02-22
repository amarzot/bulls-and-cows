# Bulls and Cows

This is an exploration of Zig and an implementation of the game bulls and cows (the way I was taught to play it).

# Building

There are some debug logs which can be disabled by passing the `-O ReleaseSafe` flag when compiling.

This should also be cross platform.

```console
$ zig build-exe main.zig -O ReleaseSafe
```

# Running

```console
$ ./main
Guess: 1234
Bulls: 0, Cows: 1
Guess: 
```
