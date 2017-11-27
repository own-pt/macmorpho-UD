opennlp=/dados/gpaulino/apache-opennlp-1.8.3/bin/opennlp
dir=/dados/gpaulino/macmorpho-bosque

for p in $dir/*Params.txt; do
    t=`basename $p TrainerParams.txt`
    bsub -o %J.out -e %J.err ./train-bosque.sh "$dir" "$p" "$t"
done
