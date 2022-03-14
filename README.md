# README

Adapted from the notes from Tim Rohe.

## Starting freesurfer

```bash
setenv FREESURFER_HOME /Applications/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.csh

tkmedit bert orig.mgz
setenv  SUBJECTS_DIR ${path_to_data}
```

**important**

anatomical must be coregistered to functional data before reconstruction!

## recon--all

```bash
subject=${subject}
path_to_data=FIXME
mri_convert ${path_to_data}/${subject}/mri/sASY02_N22-0009-00001-000176-01.img \
            ${path_to_data}/${subject}/mri/001.mgz

recon-all -autorecon-all -subject  ${subject}
```

## Checking segmentation errors in volumes

`tkmedit` is for img volumes.

Load T1 and pial surface + grey/white boundary + segmentation data to check the
segmentation process.

```bash
tkmedit ${subject} brainmask.mgz lh.white \
        -aux T1.mgz -aux-surface rh.white \
        -segmentation aseg.mgz $FREESURFER_HOME/FreeSurferColorLUT.txt
```

## Checking segmentation errors in inflated brain

tksurfer is for surfaces :)

```bash
tksurfer ${subject} rh inflated.nofix -curv rh.defect_labels
```

## Correct skull strip problems

```bash
recon-all -skullstrip -wsthresh 35 -clean-bm -no-wsgcaatlas -subject ${subject}
recon-all -subject ${subject} -autorecon2 -autorecon3
```

or use gcut

```bash
recon-all -skullstrip -clean-bm -gcut -subject ${subject}
```

```bash
recon-all -subject ${subject} -autorecon2 -autorecon3
```

## Correction of segmentation errors

```bash
tksurfer ${subject} lh pial
tksurfer ${subject} lh inflated
```

## register functional to anatomical surface

```bash
tkregister2 --mov ${path_to_data}/${subject}/glm_retinotopy/RetPolar_cos_real.img \
    --s ${subject} --regheader --noedit \
    --reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
```

## compute flattended patch

```bash
mris_flatten -w 10 \
    ${path_to_data}/${subject}/surf/lh.occip.patch.3d \
    ${path_to_data}/${subject}/surf/lh.occip.flat.patch.3d

mris_flatten -w 10 \
    ${path_to_data}/${subject}/surf/rh.occip.patch.3d \
    ${path_to_data}/${subject}/surf/rh.occip.flat.patch.3d
```

## load flattened patch

```bash
tksurfer ${subject} lh inflated -patch lh.occip.flat.patch.3d
tksurfer ${subject} rh inflated -patch rh.occip.flat.patch.3d
```

## load flattened patch with overlays

### Polar

#### lh

```bash
tksurfer ${subject} lh inflated -curv lh.curv -patch lh.occip.flat.patch.3d \
    -overlay ${path_to_data}/${subject}/glm_retinotopy/RetPolar_cos_real.img \
    -overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat \
    -overlay ${path_to_data}/${subject}/glm_retinotopy/RetPolar_sin_imag.img \
    -overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
```

#### rh

```bash
tksurfer ${subject} rh inflated -curv rh.curv -patch rh.occip.flat.patch.3d \
    -overlay ${path_to_data}/${subject}/glm_retinotopy/RetPolar_cos_real.img \
    -overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat \
    -overlay ${path_to_data}/${subject}/glm_retinotopy/RetPolar_sin_imag.img \
    -overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
```

### Eccentriciy

#### lh

```bash
tksurfer ${subject} lh inflated -curv lh.curv -patch lh.occip.flat.patch.3d \
    -overlay ${path_to_data}/${subject}/glm_retinotopy/RetEcc_cos_real.img \
    -overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat \
    -overlay ${path_to_data}/${subject}/glm_retinotopy/RetEcc_sin_imag.img \
    -overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
```

#### rh

```bash
tksurfer ${subject} rh inflated -curv rh.curv -patch rh.occip.flat.patch.3d \
    -overlay ${path_to_data}/${subject}/glm_retinotopy/RetEcc_cos_real.img \
    -overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat \
    -overlay ${path_to_data}/${subject}/glm_retinotopy/RetEcc_sin_imag.img \
    -overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
```

## combine labels

```bash
mri_mergelabels -i ${path_to_data}/${subject}/label/lh_V1.label \
                -i ${path_to_data}/${subject}/label/lh_V1_e.label \
                -o ${path_to_data}/${subject}/label/lh_V1_e.label
```

## convert label to ROI vol in space of main data

which is later read out from ROIs

- 1 = V1_e
- 2 = V2_e
- 3 = V3_e
- 4 = V3AB
- 5 = hV4
- 6 = LO
- 7 = hMT+
- 8 = IPS-0
- 9 = IPS-1
- 10 = IPS-2
- 11 = IPS-3
- 12 = IPS-4
- 13 = Transverse temp gyrus (as defined in aparc.a2009s.annot)
- 14 = Transverse temporal sulcus (as defined inaparc.a2009s.annot)
- 15 = Planum temporale (as defined in aparc.a2009s.annot)

### lh

