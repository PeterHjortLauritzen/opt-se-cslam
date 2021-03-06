#!/bin/tcsh
setenv PBS_ACCOUNT "P03010039"
# P03010039
# P93300042
# P03010083
# P93300075
# P05010048
# P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="opt-se-cslam-master"
#
# run with CSLAM or without
#
set res="ne30pg3_ne30pg3_mg17" #cslam
#set res="ne30_ne30_mg17"      #no cslam

set climateRun="True"
#set climateRun="False"
#set energyConsistency="True"
set energyConsistency="False"
set test_tracers="False"
#
# DO NOT MODIFY BELOW THIS LINE
#
set cset="FW2000"
#set cset="F2000climo"
#set cset="FHS94"
#
# mapping files (not in cime yet)
#
set pg3map="/glade/p/cgd/amp/pel/cslam-mapping-files"
#
# location of initial condition file (not in CAM yet)
#
set inic="/glade/p/cgd/amp/pel/inic"
echo "Do CSLAM mods in clm and cime:"
source clm_and_cime_mods_for_cslam.sh
echo "Done"
if ($climateRun == "True") then
  set walltime="09:00:00"
#  set walltime="02:00:00"
  #
  # 900, 1800, 2700, 5400 (pecount should divide 6*30*30 evenly)
  #
  set pecount="5400"
#  set pecount="2700"
  set NTHRDS="1"
  set stopoption="nmonths"
  set steps="12"
#  set steps="2"
else
  set walltime="00:15:00"
  set pecount="450"
  set NTHRDS="1"
  set stopoption="nsteps"
  set steps="5"
endif
if ($test_tracers == "True") then
    set caze=nadv_climateRun${climateRun}_energyConsistency${energyConsistency}_${src}_${cset}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
else
    set caze=regular_del4_above40_${src}_${cset}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
endif
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q regular --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
#./xmlchange CASEROOT=/glade/scratch/$USER/$caze
#./xmlchange EXEROOT=/glade/scratch/$USER/$caze/bld
#./xmlchange RUNDIR=/glade/scratch/$USER/$caze/run

if ($test_tracers == "True") then
    ./xmlchange --append CAM_CONFIG_OPTS="-cppdefs -Dwaccm_debug -nadv_tt=5"
else
   if ($res == "ne30pg3_ne30pg3_mg17") then
      ./xmlchange --append CAM_CONFIG_OPTS="-cppdefs -Dwaccm_debug"
   endif
endif
#./xmlchange DEBUG=TRUE #xxxx
#
./xmlchange NTHRDS=$NTHRDS
## timing detail
./xmlchange TIMER_LEVEL=10
##
if ($res == "ne30pg3_ne30pg3_mg17") then
  ./xmlchange GLC2LND_SMAPNAME=$pg3map/map_gland4km_TO_ne30pg3_aave.180510.nc
  ./xmlchange GLC2LND_FMAPNAME=$pg3map/map_gland4km_TO_ne30pg3_aave.180510.nc
  ./xmlchange LND2GLC_FMAPNAME=$pg3map/map_ne30pg3_TO_gland4km_aave.180515.nc
  ./xmlchange LND2GLC_SMAPNAME=$pg3map/map_ne30pg3_TO_gland4km_bilin.180515.nc
  ./xmlchange LND2ROF_FMAPNAME=$pg3map/map_ne30pg3_TO_0.5x0.5_nomask_aave_da_180515.nc
  ./xmlchange ROF2LND_FMAPNAME=$pg3map/map_0.5x0.5_nomask_TO_ne30pg3_aave_da_180515.nc
endif
##

./xmlquery EXEROOT
./xmlquery CASEROOT

./case.setup

if ($res == "ne30pg3_ne30pg3_mg17") then
  echo "fsurdat='$pg3map/surfdata_ne30np4.pg3_78pfts_CMIP6_simyr2000_c180228.nc'">>user_nl_clm
endif
#if ($res == "ne30_ne30_mg17") then
#  echo "fsurdat='/glade/p/cesmdata/cseg/inputdata/lnd/clm2/surfdata_map/surfdata_ne30np4_simyr2000_c110801.nc'">>user_nl_clm
#endif
#echo "se_hypervis_subcycle = 2"   >> user_nl_cam
#echo " se_variable_nsplit = .false."   >> user_nl_cam #xxx

#echo " se_nsplit = 5"   >> user_nl_cam #xxx
#echo " se_rsplit = 6"   >> user_nl_cam #xxx

if ($energyConsistency == "True") then
  echo "se_ftype =  1	">>user_nl_cam
  echo "se_qsize_condensate_loading = 1" >>user_nl_cam
  echo "se_lcp_moist = .false." >>user_nl_cam
endif
#
#  ERROR: 
# setup_interpolation_and_define_vector_complements: No meridional match for UTGW
# ORO
#
echo "fincl2 = 'PS'" >> user_nl_cam #to avoid errors
echo "fincl8 = 'PS'" >> user_nl_cam #to avoid errors

