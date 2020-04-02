# avg

This command-line utility reads lines from the standard input, searches each line for numbers and writes a summary of numeric that data to standard output. It was inspired by the pandas [DataFrame describe method](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.describe.html).

## Output

This is an example of the output from the command `seq 1 10 | avg`:

```
 count: 10
   sum: 55
   min: 1
   max: 10
  mean: 5.5
median: 5.5
stddev: 2.872281
   iqr: 4.5
   25%: 3.25
   50%: 5.5
   75%: 7.75
   95%: 9.55
   99%: 9.91
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