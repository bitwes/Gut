#!/bin/zsh
# -----------------------------------------------------------------------------
# This clears out the rst files in the output directory before generating
# rst files.
#
# Should be run from project root.
# -----------------------------------------------------------------------------
outdir='documentation/docs/godot_doctool_rst'
xmldir='documentation/godot_doctools'
filterdir="$xmldir/filtered"
htmldir='documentation/docs/_build/html'

function printdir(){
    echo "-- $1"
    ls -1 $1
    echo "-------"
}

function generate_xml(){
    echo "Clearing $xmldir xml files"
    mkdir -p $xmldir
    rm "$xmldir"/*.xml

    # The command hangs forever, always.  It looks like this will be fixed in
    # soon (fixed merged after 4.3).  So we wait 5 seconds +1 seconds using gtimeout
    # (which is mac version of timeout from coreutils) and then kill it.
    gtimeout -k 1s 2s $GODOT --doctool $xmldir --no-docbase --gdscript-docs res://addons/gut

    printdir $xmldir
}

function fitler_xml(){
    mkdir -p $filterdir
    rm "$filterdir"/*

    # This gets files for things with a class_name
    find "$xmldir" -type f ! -name '*addons*' -exec cp {} $filterdir \;
    # Include the optparse files
    find "$xmldir" -type f -name '*optparse*' -exec cp {} $filterdir \;

    cp "$xmldir"/addons--gut--gut_loader.gd.xml $filterdir

    printdir $filterdir
}


function generate_rst(){
    xml_dir=$1
    echo "Clearing $outdir rst files"
    rm "$outdir"/*.rst

    python3 documentation/godot_make_rst.py $xml_dir --filter $xml_dir -o $outdir

    printdir $outdir
}


function main(){
    rm -r "$htmldir"/*

    echo "--- Generating XML files ---"
    generate_xml
    # echo "--- Filtering XML files ---"
    # fitler_xml
    echo "--- Generating RST files ---"
    generate_rst $xmldir
}


main

