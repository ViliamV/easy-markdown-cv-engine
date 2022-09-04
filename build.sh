#!/usr/bin/env bash

set -o errexit
set -o nounset
# set -o xtrace # Print commands before executing

HELP_REGEX='^(-h|--help)$'
colorprint() {
  # Prints in green color
  echo -e "\e[32m$1\e[39m"
}

FIRST_ARG="${1:-}"
SECOND_ARG="${2:-}"

if [[ -z $FIRST_ARG ]]; then
  echo "Not enough arguments."
  exit 1
else
  # Prints help and exits if options include --help/-h
  if [[ $FIRST_ARG =~ $HELP_REGEX ]]; then
    cat doc.txt
    exit
  elif [[ $SECOND_ARG =~ $HELP_REGEX ]]; then
    case "$FIRST_ARG" in
      public)
        echo "Creates html with variable public that hides contact info"
        ;;
      html)
        echo "Creates html without variable public"
        ;;
      pdf)
        echo "Creates pdf with variable pdfphoto if exists, should look like html version"
        ;;
      pdfbw)
        echo "Creates pdf without photo for black and white print"
        ;;
      pdfprint)
        echo "Creates pdf with photo for color print"
        ;;
      jpg)
        echo "Creates jpg screenshot of html output"
        ;;
      debug)
        echo "Creates html with debug.css"
        ;;
    esac
    exit
  fi
fi

indir="/data/$CV_SOURCE/"
[[ ! -d $indir ]] && echo "Source directory $CV_SOURCE does not exists!" && exit 1
outdir="/data/$CV_OUTPUT/"

css_files=(fonts icons normalize style print media)
css_path="./res/css/"
css_final="style.css"
TEMPLATE="--template=./res/template.html"
fonts="./res/fonts/"
images="img/"
filename="cv"
public_filename="index"
vars=""

case $FIRST_ARG in
  public)
    outdir+="public/"
    filename=$public_filename
    vars="--variable=public"
    ;;
  pdf*)
    outdir+="pdf/"
    ;;&
  jpg*)
    outdir+="jpg/"
    ;;&
  html)
    outdir+="html/"
    ;;
  pdf | jpg)
    vars="--variable=usepdfphoto"
    ;;
  pdfbw)
    css_files+=(pdf_bw)
    filename+="_bw"
    ;;
  pdfprint)
    css_files+=(pdf_color)
    filename+="_print"
    ;;
  debug)
    outdir+="debug/"
    css_files+=(debug)
    ;;
  wait)
    colorprint "Waiting..."
    sleep infinity
    exit
    ;;
esac

colorprint "Env:"
echo "input directory: $indir"
echo "output directory: $outdir"
echo -e "command: $FIRST_ARG\n"

# create outdir
mkdir -p "${outdir}"

# create css argument
css=""
for c in "${css_files[@]}"; do
  css="${css} ${css_path}${c}.css"
done
cat ${css} > "${outdir}${css_final}"

# copy fonts
cp -ru "${fonts}" "${outdir}" 2> /dev/null
# copy images
cp -ru "${indir}${images}" "${outdir}" 2> /dev/null

colorprint "Creating HTML"
pandoc -s \
  --from=markdown+smart \
  --to=html5 \
  $vars \
  -o "$outdir/$filename.html" \
  $indir*.yml \
  $indir*.md \
  --css=${css_final} \
  $TEMPLATE

if [[ $FIRST_ARG == pdf* ]]; then
  colorprint "Converting to PDF"
  node topdf.js \
    "$outdir/$filename.html" \
    "$outdir/$filename.pdf" \
    2>/dev/null
fi
if [[ $FIRST_ARG == jpg ]]; then
  colorprint "Converting to JPEG"
  node tojpg.js \
    "$outdir/$filename.html" \
    "$outdir/$filename.jpg" \
    2>/dev/null
fi
if [[ $FIRST_ARG =~ ^(jpg|pdf.*) ]]; then
  # Cleanup
  loc=$(pwd)
  cd "$outdir"
  rm -r fonts img ./*.html ./*.css
  cd "$loc"
fi

colorprint "Finished"
