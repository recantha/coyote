<!--- CFApp will be different to glacier but will be set when you hit this page by ckfinder's Application.cfc --->
<cfparam name="application.sessions" default="#structNew()#">

<cfset req = getHttpRequestdata()>
<cfset strXML = req.Content.Trim()>

<cfif isXML(strXML)>
	<cfset xmlData = xmlParse(strXML)>

	<cfif StructKeyExists(xmlData.auth, "login")>
		<cfset sess = {}>
		<cfset sess.si = xmlData.auth.si.xmlText>
		<cfset sess.ds = xmlData.auth.ds.xmlText>
		<cfset sess.un = xmlData.auth.un.xmlText>
		<cfset sess.pw = xmlData.auth.pw.xmlText>

		<cfset local.enc_key = "879jnasdf89asdf8sda">
		<cfloop list="#structKeyList(sess)#" index="local.key">
			<cfset sess[local.key] = Decrypt(ToString(ToBinary(sess[local.key])), local.enc_key)>
		</cfloop>

		<cfset application.sessions[sess.si] = sess>	

	<cfelseif StructKeyExists(xmlData.auth, "logout")>
		<cfset sess = {}>
		<cfset sess.si = xmlData.auth.si.xmlText>

		<cfset local.enc_key = "879jnasdf89asdf8sda">
		<cfloop list="#structKeyList(sess)#" index="local.key">
			<cfset sess[local.key] = Decrypt(ToString(ToBinary(sess[local.key])), local.enc_key)>
		</cfloop>

		<cfset StructDelete(application.sessions, sess.si)>
	</cfif>
</cfif>