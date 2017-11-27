opennlp=/dados/gpaulino/apache-opennlp-1.8.3/bin/opennlp
modelsdir=/dados/gpaulino/models
texts=/dados/gpaulino/run-tagger/tokenized-text
tagged=/dados/gpaulino/run-tagger/tagged

for model in {Maxent,MaxentQN,NaiveBayes,Perceptron}; do
    for tagset in {keep-pcp,mm-revisto,remove-pcp}; do
	bsub -o %J.out -e %J.err "$opennlp POSTagger $modelsdir/pt-$tagset-$model < $texts/macmorpho-v1-test-$tagset-tokenized.txt > $tagged/pt-$tagset-$model.tagged" ;
    done
    bsub -o %J.out -e %J.err "$opennlp POSTagger $modelsdir/pt-bosque-$model < $texts/pt-ud-test-tokenized.txt > $tagged/pt-bosque-$model.tagged" ;
    bsub -o %J.out -e %J.err "$opennlp POSTagger $modelsdir/pt-remove-pcp-$model-complete < $texts/pt-ud-test-tokenized.txt > $tagged/pt-remove-pcp-$model-complete.tagged" ;
done
