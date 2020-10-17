package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

const (
	winpatterns_x = 8
	winpatterns_y = 3
	board_x       = 9
	board_fmt     = `
|-----|-----|-----|
|%3s  |%3s  |%3s  |
|-----|-----|-----|
|%3s  |%3s  |%3s  |
|-----|-----|-----|
|%3s  |%3s  |%3s  |
|-----|-----|-----|

`
)

var (
	board       [board_x]string
	winpatterns [winpatterns_x][winpatterns_y]int
)

func initialize() {
	winpatterns[0] = [winpatterns_y]int{0, 1, 2}
	winpatterns[1] = [winpatterns_y]int{3, 4, 5}
	winpatterns[2] = [winpatterns_y]int{6, 7, 8}
	winpatterns[3] = [winpatterns_y]int{0, 3, 6}
	winpatterns[4] = [winpatterns_y]int{1, 4, 7}
	winpatterns[5] = [winpatterns_y]int{2, 5, 8}
	winpatterns[6] = [winpatterns_y]int{0, 4, 8}
	winpatterns[7] = [winpatterns_y]int{2, 4, 6}
}

func displayBoard() {

	fmt.Printf(
		board_fmt,
		board[0], board[1], board[2],
		board[3], board[4], board[5],
		board[6], board[7], board[8])
}

func existsWinner() bool {
	for i := 0; i < winpatterns_x; i++ {
		a, b, c := winpatterns[i][0], winpatterns[i][1], winpatterns[i][2]
		if board[a] != "" && board[a] == board[b] && board[a] == board[c] {
			return true
		}
	}
	return false
}

func switchPlayer(player string) string {
	if player == "X" {
		return "O"
	} else {
		return "X"
	}
}

func scanNumber(player string) int {

	var line string
	stdin := bufio.NewReader(os.Stdin)

	for {

		fmt.Fscanln(stdin, &line)

		if len(line) != 1 {
			fmt.Printf("Failed: \"%s\" is wrong.\n", line)
			fmt.Printf("[%s's turn] Enter a number (0..8): ", player)
			continue
		}

		if n, err := strconv.Atoi(line); err != nil || n < 0 || 8 < n {
			fmt.Printf("Failed: \"%s\" is wrong.\n", line)
			fmt.Printf("[%s's turn] Enter a number (0..8): ", player)
			continue
		} else {
			return n
		}
	}
}

func selectPlayer() string {

	var line string

	stdin := bufio.NewReader(os.Stdin)

	for {

		fmt.Println("Choose the first player (X or O): ")

		fmt.Fscanln(stdin, &line)

		if line != "X" && "O" != line {
			continue
		} else {
			return line
		}
	}
}

func main() {

	initialize()

	fmt.Println("Thank you for playing this game.")

	player := selectPlayer()

	for {

		displayBoard()

		fmt.Printf("[%s's turn] Enter a number (0..8): ", player)

		pos := scanNumber(player)

		if board[pos] != "" {
			fmt.Printf("It is already placed: %d\n", pos)
			fmt.Printf("[%s] enter a number (0..8): ", player)
			continue
		}

		board[pos] = player

		if existsWinner() {
			displayBoard()
			fmt.Printf("Congratulations, %s won.\nBye.\n", player)
			break
		}
		player = switchPlayer(player)
	}
}
