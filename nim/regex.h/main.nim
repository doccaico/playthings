import strformat

const REG_EXTENDED = 1
const MAX_MATCHES = 1

type
  regex_t {.header: "<regex.h>".} = object
  regoff_t = cint
  regmatch_t {.header: "<regex.h>".} = object
    rm_so: regoff_t
    rm_eo: regoff_t

proc regcomp(reg: ptr regex_t, pattern: cstring, cflags: cint): cint
     {.header: "<regex.h>".}
proc regexec(preg: ptr regex_t, str: cstring, nmatch: csize_t,
     pmatch: ptr regmatch_t, eflags: cint): cint {.header: "<regex.h>".}
proc regfree (preg :ptr regex_t) {.header: "<regex.h>".}

proc match(pexp: ptr regex_t, sz :cstring) =
  var matches: array[MAX_MATCHES, regmatch_t]
  if regexec(pexp, sz, MAX_MATCHES, addr matches[0], 0) == 0:
    echo fmt"'{sz}' matches characters {matches[0].rm_so} - {matches[0].rm_eo}"
  else:
    echo fmt"'{sz}' does not match"

var
  rv: cint
  exp: regex_t

rv = regcomp(addr exp, "-?[0-9]+(\\.[0-9]+)?", REG_EXTENDED);
if rv != 0:
  echo rv

match(addr exp, "0");
match(addr exp, "0.");
match(addr exp, "0.0");
match(addr exp, "10.1");
match(addr exp, "-10.1");
match(addr exp, "a");
match(addr exp, "a.1");
match(addr exp, "0.a");
match(addr exp, "0.1a");
match(addr exp, "hello");
regfree(addr exp);