if ($climateRun == "True") then
    echo "se_statefreq       = 244"        >> user_nl_cam
    if ($cset == "FHS94") then
    else
	echo "empty_htapes       = .true."   >> user_nl_cam
    echo "fincl1            = 'PS','PSDRY','PSL','OMEGA','OMEGA500','OMEGA850','PRECL','PRECC',     ">> user_nl_cam
   if ($res == "ne30_ne30_mg17") then
     echo "                    'PTTEND','FT','OMEGAT','CLDTOT','TMQ','ABS_dPSdt','FU','FV','U','V','T'  ">> user_nl_cam
   endif
   if ($res == "ne30pg3_ne30pg3_mg17") then
     echo "                    'PTTEND','FT','OMEGAT','CLDTOT','TMQ','ABS_dPSdt','CSLAM_gamma','FU','FV','U','V','T'  ">> user_nl_cam
    endif
   if ($res == "f09_f09_mg17") then
     echo "                    'PTTEND','FT','OMEGAT','CLDTOT','TMQ'  ">> user_nl_cam
    endif

    endif
    echo "avgflag_pertape(1) = 'A'"                                                    >> user_nl_cam
    echo "avgflag_pertape(2) = 'A'"                                                    >> user_nl_cam
    echo "avgflag_pertape(3) = 'A'"                                                    >> user_nl_cam
    echo "avgflag_pertape(4) = 'A'"                                                    >> user_nl_cam
    echo "nhtfrq             = 0,0,0,0                                             ">> user_nl_cam
    echo "interpolate_output = .true.,.true.,.false.,.true."       	   >> user_nl_cam
    echo "ndens              = 2,2,1,2                                            ">> user_nl_cam
    echo "restart_n = 1" >> user_nl_cam
    if ($cset == "FHS94") then
	echo "fincl3 =   'SE_pBF','KE_pBF', ">> user_nl_cam
	echo "           'SE_pBP','KE_pBP', ">> user_nl_cam
	echo "           'SE_pAP','KE_pAP', ">> user_nl_cam
	echo "           'SE_pAM','KE_pAM', ">> user_nl_cam
	echo "           'SE_dED','KE_dED', ">> user_nl_cam
	echo "           'SE_dAF','KE_dAF', ">> user_nl_cam
	echo "           'SE_dBD','KE_dBD', ">> user_nl_cam
	echo "           'SE_dAD','KE_dAD', ">> user_nl_cam
	echo "           'SE_dAR','KE_dAR', ">> user_nl_cam
	echo "           'SE_dBF','KE_dBF', ">> user_nl_cam
	echo "           'SE_dBH','KE_dBH', ">> user_nl_cam
	echo "           'SE_dCH','KE_dCH', ">> user_nl_cam
	echo "           'SE_dAH','KE_dAH', ">> user_nl_cam
	echo "           'SE_p2d','KE_p2d' ">> user_nl_cam
    else
	echo "fincl3 =   'WV_pBF','WL_pBF','WI_pBF','SE_pBF','KE_pBF', ">> user_nl_cam
	echo "           'WV_pBP','WL_pBP','WI_pBP','SE_pBP','KE_pBP', ">> user_nl_cam
	echo "           'WV_pAP','WL_pAP','WI_pAP','SE_pAP','KE_pAP', ">> user_nl_cam
	echo "           'WV_pAM','WL_pAM','WI_pAM','SE_pAM','KE_pAM', ">> user_nl_cam
	echo "           'WV_dED','WL_dED','WI_dED','SE_dED','KE_dED', ">> user_nl_cam
	echo "           'WV_dAF','WL_dAF','WI_dAF','SE_dAF','KE_dAF', ">> user_nl_cam
	echo "           'WV_dBD','WL_dBD','WI_dBD','SE_dBD','KE_dBD', ">> user_nl_cam
	echo "           'WV_dAD','WL_dAD','WI_dAD','SE_dAD','KE_dAD', ">> user_nl_cam
	echo "           'WV_dAR','WL_dAR','WI_dAR','SE_dAR','KE_dAR', ">> user_nl_cam
	echo "           'WV_dBF','WL_dBF','WI_dBF','SE_dBF','KE_dBF', ">> user_nl_cam
	echo "           'WV_dBH','WL_dBH','WI_dBH','SE_dBH','KE_dBH', ">> user_nl_cam
	echo "           'WV_dCH','WL_dCH','WI_dCH','SE_dCH','KE_dCH', ">> user_nl_cam
	echo "           'WV_dAH','WL_dAH','WI_dAH','SE_dAH','KE_dAH', ">> user_nl_cam
	echo "           'WV_p2d','WL_p2d','WI_p2d','SE_p2d','KE_p2d', ">> user_nl_cam
	echo "           'WV_PDC','WL_PDC','WI_PDC'                    ">> user_nl_cam
    endif
