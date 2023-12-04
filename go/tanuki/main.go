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
Usage:

  $ tanuki 0123456789
`

type App struct {
	collector *colly.Collector
	screen    tcell.Screen
	url       string
	message   []string
	number    []string
	current   int
	prev      int
	next      int
	stopper   int
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

	n := 0
	if a.current < 20 {
		n = a.current
	} else if a.stopper < 20 {
		n = a.stopper
	} else {
		n = 20
	}

	for i, e := range a.message[:n] {
		m := fmt.Sprintf("・[%04s] %s\n", a.number[i], strings.TrimSpace(e))
		emitStr(a.screen, 0, i, tcell.StyleDefault, m)
	}

	emitStr(a.screen, 0, 23, tcell.StyleDefault, fmt.Sprintf("URL:     %s%d\n", a.url, a.current))
	emitStr(a.screen, 0, 24, tcell.StyleDefault, fmt.Sprintf("Prev(h): %s%d\n", a.url, a.prev))
	emitStr(a.screen, 0, 25, tcell.StyleDefault, fmt.Sprintf("Next(l): %s%d\n", a.url, a.next))
	// emitStr(a.screen, 0, 26, tcell.StyleDefault, fmt.Sprintf("stopper: %d\n", a.stopper))

	a.screen.Show()
}

func (a *App) scrape(page int) {

	a.message = nil
	a.number = nil

	a.collector.OnHTML("div.mess", func(e *colly.HTMLElement) {
		a.message = append(a.message, e.Text)
	})

	a.collector.OnHTML("div.res", func(e *colly.HTMLElement) {
		n := e.Attr("n")
		a.number = append(a.number, n)
	})

	a.collector.Visit(a.url + strconv.Itoa(page))

	a.setCurrent(page)
	a.setPrev()
	a.setNext()
}

func (a *App) setCurrent(p int) {
	if p == 9999 {
		n, err := strconv.Atoi(a.number[len(a.number)-1])
		if err != nil {
			fmt.Fprintf(os.Stderr, "cannot convert %q\n", a.number[0])
			os.Exit(1)
		}
		a.stopper = n
	}
	if p != a.stopper {
		a.current = p
	} else {
		a.current = 9999
	}
}

func (a *App) setPrev() {
	if a.current == 9999 && a.stopper < 20 {
		a.prev = 9999
		return
	}

	if a.current > 20 {

		n, err := strconv.Atoi(a.number[0])
		if err != nil {
			fmt.Fprintf(os.Stderr, "cannot convert %q\n", a.number[0])
			os.Exit(1)
		}

		a.prev = n - 1
	}
}

func (a *App) setNext() {
	if a.current == 9999 {
		a.next = a.current
	} else {
		a.next = a.current + 20
	}
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

	if len(os.Args) == 1 {
		fmt.Fprintf(os.Stderr, "%s\n", USAGE)
		os.Exit(1)
	}

	app := newApp(os.Args[1])

	app.scrape(9999)

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
			switch ev.Rune() {
			// prev page
			case 'h':
				app.scrape(app.prev)
				app.display()
			// next page
			case 'l':
				app.scrape(app.next)
				app.display()
			}
		}
	}
}
