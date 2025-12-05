#!/bin/bash
#set -x

#
#   Copyright 2015-2026 Felix Garcia Carballeira, Alejandro Calderon Mateos, Javier Prieto Cepeda, Saul Alonso Monsalve, Catherine Alessandra Torres Charles
#
#   This file is part of WepSIM (https://wepsim.github.io/wepsim/)
#
#   WepSIM is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   WepSIM is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Lesser General Public License for more details.
#
#   You should have received a copy of the GNU Lesser General Public License
#   along with WepSIM.  If not, see <http://www.gnu.org/licenses/>.
#

## WHAT THIS UNZIP DO 
### by CAT
# Fixes common student errors:
    # Removes spaces: 100550227_ 100550260.zip → 100550227_100550260.zip
    # Removes prefixes: ec_p2_100550260.zip → 100550260.zip
    # Collapses multiple underscores: 100__550.zip → 100_550.zip
    # Converts .zip.rar or .rar into valid directories.
# RAR Extraction
    # Extracts .rar submissions using unrar.
    # Creates a normalized directory and logs the operation.
# Unzip of Each Student Submission
    # Unzips <id>.zip into <id>/.
    # Removes macOS metadata:
    # __MACOSX/
    # .DS_Store
    # ._*
    # .localized
# Fix Internal Directory Names
    # Corrects folder names inside each submission:
    # Removes spaces and malformed underscores.
    # Renames broken folder names like:
    # 100550227_ 100260_ → 100550227_100260
# Flatten Nested Folders
    # If a submission has only one subfolder:
    #   id/SomeFolder/ → id/
    # Moves all files to the root and deletes the nested directory.
# Normalize Required File Names
    # Inside each student folder, ensures the existence of:
    #     authors.txt
    #     e1_checkpoint.txt
    #     e2_checkpoint.txt
    #     report.pdf
    # If not found, detects the closest matching file:
    #     author.TXT → authors.txt
    #     e1chekpoint.txt → e1_checkpoint.txt
    #     Entrega2.pdf → report.pdf
# Fix Invalid Checkpoint Files (JSON)
    # For e1_checkpoint.txt and e2_checkpoint.txt:
    #     Validates that the file contains JSON ({ and "metadata").
    # If invalid:
    #     Regenerates it using WEPSim (wepsim.sh -a build-checkpoint …).
# Produces two reports:
    # modifications_<bundle>.txt — human-readable summary
    # modifications_<bundle>.csv — structured CSV grouped by student ID
##

# Welcome
echo ""
echo "s10_unzip"
echo "---------"
echo ""

