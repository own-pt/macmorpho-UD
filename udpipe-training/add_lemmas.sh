DOCKER_COMMAND=$1
FILENAME=$2
MODELNAME=$3

paste $FILENAME <($DOCKER_COMMAND --tag $MODELNAME $FILENAME)  > $(pwd)/joined-$(basename $FILENAME).tmp
awk -v 'OFS=\t' '{print $1,$2,$13,$4,$5,$6,$7,$8,$9,$10}' $(pwd)/joined-$(basename $FILENAME).tmp > $(dirname $FILENAME)/lemmas-$(basename $FILENAME)
rm $(pwd)/joined-$(basename $FILENAME).tmp


