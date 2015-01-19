cd ${0%/*}

mv IXSI-ger.xsd IXSI-ger.xsd-new
unexpand -t 8 IXSI-ger.xsd-new > IXSI-ger.xsd

mv IXSI.xsd IXSI.xsd-new
unexpand -t 8 IXSI.xsd-new > IXSI.xsd
