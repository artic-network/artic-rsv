# artic-rsv
artic-rsv is an analysis pipeline for the generation of consensus sequences for samples sequenced using the ARTIC RSV amplicon schemes. This pipeline was developed to enable straightforward RSV genome assembly and, importantly, to allow the ARTIC RSV A and B primer sets to be multiplexed into one reaction. Because of this, the end-to-end workstream can process RSV A and RSV B samples simultaneously. The ARTIC RSV primer sets can be found within the [resources](https://github.com/artic-network/artic-rsv/tree/main/resources) directory for this repository.

The pipeline is built using nextflow and can be run within ONT's epi2me platform or as a standalone command line tool outside of epi2me, provided nextflow is installed. 

***This repository is under active development and we plan to add additional reporting features to the epi2me output, as well as extending this approach to be an RSV primer multiplexing pipeline for Illumina data too.***

## Pipeline overview
Broadly the workflow consists of two modules, `ampli_clean` and the `ARTIC fieldbioinformatics` pipeline. 

`ampli_clean` is a standalone tool that selects the correct reference for a given set of reads (i.e. RSV A or RSV B in this case) and then "cleans” the resulting bam file to ensure only amplicons for the correct primer set are mapping to the genome. These cleaned reads are then passed to `fieldbioinformatics` for assembly. The use of `ampli_clean` and the `--strict` flag within fieldbioinformatics ensures no erroneous SNPs are introduced into the consensus genomes by incomplete primer trimming due to cross-scheme primer binding.

## Walkthrough

### Set up - epi2me
1.	You can download epi2me, from https://labs.epi2me.io/downloads/ and follow the installation instructions at https://labs.epi2me.io/installation/
2.	After successful installation of the epi2me platform you can "import" workflows for use. To do this, go to the "Workflows" tab and in the top right hand corner there is be a button labelled "import workflow". Click on this, and paste the URL for this repository in the box (https://github.com/artic-network/artic-rsv) and click install to download this workflow.

### Running - epi2me
1.	To run the epi2me workflow, select the workflow from "Installed" workflows tab. 
2.	Then select "Run this workflow". Currently the only mandatory field to fill in is the "fastq" directory path. This should be to the directory that contains your demultiplexed nanopore reads, typically the "fastq_pass" directory produced by your sequencing run. 
3.	The pipeline will then process each barcode directory independently and generate a consensus sequence.
Please note the first time you run this workflow it will take some time as it needs to download the Docker container to run the pipeline. It only needs to do this once.

### Set up - CLI
Alternatively this pipeline can also be run by cloning this repository:

`git clone https://github.com/artic-network/artic-rsv.git`

Then it can be run assuming you have already set up [nextflow](https://www.nextflow.io/). The pipeline can then be passed command line arguments like so:

`nextflow /path/to/RSV_nextflow/main.nf --fastq="/path/to/fastq_pass"`

The only required flag is --fastq but any of the other flags can be provided too, eg: `--min` and `--max`. See the nextflow.config file for possible flags.
