#!/bin/tcsh
sed -i  's/<model_grid alias="ne30pg3_ne30pg3_mg17" not_compset="_POP|_CLM">/<model_grid alias="ne30pg3_ne30pg3_mg17" not_compset="_POP">/g' ../cime/config/cesm/config_grids.xml
sed -i 's/"512x1024,360x720cru,128x256/"ne30np4.pg3,512x1024,360x720cru,128x256/g' ../components/clm/bld/namelist_files/namelist_definition_clm4_5.xml
