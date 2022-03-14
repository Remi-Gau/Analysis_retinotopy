# README

Adapted from the notes from Tim Rohe.

## Starting freesurfer

```
setenv FREESURFER_HOME /Applications/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.csh

tkmedit bert orig.mgz

setenv               SUBJECTS_DIR /media/Data1/Freesurfer/subjects/Tim_Exp1_VE
```

#### important: anatomical must be coregistered to functional data before reconstruction!!!!!!!!!!!!!!!!

mri_convert /media/Data1/Freesurfer/subjects/VE_S1_1034/mri/sASY02_N22-0009-00001-000176-01.img /media/Data1/Freesurfer/subjects/VE_S1_1034/mri/001.mgz
mri_convert /media/Data1/Freesurfer/subjects/VE_S2_638/mri/sAB13_day3-0006-00001-000176-01.img /media/Data1/Freesurfer/subjects/VE_S2_638/mri/001.mgz
mri_convert /media/Data1/Freesurfer/subjects/VE_S5_2054/mri/RD.nii /media/Data1/Freesurfer/subjects/VE_S5_2054/mri/001.mgz
mri_convert /media/Data1/Freesurfer/subjects/VE_S6_2436/mri/sSTRUCTURAL_PILOT13-0002-00001-000176-01.img /media/Data1/Freesurfer/subjects/VE_S6_2436/mri/001.mgz

recon-all -autorecon-all -subject  VE_S1_1034
recon-all -autorecon-all -subject  VE_S2_638
recon-all -autorecon-all -subject  VE_S5_2054
recon-all -autorecon-all -subject  VE_S6_2436

# tkmedit is for img volumes
# load T1 and pial surface + grey/white boundary + segmentation data to check the segmentation process
tkmedit 01_TR_3 brainmask.mgz lh.white \ -aux T1.mgz -aux-surface rh.white \ -segmentation aseg.mgz $FREESURFER_HOME/FreeSurferColorLUT.txt

# for checking segmentation errors in inflated brain
tksurfer VE_S1_1034 rh inflated.nofix -curv rh.defect_labels

# to correct skull strip problems
recon-all -skullstrip -wsthresh 35 -clean-bm -no-wsgcaatlas -subject 01_TR_3 ; recon-all -subject 01_TR_3 -autorecon2 -autorecon3

# or use gcut
recon-all -skullstrip -clean-bm -gcut -subject 01_TR_2 ; recon-all -subject 01_TR_2 -autorecon2 -autorecon3


# for correction of segmentation errors


#tksurfer is for surfaces :)
tksurfer 01_TR lh pial

tksurfer 01_TR lh inflated

#### register functional to anatomical surface
tkregister2 --mov /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5RetPolar_cos_real.img --s 01_TR_3 --regheader --noedit --reg /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5_register.dat
#
tkregister2 --mov /media/Data1/Freesurfer/subjects/01_TR_3/functData/spmT_0025.img --s 01_TR_3 --regheader --noedit --reg /media/Data1/Freesurfer/subjects/01_TR_3/functData/functDat_register.dat


# compute flattended patch
mris_flatten -w 10 /media/Data1/Freesurfer/subjects/VE_S1_1034/surf/lh.occip.patch.3d /media/Data1/Freesurfer/subjects/VE_S1_1034/surf/lh.occip.flat.patch.3d
mris_flatten -w 10 /media/Data1/Freesurfer/subjects/VE_S1_1034/surf/rh.occip.patch.3d /media/Data1/Freesurfer/subjects/VE_S1_1034/surf/rh.occip.flat.patch.3d

#load flattened patch
tksurfer 01_TR_3 lh inflated -patch lh.occip.flat.patch.3d
tksurfer 01_TR_3 rh inflated -patch rh.occip.flat.patch.3d

### load flattened patch with overlays #####
## polar
# lh
tksurfer 01_TR_3 lh inflated -curv lh.curv -patch lh.occip.flat.patch.3d -overlay /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5RetPolar_cos_real.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5RetPolar_sin_imag.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5_register.dat 

tksurfer VE_S1_1034 lh inflated -curv lh.curv -overlay /media/Data1/Freesurfer/subjects/VE_S1_1034/retDat/Su1_RetPolar_cos_real.img -overlay-reg /media/Data1/Freesurfer/subjects/VE_S1_1034/retDat/retDat_register.dat -overlay /media/Data1/Freesurfer/subjects/VE_S1_1034/retDat/Su1_RetPolar_sin_imag.img -overlay-reg /media/Data1/Freesurfer/subjects/VE_S1_1034/retDat/retDat_register.dat 

