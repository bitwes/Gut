#!/bin/zsh
# -----------------------------------------------------------------------------
# This clears out the rst files in the output directory before generating
# rst files.
#
# Should be run from project root.
# -----------------------------------------------------------------------------
rstdir='documentation/docs/godot_doctool_rst'
xmldir='documentation/godot_doctools'
# Eventual final location for html files generated from rst.  Included in this
# script since that directory should be cleared whenever this is run.
htmldir='documentation/docs/_build/html'


function printdir(){
    echo "-- $1"
    ls -1 $1
    echo "-------"
}


function generate_xml(){
    the_dir=$1
    scripts_dir=$2

    echo "Clearing $the_dir xml files"
    mkdir -p $the_dir
    rm "$the_dir"/*.xml

    # The command hangs forever, always.  It looks like this will be fixed in
    # soon (fixed merged after 4.3).  So we wait 5 seconds +1 seconds using gtimeout
    # (which is mac version of timeout from coreutils) and then kill it.
    gtimeout -k 1s 2s $GODOT --doctool $the_dir --no-docbase --gdscript-docs $scripts_dir

    printdir $the_dir
}


function generate_rst(){
    input_dir=$1
    output_dir=$2

    echo "Clearing $output_dir rst files"
    rm "$output_dir"/*.rst

    python3 documentation/godot_make_rst.py $input_dir --filter $input_dir -o $output_dir

    printdir $output_dir
}


function generate_html(){
    the_dir=$1

    rm -r "$the_dir"/*
    docker-compose -f documentation/docker/compose.yml up

    tree $the_dir
}


function main(){
    echo "--- Generating XML files ---"
    generate_xml $xmldir "res://addons/gut"

    echo "\n\n"
    echo "--- Generating RST files ---"
    generate_rst $xmldir $rstdir

    echo "\n\n"
    echo "--- Generating HTML ---"
    generate_html $htmldir
}


main