package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"regexp"
	"strings"
)

type parserState int

const (
	wantHeader parserState = iota
	wantDelimiter
	wantRows
	stopped
)

// These don't work because re2 doesn't save intermediate matches in these rows
// var headerRegex = regexp.MustCompile(`^\s*([^|]+?)\s*(?:[|]\s*([^|]+?)\s*)*$`)
// var rowRegex = regexp.MustCompile(`^\s*([^|]+)\s*(?:[|]\s*([^|]+)\s*)*$`)
// var delimiterRegex = regexp.MustCompile(`^\s*([:]?[-]+[:]?)\s*(?:[|]\s*([:]?[-]+[:]?)\s*)*$`)

// CellRe is a regular expression which matches cells in a markdown table
var CellRe = regexp.MustCompile(`\s*([^|]+?)\s*(?:\||$)`)

// DelimiterRe is a regular expression which matches individual fields of a markdown table's delimiter row, this row type contains column alignment information
var DelimiterRe = regexp.MustCompile(`[|]?\s*([:]?[-]+[:]?)\s*`)

func intMax(x, y int) int {
	if x > y {
		return x
	}
	return y
}

// ParseMarkdownTable parses a markdown table from the given io.Reader and returns a MarkdownTable
func ParseMarkdownTable(r io.Reader) (*MarkdownTable, error) {
	table := NewMarkdownTable()
	var state parserState

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		line := scanner.Text()

		switch state {
		case wantRows:
			if line == "" {
				// We've reached the end of the table
				state = stopped
				continue
			}

			match := CellRe.FindAllStringSubmatch(line, -1)
			if match == nil {
				return nil, fmt.Errorf("failed to parse regular row: %s", line)
			}
			row := make([]string, 0)
			for colNum, cellMatch := range match {
				cell := strings.TrimRight(cellMatch[1], " ") // want capture group 1
				// log.Printf("Captured cell '%s'", cell)
				row = append(row, cell)
				table.ColumnWidths[colNum] = intMax(table.ColumnWidths[colNum], len(cell))
			}
			table.Rows = append(table.Rows, row)

		case wantHeader:
			if line == "" {
				// Allow blank lines to pass before the table start
				continue
			}

			match := CellRe.FindAllStringSubmatch(line, -1)
			if match == nil {
				return nil, fmt.Errorf("failed to parse header row: %s", line)
				// continue
			}
			for colNum, cellMatch := range match {
				heading := cellMatch[1] // want capture group 1
				// log.Printf("Captured heading '%s'", heading)
				table.Headings = append(table.Headings, heading)
				table.ColumnWidths[colNum] = intMax(table.ColumnWidths[colNum], len(heading))
			}
			state = wantDelimiter

		case wantDelimiter:
			match := DelimiterRe.FindAllStringSubmatch(line, -1)
			if match == nil {
				return nil, fmt.Errorf("failed to parse delimiter row: %s", line)
				// Would could also do something like this if we could rollback the prior header parsing
				// state = wantHeader
				// continue
			}
			for colNum, delimiterMatch := range match {
				delimiter := delimiterMatch[1]
				lToken := strings.HasPrefix(delimiter, ":")
				rToken := strings.HasSuffix(delimiter, ":")
				var alignment ColumnAlignment
				switch {
				case lToken && rToken:
					// ex :---:
					alignment = AlignCenter
				case !lToken && rToken:
					// ex ----:
					alignment = AlignRight
				default:
					// ex :---- OR -----
					alignment = AlignLeft
				}
				table.ColumnAlignments = append(table.ColumnAlignments, alignment)
				table.ColumnWidths[colNum] = intMax(table.ColumnWidths[colNum], len(delimiter))
			}
			state = wantRows

		case stopped:
			line := scanner.Text()
			if line == "" {
				// Allow blank lines to pass after table stop
				continue
			}
			log.Printf("WARNING: Ignoring input after parsing stopped: '%s'", line)

		default:
			return nil, fmt.Errorf("unknown parser state %d encountered with line: %s", state, line)
		}
	}
	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("error reading standard input: %s", err)
	}

	return table, nil
}