# Test parameters...
if [ $# -lt 1 ]; then
     echo "  Version: v1.5"
     echo "    Usage:"
     echo "    * $0 <list (one per line) of .zip files (without .zip) to uncompress: p2-88.in>"
     echo "    * $0 <group_90_bundle_from_aula_global_as_download_all_submissions>.zip"
     echo ""
     exit
fi


BUNDLE="$1"
DIR_OUTPUT="$(pwd)/modifications_${BUNDLE%.zip}.txt"
CSV_OUTPUT="$(pwd)/modifications_${BUNDLE%.zip}.csv"
rm -f "$DIR_OUTPUT" "$CSV_OUTPUT" #delete if exists

declare -A ERRORS_MAP
log_error() {
    local id="$1"
    local msg="$2"

    # Append a newline + message to this student's entry
    ERRORS_MAP["$id"]+="$msg"$'\n'
}

# Determine if input is text list or zip bundle
ARG_TYPE=$(file -b "$BUNDLE")
if [ "$ARG_TYPE" != "ASCII text" ]; then
    echo "=> First, unzip group bundle..."
    BASE_DIR="${BUNDLE%.zip}"
    unzip -ojad "$BASE_DIR" "$BUNDLE"

    # Normalize filenames in bundle
    for f in "$BASE_DIR"/*; do
        [ -f "$f" ] || continue
        base=$(basename "$f")
        # Remove spaces
        clean=$(echo "$base" | tr -d '[:space:]')

        # Remove prefixes like ec_p2_
        clean=$(echo "$clean" | sed 's/^ec_p2_//')
        
        # Replace multiple underscores
        clean=$(echo "$clean" | sed 's/__\+/_/g')

        ##clean=$(echo "$base" | tr -d '[:space:]')
        ##clean=$(echo "$clean" | sed 's/^ec_p2_//; s/__\+/_/g; s/\.zip\.rar$/.zip/') #short code. but rename .rar
        if [ "$base" != "$clean" ]; then
            echo " → Renaming submission: '$base' → '$clean'"
            log_error "${clean%.zip}" "Renamed submission: $base → $clean"
            mv "$BASE_DIR/$base" "$BASE_DIR/$clean"
            f="$BASE_DIR/$clean"
        fi

        # --- NEW: Extract RAR files ---
        case "$f" in
            *.rar)
            # Remove .zip.rar or .rar from directory name
            dir="${f%.rar}"         # remove .rar
            dir="${dir%.zip}"       # remove .zip if present
            echo " → Extracting RAR: $f → $dir"
            log_error "$(basename "$dir")" "Extracted RAR: $f → $dir"
            mkdir -p "$dir"
            unrar x -o+ "$f" "$dir/" >/dev/null
            ;;
        esac

    done

    # Rebuild the .in list
    #ls -1 "$BASE_DIR" | sed 's/\.zip$//' | sort | uniq > "$BASE_DIR.in"
    ls -1 "$BASE_DIR"/ | sed 's/\.rar$//' |  sed 's/\.zip$//' | xargs -n1 basename | sort | uniq > "$BASE_DIR.in"
else
    BASE_DIR="${BUNDLE%.in}"
fi

echo "=> Unzip each submission..."
shopt -s nullglob

while IFS= read -r A; do
    echo "$A"
    unzip -a -u -d "$BASE_DIR/$A" "$BASE_DIR/$A.zip"

    # Remove __MACOSX
    [ -d "$BASE_DIR/$A/__MACOSX" ] && rm -rf "$BASE_DIR/$A/__MACOSX"

    # Normalize nested directories inside submission
    for d in "$BASE_DIR/$A"/*/; do
        [ -d "$d" ] || continue
        old=$(basename "$d")
        clean=$(echo "$old" | sed 's/_[ ]\+/_/g; s/[ ]\+_/_/g; s/[ ]//g')
        if [ "$old" != "$clean" ]; then
            echo "  → Renaming broken directory: '$old' → '$clean'"
            log_error "$clean" "Renaming broken directory: '$old' → '$clean'"
            mv "$BASE_DIR/$A/$old" "$BASE_DIR/$A/$clean"
        fi
    done

    # Flatten if exactly 1 subdir
    SUBDIRS=($(find "$BASE_DIR/$A" -mindepth 1 -maxdepth 1 -type d ! -name "__MACOSX"))
    if [ "${#SUBDIRS[@]}" -eq 1 ]; then
        SUB="${SUBDIRS[0]}"
        echo " $A * Flattening nested folder: '$SUB' → '$BASE_DIR/$A/'"
        log_error "$A" "Flattening nested folder: '$SUB' → '$BASE_DIR/$A/'"
        for item in "$SUB"/* "$SUB"/.*; do
            base=$(basename "$item")
            [[ "$base" == "." || "$base" == ".." ]] && continue
            mv "$item" "$BASE_DIR/$A/" 2>/dev/null || true
        done
        rmdir "$SUB" 2>/dev/null || true
    fi

    # Cleanup extra MACOS junk
    find "$BASE_DIR/$A" -type d -name "__MACOSX" -exec rm -rf {} + 2>/dev/null
    find "$BASE_DIR/$A" -maxdepth 1 -type f \( -name ".DS_Store" -o -name "._*" -o -name ".localized" \) -delete

done < "$BASE_DIR.in"

# Normalize internal file names
echo "=> Normalizing internal files..."

for d in "$BASE_DIR"/*/; do
    dirbase=$(basename "$d")
    if [[ "$dirbase" =~ ^[0-9]+(_[0-9]+)+$ ]]; then
        echo "   -> Verify: $d"
        cd "$d"

        #### authors.txt ####
        if ! [ -f authors.txt ]; then
            f=$(ls | grep -i 'author' | head -n 1)
            [ -n "$f" ] && mv "$f" authors.txt && echo "          X -> authors: $f → authors.txt" 
            log_error "$dirbase" "Renamed authors.txt: $f → authors.txt"
        fi

        #### e1_checkpoint.txt ####
        if ! [ -f e1_checkpoint.txt ]; then
            f=$(ls | grep -Ei 'e1.*check' | head -n 1)
            [ -n "$f" ] && mv "$f" e1_checkpoint.txt && echo "          X -> e1_checkpoint: $f → e1_checkpoint.txt" 
            log_error "$dirbase" "Renamed e1_checkpoint: $f → e1_checkpoint.txt"
        fi

        #### e2_checkpoint.txt ####
        if ! [ -f e2_checkpoint.txt ]; then
            f=$(ls | grep -Ei 'e2.*(check|chek)' | head -n 1)
            [ -n "$f" ] && mv "$f" e2_checkpoint.txt && echo "          X -> e2_checkpoint: $f → e2_checkpoint.txt" 
            log_error "$dirbase" "Renamed e2_checkpoint: $f → e2_checkpoint.txt"
        fi

        #### report.pdf ####
        if ! [ -f report.pdf ]; then
            f=$(ls | grep -Ei '\.pdf$' | head -n 1)
            [ -n "$f" ] && mv "$f" report.pdf && echo "          X -> report: $f → report.pdf" 
            log_error "$dirbase" "Renamed report.pdf: $f → report.pdf"
        fi

        ##############################
        # Validate checkpoint content
        ##############################
        fix_checkpoint() {
            local fname="$1"
            [ -f "$fname" ] || return
            if ! grep -q '^{' "$fname" || ! grep -q '"metadata"' "$fname"; then
                echo "     X -> Invalid checkpoint '$fname', regenerating..."
                log_error "$dirbase" "Invalid JSON checkpoint → regenerated: $fname"
                (cd /work/tester && ./wepsim.sh -a build-checkpoint -m ep -f "$d/$fname" -s /tmp/empty.asm > "$d/${fname}.new")
                mv "$(pwd)/${fname}.new" "$fname"
            fi
        }

        fix_checkpoint e1_checkpoint.txt
        fix_checkpoint e2_checkpoint.txt

        cd - >/dev/null
    fi
done

# Done.
echo ""
echo "unzip done."
echo ""


echo ""                                          >> "$DIR_OUTPUT"
echo "========================================"  >> "$DIR_OUTPUT"
echo "         SUMMARY OF DETECTED ISSUES"       >> "$DIR_OUTPUT"
echo "========================================"  >> "$DIR_OUTPUT"

for id in "${!ERRORS_MAP[@]}"; do
    echo "ID: $id"                               >> "$DIR_OUTPUT"
    echo "${ERRORS_MAP[$id]}" | sed 's/^/  - /'  >> "$DIR_OUTPUT"
    echo ""                                      >> "$DIR_OUTPUT"
done

echo "student_id,action" > "$CSV_OUTPUT"

for id in "${!ERRORS_MAP[@]}"; do
    first_row=true

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue

        # Escape quotes for CSV
        safe_line=$(echo "$line" | sed 's/"/""/g')

        if $first_row; then
            # First line: include ID
            echo "$id,\"$safe_line\"" >> "$CSV_OUTPUT"
            first_row=false
        else
            # Next lines: empty ID column
            echo ",\"$safe_line\"" >> "$CSV_OUTPUT"
        fi
    done <<< "${ERRORS_MAP[$id]}"

    # Optional blank line between groups
    #echo "," >> "$CSV_OUTPUT"
done

echo "CSV generated: $CSV_OUTPUT"
