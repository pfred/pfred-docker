# User specific aliases and functions
alias checklog='tail -n 100 -f $CATALINA_HOME/logs/catalina.out'

export PFRED_HOME="/home/pfred/scripts"
export ENSEMBL_API=${PFRED_HOME}/ensemblapi
export PERL5LIB="/usr/local/lib64/perl5/"
export PERL5LIB="${PERL5LIB}:/usr/lib64/perl5/"
export PERL5LIB="${PERL5LIB}:${PFRED_HOME}/BioPerl-1.6.1"
export PERL5LIB="${PERL5LIB}:${PFRED_HOME}/pfred"
export PERL5LIB="${PERL5LIB}:${ENSEMBL_API}/ensembl/modules"
export PERL5LIB="${PERL5LIB}:${ENSEMBL_API}/ensembl-compara/modules"
export PERL5LIB="${PERL5LIB}:${ENSEMBL_API}/ensembl-variation/modules"
export PERL5LIB="${PERL5LIB}:${ENSEMBL_API}/ensembl-functgenomics/modules"


export CATALINA_HOME="/home/pfred/tomcat/apache-tomcat-7.0.62"
export CATALINA_OPTS="-Xms512m -Xmx1024m -XX:MaxPermSize=256m"

# User specific environment and startup programs
export CATALINA_HOME="/home/pfred/tomcat/apache-tomcat-7.0.62"
export PFRED_HOME="/home/pfred"
export SCRIPTS_DIR="${PFRED_HOME}/scripts/pfred"
export RUN_DIR="/home/pfred/scratch"
export BOWTIE_HOME="${PFRED_HOME}/scripts/bowtie"
export BOWTIE="${BOWTIE_HOME}/bowtie"
export BOWTIE_INDEXES="${BOWTIE_HOME}/indexes"
export BOWTIE_BUILD="${BOWTIE_HOME}/bowtie-build"

#path
export PATH=${CATALINA_HOME}/bin:$HOME/bin:${PFRED_HOME}/scripts/pfred:$PATH
export PATH=${BOWTIE_HOME}:$PATH
