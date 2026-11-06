# R script to check the qmd files for broken external links.
#
# I keep it in `assets/code/` and have the following in `_quarto.yml`:
#
#   post-render:
#     - assets/code/check_links.R"
#
# The script uses markdown-link-check (MLC)
# https://github.com/tcort/markdown-link-check.
# I made it because MLC cannot show just the external links.
# Using a config file with `"ignorePatterns": [{"pattern":"^(?!http)"}]`
# does not print the links to stdout, even with the --verbose option.

# change as necessary
logpath <- "assets/code/linkcheck.log"

# Run MLC
message("Checking for broken external links. This may take a few minutes ..")
tmp <- tempfile() # only way to fully silence MLC
# Node 22.8 needs this flag to load MLC's ES-module dependencies.
# Scope it to the checker and preserve any existing Node options.
node_options <- trimws(paste(Sys.getenv("NODE_OPTIONS"), "--experimental-require-module"))
cmd <- paste0(
  "find . -name '*.qmd' -print0 | xargs -0 -r -n1 env NODE_OPTIONS=",
  shQuote(node_options), " markdown-link-check > ", shQuote(tmp), " 2>&1"
)
res <- system(cmd)
output <- readLines(tmp)


# Summarize result lines, not the duplicate entries in MLC's error details.
fine <- grep("\\[✓\\] https?://[^[:space:]]+[[:space:]]*$", output, value = TRUE)
broken <- grep("\\[✖\\] https?://[^[:space:]]+[[:space:]]*$", output, value = TRUE)
nfine <- length(fine)
nbroken <- length(broken)
nall <- nfine + nbroken
if (res != 0L && nall == 0L) {
  summary <- paste0("Link checker failed (exit status ", res, "). No external-link results available.\n")
} else {
  summary <- paste0(
    nall, " external links checked, ",
    nbroken, " broken links found:\n"
  )
  if (res != 0L) {
    summary <- paste0(summary, "Link checker exited with status ", res, "; results may be incomplete.\n")
  }
}
message(summary)
print(broken)
# Log the full results
line <- paste0("\n", paste0(rep("-", 55), collapse = ""), "\n")
ts <- format(Sys.time(), "%e %b %Y at %X")
rootdir <- paste0(basename(getwd()), "/*")
logheader <- paste0(
  line,
  "Results of markdown-link-check for ", rootdir,
  "\nrun on ", ts, ".",
  line
)
log <- paste0(
  logheader, "\n",
  summary,
  paste(broken, collapse = "\n"),
  "\n\nDetails:\n",
  paste(output, collapse = "\n")
)
write(log, logpath)
message("\nSee `", logpath, "` for details.")
invisible(file.remove(tmp))
