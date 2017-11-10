opennlp=/dados/gpaulino/apache-opennlp-1.8.3/bin/opennlp
dir=/dados/gpaulino/macmorpho

for p in $dir/*Params.txt; do
    t=`basename $p TrainerParams.txt`
    for f in {remove-pcp,}; do
	bsub -o %J.out -e %J.err ./train-complete-data.sh "$dir" "$p" "$f" "$t"
    done
done
