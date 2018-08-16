#!/bin/tcsh
set PBS_ACCOUNT="P93300642"
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="opt-se-cslam"
#
# number of test tracers
#
setenv qsize "194" #there are already 6 tracers in FKESSLER!
set NTHRDS="1"
#
# run with CSLAM or without
#
set res=ne30pg3_ne30pg3_mg17 #cslam
#setenv res ne30_ne30_mg17        #no cslam
set stopoption="nsteps"
set steps="5"
#
# DO NOT MODIFY BELOW THIS LINE
#
set nlev="70"
set cset="FKESSLER"
#
# mapping files (not in cime yet)
#
set pg3map="/glade/p/cgd/amp/pel/cslam-mapping-files"
#
# location of initial condition file (not in CAM yet)
#
echo "Do CSLAM mods in clm and cime:"
source clm_and_cime_mods_for_cslam.sh
echo "Done"
if(`hostname` == 'hobart.cgd.ucar.edu') then
  echo "setting up for Hobart"
  set inic="/scratch/cluster/pel/inic"
  set homedir="/home"
  set scratch="/scratch/cluster"
  set queue="verylong"
  #
  # mapping files (not in cime yet)
  #
  set pg3map="/scratch/cluster/pel/cslam-mapping-files"
  set pecount="192"
else
  echo "setting up for Cheyenne"
  set inic="/glade/p/cgd/amp/pel/inic"
  set homedir="/glade/u/home"
  set scratch="/glade/scratch/"
  set queue="regular"
  #
  # mapping files (not in cime yet)
  #
  set pg3map="/glade/p/cgd/amp/pel/cslam-mapping-files"
  #
  # 900, 1800, 2700, 5400 (pecount should divide 6*30*30 evenly)
  #
  set pecount="900"
endif


set caze=${src}_${cset}_WACCM_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime 00:15:00 --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported

cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange CASEROOT=$scratch/$USER/$caze
./xmlchange EXEROOT=$scratch/$USER/$caze/bld
./xmlchange RUNDIR=$scratch/$USER/$caze/run
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
#./xmlchange --append CAM_CONFIG_OPTS="-nadv_tt=194" #there are already 6 tracers in FKESSLER
./xmlchange CAM_CONFIG_OPTS="-phys kessler -chem terminator -analytic_ic -nadv_tt=$qsize -nlev $nlev"
##
./xmlquery CAM_CONFIG_OPTS
./xmlquery EXEROOT
./xmlquery CASEROOT

./case.setup

if ($res == "ne30pg3_ne30pg3_mg17") then
  echo "fsurdat='$pg3map/surfdata_ne30np4.pg3_78pfts_CMIP6_simyr2000_c180228.nc'">>user_nl_clm
endif


if ($cset == "FKESSLER") then
cat >> $scratch/$USER/$caze/SourceMods/src.cam/dctest_baro_kessler.xml <<EOF
<?xml version="1.0"?>
<namelist_defaults>
<start_ymd> 10101 </start_ymd>
<empty_htapes>.true.</empty_htapes>
<avgflag_pertape>'I'</avgflag_pertape>
<nhtfrq>-24</nhtfrq>
<fincl1>
 'PS','PRECL'
</fincl1>
<fincl2>
 'Q','CLDLIQ','RAINQM','T','U','V','iCLy','iCL','iCL2','OMEGA'
</fincl2>
<analytic_ic_type>'baroclinic_wave'</analytic_ic_type>
</namelist_defaults>
EOF
endif

echo "se_statefreq       = 244"        >> user_nl_cam
echo "avgflag_pertape(1) = 'I'" >> user_nl_cam
echo "nhtfrq             = -24,-24 " >> user_nl_cam
echo "interpolate_output = .true.,.true." >> user_nl_cam
#
# 70 layer IC file
#
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

if(`hostname` == 'hobart.cgd.ucar.edu') then
  ./case.build
else
  qcmd -- ./case.build
endif
./case.submit
