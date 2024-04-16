package main

import (
	"flag"
	"fmt"
	"math/rand"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/gocolly/colly"
)

type Bible struct {
	title    string
	url      string
	max_page int
	chap     string
}

type model struct {
	cursor   int
	choices  []Bible
	selected map[int]struct{}
}

var (
	ot     = flag.Bool("o", false, "Old Testament")
	nt     = flag.Bool("n", false, "New Testament")
	random = flag.Bool("r", false, "Random")
)

var (
	target_url     = ""
	target_chapter = ""
	target_title   = ""
)

// 口語訳旧約聖書(1955年版)
var oldTestament = []Bible{
	{"創世記", "http://bible.salterrae.net/kougo/html/genesis.html", 50, ""},
	{"出エジプト記", "http://bible.salterrae.net/kougo/html/exodus.html", 40, ""},
	{"レビ記", "http://bible.salterrae.net/kougo/html/leviticus.html", 27, ""},
	{"民数記", "http://bible.salterrae.net/kougo/html/numbers.html", 36, ""},
	{"申命記", "http://bible.salterrae.net/kougo/html/deuteronomy.html", 34, ""},
	{"ヨシュア記", "http://bible.salterrae.net/kougo/html/joshua.html", 24, ""},
	{"士師記", "http://bible.salterrae.net/kougo/html/judges.html", 21, ""},
	{"ルツ記", "http://bible.salterrae.net/kougo/html/ruth.html", 4, ""},
	{"サムエル記 上", "http://bible.salterrae.net/kougo/html/1samuel.html", 31, ""},
	{"サムエル記 下", "http://bible.salterrae.net/kougo/html/2samuel.html", 24, ""},
	{"列王紀 上", "http://bible.salterrae.net/kougo/html/1kings.html", 22, ""},
	{"列王紀 下", "http://bible.salterrae.net/kougo/html/2kings.html", 25, ""},
	{"歴代志 上", "http://bible.salterrae.net/kougo/html/1chronicles.html", 29, ""},
	{"歴代志 下", "http://bible.salterrae.net/kougo/html/2chronicles.html", 36, ""},
	{"エズラ記", "http://bible.salterrae.net/kougo/html/ezra.html", 10, ""},
	{"ネヘミヤ書", "http://bible.salterrae.net/kougo/html/nehemiah.html", 13, ""},
	{"エステル記", "http://bible.salterrae.net/kougo/html/esther.html", 10, ""},
	{"ヨブ記", "http://bible.salterrae.net/kougo/html/job.html", 42, ""},
	{"詩篇", "http://bible.salterrae.net/kougo/html/psalms.html", 150, ""},
	{"箴言", "http://bible.salterrae.net/kougo/html/proverbs.html", 31, ""},
	{"伝道の書", "http://bible.salterrae.net/kougo/html/ecclesiastes.html", 12, ""},
	{"雅歌", "http://bible.salterrae.net/kougo/html/songofsongs.html", 8, ""},
	{"イザヤ書", "http://bible.salterrae.net/kougo/html/isaiah.html", 66, ""},
	{"エレミヤ書", "http://bible.salterrae.net/kougo/html/jeremiah.html", 52, ""},
	{"哀歌", "http://bible.salterrae.net/kougo/html/lamentations.html", 5, ""},
	{"エゼキエル書", "http://bible.salterrae.net/kougo/html/ezekiel.html", 48, ""},
	{"ダニエル書", "http://bible.salterrae.net/kougo/html/daniel.html", 12, ""},
	{"ホセア書", "http://bible.salterrae.net/kougo/html/hosea.html", 14, ""},
	{"ヨエル書", "http://bible.salterrae.net/kougo/html/joel.html", 3, ""},
	{"アモス書", "http://bible.salterrae.net/kougo/html/amos.html", 9, ""},
	{"オバデヤ書", "http://bible.salterrae.net/kougo/html/obadiah.html", 1, ""},
	{"ヨナ書", "http://bible.salterrae.net/kougo/html/jonah.html", 4, ""},
	{"ミカ書", "http://bible.salterrae.net/kougo/html/micah.html", 7, ""},
	{"ナホム書", "http://bible.salterrae.net/kougo/html/nahum.html", 3, ""},
	{"ハバクク書", "http://bible.salterrae.net/kougo/html/habakkuk.html", 3, ""},
	{"ゼパニヤ書", "http://bible.salterrae.net/kougo/html/zephaniah.html", 3, ""},
	{"ハガイ書", "http://bible.salterrae.net/kougo/html/haggai.html", 2, ""},
	{"ゼカリヤ書", "http://bible.salterrae.net/kougo/html/zecariah.html", 14, ""},
	{"マラキ書", "http://bible.salterrae.net/kougo/html/malachi.html", 4, ""},
}

