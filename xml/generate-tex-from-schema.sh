#!/bin/bash

# Script to  parse all types and groups from a e.g. WSDL file and 
# generate tex tables source snippets accordingly.
# 
# By Christoph Terwelp <terwelp@dbis.rwth-aachen.de>
#    Christian Samsel <samsel@dbis.rwth-aachen.de>

# Configuration

# Schema file to parse
file="IXSI.xsd"

# Headings
name="Name"
element="Element"
type="Typ"
comment="Kommentar"
optional="optional"
multivalue="mehrwertig"
choice="auswahl"
empty="(leer)"
schema="XML Schema"
group="Gruppenzugehoerigkeit"
basetype="Basistyp"

command -v xsltproc >/dev/null 2>&1 || { echo >&2 "I require xsltproc but it's not installed.  Aborting."; exit 1; }

mkdir -p generated

rm generated/*.tex

# generate table of simpleTypes
cat << EOF >simpletypes.xslt
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output omit-xml-declaration="yes" />
<xsl:template match="/">
<xsl:text disable-output-escaping="yes"><![CDATA[\begin{flushleft}
\rowcolors{1}{}{gray!10}
\begin{tabularx}{\linewidth}{ll>{\raggedright\arraybackslash}X} 
\toprule
$name & $basetype & $comment \\\\
\midrule ]]>
</xsl:text>
<xsl:for-each select="//xs:simpleType[@name]">
<xsl:sort select="@name"/>
<xsl:text>\emph{</xsl:text><xsl:value-of select="@name"/><xsl:text disable-output-escaping="yes"><![CDATA[} & ]]></xsl:text>
<xsl:text>\texttt{</xsl:text><xsl:value-of select="xs:restriction/@base"/><xsl:text disable-output-escaping="yes"><![CDATA[} & ]]></xsl:text>
<xsl:value-of select="xs:annotation/xs:documentation"/><xsl:text>\\\\&#xa;</xsl:text>
</xsl:for-each>
<xsl:text>\bottomrule 
\end{tabularx}\end{flushleft}\medskip</xsl:text>
</xsl:template>
</xsl:stylesheet>
EOF

echo -ne "Generating simpleTypes.tex"
xsltproc "simpletypes.xslt" $file >generated/simpleTypes.tex
if [ $? -ne 0 ]; then
	echo "failed"
exit 1
fi

echo "done"

# generate xslt to parse complexTypes
cat << EOF >getalltypes.xslt
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xsl:output omit-xml-declaration="yes" />
        <xsl:template match="/">
                <xsl:for-each select="//xs:complexType">
                        <xsl:value-of select="@name"/><xsl:text>&#xa;</xsl:text>
                </xsl:for-each>
                <xsl:for-each select="//xs:group">
                        <xsl:value-of select="@name"/><xsl:text>&#xa;</xsl:text>
                </xsl:for-each>
        </xsl:template>
</xsl:stylesheet>
EOF

#iterate over list of types
xsltproc "getalltypes.xslt" $file | uniq | sort | grep -v '^$' | while read x; do

	echo -ne "Generating generated/${x}.tex..."
#generate xslt per type
	cat << EOF >generated/${x}.xslt
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output omit-xml-declaration="yes" />
<xsl:template match="/">
<xsl:text disable-output-escaping="yes">\\begin{samepage}</xsl:text>
<xsl:text disable-output-escaping="yes">\\emph{$x}\\index{$x}: </xsl:text>
<xsl:value-of select="//*[@name='$x']/xs:annotation/xs:documentation"/>
<xsl:text>\\\\ \smallskip</xsl:text>
<xsl:if test="//*[@name='$x']//xs:extension">
<xsl:text>&#xa;$basetype: \\emph{</xsl:text><xsl:value-of select="//*[@name='$x']//xs:extension/@base"/>
<xsl:text>}\\\\&#xa;</xsl:text>
</xsl:if>
<xsl:if test="//*[@name='$x']//xs:group">
<xsl:text>&#xa;$group: </xsl:text>
<xsl:for-each select="//*[@name='$x']//xs:group">
<xsl:text>\\emph{</xsl:text><xsl:value-of select="@ref"/>
<xsl:text>} </xsl:text>
</xsl:for-each>
<xsl:text>\\\\&#xa;</xsl:text>
</xsl:if>
<xsl:text disable-output-escaping="yes"><![CDATA[
\begin{flushleft}
\rowcolors{1}{}{gray!10}
\begin{tabularx}{\linewidth}{cll>{\raggedright\arraybackslash}X} 
\toprule
 & $element  & $type & $comment \\\\
\midrule ]]>
</xsl:text>
<xsl:for-each select="//*[@name='$x']//xs:element">
<xsl:if test="name(..) = 'xs:choice'"><xsl:text> \$\medcircle\$ </xsl:text></xsl:if>
<xsl:if test="@minOccurs = 0"><xsl:text> \$\medsquare\$ </xsl:text></xsl:if>
<xsl:if test="@maxOccurs='unbounded'"><xsl:text> \$\boxbox\$ </xsl:text></xsl:if>
<xsl:text disable-output-escaping="yes"><![CDATA[ & ]]></xsl:text>
<xsl:text>\emph{</xsl:text><xsl:value-of select="@name"/><xsl:text disable-output-escaping="yes"><![CDATA[} & ]]></xsl:text>
<xsl:text>\texttt{</xsl:text><xsl:value-of select="@type"/><xsl:text  disable-output-escaping="yes"><![CDATA[} & ]]></xsl:text>
<xsl:value-of select="xs:annotation/xs:documentation"/>
<xsl:text>\\\\
</xsl:text>
</xsl:for-each>
<xsl:if test="not(//*[@name='$x']//xs:element)">
<xsl:text disable-output-escaping="yes"><![CDATA[ & \textit{$empty} & & \\\\ ]]></xsl:text>
</xsl:if>
<xsl:text>\bottomrule 
\end{tabularx}\end{flushleft}\end{samepage}\medskip</xsl:text>
</xsl:template>
</xsl:stylesheet>
EOF

	xsltproc "generated/${x}.xslt" $file >generated/${x}.tex
	if [ $? -ne 0 ]; then
        	echo "failed"
	        exit 1
    	fi
	rm "generated/${x}.xslt"
	echo "done"

done


echo "generating stripped $file..."

# generate xslt to strip annotations
cat << EOF >stripannotations.xslt
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>
    <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
    </xsl:template>
    <xsl:template match="//xs:annotation" />
</xsl:stylesheet>
EOF

xsltproc stripannotations.xslt $file | awk NF > $file-stripped

# iterate over all types again
xsltproc "getalltypes.xslt" $file | uniq | sort | grep -v '^$' | while read x; do

        echo -ne "Generating generated/${x}-schema.tex..."
#generate xslt per type
        cat << EOF >generated/${x}-schema.xslt
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output omit-xml-declaration="yes" indent="yes"/>
<xsl:template match="/">
<xsl:text disable-output-escaping="yes"><![CDATA[\begin{samepage}
\noindent $schema: \index{$x}
\begin{lstlisting}[style=XML-style]]]>
</xsl:text>
<xsl:copy-of select="//*[@name='$x']"/>
<xsl:text>\end{lstlisting}
\end{samepage}\medskip</xsl:text>
</xsl:template>
</xsl:stylesheet>
EOF


        xsltproc "generated/${x}-schema.xslt" $file-stripped >generated/${x}-schema.tex
        if [ $? -ne 0 ]; then
                echo "failed"
                exit 1
        fi
        rm "generated/${x}-schema.xslt"
        echo "done"

done

echo -ne "cleanup..."
rm $file-stripped stripannotations.xslt getalltypes.xslt simpletypes.xslt
echo "done"
