# Move files post render

if (file.exists("docs/assets/code/cv.pdf")) {
  file.rename("docs/assets/code/cv.pdf", "docs/assets/documents/cv.pdf")
}
