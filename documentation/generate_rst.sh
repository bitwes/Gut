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


function generate_xml(){
    echo "Clearing $xmldir xml files"
    rm "$xmldir"/*.xml

    # The command hangs forever, always.  It looks like this will be fixed in
    # soon (fixed merged after 4.3).  So we wait 5 seconds +1 seconds using gtimeout
    # (which is mac version of timeout from coreutils) and then kill it.
    gtimeout -k 1s 5s $GODOT --doctool $xmldir --no-docbase --gdscript-docs res://addons/gut

    echo "--- DONE ---"
}

function fitler_xml(){
    mkdir -p $filterdir
    rm "$filterdir"/*

    find "$xmldir" -type f ! -name '*addons*' -exec mv {} $filterdir \;
    find "$xmldir" -type f -name '*optparse*' -exec mv {} $filterdir \;

    echo "-- $filterdir --"
    ls -l $filterdir
}


function generate_rst(){
    echo "Clearing $outdir rst files"
    rm "$outdir"/*.rst

    python3 documentation/godot_make_rst.py $filterdir --filter $filterdir -o $outdir
}


function main(){
    generate_xml
    fitler_xml
    generate_rst
}


main
