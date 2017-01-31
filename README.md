# IXSI - Interface for X-Sharing Information documentation
[![Build Status](https://travis-ci.org/RWTH-i5-IDSG/ixsi.svg)](https://travis-ci.org/RWTH-i5-IDSG/ixsi)



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
IXSI is currently still under development and the API is not final. 

precompiled pdfs are available under (automatically generated): 

https://rwth-i5-idsg.github.io/ixsi/ixsi-docu-econnect.pdf (german version)

https://rwth-i5-idsg.github.io/ixsi/ixsi-docu-econnect-english-version.pdf (english version)

The respective XML schema is available under:

https://github.com/RWTH-i5-IDSG/ixsi/blob/econnect/xml/IXSI.xsd

IXSI was initially developed for eConnect Germany, Hub Osnabrück by

cantamen GmbH,
HaCon Ing.-Ges. mbH,
RWTH Aachen



## Mobility Broker 
The branch `mobilitybroker` contains non standard additions developed in project Mobility Broker. More Information about Mobility Broker is available: http://mobility-broker.com/ (in german)

precompiled pdf:
https://rwth-i5-idsg.github.io/ixsi/ixsi-docu-mobilitybroker.pdf

The respective XML schema for branch `mobilitybroker` is available under:
https://github.com/RWTH-i5-IDSG/ixsi/blob/mobilitybroker/xml/IXSI.xsd




