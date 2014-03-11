#!/bin/bash

ls *.snippet | while read in; do

	bname=$(basename $in .snippet)

	echo -ne "Generating ${bname}.xslt from ${bname}.snippet..."
	
	cat "${bname}.snippet" | awk \
'BEGIN { print "<?xml version=\"1.0\" encoding=\"UTF-8\"?><xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\"><xsl:output method=\"xml\" indent=\"no\" omit-xml-declaration=\"yes\" /><xsl:template match=\"/\">"}
/^[A-Z].*$/ { print "<xsl:copy-of select=\"//xs:complexType[@name='\''" $1 "'\'']\" />"; next}
{ print "<xsl:copy-of select=\"/xs:schema/xs:element[@name='\''" $1 "'\'']\" />" }
END { print "</xsl:template></xsl:stylesheet>" }' > "generated/${bname}.xslt" 2>&1

	if [ $? -ne 0 ]; then
    	echo "failed"
		exit 1
	fi
	
    echo "done"
		
	echo -ne "Generating ${bname}.xmlsnippet from ${bname}.xslt..."

	xsltproc "generated/${bname}.xslt" interface.xsd | \
		awk '/^[ \t]*$/ { print "<blank-line />"; next } { print }'| \
		tidy --input-xml true --indent yes --indent-spaces 4 -wrap 100 2>/dev/null | \
		awk '/^<blank-line \/>$/ { print ""; next } { print }'> "generated/${bname}.xmlsnippet"

	if [ $? -ne 0 ]; then
    	echo "failed"
		exit 1
	fi
	
    echo "done"
	
	echo -ne "Generating ${bname}.tex..."
	
	echo -ne > generated/${bname}.tex
	
	cat "${bname}.snippet" | awk \
'/^[A-Z].*$/ { printf "\\index{"$1"}" }
{}' >> generated/${bname}.tex 2>&1

	if [ $? -ne 0 ]; then
		echo "failed"
		exit 1
	fi
	
	echo '\begin{lstlisting}[style=xml-style]' >> generated/${bname}.tex
	
	cat "generated/${bname}.xmlsnippet" | awk 'NR > 1 && /^<[^\/]/ { print "" } { print }' >> generated/${bname}.tex
	
	echo '\end{lstlisting}' >> generated/${bname}.tex
	
	echo "done"

done
