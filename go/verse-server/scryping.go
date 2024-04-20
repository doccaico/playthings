package main

import (
	"github.com/gocolly/colly"
)

type Bible struct {
	Title_ja string
	Url_ja   string
	Title_en string
	Url_en   string
	Max_page int
}

var oldTestament = []Bible{
	{"創世記", "genesis", "Genesis", "GEN", 50},
	{"出エジプト記", "exodus", "Exodus", "EXOD", 40},
	{"レビ記", "leviticus", "Leviticus", "LEV", 27},
	{"民数記", "numbers", "Numbers", "NUM", 36},
	{"申命記", "deuteronomy", "Deuteronomy", "DEUT", 34},
	{"ヨシュア記", "joshua", "Joshua", "JOSH", 24},
	{"士師記", "judges", "Judges", "JUDG", 21},
	{"ルツ記", "ruth", "Ruth", "RUTH", 4},
	{"サムエル記 上", "1samuel", "1 Samuel", "1SAM", 31},
	{"サムエル記 下", "2samuel", "2 Samuel", "2SAM", 24},
	{"列王紀 上", "1kings", "1 Kings", "1KGS", 22},
	{"列王紀 下", "2kings", "2 Kings", "2KGS", 25},
	{"歴代志 上", "1chronicles", "1 Chronicles", "1CHRON", 29},
	{"歴代志 下", "2chronicles", "2 Chronicles", "2CHRON", 36},
	{"エズラ記", "ezra", "Ezra", "EZRA", 10},
	{"ネヘミヤ書", "nehemiah", "Nehemiah", "NEH", 13},
	{"エステル記", "esther", "Esther", "ESTH", 10},
	{"ヨブ記", "job", "Job", "JOB", 42},
	{"詩篇", "psalms", "Psalms", "PS", 150},
	{"箴言", "proverbs", "Proverbs", "PROV", 31},
	{"伝道の書", "ecclesiastes", "Ecclesiastes", "ECC", 12},
	{"雅歌", "songofsongs", "Song of Songs", "SONG", 8},
	{"イザヤ書", "isaiah", "Isaiah", "ISA", 66},
	{"エレミヤ書", "jeremiah", "Jeremiah", "JER", 52},
	{"哀歌", "lamentations", "Lamentations", "LAM", 5},
	{"エゼキエル書", "ezekiel", "Ezekiel", "EZEK", 48},
	{"ダニエル書", "daniel", "Daniel", "DAN", 12},
	{"ホセア書", "hosea", "Hosea", "HOSEA", 14},
	{"ヨエル書", "joel", "Joel", "JOEL", 3},
	{"アモス書", "amos", "Amos", "AMOS", 9},
	{"オバデヤ書", "obadiah", "Obadiah", "OBAD", 1},
	{"ヨナ書", "jonah", "Jonah", "JONAH", 4},
	{"ミカ書", "micah", "Micah", "MICAH", 7},
	{"ナホム書", "nahum", "Nahum", "NAHUM", 3},
	{"ハバクク書", "habakkuk", "Habakkuk", "HAB", 3},
	{"ゼパニヤ書", "zephaniah", "Zephaniah", "ZEPH", 3},
	{"ハガイ書", "haggai", "Haggai", "HAG", 2},
	{"ゼカリヤ書", "zecariah", "Zechariah", "ZECH", 14},
	{"マラキ書", "malachi", "Malachi", "MAL", 4},
}

var newTestament = []Bible{
	{"マタイによる福音書", "matthew", "Matthew", "MATT", 28},
	{"マルコによる福音書", "mark", "Mark", "MARK", 16},
	{"ルカによる福音書", "luke", "Luke", "LUKE", 24},
	{"ヨハネによる福音書", "john", "John", "JOHN", 21},
	{"使徒行伝", "acts", "Acts", "ACTS", 28},
	{"ローマ人への手紙", "romans", "Romans", "ROM", 16},
	{"コリント人への第一の手紙", "1corintians", "1 Corinthians", "1COR", 16},
	{"コリント人への第二の手紙", "2corintians", "2 Corinthians", "2COR", 13},
	{"ガラテヤ人への手紙", "galatians", "Galatians", "GAL", 6},
	{"エペソ人への手紙", "ephesians", "Ephesians", "EPH", 6},
	{"ピリピ人への手紙", "philippians", "Philippians", "PHIL", 4},
	{"コロサイ人への手紙", "colossians", "Colossians", "COL", 4},
	{"テサロニケ人への第一の手紙", "1thessalonians", "1 Thessalonians", "1THES", 5},
	{"テサロニケ人への第二の手紙", "2thessalonians", "2 Thessalonians", "2THES", 3},
	{"テモテヘの第一の手紙", "1timothy", "1 Timothy", "1TIM", 6},
	{"テモテヘの第二の手紙", "2timothy", "2 Timothy", "2TIM", 4},
	{"テトスヘの手紙", "titus", "Titus", "TIT", 3},
	{"ピレモンヘの手紙", "philemon", "Philemon", "PHILEM", 1},
	{"ヘブル人への手紙", "hebrews", "Hebrews", "HEB", 13},
	{"ヤコブの手紙", "james", "James", "JAS", 5},
	{"ペテロの第一の手紙", "1peter", "1 Peter", "1PET", 5},
	{"ペテロの第二の手紙", "2peter", "2 Peter", "2PET", 3},
	{"ヨハネの第一の手紙", "1john", "1 John", "1JOHN", 5},
	{"ヨハネの第二の手紙", "2john", "2 John", "2JOHN", 1},
	{"ヨハネの第三の手紙", "3john", "3 John", "3JOHN", 1},
	{"ユダの手紙", "jude", "Jude", "JUDE", 1},
	{"ヨハネの黙示録", "revelation", "Revelation", "REV", 22},
}

func getJaBody() string {

	c := colly.NewCollector()

	var result string

	c.OnHTML("div#"+target_chapter, func(e *colly.HTMLElement) {
		// Remove <h3 class="chapter">第19章</h3>
		dom := e.DOM.Find("h3").Remove().End()

		res, err := dom.Html()
		if err != nil {
			panic(err)
		}
		result = res
	})

	// http://bible.salterrae.net/kougo/html/{url}.html
	c.Visit(target_url_ja)

	return result
}

func getEnBody() string {
	c := colly.NewCollector()

	var result string

	c.OnHTML("body", func(e *colly.HTMLElement) {
		// Remove <b>Proverbs 6</b>
		dom := e.DOM.Find("b").Remove().End()

		res, err := dom.Html()
		if err != nil {
			panic(err)
		}
		result = res
	})

	// https://web.mit.edu/jywang/www/cef/Bible/NIV/NIV_Bible/bookindex.html
	c.Visit(target_url_en)

	return result
}
