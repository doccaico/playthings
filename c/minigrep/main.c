#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *query;
char *filename;
bool case_sensitive;

void minigrep_config(int argc, char **argv) {
  if (argc < 3) {
    fprintf(stderr, "Not enough arguments\n");
    exit(EXIT_FAILURE);
  }

  query = argv[1];
  filename = argv[2];
}

void minigrep_run(void) {

    FILE *stream;
    char *line = NULL;
    size_t len = 0;

    stream = fopen(filename, "r");
    if (!stream) {
        fprintf(stderr, "Couldn't open file\n");
        exit(EXIT_FAILURE);
    }

    while (getline(&line, &len, stream) != -1) {
      if (strstr(line, query)) {
        printf("%s", line);
      }
    }

    free(line);
    fclose(stream);
}

int main(int argc, char **argv) {

  // printf("query: %s\n", query);
  // printf("filename: %s\n", filename);

  minigrep_config(argc, argv);
  minigrep_run();

  return EXIT_SUCCESS;
}
