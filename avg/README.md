# avg

This command-line utility reads lines from the standard input and writes a summary of the numeric data found therein. It was inspired by the pandas ["DataFrame describe"](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.describe.html) method.

## Output

This is an example of the output generated when the input is the sequence of numbers from 1 to 10:

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

This text is displayed when the program is invoked with the `-h` or `--help` arguments:

```
usage: avg [-h|--help]

This utility reads lines from the standard input and writes a summary of the
numeric data found therein.
  -findall
    	find all numbers on each input line, rather than just the first
  -template string
    	the template to use when printing the summary (in golang text/template format)
```

## Output Format

The program uses the go [text/template package](https://golang.org/pkg/text/template/) to generate its output report. You can override the output format using the `-template` option. This is the default template used:

```
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
```

The template is named `summary` and it has the following data items available:

* `Numbers` - a pre-sorted slice of numbers in float64 format
* `Min` - the float64 value of the first item of the Numbers slice (smallest value)
* `Max` - the float64 value of the final item of the Numbers slice (largest value)
* `Count` - the number of items in the Numbers slice in integer format

Additionally, the following functions are available to the template:

* `Iqr` - inter-quartile range (absolute value of difference between 25% and 75% percentiles)
* `Mean` - simple mean or "average" (sum of values divided by count of values)
* `Median` - value of the middle item in a sorted slice if there are an odd number of elements OR the mean of the middle pair if the slice has an even number of elements
* `Percentile` - the value of the member at the given percentage into the slice, includes fractional adjustment to final value (argument is a float64; the 25th precentile is available with the argument `0.25`)
* `StdDev` - standard deviation (note: it assumes the slice represents the entire population, not a population sample)
* `Sum` - the sum of all values in the slice
* `TrimZeros` - starts with `%f` and trims trailing zeros and trailing decimal point. This is similar to `%g` but will **not** express extreme values in exponential notation.

You may use backslash-quoted special characters like `\n` within the template.
