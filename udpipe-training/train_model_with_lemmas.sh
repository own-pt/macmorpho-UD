DOCKER_COMMAND=$1
MODELNAME=$2
HELDOUTFILE=$3
TRAININGFILE=$4
ITERATIONS=$5

OPTIONS="models=1;use_lemma=1;provide_lemma=0;use_xpostag=0;provide_xpostag=0;use_feats=0;provide_feats=0;iterations=$ITERATIONS"

$DOCKER_COMMAND \
    --train --tokenizer=none --tagger=$OPTIONS --parser=none \
    --heldout=$HELDOUTFILE "$MODELNAME.output" $TRAININGFILE
