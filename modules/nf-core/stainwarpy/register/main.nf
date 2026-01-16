process STAINWARPY_REGISTER {
    tag "$meta.id"
    label 'process_single'

    container "community.wave.seqera.io/library/pip_stainwarpy:82fa38661931e2c1"

    input:
    tuple val(meta), path(hne_img), path(multiplx_img)
    val fixed_img
    val final_sz

    output:
    tuple val(meta), path("0_final_channel_image.ome.tif")             , emit: reg_image
    tuple val(meta), path("registration_metrics_tform_map.json")       , emit: reg_metrics_tform
    tuple val(meta), path("feature_based_transformation_map.npy")      , emit: tform_map
    // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    tuple val("${task.process}"), val('stainwarpy'), eval("echo 0.2.0"), emit: versions_stainwarpy_register, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    stainwarpy \\
        register \\
        ${multiplx_img} \\
        ${hne_img} \\
        . \\
        ${fixed_img} \\
        ${final_sz} \\
        ${args}

    mv registration_metrics_tfrom_map.json registration_metrics_tform_map.json
    """

    stub:

    """
    touch 0_final_channel_image.ome.tif
    touch registration_metrics_tform_map.json
    touch feature_based_transformation_map.npy
    """
}
