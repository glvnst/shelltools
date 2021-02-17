# movehere

shell utility for merging other directories into the current working directory

## Usage

```

 Usage: movehere dir [...]
 
 This utility moves the contents of the given directories into the
 current working directory. Subsequently the given directories are
 removed.
 
 For example, the command: "movehere example_prog"
 will move the contents of the example_prog directory into the
 current working directory and delete the now-empty directory
 example_prog.
 
 .                              [ same ]
 ./example_prog                 [ removed ]
 ./example_prog/.env            ->  ./.env
 ./example_prog/README.md       ->  ./README.md
 ./example_prog/some_deps       ->  ./some_deps
 ./example_prog/some_deps/dep1  ->  ./some_deps/dep1
 ./example_prog/some_deps/dep2  ->  ./some_deps/dep2
 ./example_prog/src             ->  ./src
 ./example_prog/src/main.c      ->  ./src/main.c
 
 In this case movehere simply replaces the following commands:
 mv example_prog/{.*,*} ./ \ 
 && rmdir example_prog
 
 However this utility handles edge cases that can complicate that simple
 approach, such as the subdirectory containing an item with the same 
 name as the subdirectory (e.g. example_prog/example_prog)
```