<cfcomponent>
	<cffunction name="init" returntype="messages" access="public">
		<cfreturn this/>
	</cffunction>

	<cffunction name="success" returntype="struct" access="public">
		<cfargument name="message" type="string" required="true">
		<cfargument name="href_text" type="string" required="true">
		<cfargument name="href_link" type="string" required="true">
		<cfargument name="meta_delay" type="numeric" required="false" default="-1">
		<cfargument name="instant" type="boolean" required="false" default="false">

		<cfreturn display("success", arguments.message, arguments.href_text, arguments.href_link, arguments.meta_delay, arguments.instant)>
	</cffunction>

	<cffunction name="failure" returntype="struct" access="public">
		<cfargument name="message" type="string" required="true">
		<cfargument name="href_text" type="string" required="true">
		<cfargument name="href_link" type="string" required="true">
		<cfargument name="meta_delay" type="numeric" required="false" default="-1">
		<cfargument name="instant" type="boolean" required="false" default="false">

		<cfreturn display("failure", arguments.message, arguments.href_text, arguments.href_link, arguments.meta_delay, arguments.instant)>
	</cffunction>

	<cffunction name="display" returntype="struct" access="private">
		<cfargument name="type" type="string" required="true">
		<cfargument name="message" type="string" required="true">
		<cfargument name="href_text" type="string" required="true">
		<cfargument name="href_link" type="string" required="true">
		<cfargument name="meta_delay" type="numeric" required="false" default="-1">
		<cfargument name="instant" type="boolean" required="false" default="false">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfif arguments.instant>
			<cflocation url="#arguments.href_link#" addtoken="false">
		<cfelseif arguments.meta_delay gt -1>
			<cfhtmlhead text='<meta http-equiv="Refresh" content="#arguments.meta_delay#;URL=#arguments.href_link#">'>
		</cfif>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<h3>#arguments.message#</h3>
				<p><a href="#arguments.href_link#">#arguments.href_text#</a></p>
				<div class="clear"></div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
</cfcomponent>