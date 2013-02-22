<cfcomponent displayname="coyote" hint="Main framework functions">
	<cffunction name="init" returntype="coyote" access="public">
		<cfargument name="settings" type="struct" required="true">

		<cfset variables.settings = duplicate(arguments.settings)>

		<cfreturn this/>
	</cffunction>

	<cffunction name="load" returntype="void" access="public">
		<cfargument name="components" type="array" required="true" hint="Components to be loaded">

		<cfset var local = {}>
		<cfset local.debug = StructKeyExists(url, "debugapp")>

		<cfset variables.components = {}>
		<cfloop from="1" to="#ArrayLen(arguments.components)#" index="local.f">
			<cfset local.family = arguments.components[local.f]>
			<cfset local.family_name = local.family.name>

			<cfparam name="local.family.singleton" default="false">
			<cfset local.family_singleton = local.family.singleton>

			<cfset StructDelete(local.family, "name")>
			<cfset StructDelete(local.family, "singleton")>

			<cfif local.debug><cfoutput><p>About to load #local.family_name#: #now()#</p></cfoutput></cfif>

			<cfif StructKeyExists(variables.components, local.family_name)>
				<cfabort showerror="Family #local.family_name# already exists - can only be configured once in ANY of the components.xml">

			<cfelse>
				<cfset variables.components[local.family_name] = {}>

				<cfloop list="#StructKeyList(local.family)#" index="local.child">
					<cfif local.debug><cfoutput><p>About to create #local.family_name#.#local.child#: #now()#</p></cfoutput></cfif>
					<cftry>
						<cfif local.debug><cfoutput><p>GML1 #now()#</p></cfoutput></cfif>

						<cfif NOT local.family_singleton>
							<cfset local.obj = createObject("component", "com.#local.family[local.child]#")>
							<cfset variables.components[local.family_name][local.child] = local.obj.init()>

							<cfif local.debug><cfoutput><p>Initialized #local.family_name# / #local.child# #now()#</p></cfoutput></cfif>

						<cfelse>
							<cfset variables.components[local.family_name][local.child] = local.family[local.child]>
						</cfif>

						<cfif local.debug><cfoutput><p>GML2 (created) #now()#</p></cfoutput></cfif>

						<cfcatch type="any">
							<cfset variables.components.error = {catch=cfcatch}>
							<cfif NOT StructKeyExists(cfcatch, "missingFileName")>
								<cfdump var="#cfcatch#"><cfabort>
							<cfelse>
								<cfdump var="#cfcatch#" expand="false" label="Problem with #local.family_name#.#local.child#"><cfabort>
							</cfif>
						</cfcatch>
					</cftry>
				</cfloop>
			</cfif>
		</cfloop>

		<cfset variables.components.coyote = {model=this}>
	</cffunction>

	<cffunction name="getResult" returntype="struct" access="public" hint="Generic result structure">
		<cfset var local = {}>
		<cfset local.result = structNew()>
		<cfset local.result = { title="", output="", restrictOutput="", success=true }>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="getScope" returntype="struct" access="public">
		<cfset var local = {}>
		<cfset local.scope = {}>
		
		<cfloop list="#StructKeyList(form)#" index="local.fld">
			<cfset local.scope[local.fld] = form[local.fld]>
		</cfloop>
		<cfloop list="#StructKeyList(url)#" index="local.fld">
			<cfset local.scope[local.fld] = url[local.fld]>
		</cfloop>
		<cfloop list="#StructKeyList(cgi)#" index="local.fld">
			<cfset local.scope[local.fld] = cgi[local.fld]>
		</cfloop>
		
		<cfset local.scope.script_name = cgi.SCRIPT_NAME & cgi.PATH_INFO>

		<cfreturn local.scope>
	</cffunction>

	<cffunction name="getSetting" returntype="any" access="public" output="false">
		<cfargument name="name" type="string" required="true">

		<cfif NOT StructKeyExists(variables.settings, arguments.name)>
			<cftry>
				<cfthrow type="application" message="Setting #arguments.name# does not exist">
				<cfcatch type="any">
					<cfoutput>
						<p>#cfcatch.message#<br>
							<cfdump var="#cfcatch.TagContext[3]#">
						</p>
					</cfoutput>
					<cfabort>
				</cfcatch>
			</cftry>
		<cfelse>
			<cfreturn variables.settings[arguments.name]>
		</cfif>
	</cffunction>

	<cffunction name="getFactory" returntype="any" access="public">
		<cfargument name="path" type="string" required="false" default="">
		<cfargument name="return_family" type="boolean" required="false" default="false">

		<cfset var local = {}>
		<cfset local.path = arguments.path>

		<cfif Len(local.path) eq 0>
			<cfreturn variables.components>
		<cfelse>
			<cfif NOT comExists(local.path)>
				<cfdump var="#variables#">
				<cfabort showerror="#local.path# does not exist in Coyote's object store">

			<cfelse>
				<cfset local.family = variables.components[ListGetAt(local.path, 1, ".")]>
			
				<cfif arguments.return_family>
					<cfset local.com = local.family>
				<cfelse>
					<cfif ListLen(arguments.path, ".") eq 1>
						<cfset local.com = local.family.model>

					<cfelse>
						<cfset local.com = local.family[ListGetAt(local.path, 2, ".")]>
					</cfif>
				</cfif>
			</cfif>
		</cfif>

		<cfreturn local.com>
	</cffunction>

	<cffunction name="comExists" returntype="boolean" access="public">
		<cfargument name="path" type="string" required="true">

		<cfset var local = {}>
		<cfset local.path = arguments.path>

		<cfset local.family = ListGetAt(local.path, 1, ".")>
		<cfif StructKeyExists(variables.components, local.family)>

			<cfif ListLen(arguments.path, ".") eq 1>
				<cfreturn true>

			<cfelse>
				<cfset local.child = ListGetAt(local.path, 2, ".")>
				<cfif StructKeyExists(variables.components[local.family], local.child)>
					<cfreturn true>
				</cfif>
			</cfif>

		</cfif>

		<cfreturn false>
	</cffunction>

</cfcomponent>