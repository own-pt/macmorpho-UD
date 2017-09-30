INPUTFILE=$1
DATASET=$2

# receives file as conllu
# outputs as conllu

INPUT=$(mktemp)
awk '{print $2} END {print ""}' $INPUTFILE > $INPUT

OUTPUT=$(mktemp)
/usr/local/bin/analyzer -f analyzer_$DATASET.cfg <$INPUT > $OUTPUT

awk -v 'OFS=\t' 'BEGINFILE {id=1} $0 == "" {id=1; print $0} $0 != ""  {print id++, $1, $2, $3, "_", "_", "0", "_", "_", "_" ; id++} ' $OUTPUT

rm $INPUT
rm $OUTPUT