tksurfer VE_S2_638 lh inflated -curv lh.curv -overlay /media/Data1/Freesurfer/subjects/VE_S2_638/retDat/Su2_RetPolar_cos_real.img -overlay-reg /media/Data1/Freesurfer/subjects/VE_S2_638/retDat/retDat_register.dat -overlay /media/Data1/Freesurfer/subjects/VE_S2_638/retDat/Su2_RetPolar_sin_imag.img -overlay-reg /media/Data1/Freesurfer/subjects/VE_S2_638/retDat/retDat_register.dat 

# rh
tksurfer 01_TR_3 rh inflated -curv rh.curv -patch rh.occip.flat.patch.3d -overlay /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5RetPolar_cos_real.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5RetPolar_sin_imag.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5_register.dat 

tksurfer VE_S5_2054 rh inflated -curv rh.curv -overlay /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/Su5_RetPolar_cos_real.img -overlay-reg /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/retDat_register.dat -overlay /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/Su5_RetPolar_sin_imag.img -overlay-reg /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/retDat_register.dat 

## ecc
# lh
tksurfer 01_TR_3 lh inflated -curv lh.curv -patch lh.occip.flat.patch.3d -overlay /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5RetEcc_cos_real.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5RetEcc_sin_imag.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5_register.dat 

tksurfer VE_S5_2054 lh inflated -curv lh.curv -overlay /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/Su5_RetEccen_cos_real.img -overlay-reg /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/retDat_register.dat -overlay /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/Su5_RetEccen_sin_imag.img -overlay-reg /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/retDat_register.dat 

tksurfer VE_S1_1034 lh inflated -curv lh.curv -overlay /media/Data1/Freesurfer/subjects/VE_S1_1034/retDat/Su1_RetEccen_cos_real.img -overlay-reg /media/Data1/Freesurfer/subjects/VE_S1_1034/retDat/retDat_register.dat -overlay /media/Data1/Freesurfer/subjects/VE_S1_1034/retDat/Su1_RetEccen_sin_imag.img -overlay-reg /media/Data1/Freesurfer/subjects/VE_S1_1034/retDat/retDat_register.dat 
# rh
tksurfer 01_TR_3 rh inflated -curv rh.curv -patch rh.occip.flat.patch.3d -overlay /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5RetEcc_cos_real.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5RetEcc_sin_imag.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_3/retDat/t5s5_register.dat 

##### combine labels
mri_mergelabels -i /media/Data1/Freesurfer/subjects/VE_S1_1034/label/lh_V1.label -i /media/Data1/Freesurfer/subjects/VE_S1_1034/label/lh_V1_e.label -o /media/Data1/Freesurfer/subjects/VE_S1_1034/label/lh_V1_e.label

###### convert label to ROI vol in space of main data which is later read out from ROIs
# combined lh & rh
1 = V1_e
2 = V2_e
3 = V3_e
4 = V3AB
5 = hV4
6 = LO
7 = hMT+
8 = IPS-0
9 = IPS-1
10 = IPS-2
11 = IPS-3
12 = IPS-4
13 = Transverse temp gyrus (as defined in aparc.a2009s.annot)
14 = Transverse temporal sulcus (as defined inaparc.a2009s.annot)
15 = Planum temporale (as defined in aparc.a2009s.annot)

# lh
mri_label2vol --label /media/Data1/Freesurfer/subjects/01_TR_3/label/lh_V1_e.label --label /media/Data1/Freesurfer/subjects/01_TR_3/label/lh_V2_e.label --label /media/Data1/Freesurfer/subjects/01_TR_3/label/lh_V3_e.label --label /media/Data1/Freesurfer/subjects/01_TR_3/label/lh_V3AB.label --label /media/Data1/Freesurfer/subjects/01_TR_3/label/lh_hV4.label --label /media/Data1/Freesurfer/subjects/01_TR_3/label/lh_LO.label --label /media/Data1/Freesurfer/subjects/01_TR_3/label/lh_hMT+.label --label /media/Data1/Freesurfer/subjects/01_TR_3/label/lh_IPS-0.label --label /media/Data1/Freesurfer/subjects/01_TR_3/label/lh_IPS-1.label --temp /media/Data1/Freesurfer/subjects/01_TR_3/functData/beta_0001.img --reg /media/Data1/Freesurfer/subjects/01_TR_3/functData/functDat_register.dat --fillthresh .3 --proj frac 0 1 .1 --subject 01_TR_3 --hemi lh  --o /media/Data1/Freesurfer/subjects/01_TR_3/ROI/VC_lh.nii

mri_label2vol --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh_V1_e.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh_V2_e.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh_V3_e.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh_V3AB.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh_hV4.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh_LO.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh_hMT+.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh_IPS-0.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh_IPS-1.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh_IPS-2.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh_IPS-3.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh_IPS-4.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh.G_temp_sup-G_T_transv.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh.S_temporal_transverse.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/lh.G_temp_sup-Plan_tempo.label --temp /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/Su5_RetPolar_cos_real.img --reg /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/retDat_register.dat --fillthresh .3 --proj frac 0 1 .1 --subject VE_S5_2054 --hemi lh  --o /media/Data1/Freesurfer/subjects/VE_S5_2054/ROI/S5_L_Hemi.nii

