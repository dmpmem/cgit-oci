#!/bin/sh
set -e
echo -n "<pre>"
bat -pp --color always --file-name "$1" | ansi2html -i
echo -n '</pre>'
