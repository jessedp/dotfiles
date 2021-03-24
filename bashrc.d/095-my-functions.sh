# JSON
function jsonlint() {
  if [ -f "$1" ]; then
    python -mjson.tool < $1 > /dev/null
  else
    python -mjson.tool > /dev/null
  fi
}
function jsonpp() {
  if [ -f "$1" ]; then
    python -mjson.tool < $1
  else
    python -mjson.tool
  fi
}