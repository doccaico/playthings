package main

import (
	"fmt"
	"time"
)

const (
	SUN string = "Su"
	MON string = "Mo"
	TUE string = "Tu"
	WED string = "We"
	THU string = "Th"
	FRI string = "Fr"
	SAT string = "Sa"

	startDOW int    = 0 // Sun: 0, Mon: 1 ... Sut: 6 (0 .. 6)
	PAD      string = " ."
)

// do not change an order
var DOW = []string{SUN, MON, TUE, WED, THU, FRI, SAT}

func printDOA() {
	for _, v := range DOW[startDOW:] {
		fmt.Print(v)
	}
	for _, v := range DOW[:startDOW] {
		fmt.Print(v)
	}
	fmt.Println()
}

func countBeginningPad(firstDOA int) int {
	if firstDOA == startDOW {
		return 0
	} else if firstDOA > startDOW {
		return firstDOA - startDOW
	} else {
		return 7 - (startDOW - firstDOA)
	}
}

func countEndPad(count int, lastday int) int {
	if r := count % 7; r == 0 {
		return 0
	} else {
		return 7 - r
	}
}

func main() {
	n := time.Now()
	lastday := time.Date(n.Year(), n.Month()+1, 1, 0, 0, 0, 0, time.Local).AddDate(0, 0, -1).Day()
	firstDOA := int(time.Date(n.Year(), n.Month(), 1, 0, 0, 0, 0, time.Local).Weekday())

	var data []string
	count := 0

	m := countBeginningPad(firstDOA)
	for i := 0; i < m; i++ {
		data = append(data, PAD)
	}
	count += m

	for i := 1; i < lastday+1; i++ {
		data = append(data, fmt.Sprintf("%2d", i))
	}
	count += lastday

	m = countEndPad(count, lastday)
	for i := 0; i < m; i++ {
		data = append(data, PAD)
	}
	count += m

	// output
	fmt.Printf("Today: %s\n\n", time.Now().Format("2006/01/02"))
	printDOA()
	for i := 0; i < count/7; i++ {
		for j := 0; j < 7; j++ {
			fmt.Print(data[i*7+j])
		}
		fmt.Println()
	}

}
