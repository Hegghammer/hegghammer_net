# Move cv.pdf to assets/documents after render

file <- "cv.pdf"
srcdir <- "docs/assets/code"
src <- file.path(srcdir, file)
dstdir <- "docs/assets/documents"
dst <- file.path(dstdir, file)

invisible(
  if (file.exists(src)) {
    file.rename(src, dst)
    message("`", file, "` moved from `", srcdir, "` to `", dstdir, "`.")
  }
)
