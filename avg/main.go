package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"log"
	"math"
	"os"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"text/template"
)

const helpText = `usage: %s [-h|--help]

This command reads input lines from the standard input, finds the first numeric
value on each line, and prints a mathematical summary of the numbers found when
EOF is reached.

Default Template: %s
`

// NumberRegexp is a regular expression which captures signed floats and ints.
var NumberRegexp = regexp.MustCompile(`[-+]?\d*\.?\d+([eE][-+]?\d+)?`)

// DefaultSummaryTemplate is the default template, AFAICT, but who could tell?
const DefaultSummaryTemplate = `
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
`

// SummaryTemplateFuncMap defines functions available to summary templates.
var SummaryTemplateFuncMap = template.FuncMap{
	"Iqr":        Iqr,
	"Mean":       Mean,
	"Median":     Median,
	"Percentile": Percentile,
	"StdDev":     StdDev,
	"Sum":        Sum,
	"TrimZeros":  TrimZeros,
}

// SummaryData is a struct made available to summary templates consisting of the Numbers slice, Min, Max, and Count members.
type SummaryData struct {
	Numbers []float64
	Min     float64
	Max     float64
	Count   int
}

var templateText string
var findAllFlag bool = false

// Mean calculates the mathematical mean for a given slice.
func Mean(dataset []float64) float64 {
	return Sum(dataset) / float64(len(dataset))
}

// Median calculates the mathematical median value for a given slice.
func Median(dataset []float64) float64 {
	// assumes the dataset is already sorted
	length := len(dataset)
	if length < 2 {
		return math.NaN()
	}
	middleMember := length / 2

	if length%2 != 0 {
		// odd length
		return dataset[middleMember]
	}

	// even length requires the mean of the middle pair
	return (dataset[middleMember] + dataset[middleMember-1]) / 2
}

// Sum calculates the mathematical sum of the values in a given slice.
func Sum(dataset []float64) float64 {
	var sum float64 = 0
	for _, value := range dataset {
		sum += value
	}
	return sum
}

// Modf returns a tuple containing: the integer portion, the fractional portion of a given float.
func Modf(num float64) (int, float64) {
	whole, fractional := math.Modf(num)
	return int(whole), fractional
}

// Iqr returns the mathematical inter-quartile range of the given slice.
func Iqr(dataset []float64) float64 {
	// assumes the dataset is already sorted
	if len(dataset) < 2 {
		return math.NaN()
	}
	return math.Abs(Percentile(dataset, 0.75) - Percentile(dataset, 0.25))
}

// Percentile returns the given mathematical percentile of the given slice.
func Percentile(dataset []float64, percentile float64) float64 {
	// assumes the dataset is already sorted
	if len(dataset) < 2 {
		return math.NaN()
	}

	// bounds check on dataset length, and percentile >0 && <=1.0
	position := percentile * float64(len(dataset)-1)
	positionInt, positionFrac := Modf(position)
	result := dataset[positionInt]
	adjustment := positionFrac * (dataset[positionInt+1] - result)

	return result + adjustment
}

// StdDev return the mathematical standard deviation for the given slicen.
func StdDev(dataset []float64) float64 {
	// assumes the dataset is already sorted
	if len(dataset) < 2 {
		return math.NaN()
	}

	mean := Mean(dataset)
	var deviation float64 = 0
	for _, val := range dataset {
		deviation += math.Pow(val-mean, 2)
	}
	return math.Sqrt(deviation / float64(len(dataset)))
}

// TrimZeros returns the given float with the trailing zeros and decimal point removed.
func TrimZeros(val float64) string {
	return strings.TrimRight(strings.TrimRight(fmt.Sprintf("%f", val), "0"), ".")
}

// ScanNumbers reads lines from the given io.Reader and returns a slice of numbers found.
func ScanNumbers(rd io.Reader, findAll bool) (numbers []float64) {
	var matches [][]byte

	scanner := bufio.NewScanner(rd)
	for scanner.Scan() {
		line := scanner.Bytes()
		if findAll {
			matches = NumberRegexp.FindAll(line, -1)
		} else {
			match := NumberRegexp.Find(line)
			if match == nil {
				continue
			}
			matches = [][]byte{match}
		}
		for _, value := range matches {
			matchFloat, err := strconv.ParseFloat(string(value), 64)
			if err != nil {
				log.Printf("Couldn't parse %s into float\n", value)
				continue
			}
			numbers = append(numbers, matchFloat)
		}
	}
	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "reading standard input:", err)
	}

	return numbers
}

// printSummary parses and executes the summary template
func printSummary(tmpl string, data SummaryData, wr io.Writer) {
	t, err := template.New("summary").Funcs(SummaryTemplateFuncMap).Parse(tmpl)
	if err != nil {
		log.Fatalf("printSummary failed to parse template. Error: %s\n", err)
	}

	err = t.Execute(wr, data)
	if err != nil {
		log.Fatalf("printSummary failed to execute template. Error: %s\n", err)
	}
}

func init() {
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, helpText, os.Args[0], DefaultSummaryTemplate)
		flag.PrintDefaults()
	}
	flag.StringVar(&templateText, "template", "",
		"the template to use when printing the summary (in golang text/template format)")
	flag.BoolVar(&findAllFlag, "findall", findAllFlag,
		"find all numbers on each input line, rather than just the first")
}

func main() {
	flag.Parse()

	numbers := ScanNumbers(os.Stdin, findAllFlag)
	// summarize
	count := len(numbers)
	if count < 1 {
		fmt.Println("No input data found.")
		return
	}
	sort.Float64s(numbers)

	min := numbers[0]
	max := numbers[count-1]

	// Create a new template and parse the letter into it.
	if templateText == "" {
		templateText = strings.TrimLeft(DefaultSummaryTemplate, "\n")
	} else {
		// We want to support backslash-escaped runes like \n in the template
		unquotedTemplateText, err := strconv.Unquote(`"` + templateText + `"`)
		if err == nil {
			templateText = unquotedTemplateText
		}

		templateText = fmt.Sprintln(templateText)
	}

	printSummary(templateText,
		SummaryData{numbers, min, max, count},
		os.Stdout)
}
