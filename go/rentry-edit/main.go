package main

import (
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"strings"
)

// *Referance*
// https://github.com/agamsol/rentry
// https://github.com/radude/rentry

const BASE_URL = "https://rentry.co"

type Response struct {
	Status  string `json:"status"`
	Content string `json:"content"`
}

func get_token() string {
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	client := &http.Client{Transport: tr}
	req, err := http.NewRequest("HEAD", BASE_URL, nil)
	if err != nil {
		panic(err)
	}
	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	// // サーバーがおかしい時は "403 Forbidden" が返ってくる
	// println(resp.Status)
	// // サーバーがおかしい時は "Set-Cookie" が無い
	// for k, v := range resp.Header {
	// 	fmt.Printf("%#v %#v\n", k, v)
	// }
	token := strings.Split(strings.Split(resp.Header["Set-Cookie"][0], "; ")[0], "=")[1]

	return token
}

func post_file(id string, edit_code string, file string, token string) []byte {

	text, err := ioutil.ReadFile(file)
	if err != nil {
		panic(err)
	}

	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	client := &http.Client{Transport: tr}
	var data = strings.NewReader(
		fmt.Sprintf("csrfmiddlewaretoken=%s&edit_code=%s&text=%s",
			token, edit_code, url.QueryEscape(string(text))))
	req, err := http.NewRequest("POST", "https://rentry.co/api/edit/"+id, data)
	if err != nil {
		panic(err)
	}

	req.Header.Set("Cookie", "csrftoken="+token)
	req.Header.Set("Referer", "https://rentry.co")
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	bodyText, err := io.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	return bodyText
}

func main() {

	if len(os.Args) != 4 {
		panic("Usage: rentry-edit xe2nf929 xxxx1234 file.txt")
	}

	id := os.Args[1]
	edit_code := os.Args[2]
	file := os.Args[3]

	token := get_token()

	res := post_file(id, edit_code, file, token)

	var res_json Response
	if err := json.Unmarshal(res, &res_json); err != nil {
		panic(err)
	}

	if res_json.Status != "200" {
		panic(fmt.Sprintf(`status: wants "200", but got "%s"`, res_json.Status))
	}

	if res_json.Content != "OK" {
		panic(fmt.Sprintf(`content: wants "OK", but got "%s"`, res_json.Content))
	}

	fmt.Printf("Successfully edited the %s/%s", BASE_URL, id)

}
