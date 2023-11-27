process ampliClean {
  container "${params.wf.container}@${params.wf.container_sha}"

  publishDir path: "${params.outdir}/${barcode}/ampli_clean", mode: 'copy'

  input:
    tuple val(barcode), path(binned_reads)
    path refs
    path bed
    val min
    val max
    
    
  output:
    tuple val("${barcode}"), path("${barcode}.RSVA.fastq.gz")

  script:
    """
    ampli_clean -f ${binned_reads} -r ${refs} -o ${barcode} -b ${bed} --min ${min} --max ${max} -s --fastq
    """
}

process articMinion {
  container "${params.wf.container}@${params.wf.container_sha}"

  publishDir path: "${params.outdir}/${barcode}/artic", mode: 'copy'

  input:
    tuple val(barcode), path(input_reads)
    path schemes_dir

  output:
    path "${barcode}.consensus.fasta"

    """
    artic minion --medaka --threads 12 --scheme-directory ${schemes_dir} --read-file ${input_reads} --medaka-model r941_min_high_g303 RSVA/V1 ${barcode}
    """
}
//These lines for fastq dir parsing are taken from rmcolq's workflow https://github.com/rmcolq/pantheon
EXTENSIONS = ["fastq", "fastq.gz", "fq", "fq.gz"]

ArrayList get_fq_files_in_dir(Path dir) {
    return EXTENSIONS.collect { file(dir.resolve("*.$it"), type: "file") } .flatten()
}

workflow {
//Define input channels  
  ref_ch = file("${params.refs}")
  bed_ch = file("${params.bed}")
  schemes_dir_ch = file("${params.schemes_dir}")
  min_ch = Channel.value("${params.min}")
  max_ch = Channel.value("${params.max}")
//These lines for fastq dir parsing are taken from rmcolq's workflow https://github.com/rmcolq/pantheon
  run_dir = file("${params.fastq}", type: "dir", checkIfExists:true)
  barcode_input = Channel.fromPath("${run_dir}/*", type: "dir", checkIfExists:true, maxDepth:1).map { [it.baseName, get_fq_files_in_dir(it)]}

//Run the processes
  ampliClean(barcode_input, ref_ch, bed_ch, min_ch, max_ch)
  articMinion(ampliClean.out, schemes_dir_ch)
}
