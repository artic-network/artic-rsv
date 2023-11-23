process ampliClean {
  container "${params.wf.container}@${params.wf.container_sha}"
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
  container "${params.wf.container}@${params.wf.container_sha}"
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
  ref_ch = file(params.refs)
  bed_ch = file(params.bed)
  fastqIn_ch = Channel.fromPath(params.fastq, checkIfExists:true)
    | map { file -> 
      def key = file.parent.toString().tokenize('/').last()
      return tuple(key, file)
    } \
    | groupTuple()

  ampliClean(fastqIn_ch, ref_ch, bed_ch) | articMinion
}
