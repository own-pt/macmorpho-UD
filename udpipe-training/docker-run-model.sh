DOCKER_COMMAND=$1	  # e.g.: docker -H :4000 run udpipe 
DATASET_NAME=$2 			# NAME in {mm-revisto, keep-pcp, remove-pcp}
DIR=$3
ITERATIONS=${4:-20}
CONTAINER_NAME=$5	       # should be set as equal to --name value in docker command (container name);
                               # (not necessarily equal to $DATASET_NAME)
# useful for when running docker with `-d` flag
LEMMA_PREFIX=$6 		# if null, no prefix in name file (so we won't expect it's lemmatized)
                                # for instance, "lemmas-" 

./train_model.sh "$DOCKER_COMMAND" $DIR/$CONTAINER_NAME-model $DIR/${LEMMA_PREFIX}macmorpho-v1-dev-$DATASET_NAME.conllu $DIR/${LEMMA_PREFIX}macmorpho-v1-train-$DATASET_NAME.conllu $ITERATIONS;

if [[ ! -z $CONTAINER_NAME ]] ; 	# true if CONTAINER_NAME is set
then docker wait $CONTAINER_NAME ;
     docker rename $CONTAINER_NAME ${CONTAINER_NAME}_training ;
fi

echo "Reporting accuracy to file:" $DIR/$CONTAINER_NAME-accuracy-report.log ;
./report_accuracy.sh "$DOCKER_COMMAND" $DIR/$CONTAINER_NAME-model $DIR/${LEMMA_PREFIX}macmorpho-v1-test-$DATASET_NAME.conllu > $DIR/$CONTAINER_NAME-accuracy-report.log ;
docker logs $CONTAINER_NAME >> $DIR/$CONTAINER_NAME-accuracy-report.log

