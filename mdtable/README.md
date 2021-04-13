# mdtable

utility for creating markdown tables from json

Work in progress. -- Currently this utility only support generating markdown tables.

Based on my earlier work <https://galvanist.com/posts/2019-04-28-markdown-tables-from-dicts/>

---

example usage:

```
docker images --format '{{json .}}' | hsort -rc | ./mdtable.py
```