package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/gdamore/tcell/encoding"
	"github.com/gdamore/tcell/v2"

	"github.com/gocolly/colly/v2"
	"github.com/mattn/go-runewidth"
)

const USAGE = `
  (例) $ tanuki 1467456
`

type App struct {
	collector *colly.Collector
	url       string
	message   []string
	number    []string
	pages     []string
}

func newApp(id string) *App {
	return &App{
		collector: colly.NewCollector(),
		url:       fmt.Sprintf("https://b.2ch2.net/test/read.cgi/zatsudan/%s/-", id),
	}
}

func (a *App) display(s tcell.Screen) {

	s.Clear()

	for i, e := range a.message[:20] {
		m := fmt.Sprintf("・[%04s] %s\n", a.number[i], strings.TrimSpace(e))
		emitStr(s, 0, i, tcell.StyleDefault, m)
	}

	// mm := fmt.Sprintf("len = %d\n", len(a.message))
	// emitStr(s, 0, 0, tcell.StyleDefault, mm)

	s.Show()
}

func (a *App) scrape(page string) {

	a.message = nil
	a.number = nil

	a.collector.OnHTML("div.mess", func(e *colly.HTMLElement) {
		a.message = append(a.message, e.Text)
	})

	a.collector.OnHTML("div.res", func(e *colly.HTMLElement) {
		n := e.Attr("n")
		a.number = append(a.number, n)
	})

	a.collector.Visit(a.url + page)

	prev, err := strconv.Atoi(a.number[0])
	if err != nil {
		fmt.Printf("%sを変換出来ませんでした\n", a.number[0])
	}

	prev--

	s := strconv.Itoa(prev)

	a.pages = append(a.pages, s)

}

func emitStr(s tcell.Screen, x, y int, style tcell.Style, str string) {
	for _, c := range str {
		var comb []rune
		w := runewidth.RuneWidth(c)
		if w == 0 {
			comb = []rune{c}
			c = ' '
			w = 1
		}
		s.SetContent(x, y, c, comb, style)
		x += w
	}
}

func main() {

	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "%s\n", USAGE)
		os.Exit(1)
	}

	id := os.Args[1]

	encoding.Register()

	s, e := tcell.NewScreen()
	if e != nil {
		fmt.Fprintf(os.Stderr, "%v\n", e)
		os.Exit(1)
	}
	if e := s.Init(); e != nil {
		fmt.Fprintf(os.Stderr, "%v\n", e)
		os.Exit(1)
	}

	defStyle := tcell.StyleDefault.
		Background(tcell.ColorBlack).
		Foreground(tcell.ColorWhite)
	s.SetStyle(defStyle)

	app := newApp(id)

	app.scrape("9999")

	app.display(s)

	for {
		switch ev := s.PollEvent().(type) {
		case *tcell.EventResize:
			s.Sync()
			app.display(s)
		case *tcell.EventKey:
			if ev.Key() == tcell.KeyEscape {
				s.Fini()
				os.Exit(0)
			}
			if ev.Rune() == 'j' {
				i := len(app.pages) - 1
				app.scrape(app.pages[i])
				app.display(s)
			}
		}
	}
}
