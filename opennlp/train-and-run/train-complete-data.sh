opennlp=/dados/gpaulino/apache-opennlp-1.8.3/bin/opennlp
dir=$1
p=$2
f=$3
t=$4

$opennlp POSTaggerTrainer.conllu -params $p -encoding utf-8 -lang pt -model $dir/pt-$f-$t-complete -data $dir/macmorpho-v1-$f-complete.conllu > $dir/pt-$f-$t-complete.train.log
$opennlp POSTaggerEvaluator.conllu -model $dir/pt-$f-$t-complete -data $dir/../macmorpho-bosque/pt-ud-test.conllu -encoding utf-8 > $dir/pt-$f-$t-complete.eval.log
