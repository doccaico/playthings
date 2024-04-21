package main

import (
	"fmt"
	"math/rand/v2"
	"net/http"
	"os/exec"
	"strconv"
	"text/template"
)

var (
	target_title_ja = ""
	target_title_en = ""
	target_url_ja   = ""
	target_url_en   = ""
	target_chapter  = ""
	target_max_page = 0
)

type Value struct {
	Title   string
	Chapter []int
}

type Index struct {
	Ot []Value
	Nt []Value
}

type Page struct {
	Title      string
	TitleJa    string
	TitleEn    string
	Chapter    string
	MaxChapter int
	BodyJa     string
	BodyEn     string
	UrlJa      string
	UrlEn      string
}

func setRandomValue() {

	var bible *[]Bible

	if rand.N(2) == 0 {
		bible = &oldTestament
	} else {
		bible = &newTestament
	}

	// 0 <= r && r < len(bible)
	i := rand.N(len(*bible))

	min_val := 1
	max_val := (*bible)[i].Max_page

	// min_val <= r && r <= max_val
	target_chapter = strconv.Itoa(rand.N(max_val-min_val+1) + min_val)

	target_url_ja = fmt.Sprintf("http://bible.salterrae.net/kougo/html/%s.html", (*bible)[i].Url_ja)
	target_url_en = fmt.Sprintf("https://web.mit.edu/jywang/www/cef/Bible/NIV/NIV_Bible/%s+%s.html", (*bible)[i].Url_en, target_chapter)
	target_title_ja = (*bible)[i].Title_ja
	target_title_en = (*bible)[i].Title_en
	target_max_page = max_val
}

func setPagesValue(r *http.Request) {

	var bible *[]Bible

	if r.FormValue("version") == "ot" {
		bible = &oldTestament
	} else {
		bible = &newTestament
	}

	p, _ := strconv.Atoi(r.FormValue("page"))

	target_title_ja = (*bible)[p].Title_ja
	target_title_en = (*bible)[p].Title_en
	target_url_ja = fmt.Sprintf("http://bible.salterrae.net/kougo/html/%s.html", (*bible)[p].Url_ja)
	target_url_en = fmt.Sprintf("https://web.mit.edu/jywang/www/cef/Bible/NIV/NIV_Bible/%s+%s.html", (*bible)[p].Url_en, r.FormValue("chapter"))
	target_chapter = r.FormValue("chapter")
	target_max_page = (*bible)[p].Max_page

}

func handlerRandom(w http.ResponseWriter, r *http.Request) {

	setRandomValue()

	jaBody := getJaBody()
	enBody := getEnBody()

	page := Page{
		"Bible", target_title_ja, target_title_en, target_chapter, target_max_page,
		jaBody, enBody, target_url_ja, target_url_en}

	tmpl, err := template.ParseFiles("web/random.html")
	if err != nil {
		panic(err)
	}

	err = tmpl.Execute(w, page)
	if err != nil {
		panic(err)
	}
}

func handlerIndex(w http.ResponseWriter, r *http.Request) {

	index := Index{}

	ot := make([]Value, len(oldTestament))
	for i, v := range oldTestament {
		ot[i].Title = v.Title_ja
		ot[i].Chapter = make([]int, v.Max_page)
		for j := range v.Max_page {
			ot[i].Chapter[j] = j + 1
		}
	}
	index.Ot = ot

	nt := make([]Value, len(newTestament))
	for i, v := range newTestament {
		nt[i].Title = v.Title_ja
		nt[i].Chapter = make([]int, v.Max_page)
		for j := range v.Max_page {
			nt[i].Chapter[j] = j + 1
		}
	}
	index.Nt = nt

	tmpl, err := template.ParseFiles("web/index.html")
	if err != nil {
		panic(err)
	}

	err = tmpl.Execute(w, index)
	if err != nil {
		panic(err)
	}
}

func handlerPages(w http.ResponseWriter, r *http.Request) {

	setPagesValue(r)

	jaBody := getJaBody()
	enBody := getEnBody()

	page := Page{
		"Bible", target_title_ja, target_title_en, target_chapter, target_max_page,
		jaBody, enBody, target_url_ja, target_url_en}

	tmpl, err := template.ParseFiles("web/page.html")
	if err != nil {
		panic(err)
	}

	err = tmpl.Execute(w, page)
	if err != nil {
		panic(err)
	}
}

func handlerICon(w http.ResponseWriter, r *http.Request) {}

func main() {

	http.Handle("/web/", http.StripPrefix("/web/", http.FileServer(http.Dir("web/"))))
	http.HandleFunc("/favicon.ico", handlerICon)
	http.HandleFunc("/", handlerIndex)
	http.HandleFunc("/pages/", handlerPages)
	http.HandleFunc("/random/", handlerRandom)

	// https://gist.github.com/sevkin/9798d67b2cb9d07cb05f89f14ba682f8
	cmd := exec.Command("cmd", "/c", "start", "http://localhost:8080/")
	if err := cmd.Run(); err != nil {
		fmt.Println("Error: ", err)
	}

	http.ListenAndServe(":8080", nil)
}
