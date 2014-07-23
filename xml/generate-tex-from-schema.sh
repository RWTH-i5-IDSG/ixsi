#!/bin/bash

# Script to  parse all Types from a e.g. WSDL file and generate tex tables accordingly.
# 
# By Christoph Terwelp <terwelp@dbis.rwth-aachen.de>
#    Christian Samsel <samsel@dbis.rwth-aachen.de>

# Configuration

# Schema file to parse
file="IXSI.xsd"

# Headings
element="Element"
type="Typ"
comment="Kommentar"
optional="optional"
multivalue="mehrwertig"

command -v xsltproc >/dev/null 2>&1 || { echo >&2 "I require xsltproc but it's not installed.  Aborting."; exit 1; }

mkdir -p generated

rm generated/*


cat << EOF >getalltypes.xslt
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xsl:output omit-xml-declaration="yes" />
        <xsl:template match="/">
                <xsl:for-each select="//xs:complexType">
                        <xsl:value-of select="@name"/><xsl:text>
</xsl:text>
                </xsl:for-each>
        </xsl:template>
</xsl:stylesheet>
EOF


xsltproc "getalltypes.xslt" $file | uniq | sort | grep -v '^$' | while read x; do

	echo -ne "Generating generated/${x}.tex..."
	

	cat << EOF >generated/${x}.xslt
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output omit-xml-declaration="yes" />
<xsl:template match="/">
<xsl:text disable-output-escaping="yes">\\emph{$x}\\index{$x}: </xsl:text>
<xsl:value-of select="//xs:complexType[@name='$x']/xs:annotation/xs:documentation"/>
<xsl:text disable-output-escaping="yes"><![CDATA[\begin{flushleft}
\rowcolors{1}{}{gray!25}
\begin{tabularx}{\linewidth}{ll>{\raggedright\arraybackslash}X} 
\toprule
$element  & $type & $comment \\\\
\midrule ]]>
</xsl:text>
<xsl:for-each select="//xs:complexType[@name='$x']//xs:element">
<xsl:text>\texttt{</xsl:text><xsl:value-of select="@name"/><xsl:text  disable-output-escaping="yes"><![CDATA[} & ]]></xsl:text>
<xsl:value-of select="@type"/><xsl:text  disable-output-escaping="yes"><![CDATA[ & ]]></xsl:text>
<xsl:if test="@minOccurs = 0"><xsl:text> \\emph{$optional} </xsl:text></xsl:if>
<xsl:value-of select="xs:annotation/xs:documentation"/>
<xsl:text>\\\\
</xsl:text>
</xsl:for-each>
<xsl:text>\bottomrule 
\end{tabularx} \end{flushleft}</xsl:text>
</xsl:template>
</xsl:stylesheet>
EOF


	xsltproc "generated/${x}.xslt" IXSI.xsd >generated/${x}.tex
	if [ $? -ne 0 ]; then
        	echo "failed"
	        exit 1
    	fi
	rm "generated/${x}.xslt"
	echo "done"

done

rm "getalltypes.xslt"
