package main

import (
	"fmt"
	"math/rand"
	"os"
	"os/exec"
	"strings"
	"time"
)

const (
	width        int     = 20
	height       int     = 20
	initial_rand float64 = 0.35 // 0 - 1
)

var board [width * height]int
var displayClear []string

func initCommand() {
	displayClear = strings.Split(CommandClear, " ")
}

func clear() {
	prg := exec.Command(displayClear[0], displayClear[1:]...)
	prg.Stdout = os.Stdout
	prg.Run()
}

func suffle() {

	rand.Seed(time.Now().UnixNano())
	rand.Shuffle(len(board), func(i, j int) { board[i], board[j] = board[j], board[i] })

	for i := 0; i < (width * height); i++ {

		if i < int(float64(width*height)*initial_rand) {
			board[i] = 1
		}
	}
	rand.Shuffle(len(board), func(i, j int) { board[i], board[j] = board[j], board[i] })
}

func displayOutput() {
	for h := 0; h < height; h++ {
		for w := 0; w < width; w++ {
			if board[width*h+w] == 1 {
				fmt.Print("*")
			} else {
				fmt.Print(".")
			}

			if w == (width - 1) {
				fmt.Println()
			}
		}
	}
}

func nextGeneraton() {
	var alive_neighbours [width * height]int

	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			c := [8]int{
				getState(x-1, y-1), getState(x, y-1), getState(x+1, y-1),
				getState(x-1, y), getState(x+1, y),
				getState(x-1, y+1), getState(x, y+1), getState(x+1, y+1)}
			total := 0
			for i := 0; i < 8; i++ {
				if c[i] == 1 {
					total += 1
				}
			}
			alive_neighbours[x+y*width] = total
		}
	}

	for i := 0; i < height*width; i++ {

		switch alive_neighbours[i] {
		case 2:
			// Do nothing.
		case 3:
			board[i] = 1
		default:
			board[i] = 0
		}

	}
}

func getState(x, y int) int {
	if x < 0 || y < 0 || x >= width || y >= height {
		return -1
	}
	return board[x+y*width]
}

func main() {

	initCommand()
	suffle()

	for {
		clear()
		nextGeneraton()
		displayOutput()
		time.Sleep(time.Millisecond * 500)
	}
}
