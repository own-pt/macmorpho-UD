opennlp=/dados/gpaulino/apache-opennlp-1.8.3/bin/opennlp
dir=$1
p=$2
t=$3

$opennlp POSTaggerTrainer.conllu -params $p -encoding utf-8 -lang pt -model $dir/pt-bosque-$t -data $dir/pt-ud-train-and-dev.conllu > $dir/pt-bosque-$t.train.log
$opennlp POSTaggerEvaluator.conllu -model $dir/pt-bosque-$t -data $dir/pt-ud-test.conllu -encoding utf-8 > $dir/pt-bosque-$t.eval.log
