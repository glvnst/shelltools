# avg

This command-line utility reads lines from the standard input, searches each line for numbers and writes a summary of numeric that data to standard output. It was inspired by the pandas [DataFrame describe method](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.describe.html).

## Output

This is an example of the output from the command `seq 1 117.17 1000000 | avg`:

```
 count: 8535
   sum: 4267204615.95
   min: 1
   max: 999930
  mean: 499965.391441
median: 499965
stddev: 288688.399358
   iqr: 499964
   25%: 249983.5
   50%: 499965
   75%: 749947.5
   95%: 949933.1
   99%: 989930.22
```

## Usage

This is the usage text displayed by invoking the program with the `-h` or `--help` arguments.

```
usage: avg [-h|--help]

This command reads input lines from the standard input, finds the first numeric
value on each line, and prints a mathematical summary of the numbers found when
EOF is reached.

Default Template: 
 count: {{len .Numbers | printf "%d"}}
   sum: {{Sum .Numbers | TrimZeros}}
   min: {{TrimZeros .Min}}
   max: {{TrimZeros .Max}}
  mean: {{Mean .Numbers | TrimZeros}}
median: {{Median .Numbers | TrimZeros}}
stddev: {{StdDev .Numbers | TrimZeros}}
   iqr: {{Iqr .Numbers | TrimZeros}}
   25%: {{Percentile .Numbers 0.25 | TrimZeros}}
   50%: {{Percentile .Numbers 0.5 | TrimZeros}}
   75%: {{Percentile .Numbers 0.75 | TrimZeros}}
   95%: {{Percentile .Numbers 0.95 | TrimZeros}}
   99%: {{Percentile .Numbers 0.99 | TrimZeros}}

  -findall
    	find all numbers on each input line, rather than just the first
  -template string
    	the template to use when printing the summary (in golang text/template format)
```