#!/bin/tcsh
setenv ACCOUNT_NO
setenv PBS_ACCOUNT P93300642
setenv src "opt-se-cslam"
setenv caze trunk-aug15-NTHRDS1_trunk_waccm_cslam_FW2000_1day
setenv pg3map "/glade/p/cgd/amp/pel/cslam-mapping-files"
setenv inic "/glade/p/cgd/amp/pel/inic"
echo "Do CSLAM mods in clm and cime:"
source clm_and_cime_mods_for_cslam.sh
echo "Done"
echo $caze
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset FW2000 --res ne30pg3_ne30pg3_mg17  --q regular --walltime 00:15:00 --pecount 2016  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
#./xmlchange STOP_OPTION=nmonths,STOP_N=13
./xmlchange STOP_OPTION=steps,STOP_N=5
./xmlchange DOUT_S=FALSE
./xmlchange CASEROOT=/glade/scratch/$USER/$caze
./xmlchange EXEROOT=/glade/scratch/$USER/$caze/bld
./xmlchange RUNDIR=/glade/scratch/$USER/$caze/run
## timing detail
./xmlchange NTHRDS=1
./xmlchange TIMER_LEVEL=10
##
./xmlchange GLC2LND_SMAPNAME=$pg3map/map_gland4km_TO_ne30pg3_aave.180510.nc
./xmlchange GLC2LND_FMAPNAME=$pg3map/map_gland4km_TO_ne30pg3_aave.180510.nc
./xmlchange LND2GLC_FMAPNAME=$pg3map/map_ne30pg3_TO_gland4km_aave.180515.nc
./xmlchange LND2GLC_SMAPNAME=$pg3map/map_ne30pg3_TO_gland4km_bilin.180515.nc
./xmlchange LND2ROF_FMAPNAME=$pg3map/map_ne30pg3_TO_0.5x0.5_nomask_aave_da_180515.nc
./xmlchange ROF2LND_FMAPNAME=$pg3map/map_0.5x0.5_nomask_TO_ne30pg3_aave_da_180515.nc
##

./xmlquery EXEROOT
./xmlquery CASEROOT

./case.setup

echo "fsurdat='$pg3map/surfdata_ne30np4.pg3_78pfts_CMIP6_simyr2000_c180228.nc'">>user_nl_clm

echo "se_statefreq       = 244"        >> user_nl_cam
echo "empty_htapes       = .true."   >> user_nl_cam
echo "fincl1             = 'PS','PSDRY','PSL','OMEGA','OMEGA500','OMEGA850','PRECL','PRECC',  "   >> user_nl_cam
echo "                     'PTTEND','OMEGAT','CLDTOT','TMQ','T','U','V','Q'    " >> user_nl_cam
echo "avgflag_pertape(1) = 'I'" >> user_nl_cam
echo "nhtfrq             = -24,-24 " >> user_nl_cam
echo "interpolate_output = .true.,.true." >> user_nl_cam

echo "ncdata = '$inic/20180516waccm_se_spinup_pe720_10days.cam.i.1974-01-02-00000.nc'"   >> user_nl_cam
echo "se_statefreq       = 244"   >> user_nl_cam
echo "se_nsplit          = 10"   >> user_nl_cam
echo "inithist           = 'DAILY'"   >> user_nl_cam
echo "se_hypervis_subcycle = 1"   >> user_nl_cam
echo "interpolate_output   = .true.,.true.,.true.,.true.,.true.,.true.,.true."   >> user_nl_cam

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
