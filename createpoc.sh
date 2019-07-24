#!/usr/bin/env bash

#####
# Get Aladin.
#####

mkdir poctools
pushd poctools
wget http://aladin.unistra.fr/java/download/AladinBeta.jar
popd


#####
# Setup Python environment.
#####

python -m venv pocvenv
source pocvenv/bin/activate
pip install requests pillow


#####
# For two overlapping FITS files:
# * Fetch the FITS files,
# * Convert them to HiPS tiles,
# * Start the webserver.
#####

mkdir pocdata
pushd pocdata

mkdir fits1
wget -P fits1 http://ds.astro.rug.astro-wise.org:8000/Sci-JMCFARLAND-OMEGACAM-------OCAM_r_SDSS-ESO_CCD_%2366-Regr---Sci-56981.2866678-892f93277ec0f44eaaec225e48c2d8a370dd5e7e.fits
mkdir hips1
java -Xmx16g -jar ../poctools/AladinBeta.jar -hipsgen in=fits1 out=hips1 creator_did=HiPSID hips_pixel_cut="-33 3500" hips_data_range="-41000 120000" INDEX TILES PNG DETAILS CLEANFITS
python -m http.server 8101 --directory hips1 &

mkdir fits2
wget -P fits2 http://ds.astro.rug.astro-wise.org:8000/Sci-JMCFARLAND-OMEGACAM-------OCAM_r_SDSS-ESO_CCD_%2366-Regr---Sci-56981.2869923-3c338b3af3e4b211ff86e323ad4b4ac39507a1d9.fits
mkdir hips2
java -Xmx16g -jar ../poctools/AladinBeta.jar -hipsgen in=fits2 out=hips2 creator_did=HiPSID hips_pixel_cut="-33 3500" hips_data_range="-41000 120000" INDEX TILES PNG DETAILS CLEANFITS
python -m http.server 8102 --directory hips2 &

popd


#####
# Setup and start the HiPS Proxy
#####

mkdir pocdata/hipsauto
cp -avi pocdata/hips1/properties pocdata/hipsauto/properties
pushd pocdata/hipsauto
python ../../hipscombineproxy.py &
popd


#####
# Start Aladin
#####

java -jar poctools/AladinBeta.jar "http://localhost:8100"

# Aladin should now start and look like aladinpoc.png
