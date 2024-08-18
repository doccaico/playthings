package main

import (
	"fmt"
	"io"
	"os"
	"text/template"

	"github.com/russross/blackfriday/v2"
)

const (
	MD_TEMPLATE = "mymd.tmpl.html"
)

func readFile(filepath string) ([]byte, error) {
	f, err := os.Open(filepath)
	if err != nil {
		return []byte{}, fmt.Errorf("Error: cannot open file %q", filepath)
	}
	defer f.Close()

	data, err := io.ReadAll(f)
	if err != nil {
		return []byte{}, fmt.Errorf("Error: cannot read file %q", filepath)
	}
	return data, nil
}

func main() {

	if 2 != len(os.Args) {
		panic("Usage: mymd hoge.md")
	}

	// read 'hoge.md'
	md, err := readFile(os.Args[1])
	if err != nil {
		panic(err)
	}
	// convert md to html
	md_output := blackfriday.Run(md, blackfriday.WithNoExtensions())

	// read 'mymd.tmpl.html'
	tmpl, err := readFile(MD_TEMPLATE)
	if err != nil {
		panic(err)
	}

	// template
	t, err := template.New("template").Parse(string(tmpl))
	if err != nil {
		panic(err)
	}
	if err := t.Execute(os.Stdout, string(md_output)); err != nil {
		panic(err)
	}
}
