<cfcomponent hint="Functions added to the URL scope to make them global">
	<cffunction name="getResult" returntype="struct" access="public">
		<cfreturn getFactory("coyote").getResult()>
	</cffunction>

	<cffunction name="getScope" returntype="struct" access="public">
		<cfreturn getFactory("coyote").getScope()>
	</cffunction>

	<cffunction name="getFactory" returntype="any" access="public">
		<cfargument name="path" type="string" required="false" default="">

		<cfset var local = {}>
		<cfif arguments.path eq "coyote">
			<cfreturn application.coyote>

		<cfelse>
			<cftry>
				<cfinvoke component="#application.coyote#" method="getFactory" returnvariable="local.ret">
					<cfloop list="#StructKeyList(arguments)#" index="local.arg">
						<cfinvokeargument name="#local.arg#" value="#arguments[local.arg]#">
					</cfloop>
				</cfinvoke>
				
				<cfcatch type="any">
					<cfdump var="#cfcatch#">
					<cfoutput>Problem in getFactory() for args: <cfdump var="#arguments#"></cfoutput>
					<cfoutput>#structKeyList(arguments)#</cfoutput>
					<cfoutput>#arguments.path#</cfoutput>
					<cfdump var="#arguments#"><cfabort>
	
					<cfdump var="#cfcatch#">
					<cfabort>
				</cfcatch>
			</cftry>
		</cfif>

		<cfreturn local.ret>
	</cffunction>

	<cffunction name="getSetting" returntype="any" access="public" output="false">
		<cfargument name="name" type="string" required="false" default="">

		<cfset var local = {}>

		<cfset local.method = "getSetting">
		<cfinvoke component="#application.coyote#" method="#local.method#" returnvariable="local.ret">
			<cfloop list="#StructKeyList(arguments)#" index="local.arg">
				<cfinvokeargument name="#local.arg#" value="#arguments[local.arg]#">
			</cfloop>
		</cfinvoke>

		<cfreturn local.ret>
	</cffunction>

</cfcomponent>