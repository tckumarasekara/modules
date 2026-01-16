process STAINWARPY_EXTRACTCHANNEL {
    tag "$meta.id"
    label 'process_single'

    container "community.wave.seqera.io/library/pip_stainwarpy:82fa38661931e2c1"

    input:
    tuple val(meta), path(multiplx_img)

    output:
    tuple val(meta), path("multiplexed_single_channel_img.ome.tif")    , emit: single_ch_image
    // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    tuple val("${task.process}"), val('stainwarpy'), eval("echo 0.2.0"), emit: versions_stainwarpy_extractchannel, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    stainwarpy \\
        extract-channel \\
        ${multiplx_img} \\
        . \\
        ${args}
    """

    stub:

    """
    touch multiplexed_single_channel_img.ome.tif
    """
}
