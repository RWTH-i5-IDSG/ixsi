#!/bin/bash

# Script to  parse all Types from a e.g. WSDL file and generate tex tables accordingly.
# 
# By Christoph Terwelp <terwelp@dbis.rwth-aachen.de>
#    Christian Samsel <samsel@dbis.rwth-aachen.de>

command -v xsltproc >/dev/null 2>&1 || { echo >&2 "I require xsltproc but it's not installed.  Aborting."; exit 1; }

mkdir -p generated

rm generated/*


cat << EOF >generated/getalltypes.xslt
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


xsltproc "generated/getalltypes.xslt" IXSI.xsd  | uniq | sort | grep -v '^$' | while read type; do

	echo -ne "Generating ${type}-docu.xslt..."
	

	cat << EOF >generated/${type}-docu.xslt
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output omit-xml-declaration="yes" />
<xsl:template match="/">
<xsl:text disable-output-escaping="yes">\\emph{$type}\\index{$type}: </xsl:text>
<xsl:value-of select="//xs:complexType[@name='$type']/xs:annotation/xs:documentation"/>
<xsl:text disable-output-escaping="yes"><![CDATA[\begin{flushleft}
\rowcolors{1}{}{gray!25}
\begin{tabularx}{\linewidth}{ll>{\raggedright\arraybackslash}X} 
\toprule
Element & Typ & Kommentar\\\\
\midrule ]]>
</xsl:text>
<xsl:for-each select="//xs:complexType[@name='$type']//xs:element">
<xsl:text>\texttt{</xsl:text><xsl:value-of select="@name"/><xsl:text  disable-output-escaping="yes"><![CDATA[} & ]]></xsl:text>
<xsl:value-of select="@type"/><xsl:text  disable-output-escaping="yes"><![CDATA[ & ]]></xsl:text>
<xsl:if test="@minOccurs = 0"><xsl:text> \\emph{optional} </xsl:text></xsl:if>
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

	echo -ne "Generating ${type}-docu.tex from ${bname}-docu.xslt..."
	xsltproc "generated/${type}-docu.xslt" IXSI.xsd >generated/${type}-docu.tex
	echo "done"

done

rm generated/*.xslt
