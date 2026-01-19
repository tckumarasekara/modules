//
// Register H&E stained and multiplexed tissue images and transform segmentation masks using stainwarpy
//

include { STAINWARPY_REGISTER             } from '../../../modules/nf-core/stainwarpy/register/main'
include { STAINWARPY_EXTRACTCHANNEL       } from '../../../modules/nf-core/stainwarpy/extractchannel/main'
include { STAINWARPY_TRANSFORMSEGMASK     } from '../../../modules/nf-core/stainwarpy/transformsegmask/main'

workflow TIF_REGISTRATION_STAINWARPY {

    take:
    ch_hne              // channel: [ val(meta), [ path to .tif ] ]
    ch_multiplexed      // channel: [ val(meta), [ path to .tif ] ]
    ch_segmask          // channel: [ val(meta), [ path to .tif ] ]
    val_fixed_img       // val: fixed image to use ("multiplexed" or "hne")
    val_final_img_sz    // val: final image size to use ("multiplexed" or "hne")

    main:
    ch_versions = channel.empty()

    if ( val_fixed_img == 'multiplexed') {
        STAINWARPY_EXTRACTCHANNEL ( ch_multiplexed )
        ch_versions = ch_versions.mix(STAINWARPY_EXTRACTCHANNEL.out.versions_stainwarpy_extractchannel.first())

        STAINWARPY_REGISTER ( ch_hne, STAINWARPY_EXTRACTCHANNEL.out.single_ch_image,  val_fixed_img, val_final_img_sz )
        ch_versions = ch_versions.mix(STAINWARPY_REGISTER.out.versions_stainwarpy_register.first())

        STAINWARPY_TRANSFORMSEGMASK ( ch_hne, STAINWARPY_EXTRACTCHANNEL.out.single_ch_image, ch_segmask, STAINWARPY_REGISTER.out.tform_map, val_fixed_img, val_final_img_sz )
        ch_versions = ch_versions.mix(STAINWARPY_TRANSFORMSEGMASK.out.versions_stainwarpy_transformsegmask.first())
    } else {
        STAINWARPY_REGISTER ( ch_hne, ch_multiplexed, val_fixed_img, val_final_img_sz )
        ch_versions = ch_versions.mix(STAINWARPY_REGISTER.out.versions_stainwarpy_register.first())

        STAINWARPY_TRANSFORMSEGMASK ( ch_hne, ch_multiplexed, ch_segmask, STAINWARPY_REGISTER.out.tform_map, val_fixed_img, val_final_img_sz )
        ch_versions = ch_versions.mix(STAINWARPY_TRANSFORMSEGMASK.out.versions_stainwarpy_transformsegmask.first())
    }

    emit:
    img_tformed         = STAINWARPY_REGISTER.out.reg_image                     // channel: [ val(meta), [ 0_final_channel_image.ome.tif          ] ]
    segmask_tformed     = STAINWARPY_TRANSFORMSEGMASK.out.transformed_seg_mask  // channel: [ val(meta), [ transformed_segmentation_mask.ome.tif  ] ]
    metrics_tform_map   = STAINWARPY_REGISTER.out.reg_metrics_tform             // channel: [ val(meta), [ registration_metrics_tform_map.json    ] ]
    versions            = ch_versions
}
