#!/bin/bash

#in=$1

#if [ "$in" = "" ]; then
#	echo "Usage: $0 [FILENAME]"
#	exit
#fi
command -v xsltproc >/dev/null 2>&1 || { echo >&2 "I require xsltproc but it's not installed.  Aborting."; exit 1; }

rm generated/*

ls *.snippet | while read in; do

	bname=$(basename $in .snippet)
	ename=`cat ${bname}.snippet`
	
	echo -ne "Generating ${bname}-docu.xslt form ${bname}.snippet...."
	

	cat << EOF >generated/${bname}-docu.xslt
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output omit-xml-declaration="yes" />
<xsl:template match="/">
<xsl:value-of select="$ename/xs:annotation/xs:documentation"/>
<xsl:text disable-output-escaping="yes"><![CDATA[\begin{flushleft}
\rowcolors{1}{}{gray!25}
\begin{tabularx}{\linewidth}{ll>{\raggedright\arraybackslash}X} 
\toprule
Element & Typ & Kommentar\\\\
\midrule ]]>
</xsl:text>
<xsl:for-each select="$ename//xs:element">
<xsl:text>\texttt{</xsl:text><xsl:value-of select="@name"/><xsl:text  disable-output-escaping="yes"><![CDATA[} & ]]></xsl:text>
<xsl:value-of select="@type"/><xsl:text  disable-output-escaping="yes"><![CDATA[ & ]]></xsl:text>
<xsl:value-of select="xs:annotation/xs:documentation"/>
<xsl:text>\\\\
</xsl:text>
</xsl:for-each>
<xsl:text>\bottomrule 
\end{tabularx} \end{flushleft}</xsl:text>
</xsl:template>
</xsl:stylesheet>
EOF

	echo "done"

	echo -ne "Generating ${bname}-docu.tex from ${bname}-docu.xslt..."
	xsltproc "generated/${bname}-docu.xslt" IXSI.xsd >generated/${bname}-docu.tex
	echo "done"

done

rm generated/*.xslt
