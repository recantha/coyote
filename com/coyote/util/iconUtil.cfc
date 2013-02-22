<cfcomponent>

	<cffunction name="init" returntype="iconUtil" access="public">
		<cfreturn this/>
	</cffunction>

	<cffunction name="icon" returntype="struct" access="public">
		<cfargument name="icon" type="string" required="true">
		<cfargument name="label" type="string" required="false" default="">
		<cfargument name="href" type="string" required="false" default="">
		<cfargument name="iconfolder" type="string" required="false" default="#getSetting('glacier_iconfolder')#">
		<cfargument name="iconurl" type="string" required="false" default="">
		<cfargument name="align" type="string" required="false" default="absbottom">
		<cfargument name="tip" type="string" required="false" default="">
		<cfargument name="width" type="string" required="false" default="24">
		<cfargument name="target" type="string" required="false" default="_self">
		<cfargument name="class" type="string" required="false" default="" hint="Style to apply to label">

		<cfset var local = {}>
		<!--- Slimline --->
		<cfset local.result = {output=""}>

		<!--- Sort out icon url --->
		<cfif Len(arguments.iconurl)>
			<cfset local.iconurl = arguments.iconurl>
		<cfelseif Len(arguments.iconfolder)>
			<cfset local.iconurl = ListAppend(arguments.iconfolder, "#arguments.icon#.png", "/")>
		<cfelse>
			<cfthrow type="application" message="Either iconurl or iconfolder must be specified in iconUtil.icon()">
		</cfif>

		<!--- Classes to be applied --->
		<cfset local.class = "">
		<cfif Len(arguments.href)><cfset local.class = ListAppend(local.class, "fake_pointer", " ")></cfif>
		<cfif Len(arguments.class)><cfset local.class = ListAppend(local.class, arguments.class, " ")></cfif>
		<cfif Len(arguments.tip)><cfset local.class = ListAppend(local.class, "tooltip", " ")></cfif>

		<!--- Build the anchor tab --->
		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<a
					<cfif Len(arguments.href)>
						href="#arguments.href#"
						target="#arguments.target#"
					</cfif>
					class="#local.class#"
				>
					<img src="#local.iconurl#" border="0" width="#arguments.width#" align="#arguments.align#">
					<cfif Len(arguments.label)>#arguments.label#</cfif>
					<cfif Len(arguments.tip)>
						<span class="classic">#arguments.tip#</span>
					</cfif>
				</a>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

</cfcomponent>
