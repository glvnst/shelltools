package main

import (
	"fmt"
	"strings"
)

func ceildiv(x, y int) int {
	result := x / y
	if x%y > 0 {
		result++
	}
	return result
}

func spacePad(s string, width int, alignment ColumnAlignment) string {
	var fmtWidth int

	switch alignment {
	case AlignRight:
		fmtWidth = width
	case AlignLeft:
		fmtWidth = 0 - width
	case AlignCenter:
		s = strings.Repeat(" ", ceildiv(width-len(s), 2)) + s
		fmtWidth = 0 - width
	default:
		panic(fmt.Sprintf("spacePad attempt to pad with unknown alignment: %+v", alignment))
	}

	return fmt.Sprintf("%[2]*[1]s", s, fmtWidth)
}

// PrintMarkdownTable prints the given MarkdownTable to STDOUT
func PrintMarkdownTable(table *MarkdownTable) {
	// short-circuit if there is nothing to print
	if len(table.Rows) < 1 {
		return
	}

	columnCount := len(table.Headings) - 1

	// print the header row
	for colNum, header := range table.Headings {
		fmt.Print(spacePad(header, table.ColumnWidths[colNum], table.ColumnAlignments[colNum]))
		if colNum < columnCount {
			fmt.Print(" | ")
		} else {
			fmt.Println("")
		}
	}

	// print the delimiter row
	for colNum := range table.Headings {
		switch table.ColumnAlignments[colNum] {
		case AlignRight:
			fmt.Print(strings.Repeat("-", table.ColumnWidths[colNum]-1), ":")
		case AlignCenter:
			fmt.Print(":", strings.Repeat("-", table.ColumnWidths[colNum]-2), ":")
		default:
			fmt.Print(strings.Repeat("-", table.ColumnWidths[colNum]))
		}
		if colNum < columnCount {
			fmt.Print(" | ")
		} else {
			fmt.Println("")
		}
	}

	// print the data rows
	for _, row := range table.Rows {
		for colNum, cell := range row {
			fmt.Print(spacePad(cell, table.ColumnWidths[colNum], table.ColumnAlignments[colNum]))
			if colNum < columnCount {
				fmt.Print(" | ")
			} else {
				fmt.Println("")
			}
		}
	}
}
