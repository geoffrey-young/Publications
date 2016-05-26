<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                indent-result="yes">

<xsl:template match="/">
<html>
<head><title>Ship Captains</title></head>
<body>
  <xsl:apply-templates/>
</body>
</html>
</xsl:template>

<xsl:template match="captainlist">
  <h3>Some Famous Captains</h3>
  <hr/>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="captain">
  <b><xsl:apply-templates/></b><br/>
</xsl:template>

<xsl:template match="shiplist">
 <h3>Some Famous Ships</h3>
 <xsl:apply-templates/>
 <hr />
</xsl:template>

<xsl:template match="shiplist/ship">
 <h4><xsl:value-of select="name"/></h4>
 <p>Ship type is <xsl:value-of select="@type"/>,
    registered in <xsl:value-of select="registry"/></p>
</xsl:template>

</xsl:stylesheet>