# rh
mri_label2vol --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh_V1_e.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh_V2_e.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh_V3_e.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh_V3AB.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh_hV4.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh_LO.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh_hMT+.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh_IPS-0.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh_IPS-1.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh_IPS-2.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh_IPS-3.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh_IPS-4.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh.G_temp_sup-G_T_transv.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh.S_temporal_transverse.label --label /media/Data1/Freesurfer/subjects/VE_S5_2054/label/rh.G_temp_sup-Plan_tempo.label --temp /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/Su5_RetPolar_cos_real.img --reg /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/retDat_register.dat --fillthresh .3 --proj frac 0 1 .1 --subject VE_S5_2054 --hemi rh  --o /media/Data1/Freesurfer/subjects/VE_S5_2054/ROI/S5_R_Hemi.nii


#####!!!Very important: check ROIs in original volume space !!!!!######
tkmedit VE_S5_2054 orig.mgz -overlay /media/Data1/Freesurfer/subjects/VE_S5_2054/ROI/S5_R_Hemi.nii -overlay-reg /media/Data1/Freesurfer/subjects/VE_S5_2054/retDat/retDat_register.dat -fthresh .5 -fmid 15

→ load label in tkmedit and compare congruence with 'ROI activation' (by selecting activation threshold ROI by ROI and sample type = nearest neighbour)

#### subcortical segm to ROI
--match xxx  is the code found in $FREESURFER_HOME/FreeSurferColorLUT.txt:
10   Left-Thalamus
49  Right-Thalamus 

mri_binarize --i /media/Data1/Freesurfer/subjects/VE_S5_2054/mri/aseg.mgz --match 10 --o /media/Data1/Freesurfer/subjects/VE_S5_2054/ROI/L_Thalamus.nii

mri_binarize --i /media/Data1/Freesurfer/subjects/VE_S5_2054/mri/aseg.mgz --match 49 --o /media/Data1/Freesurfer/subjects/VE_S5_2054/ROI/R_Thalamus.nii


######## create lables from annotation file created by Fressurfers automatic cortical parcellation
mri_annotation2label --subject VE_S5_2054 --hemi lh --annotation aparc.a2009s --outdir /media/Data1/Freesurfer/subjects/VE_S5_2054/label
mri_annotation2label --subject VE_S5_2054 --hemi rh --annotation aparc.a2009s --outdir /media/Data1/Freesurfer/subjects/VE_S5_2054/label


# convert bshort to Analyze format
mri_convert /media/Data1/Freesurfer/subjects/01_TR_2/ROI/VC_lh_RetSequ.bshort.bhdr /media/Data1/Freesurfer/subjects/01_TR_2/ROI/VC_lh_RetSequ2.img
mri_convert /media/Data1/Freesurfer/subjects/01_TR_2/ROI/VC_rh_RetSequ.bshort.bhdr /media/Data1/Freesurfer/subjects/01_TR_2/ROI/VC_rh_RetSequ2.img

mri_convert -it bshort -ot nii /media/Data1/Freesurfer/subjects/01_TR_2/ROI/VC_lh_BA1.bshort.bhdr /media/Data1/Freesurfer/subjects/01_TR_2/ROI/VC_lh_BA1.nii


%%%%---- overlay main exp data
# lh
tksurfer 01_TR_2 lh inflated -patch lh.occip.flat.patch.3d -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0025.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0026.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0027.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0028.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0029.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0030.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0031.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0032.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0033.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0034.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0035.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0036.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0037.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0038.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0039.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0040.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0041.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0042.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0043.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0044.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0045.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0046.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0047.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0048.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0049.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0050.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0051.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0052.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0053.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0054.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0055.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat -overlay /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/con_0056.img -overlay-reg /media/Data1/Freesurfer/subjects/01_TR_2/functData/4x4x2_s3_allTrials_01_TR_AllSessions/functDat_register.dat 


-labels-under /media/Data1/Freesurfer/subjects/01_TR_2/labels/lh_V1_e.label -labels-under /media/Data1/Freesurfer/subjects/01_TR_2/labels/lh_V2_e.label -labels-under /media/Data1/Freesurfer/subjects/01_TR_2/labels/lh_V1_3.label -labels-under /media/Data1/Freesurfer/subjects/01_TR_2/labels/lh_V3AB.label -labels-under /media/Data1/Freesurfer/subjects/01_TR_2/labels/lh_hV4.label -labels-under /media/Data1/Freesurfer/subjects/01_TR_2/labels/lh_LO.label -labels-under /media/Data1/Freesurfer/subjects/01_TR_2/labels/lh_hMT+.label -labels-under /media/Data1/Freesurfer/subjects/01_TR_2/labels/lh_IPS.label