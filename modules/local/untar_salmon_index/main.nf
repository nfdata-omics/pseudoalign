process UNTAR_SALMON_INDEX {
    tag "${archive}"
    label 'process_single'

    conda "conda-forge::sed=4.7 bioconda::grep=3.4 conda-forge::tar=1.34"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"

    input:
    path archive

    output:
    path "${prefix}", emit: untar
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = archive.baseName.toString().replaceFirst(/\.tar$/, "")
    """
    mkdir ${prefix}
    tar \\
        -C ${prefix} --strip-components 1 \\
        -xavf ${args} \\
        ${archive}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        untar: \$(echo \$(tar --version 2>&1) | sed 's/^.*(GNU tar) //; s/ Copyright.*\$//')
    END_VERSIONS
    """

    stub:
    prefix = archive.baseName.toString().replaceFirst(/\.tar$/, "")
    """
    mkdir ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        untar: \$(echo \$(tar --version 2>&1) | sed 's/^.*(GNU tar) //; s/ Copyright.*\$//')
    END_VERSIONS
    """
}
