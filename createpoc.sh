#!/usr/bin/env bash

mkdir poctools
pushd poctools
wget http://aladin.unistra.fr/java/download/AladinBeta.jar
popd


mkdir pocdata
pushd pocdata

mkdir fits1
wget -P fits1 http://ds.astro.rug.astro-wise.org:8000/Sci-JMCFARLAND-OMEGACAM-------OCAM_r_SDSS-ESO_CCD_%2366-Regr---Sci-56981.2866678-892f93277ec0f44eaaec225e48c2d8a370dd5e7e.fits
mkdir hips1
java -Xmx16g -jar ../poctools/AladinBeta.jar -hipsgen in=fits1 out=hips1 creator_did=HiPSID INDEX TILES PNG DETAILS CLEANFITS


mkdir fits2
wget -P fits2 http://ds.astro.rug.astro-wise.org:8000/Sci-JMCFARLAND-OMEGACAM-------OCAM_r_SDSS-ESO_CCD_%2366-Regr---Sci-56981.2869923-3c338b3af3e4b211ff86e323ad4b4ac39507a1d9.fits
mkdir hips2
java -Xmx16g -jar ../poctools/AladinBeta.jar -hipsgen in=fits2 out=hips2 creator_did=HiPSID INDEX TILES PNG DETAILS CLEANFITS

mkdir hipsauto
cp -avi hips1/properties hipsauto/properties
popd


python -m venv pocvenv
source pocvenv/bin/activate
pip install requests pillow


pushd pocdata/hips1
python -m http.server 8101 &
popd

pushd pocdata/hips2
python -m http.server 8102 &
popd

pushd pocdata/hipsauto
python ../../hipscombineproxy.py &
popd

java -jar poctools/AladinBeta.jar "http://localhost:8100"




