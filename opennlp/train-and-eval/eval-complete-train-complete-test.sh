# Evaluates trained model on complete Macmorpho on complete Bosque.

opennlp=/dados/gpaulino/apache-opennlp-1.8.3/bin/opennlp
opennlp=/dados/gpaulino/apache-opennlp-1.8.3/bin/opennlp
dir=/dados/gpaulino/macmorpho

for p in $dir/*Params.txt; do
    t=`basename $p TrainerParams.txt`
    for f in {remove-pcp,}; do
	bsub -o %J.out -e %J.err $opennlp POSTaggerEvaluator.conllu -model $dir/pt-$f-$t-complete -data $dir/../macmorpho-bosque/pt-ud-complete.conllu -encoding utf-8 > $dir/pt-$f-$t-complete-train-complete-test.eval.log
    done
done
