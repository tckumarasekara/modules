process STAINWARPY_TRANSFORMSEGMASK {
    tag "$meta.id"
    label 'process_single'

    container "community.wave.seqera.io/library/pip_stainwarpy:333bade85f7f91f3"

    input:
    tuple val(meta), path(hne_img), path(multiplx_img), path(seg_mask), path(tform_map)
    val fixed_img
    val final_sz

    output:
    tuple val(meta), path("transformed_segmentation_mask.ome.tif")     , emit: transformed_seg_mask
    tuple val("${task.process}"), val('stainwarpy'), eval("stainwarpy --version | sed 's/.* //'"), emit: versions_stainwarpy_transformsegmask, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    stainwarpy \\
        transform-seg-mask \\
        ${seg_mask} \\
        ${multiplx_img} \\
        ${hne_img} \\
        . \\
        ${tform_map} \\
        ${fixed_img} \\
        ${final_sz} \\
        ${args}
    """

    stub:

    """
    touch transformed_segmentation_mask.ome.tif
    """
}
