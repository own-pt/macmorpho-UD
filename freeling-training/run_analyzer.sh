INPUTFILE=$1

# receives file as conllu
# outputs as conllu

DATA=$(mktemp)
awk '{print $2} END {print ""}' $INPUTFILE > $DATA

OUTPUT=$(mktemp)
/usr/local/bin/analyzer -f analyzer.cfg <$DATA > $OUTPUT

awk -v 'OFS=\t' 'BEGINFILE {id=1} $0 == "" {id=1; print $0} $0 != ""  {print id++, $1, $2, $3, "_", "_", "0", "_", "_", "_" ; id++} ' $OUTPUT

# rm $DATA
# rm $OUTPUT
echo $DATA
echo $OUTPUT
