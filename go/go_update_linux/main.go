package main

import (
	"bytes"
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
	Version string `json:"version"`
	Stable  bool   `json:"stable"`
	Files   []struct {
		Filename string `json:"filename"`
		Os       string `json:"os"`
		Arch     string `json:"arch"`
		Kind     string `json:"kind"`
	} `json:"files"`
}

func getLatestBaseURL(url string) (string, error) {

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

	var l []Latest

	if err := json.NewDecoder(resp.Body).Decode(&l); err != nil {
		s := fmt.Errorf("json.NewDecoder is return error: %w", err)
		return "", s
	}

	var res string
	for _, f := range l[0].Files {
		if f.Os == "linux" && f.Arch == "amd64" && f.Kind == "archive" {
			res = f.Filename
		}
	}
	// go1.22.2.linux-amd64.tar.gz
	return res, nil

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

func isExist(exe string) string {
	path, err := exec.LookPath(exe)
	if err != nil {
		return ""
	}
	return path
}

func getCurrentVersion(path string) (string, error) {

	var buffer bytes.Buffer

	cmd := exec.Command(path, "version")
	cmd.Stdout = &buffer
	if err := cmd.Run(); err != nil {
		return "", err
	}

	v := buffer.String()

	res := strings.Replace(v, "go version", "", -1)
	res = strings.Replace(res, "linux/amd64", "", -1)
	res = strings.TrimSpace(res)
	return res, nil
}

func getNewVersion(path string) string {
	// get: "go1.22.2linux-amd64.tar.gz"
	// return: "go1.22.2"
	return strings.Replace(path, ".linux-amd64.tar.gz", "", -1)
}

func main() {

	path := isExist("go")

	var current_version string
	if path != "" {
		cv, err := getCurrentVersion(path)
		if err != nil {
			log.Fatal(err)
		}
		current_version = cv
	}

	latest_url_base, err := getLatestBaseURL("https://go.dev/dl/?mode=json")
	if err != nil {
		log.Fatal(err)
	}
	latest_url := fmt.Sprintf("https://go.dev/dl/%s", latest_url_base)

	new_version := getNewVersion(latest_url_base)
	if current_version == new_version {
		fmt.Println("Already latest Go:", current_version)
		os.Exit(0)
	}

	userprofile := os.Getenv("HOME")
	abs_path := filepath.Join(userprofile, "Downloads", latest_url_base)

	err = downloadFile(abs_path, latest_url)
	if err != nil {
		s := fmt.Errorf("downloadFile is return error: %w", err)
		log.Fatal(s)
	}

	output_dir := filepath.Join(userprofile, "Downloads")

	fmt.Println("[Extraction] ...")
	fmt.Println(output_dir)
	cmd := exec.Command("tar", "-zxvf", abs_path, "-C", output_dir)
	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}

	source := filepath.Join(userprofile, "Downloads", "go")
	dest := filepath.Join(userprofile, "Languages", "go")

	// c:\go が存在すれば、削除する
	if _, err := os.Stat(dest); !os.IsNotExist(err) {
		fmt.Printf("[Delete] %q\n", dest)
		os.RemoveAll(dest)
	}

	fmt.Printf("[Move] %q to %q\n", source, dest)
	err = os.Rename(source, dest)
	if err != nil {
		log.Fatal(err)
	}

}
