# does not use lemmas
for name in {mm-revisto,keep-pcp,remove-pcp}; do
    for iter in {9,20,30}; do
	./docker-run-model.sh "docker run --name ${name}_${iter}_iterations -dit -v `pwd`:`pwd` brlcluster.br.ibm.com/gpaulino/udpipe:1.2" $name `pwd` $iter ${name}_${iter}_iterations &> ${name}_${iter}_iterations.log &
    done
done
