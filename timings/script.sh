#! /bin/bash

files=("B.model_timing_stats  " "C.model_timing_stats  ")
names=("prim_advec_tracers_fvm" "remap_Q_ppm           ")
my_name=("cslam all" "tracer remapping")

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
