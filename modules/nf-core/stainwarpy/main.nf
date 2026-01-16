process STAINWARPY {
    tag "$meta.id"
    label 'process_single'

    container "community.wave.seqera.io/library/pip_stainwarpy:82fa38661931e2c1"

    input:
    tuple val(meta), path(hne_img), path(multiplx_img), path(seg_mask)
    val fixed_img
    val final_sz

    output:
    tuple val(meta), path("0_final_channel_image.ome.tif")             , emit: reg_image
    tuple val(meta), path("registration_metrics_tform_map.json")       , emit: reg_metrics_tform
    tuple val(meta), path("transformed_segmentation_mask.ome.tif")     , emit: transformed_seg_mask
    // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    tuple val("${task.process}"), val('stainwarpy'), eval("echo 0.2.0"), emit: versions_stainwarpy, topic: versions
    when:
    task.ext.when == null || task.ext.when

    script:
    def args_cmd1 = task.ext.args_cmd1 ?: ''
    def args_cmd2 = task.ext.args_cmd2 ?: ''
    def args_cmd3 = task.ext.args_cmd3 ?: ''
    def multiplx_ch_image = "multiplexed_single_channel_img.ome.tif"
    def tform_map = "feature_based_transformation_map.npy"

    """
    stainwarpy \\
        extract-channel \\
        ${multiplx_img} \\
        . \\
        ${args_cmd1}

    stainwarpy \\
        register \\
        ${multiplx_ch_image} \\
        ${hne_img} \\
        . \\
        ${fixed_img} \\
        ${final_sz} \\
        ${args_cmd2}

    stainwarpy \\
        transform-seg-mask \\
        ${seg_mask} \\
        ${multiplx_ch_image} \\
        ${hne_img} \\
        . \\
        ${tform_map} \\
        ${fixed_img} \\
        ${final_sz} \\
        ${args_cmd3}

    mv registration_metrics_tfrom_map.json registration_metrics_tform_map.json
    rm ${multiplx_ch_image}
    rm ${tform_map}
    """

    stub:

    """
    touch 0_final_channel_image.ome.tif
    touch registration_metrics_tform_map.json
    touch transformed_segmentation_mask.ome.tif
    """
}
