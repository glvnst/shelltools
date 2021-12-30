# mdtablefmt

utility for reformatting markdown tables

It reads the text for a single markdown table from the standard input and prints the table to standard output with the columns of the proper width and alignment.

## Example

These tables both render the same but the latter (which has been piped through `mdtablefmt`) is easier to read.

### Input

```markdown
stat | before | after
---: | :-----: | :------:
Memory | 8GiB | 127GiB
CPUs | 4 | 16
Storage space | 423 G | 31 T
Storage driver | aufs | overlay2
OS | Debian GNU/Linux 8 | Ubuntu 20.04 LTS
Docker version | 17.05.0-ce | 19.03.9-ce
Memory limit support | no | yes
Swap limit support | no | yes
Kernel memory limit support | no | yes
OOM kill disable support | no | yes
CPU cfs quota support | no | yes
CPU cfs period support | no | yes
Virtualization in container support | no | yes
```

### Output

```markdown
                               stat |       before       |       after     
----------------------------------: | :----------------: | :--------------:
                             Memory |        8GiB        |      127GiB     
                               CPUs |          4         |        16       
                      Storage space |        423 G       |       31 T      
                     Storage driver |        aufs        |     overlay2    
                                 OS | Debian GNU/Linux 8 | Ubuntu 20.04 LTS
                     Docker version |     17.05.0-ce     |    19.03.9-ce   
               Memory limit support |         no         |        yes      
                 Swap limit support |         no         |        yes      
        Kernel memory limit support |         no         |        yes      
           OOM kill disable support |         no         |        yes      
              CPU cfs quota support |         no         |        yes      
             CPU cfs period support |         no         |        yes      
Virtualization in container support |         no         |        yes      
```
