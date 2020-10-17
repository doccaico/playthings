#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <unistd.h>
#include <ncurses.h>

int board[][4] = {
  {0, 0, 0, 0},
  {0, 0, 0, 0},
  {0, 0, 0, 0},
  {0, 0, 0, 0},
};

bool running = true;
bool win = false;
bool moved = false;

void print_board(void) {
  mvaddstr(11, 20, "-----------------------------");
  mvaddstr(12, 20, "|      |      |      |      |");
  mvaddstr(13, 20, "|---------------------------|");
  mvaddstr(14, 20, "|      |      |      |      |");
  mvaddstr(15, 20, "|---------------------------|");
  mvaddstr(16, 20, "|      |      |      |      |");
  mvaddstr(17, 20, "|---------------------------|");
  mvaddstr(18, 20, "|      |      |      |      |");
  mvaddstr(19, 20, "-----------------------------");

  char buf[4 + 1];

  for (int y = 0; y < 4; y++) {
    for (int x = 0; x < 4; x++) {
      if (board[y][x] != 0) {
        sprintf(buf, "%4d", board[y][x]);
        mvaddstr(12 + y * 2, 22 + x * 7, buf);
      }
    }
  }
  refresh();
}

bool is_Zero(int n) {
  return board[n / 4][n % 4] == 0;
}

int search_forward(int n) {
  if (n == 15) {
    return -1;
  }
  for (int i = 1; n + i <= 15; i++) {
    if (is_Zero(n + i)) {
      return n + i;
    }
  }
  return -1;
}

int search_backward(int n) {
  if (n == 0) {
    return -1;
  }
  for (int i = 1; n - i >= 0; i++) {
    if (is_Zero(n - i)) {
      return n - i;
    }
  }
  return -1;
}

int get_random_pos(void) {
  int r = rand() % 16;
  int ret;

  if (is_Zero(r)) {
    return r;
  }
  ret = search_forward(r);
  if (ret != -1) {
    return ret;
  }
  ret = search_backward(r);
  if (ret != -1) {
    return ret;
  }
  running = false;
  win = false;
}

int two_or_four(void) {
  return (rand() % 2) ? 2 : 4;
}

void rotate() {
  int i, j, n = 4;
  int tmp;

  for (i = 0; i < n / 2; i++) {
    for (j = i; j < n - i - 1; j++) {
      tmp = board[i][j];
      board[i][j] = board[j][n - i - 1];
      board[j][n - i - 1] = board[n - i - 1][n - j - 1];
      board[n - i - 1][n - j - 1] = board[n - j - 1][i];
      board[n - j - 1][i] = tmp;
    }
  }
}

int find_next_index(int n) {
  for (int i = n; i < 4; i++) {
    if (board[n] != 0) {
      return i;
    }
  }
  return 0;
}

int find_nonzero_number(int b[4], int i) {
  for (; i < 4; i++) {
    if (b[i] != 0) {
      return i;
    }
  }
  return -1;
}

int find_number(int b[4], int i, int n) {
  for (; i < 4; i++) {
    if (b[i] == n) {
      return i;
    } else if (b[i] != 0) {
      return -1;
    }
  }
  return -1;
}

void slide(int b[4]) {
  int found; // index

  for (int i = 0; i < 3; i++) {
    // print();
    if (b[i] == 0) {
      found = find_nonzero_number(b, i + 1);
      // printf(" nonzero found = %d\n", found);
      if (found != -1) {
        // 0のマスに0以外の数値を移動して移動元を0にする
        b[i] = b[found];
        b[found] = 0;
        moved = true;

        found = find_number(b, i + 1, b[i]);
        // printf(" nonzero v2 found = %d\n", found);
        if (found != -1) {
          // #1 同じ数値が見つかったので加算して移動元を0にする
          b[i] += b[found];
          b[found] = 0;
          moved = true;
        }
      }
    } else {
      found = find_number(b, i + 1, b[i]);
      // printf(" found = %d\n", found);
      if (found != -1) {
        // #1 と同じ
        b[i] += b[found];
        b[found] = 0;
        moved = true;
      }
    }
  }
}

void move_left(void) {
  slide(&board[0][0]);
  slide(&board[1][0]);
  slide(&board[2][0]);
  slide(&board[3][0]);
}

void move_up(void) {
  rotate();
  slide(&board[0][0]);
  slide(&board[1][0]);
  slide(&board[2][0]);
  slide(&board[3][0]);
  rotate();
  rotate();
  rotate();
}

void move_right(void) {
  rotate();
  rotate();
  slide(&board[0][0]);
  slide(&board[1][0]);
  slide(&board[2][0]);
  slide(&board[3][0]);
  rotate();
  rotate();
}

void move_down(void) {
  rotate();
  rotate();
  rotate();
  slide(&board[0][0]);
  slide(&board[1][0]);
  slide(&board[2][0]);
  slide(&board[3][0]);
  rotate();
}

void add_two_numbers() {
  int one = get_random_pos();
  int two = get_random_pos();

  board[one / 4][one % 4] = two_or_four();
  board[two / 4][two % 4] = two_or_four();
}

void add_next_number() {
  int one = get_random_pos();

  board[one / 4][one % 4] = 2;
}

int main(void) {
  WINDOW *win;

  if ((win = initscr()) == NULL) {
    fprintf(stderr, "Error initialising ncurses.\n");
    exit(EXIT_FAILURE);
  }

  curs_set(0);
  noecho();
  keypad(stdscr, true);

  srand((unsigned int)time(NULL));

  add_two_numbers();

  print_board();

  int ch;

  while (running) {
    ch = wgetch(win);

    switch (ch) {
    case KEY_UP:
      move_up();
      break;
    case KEY_DOWN:
      move_down();
      break;
    case KEY_LEFT:
      move_left();
      break;
    case KEY_RIGHT:
      move_right();
      break;
    }

    if (moved) {
      print_board();
      usleep(150000);
      add_next_number();
      print_board();
    }
    moved = false;

    if (ch == 'q') {
      running = false;
    }
  }

  delwin(win);
  endwin();
  refresh();

  return EXIT_SUCCESS;
}
