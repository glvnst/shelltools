package main

import (
	"math"
	"strings"
	"testing"
)

const mockInputFile = `This is a test input file.
1.0000000000000 is the first number and 1.1 is the second.
1.50 is a number, 13. is a different one;
1.75 tests is a strange number of tests.
200 == numberwang
200.101 is not numberwang, unlike 333.333!
This doesn't start with the number 10010.1010. It ends with 9!
`

type dataset struct {
	Slice        []float64
	Mean         float64
	Median       float64
	Sum          float64
	Percentile25 float64
	Percentile75 float64
	Iqr          float64
	StdDev       float64
}

func testDataset() (result dataset) {
	// result := dataset{}
	result.Slice = []float64{
		0.1,
		1.1,
		2.1,
		3.1,
		4.1,
		5.1,
		6.1,
		7.1,
		8.2,
		9.1,
		10,
		11,
		12,
		13,
		14,
		15,
	}
	result.Mean = 7.56875
	result.Median = 7.65
	result.Sum = 121.1
	result.Percentile25 = 3.85
	result.Percentile75 = 11.25
	result.Iqr = 7.4
	result.StdDev = 4.569972476667665

	return
}

func floatCmp(a, b float64) bool {
	diff := math.Abs(a - b)
	// log.Printf("diff %g %d\n", diff, int(diff))
	return diff < 0.0000000001
}

func TestMean(t *testing.T) {
	td := testDataset()

	want := td.Mean
	got := Mean(td.Slice)
	if !floatCmp(got, want) {
		t.Errorf("want %g, got %g\n", want, got)
	}
}

func TestMedian(t *testing.T) {
	td := testDataset()

	want := td.Median
	got := Median(td.Slice)
	if !floatCmp(got, want) {
		t.Errorf("want %g, got %g\n", want, got)
	}
}

func TestSum(t *testing.T) {
	td := testDataset()

	want := td.Sum
	got := Sum(td.Slice)
	if !floatCmp(got, want) {
		t.Errorf("want %g, got %g\n", want, got)
	}
}

func TestModf(t *testing.T) {
	for _, value := range []float64{10.123, 11.234, 12.4567, 13.234, 14.123} {
		gotWhole, gotFrac := Modf(value)
		wantWholeF, wantFrac := math.Modf(value)
		wantWhole := int(wantWholeF)
		if gotWhole != wantWhole {
			t.Errorf("want whole %d, got %d\n", wantWhole, gotWhole)
		}
		if !floatCmp(gotFrac, wantFrac) {
			t.Errorf("want frac %f, got %g\n", wantFrac, gotFrac)
		}
	}
}

func TestIqr(t *testing.T) {
	td := testDataset()

	want := td.Iqr
	got := Iqr(td.Slice)
	if !floatCmp(got, want) {
		t.Errorf("want %g, got %g\n", want, got)
	}
}

func TestPercentile(t *testing.T) {
	td := testDataset()

	want := td.Percentile25
	got := Percentile(td.Slice, 0.25)
	if !floatCmp(got, want) {
		t.Errorf("want %g, got %g\n", want, got)
	}

	want = td.Percentile75
	got = Percentile(td.Slice, 0.75)
	if !floatCmp(got, want) {
		t.Errorf("want %g, got %g\n", want, got)
	}
}

func TestStdDev(t *testing.T) {
	td := testDataset()

	want := td.StdDev
	got := StdDev(td.Slice)
	if !floatCmp(got, want) {
		t.Errorf("want %g, got %g\n", want, got)
	}
}

func TestTrimZeros(t *testing.T) {
	numbers := []float64{
		0,
		0.0,
		1.0000000000000,
		1.50,
		1.75,
		200,
		200.101,
		10010.1010,
	}
	wantStrings := []string{
		"0",
		"0",
		"1",
		"1.5",
		"1.75",
		"200",
		"200.101",
		"10010.101",
	}

	for idx, value := range numbers {
		want := wantStrings[idx]
		got := TrimZeros(value)
		if got != want {
			t.Errorf("want %s, got %s\n", want, got)
		}
	}
}

func TestScanNumbers(t *testing.T) {
	mockFile := strings.NewReader(mockInputFile)
	wantNumbers := []float64{
		1.0000000000000,
		1.50,
		1.75,
		200,
		200.101,
		10010.1010,
	}
	gotNumbers := ScanNumbers(mockFile, false)
	if len(wantNumbers) != len(gotNumbers) {
		t.Errorf("want %d, got %d\n", len(wantNumbers), len(gotNumbers))
	}
	for idx, value := range wantNumbers {
		want := value
		got := gotNumbers[idx]
		if !floatCmp(got, want) {
			t.Errorf("want %g, got %g\n", want, got)
		}
	}

	// re-creating mockFile. alternatively we could seek 0
	mockFile = strings.NewReader(mockInputFile)
	wantNumbers = []float64{
		1.0000000000000,
		1.1,
		1.50,
		13.,
		1.75,
		200,
		200.101,
		333.333,
		10010.1010,
		9,
	}
	gotNumbers = ScanNumbers(mockFile, true)
	if len(wantNumbers) != len(gotNumbers) {
		t.Errorf("want %d, got %d\n", len(wantNumbers), len(gotNumbers))
	}
	for idx, value := range wantNumbers {
		want := value
		got := gotNumbers[idx]
		if !floatCmp(got, want) {
			t.Errorf("want %g, got %g\n", want, got)
		}
	}
}