// 口語訳新約聖書(1954年版)
var newTestament = []Bible{
	{"マタイによる福音書", "http://bible.salterrae.net/kougo/html/matthew.html", 28, ""},
	{"マルコによる福音書", "http://bible.salterrae.net/kougo/html/mark.html", 16, ""},
	{"ルカによる福音書", "http://bible.salterrae.net/kougo/html/luke.html", 24, ""},
	{"ヨハネによる福音書", "http://bible.salterrae.net/kougo/html/john.html", 21, ""},
	{"使徒行伝", "http://bible.salterrae.net/kougo/html/acts.html", 28, ""},
	{"ローマ人への手紙", "http://bible.salterrae.net/kougo/html/romans.html", 16, ""},
	{"コリント人への第一の手紙", "http://bible.salterrae.net/kougo/html/1corintians.html", 16, ""},
	{"コリント人への第二の手紙", "http://bible.salterrae.net/kougo/html/2corintians.html", 13, ""},
	{"ガラテヤ人への手紙", "http://bible.salterrae.net/kougo/html/galatians.html", 6, ""},
	{"エペソ人への手紙", "http://bible.salterrae.net/kougo/html/ephesians.html", 6, ""},
	{"ピリピ人への手紙", "http://bible.salterrae.net/kougo/html/philippians.html", 4, ""},
	{"コロサイ人への手紙", "http://bible.salterrae.net/kougo/html/colossians.html", 4, ""},
	{"テサロニケ人への第一の手紙", "http://bible.salterrae.net/kougo/html/1thessalonians.html", 5, ""},
	{"テサロニケ人への第二の手紙", "http://bible.salterrae.net/kougo/html/2thessalonians.html", 3, ""},
	{"テモテヘの第一の手紙", "http://bible.salterrae.net/kougo/html/1timothy.html", 6, ""},
	{"テモテヘの第二の手紙", "http://bible.salterrae.net/kougo/html/2timothy.html", 4, ""},
	{"テトスヘの手紙", "http://bible.salterrae.net/kougo/html/titus.html", 3, ""},
	{"ピレモンヘの手紙", "http://bible.salterrae.net/kougo/html/philemon.html", 1, ""},
	{"ヘブル人への手紙", "http://bible.salterrae.net/kougo/html/hebrews.html", 13, ""},
	{"ヤコブの手紙", "http://bible.salterrae.net/kougo/html/james.html", 5, ""},
	{"ペテロの第一の手紙", "http://bible.salterrae.net/kougo/html/1peter.html", 5, ""},
	{"ペテロの第二の手紙", "http://bible.salterrae.net/kougo/html/2peter.html", 3, ""},
	{"ヨハネの第一の手紙", "http://bible.salterrae.net/kougo/html/1john.html", 5, ""},
	{"ヨハネの第二の手紙", "http://bible.salterrae.net/kougo/html/2john.html", 1, ""},
	{"ヨハネの第三の手紙", "http://bible.salterrae.net/kougo/html/3john.html", 1, ""},
	{"ユダの手紙", "http://bible.salterrae.net/kougo/html/jude.html", 1, ""},
	{"ヨハネの黙示録", "http://bible.salterrae.net/kougo/html/revelation.html", 22, ""},
}

func initialModel() model {
	if *ot {
		return model{
			choices:  oldTestament,
			selected: make(map[int]struct{}),
		}
	}

	return model{
		choices:  newTestament,
		selected: make(map[int]struct{}),
	}
}

func (m model) Init() tea.Cmd {
	return tea.SetWindowTitle("Bible")
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "q":
			return m, tea.Quit
		case "up", "k":
			if m.cursor > 0 {
				m.cursor--
			}
		case "down", "j":
			if m.cursor < len(m.choices)-1 {
				m.cursor++
			}
		case "enter", " ":
			page, _ := strconv.Atoi(m.choices[m.cursor].chap)
			if 0 < page && page <= m.choices[m.cursor].max_page {
				target_url = m.choices[m.cursor].url
				target_chapter = strconv.Itoa(page)
				target_title = m.choices[m.cursor].title
				return m, tea.Quit
			}
		case "esc":
			m.choices[m.cursor].chap = ""
		case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
			if len(m.choices[m.cursor].chap) == 3 {
				m.choices[m.cursor].chap = msg.String()
			} else {
				m.choices[m.cursor].chap += msg.String()
			}
		}
	}

	return m, nil
}

func (m model) View() string {
	s := "Which one would you like to read?\n\n"

	for i, choice := range m.choices {
		cursor := " "
		if m.cursor == i {
			cursor = ">"
		}

		s += fmt.Sprintf("%s %s (%03s/%03d)\n", cursor, choice.title, choice.chap, choice.max_page)
	}

	s += "\nPress 'q' or 'ctrl+c' to quit.\n"

	return s
}

func setRandomValue() {
	seed := time.Now().UnixNano()
	r := rand.New(rand.NewSource(seed))

	var p *[]Bible
	m := 0
	if *ot {
		p = &oldTestament
		m = len(oldTestament)
	} else {
		p = &newTestament
		m = len(newTestament)
	}

	i := r.Intn(m)
	target_url = (*p)[i].url

	target_title = (*p)[i].title

	i = r.Intn((*p)[i].max_page-1) + 1
	target_chapter = strconv.Itoa(i)
}

func main() {
	flag.Parse()

	if !*ot && !*nt {
		fmt.Println("Usage: verse.exe -o/-n [-r]")
		os.Exit(0)
	}

	if *random {
		setRandomValue()
	} else {
		p := tea.NewProgram(initialModel())
		if _, err := p.Run(); err != nil {
			fmt.Printf("Alas, there's been an error: %v", err)
			os.Exit(1)
		}
	}

	// replace
	pattern := `(\d{1,3}):(\d{1,3})`

	re, err := regexp.Compile(pattern)
	if err != nil {
		fmt.Println("Error compiling regex:", err)
		return
	}

	// crawl
	c := colly.NewCollector()

	var res string
	c.OnHTML("div#"+target_chapter, func(e *colly.HTMLElement) {
		res = re.ReplaceAllString(e.Text, "[$1:$2] ")
		res = strings.Replace(res, "\n[", "[", -1)
	})

	c.Visit(target_url)

	// output
	fmt.Print(res)
	fmt.Printf("%s %s(%s)\n", target_url, target_title, target_chapter)
}
