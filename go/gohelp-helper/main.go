package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/gocolly/colly"
)

func help() {
	fmt.Println(
		`$ go run . [-s, -d]
    -s output std
    -d output detail`)
}

func printStd() {
	c := colly.NewCollector()

	c.OnHTML("td > div > div > a[href]", func(e *colly.HTMLElement) {

		i := strings.Index(e.Attr("href"), "@")

		url := ""
		if i > -1 {
			url = e.Attr("href")[1:i]
		}
		fmt.Println(url)
	})

	c.OnHTML("td > div > span > a[href]", func(e *colly.HTMLElement) {

		i := strings.Index(e.Attr("href"), "@")

		url := ""
		if i > -1 {
			url = e.Attr("href")[1:i]
		}
		fmt.Println(url)
	})

	c.Visit("https://pkg.go.dev/std")
}

func printDetail(url string) {
	c := colly.NewCollector()

	texts := map[string]string{}

	c.OnHTML("section.Documentation-index ul li a[href]", func(e *colly.HTMLElement) {
		text := strings.TrimSpace(e.Text)

		if !strings.Contains(text, "\n") {
			if text != "Constants" && text != "Variables" {
				// 重複を消す
				texts[text] = e.Attr("href")
			}
		}
	})

	c.Visit(url)

	for k, v := range texts {
		fmt.Println(k, v)
	}
}

func main() {
	if len(os.Args) < 2 {
		help()
		os.Exit(0)
	}

	if os.Args[1] == "-s" {
		printStd()
	} else if os.Args[1] == "-d" && len(os.Args) == 3 {
		printDetail(os.Args[2])
	} else if os.Args[1] == "-h" && os.Args[1] == "--help" {
		help()
	}
}
