#! /bin/bash
#opt="Overview"
opt="seDycoreOverview"
#opt="cslam"
files=("FV.model_timing_stats"  "nsplit4_rsplit3_qsplit1_superc3_superc-jet3_tsteptype4.model_timing_stats" "2" "3")
#files=("nsplit4_rsplit6_qsplit1_superc3_superc-jet3_tsteptype4_cisl_opt_only.model_timing_stats" "nsplit4_rsplit6_qsplit1_superc3_superc-jet3_tsteptype4.model_timing_stats" "nsplit4_rsplit6_qsplit1_superc3_superc-jet3_tsteptype2.model_timing_stats" "nsplit4_rsplit6_qsplit1_superc6_superc-jet3_kmin32_tsteptype4.model_timing_stats"  "nsplit4_rsplit6_qsplit1_superc6_superc-jet6_LCI_tsteptype4.model_timing_stats" "nsplit4_rsplit6_qsplit1_superc6_superc-jet3_kmin32_tsteptype4_PCoMlev123.model_timing_stats" "FV.model_timing_stats  ")
#files=("nsplit4_rsplit6_qsplit1_superc6_superc-jet3_kmin32_tsteptype4.model_timing_stats"  "nsplit4_rsplit6_qsplit1_superc6_superc-jet6_LCI_tsteptype4.model_timing_stats" "nsplit4_rsplit6_qsplit1_superc6_superc-jet3_kmin32_tsteptype4_PCoMlev123.model_timing_stats" "nsplit4_rsplit6_qsplit1_superc6_superc-jet3_kmin32_tsteptype4_PCoMlev123.model_timing_stats_new nsplit4_rsplit6_qsplit1_superc6_superc-jet3_kmin32_tsteptype4_PCoMlev123.model_timing_stats_selective_zero" "1")
files=("nsplit4_rsplit6_qsplit1_superc6_superc-jet3_kmin32_tsteptype4.model_timing_stats"  "nsplit4_rsplit6_qsplit1_superc6_superc-jet6_LCI_tsteptype4.model_timing_stats" "nsplit4_rsplit6_qsplit1_superc6_superc-jet3_kmin32_tsteptype4_PCoMlev123.model_timing_stats" "nsplit4_rsplit6_qsplit1_superc6_superc-jet3_kmin32_tsteptype4_PCoMlev123.model_timing_stats_new" "nsplit4_rsplit6_qsplit1_superc6_superc-jet3_kmin32_tsteptype4_PCoMlev123.model_timing_stats_selective_zero" "1" "2")
#
# general overview: physics, dynamics, coupling, I/O
#
if [ $opt == "Overview" ]; then
names=("CPL:ATM_RUN      " 
       "a:phys_run1      " 
       "a:phys_run2      " 
       "\"a:dyn_run\"    " 
       "a:d_p_coupling   " 
       "a:p_d_coupling   " 
       "wshist           " 
       "cam_write_restart" 
       "cam_run4_wrapup  ")
fi
#
# SE dycore breakdown
#
if [ $opt == "seDycoreOverview" ]; then
names=("\"a:dyn_run\"             " 
       "vertical_remap          " 
       "prim_advance_exp        " 
       "compute_and_apply_rhs   " 
       "\"a:advance_hypervis\"    "  
       "prim_advec_tracers_remap" 
       "prim_advec_tracers_fvm  ")
echo "prim_advance_exp is frictionless dycore, hyperviscosity"
fi
if [ $opt == "cslam" ]; then
names=("prim_advec_tracers_fvm            "
       "fvm:before_Qnhc                   "
       "fvm:ghost_exchange:Qnhc           "
       "fvm:orthogonal_swept_areas        "
       "fvm:tracers_reconstruct           "
       "fvm:swept_flux                    "
       "fvm:fill_halo_fvm:large_Courant   "
       "fvm:large_Courant_number_increment")
fi
#
# CSLAM breakdown
#

#
#  cam_run1: stepon_run1 (FV: dyn_run, d_p_coupling;  SE: d_p_coupling), phys_run1    
#  cam_run2: phys_run2, stepon_run2 (FV: p_d_coupling; SE: p_d_coupling)
#  cam_run3: stepon_run3 (FV: Write max/min dyn state; SE: dyn_run)
#  cam_run4: history writes ('wshist'), restart ('cam_write_restart'), other file output ('cam_run4_wrapup')
#

#  dyn_run timer is dycore


#names=("CAM_run1" "CAM_run2" "CAM_run3" "CAM_run4" "CAM_adv_timestep")
#names=("prim_advec_tracers_fvm" "remap_Q_ppm           ")
#my_name=("cslam all" "tracer remapping")

header="         "
for file in "${files[@]}"; do 
  header=$header"   "$file
done
echo "$header"
echo " "
for name in "${names[@]}"; do 
  line="$name"
  for file in "${files[@]}"; do
    tmp=$(grep $name $file | awk '{print $6}')
    line=$line"   "$tmp
  done
  echo "$line "
done
