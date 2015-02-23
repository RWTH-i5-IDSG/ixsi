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

to automatically update the generated part on pull/merge or checkout you can add the respective script as a local hook:

```
echo "`git rev-parse --git-dir`/../xml/generate-tex-from-schema.sh" >> .git/hooks/post-checkout
echo "`git rev-parse --git-dir`/../xml/generate-tex-from-schema.sh" >> .git/hooks/post-merge
chmod +x .git/hooks/post-{checkout,merge}
```
IXSI is currently still under development and the API is not final. The branch `consumption` contains non standard additions to support the transfer of conumption data.

precomiled pdfs are available under: 

https://treibhaus.informatik.rwth-aachen.de/ixsi/ixsi-german.pdf

https://treibhaus.informatik.rwth-aachen.de/ixsi/ixsi-english.pdf

IXSI was developed for eConnect Germany, Hub Osnabrück by

cantamen GmbH,
HaCon Ing.-Ges. mbH,
RWTH Aachen
