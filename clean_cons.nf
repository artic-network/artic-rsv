// Declare syntax version
nextflow.enable.dsl=2

// Script parameters
params.refs = "/home/dmmalone/RSV_analysis/testing_ground/RSV_refs.fasta"
params.bed = "/home/dmmalone/RSV_analysis/testing_ground/RSVA.primer.bed"
params.fastqIn = "/home/dmmalone/RSV_analysis/RSVLO_A_Run2/fastq_pass/*/*"

process ampliClean {
  input:
    tuple val(key), file(samples)
    path refs
    path bed
    
    
  output:
    path "${key}.RSVA.fastq.gz"
    val base

  script:
    base = key
    println key
    """
    ampli_clean -f ${samples} -r ${refs} -o ${key} -b ${bed} -s --fastq
    """
}

process articMinion {
  input:
    path input_reads
    val base

  output:
    path "${base}.consensus.fasta"

    """
    artic minion --medaka --threads 12 --scheme-directory /home/dmmalone/primer-schemes/ --read-file ${input_reads} --medaka-model r941_min_high_g303 RSVA/V1 ${base} 
    """
}

workflow {
  def ref_ch = Channel.value(params.refs)
  def bed_ch = Channel.value(params.bed)
  def fastqIn_ch = Channel.fromPath(params.fastqIn, checkIfExists:true) 
    | map { file -> 
      def key = file.parent.toString().tokenize('/').last()
      return tuple(key, file)
    } \
    | groupTuple()

  ampliClean(fastqIn_ch, ref_ch, bed_ch) | articMinion
}
