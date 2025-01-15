#!/bin/sh
set -e
if [[ "$1" == *.md ]]; then
  exec markdown-tool
fi
echo -n "<pre>"
bat -pp --color always --file-name "$1" | ansi2html -i
echo -n '</pre>'
