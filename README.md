# RSV_nextflow
RSV_nextflow is nextflow pipeline for the generation of consensus sequences for RSV samples sequenced using the ARTIC RSV amplicon scheme on the Nanopore platforms. It is set up to work within Oxford Nanopore Technologies's epi2me platform, but can be run outside of epi2me if you have nextflow available. This workflow was developed to enable RSV genome assembly to be straightforward but also importantly to allow the two ARTIC RSV primer sets for RSV A and B to be multiplexed into one reaction.

***This repo is under active development and we hope to add much more in the way for output reporting for epi2me, as well as adapting this approach to be an RSV primer multiplexing pipeline for Illumina data as well*** 

 
## Pipeline overview
Broadly the workflow consists of two separate parts, ampli_clean and the fieldbioinformatics pipeline. Ampli_clean is a standalone tool that allows correct reference selection for a given set of reads (ie RSV A or RSV B in this case) and then can "clean" the resulting bam file to ensure only amplicons for the correct primer set are mapping to the genome. These cleaned reads are then passed to the fieldbioinformatics pipeline for assembly. The use of ampli_clean and the `--strict` flag within fieldbioinformatics should ensure no erroneous SNPs are introduced into the consensus genomes by incomplete primer trimming due to primer binding from the "other" primer set.

 
## Walkthrough
### Installation - epi2me
After successful installation of the epi2me platform you can "import" worflows for use. To do this go to the "Workflows" tab and in the top right hand corner there should be a button labelled "import workflow". Here you can paste the URL for this repository (https://github.com/Desperate-Dan/RSV_nextflow.git) and click install to download this workflow. 

### Running - epi2me
To run the epi2me workflow, select the workflow from "Installed" workflows tab. Then select "Run this workflow". Currently the only mandatory field to fill in is the "fastq" directory path. This should be to the directory that contains your demultiplexed nanopore reads, typically the "fastq_pass" directory produced by your sequencing run. The pipeline will then process each barcode directory independently and generate a consensus sequence.

***Please note the first time you run this workflow it will take some time as it needs to download the docker container to run the pipeline. It only needs to do this once.***

### Installation - CLI
Alternatively this pipeline can also be run by cloning this repo:

`git clone https://github.com/Desperate-Dan/RSV_nextflow.git`

Then it can be run assuming you have already set up nextflow (See https://www.nextflow.io/ for details). The pipeline can then be passed command line arguments like so:

`nextflow /path/to/RSV_nextflow/main.nf --fastq="/path/to/fastq_pass"`

The only required flag is `--fastq` but any of the other flags can be provided too, eg: `--min` and `--max`. See the `nextflow.config` file for possible flags.



