# simple rpc mechanism
# works by sending itself over to the remote
#
# packet format: <type> <blank> <data>
# type is an alphanumeric string
# blank is one or more ascii space characters
#
# the type determines whether the data that follows is escaped or not
# if data is escaped, it's represented as if produced by od -to1 -An -v
# (thus it may contain more blanks between each byte that must be ignored)
# data is at most 4kb long
#
# types are:
# - meta
# - stdout (line buffered)
# - stderr (unbuffered)
# - exit


LANG=C LC_ALL=C
export LANG LC_ALL

IFS=' 
'



# mux runs a command and packs its stdout/stderr/exit code
# into a single stream that can be decomposed unambiguously
# todo: signals and stuff

mux_stream() {
    target=$1
    while set -- $(dd bs=4096 count=1 | od -bvAn); [ "$#" -ne 0 ]; do
        echo "$target $*"
    done 2>/dev/null
}

mux () {
    {
        e=$(
            {
                {
                    { "$@"; echo "$?" >&4; } |
                    mux_stream stdout
                } 2>&1 >&3 |
                mux_stream stderr >&3
            } 4>&1
        )
    } 3>&1
    echo "exit $e"
}

put_bytes () {
    printf "$(echo "$*" | sed 's/[^0-7]//g;s/.../\\&/g')"
}

# demux unpacks the stream
demux () {
    while read -r type data; do
        case $type in
            stdout) put_bytes "$data" ;;
            stderr) put_bytes "$data" >&2;;
            exit) return "$data" ;;
        esac
    done
}

# demo
mux "$@" | demux



# todo: rest of the owl
