#!/bin/bash
# Written by Dilawar Singh, 2014
# dilawars@ncbs.res.in

## This is command template.
command="partition mtgenes = 3: CR, cytB, struct;
set partition = mtgenes;
exclude  1-160 211-260 364-384;
lset applyto=(1,2,3) nst=6 rates=gamma;
unlink statefreq=(all) revmat=(all) shape=(all) pinvar=(all);
prset applyto=(all) ratepr=variable;
mcmcp ngen=10000000 samplefreq=10000 printfreq=1000 nruns=4 nchains=4 mcmcdiagn=yes diagnfreq=1000000 burnin=1000;
mcmc burnin=1000;"
command1="sump burnin=1000 Outputname=sump.stat Printtofile=Yes;
sumt burnin=1000;"

## This is run.sh
run="#!/bin/bash
mb < command.txt > mrbayes.log
mb < command1.txt >> mrbayes.log
"

set -e
if [[ ! $# -eq 1 ]]; then
	echo "USAGE: $0 filename"
	exit
fi

if [ ! -f ./command ]; then
	echo "Create a file called command"
	echo "it should contain all mb commands you want to execute on server"
fi

file="$1"
echo "Copying input file to current directory"
if [ ! -f $file ]; then
    cp $file .
fi
file=`basename $file`
COMMAND="$2"
TIMESTAMP=`date +%Y%m%d%H%M%S`

echo "I am going to execute following command on server"
WORKDIR=Work/NISHMA/$TIMESTAMP
mkdir -p $WORKDIR

echo "Generating files to be sent to server"
rm -f command.txt run.sh
printf "execute $file;\n$command\n" > command.txt
printf "execute $file;\n$command1\n" > command1.txt
echo "$run" > run.sh
chmod +x run.sh

echo "Sending file to NARGIS server"
rsync -azv $file plot*.sh run.sh sge.sh command.txt command1.txt nargis:$WORKDIR
ssh -T nargis << EOF
cd $WORKDIR && qsub sge.sh
EOF
echo "Done"