```bash
mri_label2vol --label ${path_to_data}/${subject}/label/lh_V1_e.label \
    --label ${path_to_data}/${subject}/label/lh_V2_e.label \
    --label ${path_to_data}/${subject}/label/lh_V3_e.label \
    --label ${path_to_data}/${subject}/label/lh_V3AB.label \
    --label ${path_to_data}/${subject}/label/lh_hV4.label \
    --label ${path_to_data}/${subject}/label/lh_LO.label \
    --label ${path_to_data}/${subject}/label/lh_hMT+.label \
    --label ${path_to_data}/${subject}/label/lh_IPS-0.label \
    --label ${path_to_data}/${subject}/label/lh_IPS-1.label \
    --temp ${path_to_data}/${subject}/glm_retinotopy/beta_0001.img \
    --reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat\
    --fillthresh .3 \
    --proj frac 0 1 .1 \
    --subject ${subject} \
    --hemi lh \
    --o ${path_to_data}/${subject}/ROI/VC_lh.nii
```

### rh

```bash
mri_label2vol --label ${path_to_data}/${subject}/label/rh_V1_e.label
    --label ${path_to_data}/${subject}/label/rh_V2_e.label
    --label ${path_to_data}/${subject}/label/rh_V3_e.label
    --label ${path_to_data}/${subject}/label/rh_V3AB.label
    --label ${path_to_data}/${subject}/label/rh_hV4.label
    --label ${path_to_data}/${subject}/label/rh_LO.label
    --label ${path_to_data}/${subject}/label/rh_hMT+.label
    --label ${path_to_data}/${subject}/label/rh_IPS-0.label
    --label ${path_to_data}/${subject}/label/rh_IPS-1.label
    --label ${path_to_data}/${subject}/label/rh_IPS-2.label
    --label ${path_to_data}/${subject}/label/rh_IPS-3.label
    --label ${path_to_data}/${subject}/label/rh_IPS-4.label
    --label ${path_to_data}/${subject}/label/rh.G_temp_sup-G_T_transv.label
    --label ${path_to_data}/${subject}/label/rh.S_temporal_transverse.label
    --label ${path_to_data}/${subject}/label/rh.G_temp_sup-Plan_tempo.label
    --temp ${path_to_data}/${subject}/glm_retinotopy/RetPolar_cos_real.img
    --reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
    --fillthresh .3
    --proj frac 0 1 .1
    --subject ${subject}
    --hemi rh
    --o ${path_to_data}/${subject}/ROI/VC_rh.nii
```

**Very important** check ROIs in original volume space !!!!!

load labels in tkmedit and compare congruence with 'ROI activation' (by
selecting activation threshold ROI by ROI and sample type = nearest neighbour)

```bash
tkmedit ${subject} orig.mgz \
    -overlay ${path_to_data}/${subject}/ROI/VC_rh.nii \
    -overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat \
    -fthresh .5 -fmid 15
```

## Subcortical segmentation to ROI

--match xxx is the code found in `$FREESURFER_HOME/FreeSurferColorLUT.txt`:

- 10 = Left-Thalamus
- 49 = Right-Thalamus

```bash
mri_binarize --i ${path_to_data}/${subject}/mri/aseg.mgz \
    --match 10 \
    --o ${path_to_data}/${subject}/ROI/L_Thalamus.nii

mri_binarize --i ${path_to_data}/${subject}/mri/aseg.mgz \
    --match 49 \
    --o ${path_to_data}/${subject}/ROI/R_Thalamus.nii
```

## Create labels from annotation file created by Fressurfer parcellation

```bash
mri_annotation2label --subject ${subject}  \
    --hemi lh \
    --annotation aparc.a2009s  \
    --outdir ${path_to_data}/${subject}/label mri_annotation2label  \
    --subject ${subject} \
    --hemi rh  \
    --annotation aparc.a2009s  \
    --outdir ${path_to_data}/${subject}/label
```

# convert bshort to analyze format

```bash
mri_convert ${path_to_data}/${subject}/ROI/VC_lh_RetSequ.bshort.bhdr \
    ${path_to_data}/${subject}/ROI/VC_lh_RetSequ2.img

mri_convert ${path_to_data}/${subject}/ROI/VC_rh_RetSequ.bshort.bhdr \
    ${path_to_data}/${subject}/ROI/VC_rh_RetSequ2.img

mri_convert -it bshort -ot nii \
    ${path_to_data}/${subject}/ROI/VC_lh_BA1.bshort.bhdr \
    ${path_to_data}/${subject}/ROI/VC_lh_BA1.nii
```

## overlay main exp data

# lh

```bash
tksurfer ${subject} lh inflated -patch lh.occip.flat.patch.3d 
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0025.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0026.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0027.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0028.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0029.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0030.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0031.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0032.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0033.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0034.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0035.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0036.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0037.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0038.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0039.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0040.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0041.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0042.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0043.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0044.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0045.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0046.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0047.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0048.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0049.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0050.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0051.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0052.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0053.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0054.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0055.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-overlay ${path_to_data}/${subject}/glm_retinotopy/con_0056.img
-overlay-reg ${path_to_data}/${subject}/glm_retinotopy/${subject}_register.dat
-labels-under ${path_to_data}/${subject}/labels/lh_V1_e.label 
-labels-under ${path_to_data}/${subject}/labels/lh_V2_e.label 
-labels-under ${path_to_data}/${subject}/labels/lh_V1_3.label 
-labels-under ${path_to_data}/${subject}/labels/lh_V3AB.label 
-labels-under ${path_to_data}/${subject}/labels/lh_hV4.label 
-labels-under ${path_to_data}/${subject}/labels/lh_LO.label 
-labels-under ${path_to_data}/${subject}/labels/lh_hMT+.label 
-labels-under ${path_to_data}/${subject}/labels/lh_IPS.label
```
