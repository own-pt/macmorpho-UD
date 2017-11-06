for f in {keep-pcp,remove-pcp,mm-revisto}; do
    if [ ! -e pt-$f ]; then
	~/apache-opennlp-1.8.2/bin/opennlp POSTaggerTrainer.conllu -encoding utf-8 -lang pt -model pt-$f -data ../macmorpho-v1-train-$f.conllu > pt-$f.train.log
    else
	echo skipping $f
	~/apache-opennlp-1.8.2/bin/opennlp POSTaggerEvaluator.conllu -model pt-$f -data ../macmorpho-v1-test-$f.conllu -encoding utf-8 > pt-$f.eval.log
    fi
done
