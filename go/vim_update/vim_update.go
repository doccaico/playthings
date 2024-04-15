package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

type Latest struct {
	Url string `json:"url"`
}

type EXEObject struct {
	Assets []struct {
		Name                 string `json:"name"`
		Browser_download_url string `json:"browser_download_url"`
	} `json:"assets"`
}

func getLatestURL(url string) (string, error) {

	fmt.Printf("[Access] %s\n", url)

	resp, err := http.Get(url)
	if err != nil {
		s := fmt.Errorf("http.Get %q is return error: %w", url, err)
		return "", s
	}
	if resp.StatusCode != http.StatusOK {
		s := fmt.Errorf("http.Get %q is return Not Found", url)
		return "", s
	}
	defer resp.Body.Close()

	var l Latest

	if err := json.NewDecoder(resp.Body).Decode(&l); err != nil {
		s := fmt.Errorf("json.NewDecoder is return error: %w", err)
		return "", s
	}

	return l.Url, nil
}

func getEXEObject(url string) (EXEObject, error) {

	fmt.Printf("[Access] %s\n", url)

	resp, err := http.Get(url)
	if err != nil {
		s := fmt.Errorf("http.Get %q is return error: %w", url, err)
		return EXEObject{}, s
	}
	if resp.StatusCode != http.StatusOK {
		s := fmt.Errorf("http.Get %q is return Not Found", url)
		return EXEObject{}, s
	}
	defer resp.Body.Close()

	var eo EXEObject

	if err := json.NewDecoder(resp.Body).Decode(&eo); err != nil {
		s := fmt.Errorf("json.NewDecoder is return error: %w", err)
		return EXEObject{}, s
	}

	return eo, nil

}

func downloadFile(f string, url string) error {

	fmt.Printf("[Download] starts ... %q\n", f)

	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	out, err := os.Create(f)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, resp.Body)
	return err
}

func main() {

	latest_url, err := getLatestURL("https://api.github.com/repos/vim/vim-win32-installer/releases/latest")
	if err != nil {
		log.Fatal(err)
	}

	eo, err := getEXEObject(latest_url)
	if err != nil {
		log.Fatal(err)
	}

	var f string
	var u string
	for _, asset := range eo.Assets {
		if strings.HasSuffix(asset.Name, "_x64.exe") {
			f = asset.Name
			u = asset.Browser_download_url
			break
		}
	}

	userprofile := os.Getenv("USERPROFILE")
	abs_path := filepath.Join(userprofile, "Downloads", f)

	err = downloadFile(abs_path, u)
	if err != nil {
		s := fmt.Errorf("downloadFile is return error: %w", err)
		log.Fatal(s)
	}

	dl_dir := filepath.Join(userprofile, "Downloads")
	fmt.Printf("[Open] explorer.exe ... %q\n", dl_dir)
	cmd := exec.Command("explorer.exe", dl_dir)
	cmd.Run()

}
