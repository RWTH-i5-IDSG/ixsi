ixsi
====

IXSI - Interface for X-Sharing Information documentation

IXSI is a interface for exchanging information  between a Travel Information System and a Ride Sharing System (Carsharing, Bikesharing).
This repository contains the documentation written in TeX. To generate the pdf:

``` 
	git clone https://github.com/RWTH-i5-IDSG/ixsi.git
	cd ixsi
	xml/generate-tex-from-schema.sh
	make
``` 

a recent TexLive version is recommended for building.

IXSI is currently still under development and the API is not final. The branch `consumption` contains non standard additions to support the transfer of conumption data.

precomiled pdfs are available under: 

https://treibhaus.informatik.rwth-aachen.de/ixsi/ixsi-german.pdf

https://treibhaus.informatik.rwth-aachen.de/ixsi/ixsi-english.pdf

IXSI was developed for eConnect Germany, Hub Osnabrück by

cantamen GmbH,
HaCon Ing.-Ges. mbH,
RWTH Aachen
