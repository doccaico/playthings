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
	screen    tcell.Screen
	url       string
	message   []string
	number    []string
	pages     []string
}

func newApp(id string) *App {

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

	c := colly.NewCollector()
	c.AllowURLRevisit = true

	return &App{
		collector: c,
		screen:    s,
		url:       fmt.Sprintf("https://b.2ch2.net/test/read.cgi/zatsudan/%s/-", id),
	}
}

func (a *App) display() {

	a.screen.Clear()

	for i, e := range a.message[:20] {
		m := fmt.Sprintf("・[%04s] %s\n", a.number[i], strings.TrimSpace(e))
		emitStr(a.screen, 0, i, tcell.StyleDefault, m)

	}

	// emitStr(a.screen, 0, 22, tcell.StyleDefault, fmt.Sprintf("pages len = %d\n", len(a.pages)))
	// emitStr(a.screen, 0, 23, tcell.StyleDefault, fmt.Sprintf("pages = %v\n", a.pages))
	// emitStr(a.screen, 0, 24, tcell.StyleDefault, fmt.Sprintf("prev = %d\n", a.prev))
	// emitStr(a.screen, 0, 25, tcell.StyleDefault, fmt.Sprintf("next = %d\n", a.next))
	// emitStr(a.screen, 0, 26, tcell.StyleDefault, fmt.Sprintf("app.pages[app.next] = %s\n", a.pages[a.next]))
	// emitStr(a.screen, 0, 27, tcell.StyleDefault, fmt.Sprintf("message = %v\n", a.message))

	a.screen.Show()
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

	a.pages = append(a.pages, strconv.Itoa(prev))
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

	app := newApp(os.Args[1])

	app.scrape("9999")

	app.display()

	for {
		switch ev := app.screen.PollEvent().(type) {
		case *tcell.EventResize:
			app.screen.Sync()
			app.display()
		case *tcell.EventKey:
			if ev.Key() == tcell.KeyEscape {
				app.screen.Fini()
				os.Exit(0)
			}
			// prev
			if ev.Rune() == 'h' {
				i := len(app.pages) - 1
				app.scrape(app.pages[i])
				app.display()
			}
		}
	}
}
