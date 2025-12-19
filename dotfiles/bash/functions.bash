mkcd() {
  mkdir -p "$1" && cd "$1"
}

gclean() {
  git branch --merged | grep -v "\*" | xargs -n 1 git branch -d
}