#  echo "fincl4 =   'WV_pBF','WL_pBF','WI_pBF','SE_pBF','KE_pBF', ">> user_nl_cam
#  echo "           'WV_pBP','WL_pBP','WI_pBP','SE_pBP','KE_pBP', ">> user_nl_cam
#  echo "           'WV_pAP','WL_pAP','WI_pAP','SE_pAP','KE_pAP', ">> user_nl_cam
#  echo "           'WV_pAM','WL_pAM','WI_pAM','SE_pAM','KE_pAM', ">> user_nl_cam
#  echo "           'WV_dED','WL_dED','WI_dED','SE_dED','KE_dED', ">> user_nl_cam
#  echo "           'WV_dAF','WL_dAF','WI_dAF','SE_dAF','KE_dAF', ">> user_nl_cam
#  echo "           'WV_dBD','WL_dBD','WI_dBD','SE_dBD','KE_dBD', ">> user_nl_cam
#  echo "           'WV_dAD','WL_dAD','WI_dAD','SE_dAD','KE_dAD', ">> user_nl_cam
#  echo "           'WV_dAR','WL_dAR','WI_dAR','SE_dAR','KE_dAR', ">> user_nl_cam
#  echo "           'WV_dBF','WL_dBF','WI_dBF','SE_dBF','KE_dBF', ">> user_nl_cam
#  echo "           'WV_dBH','WL_dBH','WI_dBH','SE_dBH','KE_dBH', ">> user_nl_cam
#  echo "           'WV_dCH','WL_dCH','WI_dCH','SE_dCH','KE_dCH', ">> user_nl_cam
#  echo "           'WV_dAH','WL_dAH','WI_dAH','SE_dAH','KE_dAH', ">> user_nl_cam
#  echo "           'WV_p2d','WL_p2d','WI_p2d','SE_p2d','KE_p2d', ">> user_nl_cam
#  echo "           'WV_PDC','WL_PDC','WI_PDC'                    ">> user_nl_cam
    echo "inithist           = 'YEARLY'"   >> user_nl_cam
else
  echo "inithist           = 'DAILY'"   >> user_nl_cam
  echo "se_statefreq       = 1"        >> user_nl_cam
  echo "empty_htapes       = .true."   >> user_nl_cam
  echo "fincl1             = 'PS','PSDRY','PSL','OMEGA','OMEGA500','OMEGA850','PRECL','PRECC',  "   >> user_nl_cam
  echo "                    'PTTEND','FT','OMEGAT','CLDTOT','TMQ','ABS_dPSdt'  ">> user_nl_cam
#  echo "                    'PTTEND','FT','OMEGAT','CLDTOT','TMQ','ABS_dPSdt','CSLAM_gamma'  ">> user_nl_cam
  if ($test_tracers == "True") then
    echo "fincl2 = 'TT_LW', 'TT_MD', 'TT_HI', 'TTRMD' , 'TT_UN'" >> user_nl_cam
  endif
#  echo "                     'PTTEND','OMEGAT','CLDTOT','TMQ','T','U','V','Q'" >> user_nl_cam
  echo "avgflag_pertape(1) = 'I'" >> user_nl_cam
  echo "avgflag_pertape(2) = 'I'" >> user_nl_cam
  echo "nhtfrq             = 1,1 " >> user_nl_cam
  echo "interpolate_output = .true.,.true." >> user_nl_cam
endif

if ($cset == "FW2000") then
#  echo "se_nsplit = 4" >> user_nl_cam
#  echo "se_fvm_supercycling     = 7" >> user_nl_cam
#  echo "se_fvm_supercycling_jet = 7" >> user_nl_cam
  if ($res == "ne30pg3_ne30pg3_mg17") then
    echo "ncdata = '$inic/waccm.i.spinup.nc'" >> user_nl_cam
  else
    echo "ncdata = '$inic/20180516waccm_se_spinup_pe720_10days.cam.i.1974-01-02-00000.nc'"   >> user_nl_cam
  endif
endif
if ($cset == "FKESSLER") then
  echo "ncdata = '$inic/trunk-F2000climo-30yrs-C60topo.cam.i.0023-02-01-00000.nc'"   >> user_nl_cam
endif





#
# spinup
#
#echo "se_nsplit = 120" >> user_nl_cam
#echo "inithist='6-HOURLY'" >> user_nl_cam
#echo "se_hypervis_on_plevs = .false." >> user_nl_cam
#echo "se_nu_top =  1.0e6"   >> user_nl_cam
#
#echo "se_nu     =  0.1E17" >> user_nl_cam
#echo "se_nu_div =  0.1E17" >> user_nl_cam
#echo "se_nu_p   =  0.1E17" >> user_nl_cam
#echo "se_hypervis_subcycle = 3" >> user_nl_cam

qcmd -- ./case.build
./case.submit
