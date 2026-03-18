outdir="ACEFILES"
FOLDER="H5FILES"
xs_xml_dir=/workspaces/sandy_workshop/openmc_data/jeff40_xs
PWD=`pwd`

mkdir -p $FOLDER
for i in {0..9}
do
	python /workspaces/sandy_workshop/openmc_data/openmc-ace-to-hdf5 ${outdir}/92234_${i}.03c; mv -v U234.h5 $FOLDER/U234_${i}.h5
    sed "s|U234.h5|${PWD}/${FOLDER}/U234_$i.h5|" <${xs_xml_dir}/cross_sections.xml >${xs_xml_dir}/cross_sections_${i}.xml
done