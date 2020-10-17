#!/usr/bin/env ruby

require 'optparse'

Version = "0.0.1"

Help = %{\
Usage: wc [OPTION]... [FILE]...
  or:  wc [OPTION]... --files0-from=F
Print newline, word, and byte counts for each FILE, and a total line if
more than one FILE is specified.  A word is a non-zero-length sequence of
characters delimited by white space.

With no FILE, or when FILE is -, read standard input.

The options below may be used to select which counts are printed, always in
the following order: newline, word, character, byte, maximum line length.
  -c, --bytes            print the byte counts
  -m, --chars            print the character counts
  -l, --lines            print the newline counts
      --files0-from=F    read input from the files specified by
                           NUL-terminated names in file F;
                           If F is - then read names from standard input
  -L, --max-line-length  print the maximum display width
  -w, --words            print the word counts
      --help     display this help and exit
      --version  output version information and exit
}


$optBytes = false # -c, --bytes
$optChars = false # -m, --chars
$optLines = false # -l, --lines
$optFiles0 = nil # --files0-from=FILE
$optMaxLineLength = false # -L, --max-line-length

# !! clearly has many bugs
$optWords = false # -w, --words

$optFiles0Stdin = false # true when "echo "abc" | wc --files0-from=-"
$exit_status = 0 # exit status of this program
# 0: Success
# 1: Failure
# 130: SIGINT(Ctrl+c)
$counts = []

Count = Struct.new(:name, :bytes, :chars, :lines, :maxlen, :words)


def die(fmt, arg, exit_status)
  STDERR.puts sprintf(fmt, arg)
  exit(exit_status)
end

def warn(fmt, arg, exit_status)
  STDERR.puts sprintf(fmt, arg)
  $exit_status = code
end

def parseOpt(params)

  if params.has_value?(true)
    if params["c"] or params["bytes"]
      $optBytes = true
    end
    if params["m"] or params["chars"]
      $optChars = true
    end
    if params["l"] or params["lines"]
      $optLines = true
    end
    if params["L"] or params["max-lines-length"]
      $optMaxLineLength = true
    end
    if params["w"] or params["words"]
      $optWords = true
    end
    if params["version"]
      puts Version
      exit(0)
    end
    if params["help"]
      puts Help
      exit(0)
    end
  else
    $optBytes = $optLines = $optWords=  true
  end

  unless params["files0-from"].nil?
    $optFiles0 = params["files0-from"]
  end

  if params["files0-from"] == "-"
    if ARGV.empty?
      p "in"
      $optFiles0Stdin = true
      # really use?
    else
      STDERR.puts %{\
wc: extra operand '#{ARGV[0]}'
file operands cannot be combined with --files0-from
Try 'wc --help' for more information.}
      exit 1
    end
  end
  $optFiles0 = params["files0-from"]
end

def cat(name, lines)
  nbytes = 0
  nchars = 0
  nlines = 0
  nmaxlen = 0
  nwords = 0

  for line in lines
    if $optBytes
      nbytes += line.bytesize
    end
    if $optChars
      nchars += line.length
    end
    if $optLines
      nlines += 1
    end
    if $optMaxLineLength
      b = line.length
      if b > nmaxlen
        nmaxlen = b
      end
    end
    if $optWords
      sl = line.gsub(/\n/, '')
      if sl.length != 0
        sl = sl.split(/\s|　/)
      else
        sl = [sl]
      end
      sl.keep_if { |v| v != "" }
      nwords += sl.size
    end

  end
  nlines -= 1 if lines[-1][-1] != "\n"
  return Count.new(name, nbytes, nchars, nlines, nmaxlen, nwords)
end

def format(cat)
  puts "Name: #{cat.name}"
  puts "optBytes: #{cat.bytes}" if $optBytes
  puts "optChars: #{cat.chars}" if $optChars
  puts "optLines: #{cat.lines}" if $optLines
  puts "optMaxLineLength: #{cat.maxlen}" if $optMaxLineLength
  puts "optWords: #{cat.words}" if $optWords
end

def print_total
  nbytes = 0
  nchars = 0
  nlines = 0
  nmaxlen = 0
  nwords = 0
  for c in $counts
    if $optBytes
      nbytes += c.bytes
    end
    if $optChars
      nchars += c.chars
    end
    if $optLines
      nlines += c.lines
    end
    if $optMaxLineLength
      nmaxlen += c.maxlen
    end
    if $optWords
      nwords += c.words
    end
  end

  puts "Total:"
  puts "Bytes: #{nbytes}" if $optBytes
  puts "Chars: #{nchars}" if $optChars
  puts "Lines: #{nlines}" if $optLines
  puts "MaxLineLength: #{nmaxlen}" if $optMaxLineLength
  puts "Words: #{nwords}" if $optWords
end

def xreadlines(fname, func, exit_status, fmt_edir, fmt_enoent, ret = false)
  begin
    lines = IO.readlines(fname)
    rescue Errno::EISDIR
      func.call(fmt_edir, fname, 1)
      return [] if ret
    rescue Errno::ENOENT
      func.call(fmt_enoent, fname, 1)
      return [] if ret
  end
end

# main
trap("INT", "exit 130")
parseOpt(ARGV.getopts(
  'cmlLw', 'bytes', 'chars', 'lines', 'files0-from:',
  'max-line-length', 'words', "version", "help",
))

fnames = ARGV
p fnames
if $optFiles0.nil?

  # read stdin
  if fnames.empty?
    lines = $stdin.readlines
    $counts << cat("", lines)
    p $counts[0]
    format($counts[$counts.length - 1])
  else

    for fname in fnames
      # read files
      if fname == "-"
        lines = $stdin.readlines()
      else
        lines = xreadlines(
          fname,
          method(:warn),
          fmt_edir = "wc: %s: Is a directory",
          fmt_enoent = "wc: %s: No such file or directory",
          exit_status = 1,
          ret = true
        )
      end

      unless lines.length == 0
        $counts << cat(fname, lines)
        format($counts[$counts.length - 1])
      end
    end
  end

else

  # read stdin
  if $optFiles0Stdin
    loop do
      fname = $stdin.gets("\0", chomp: true)
      break if fname.nil?

      lines = xreadlines(
        fname,
        method(:die),
        fmt_edir = "wc: %s: read error: Is a directory",
        fmt_enoent = "wc: cannot open '%s' for reading: No such file or directory",
        exit_status = 1,
      )

      $counts << cat(fname, lines)
      format($counts[$counts.length - 1])
    end

  else

    # read file (--files0-from=file)
    fnames = IO.readlines($optFiles0, "\0", chomp: true)

    for fname in fnames
      lines = xreadlines(
        fname,
        method(:die),
        fmt_edir = "wc: %s: read error: Is a directory",
        fmt_enoent = "wc: cannot open '%s' for reading: No such file or directory",
        exit_status = 1,
      )

      $counts << cat(fname, lines)
      format($counts[$counts.length - 1])
    end
  end

end

if $counts.length > 1
  print_total
end

puts $OPT_bytes
puts "return exit_status: #{$exit_status}"
exit($exit_status)
