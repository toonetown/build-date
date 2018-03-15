#!/bin/bash

cd "$(dirname "${0}")"
BUILD_DIR="$(pwd)"
cd ->/dev/null

# Overridable build locations
: ${DEFAULT_DATE_DIST:="${BUILD_DIR}/date"}
: ${OBJDIR_ROOT:="${BUILD_DIR}/target"}

print_usage() {
    while [ $# -gt 0 ]; do
        echo "${1}" >&2
        shift 1
        if [ $# -eq 0 ]; then echo "" >&2; fi
    done
    echo "Usage: ${0} [/path/to/date-dist] <'package'|'clean'>"                             >&2
    echo ""                                                                                 >&2
    echo "\"/path/to/date-dist\" is optional and defaults to:"                              >&2
    echo "    \"${DEFAULT_DATE_DIST}\""                                                     >&2
    echo ""                                                                                 >&2
    echo "You can specify to package the release (after it's already been built) by"        >&2
    echo "running \"${0} package /path/to/output"                                           >&2
    echo ""                                                                                 >&2
    return 1
}

do_clean() { rm -rf "${OBJDIR_ROOT}"; }

do_copy_headers() {
    do_clean || return $?
    mkdir -p "${OBJDIR_ROOT}" || return $?
    cp -r "${PATH_TO_DATE_DIST}/include" "${OBJDIR_ROOT}/include" || return $?
}

do_package() {
    [ -d "${1}" ] || {
        print_usage "Invalid package output directory:" "    \"${1}\""
        exit $?
    }
    
    # Copy the headers
    do_copy_headers || return $?
    
    # Build the tarball
    BASE="date-$(cat "${PATH_TO_DATE_DIST}/version.txt")"
    cp -r "${OBJDIR_ROOT}" "${BASE}" || exit $?
    rm -rf "${BASE}/"*"/build" || exit $?
    find "${BASE}" -name .DS_Store -exec rm {} \; || exit $?
    tar -zcvpf "${1}/${BASE}.tar.gz" "${BASE}" || exit $?
    rm -rf "${BASE}"
}


# Calculate the path to the date-dist repository
if [ -d "${1}" ]; then
    cd "${1}"
    PATH_TO_DATE_DIST="$(pwd)"
    cd ->/dev/null
    shift 1
else
    PATH_TO_DATE_DIST="${DEFAULT_DATE_DIST}"
fi

[ -d "${PATH_TO_DATE_DIST}" -a \
  -f "${PATH_TO_DATE_DIST}/include/date/date.h" -a \
  -f "${PATH_TO_DATE_DIST}/version.txt" ] || {
    print_usage "Invalid Date directory:" "    \"${PATH_TO_DATE_DIST}\""
    exit $?
}


# Call the appropriate function based on target
TARGET="${1}"; shift
case "${TARGET}" in
    "clean")
        do_clean
        ;;
    "package")
        do_package "$@"
        ;;
    *)
        print_usage "Missing/invalid target '${TARGET}'"
        ;;
esac
exit $?
