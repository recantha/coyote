<cffunction name="createObjectByProxy" access="public" returntype="any" hint="Creates a CFC Creation proxy. Does NOT initialize the component, only creates it. (based on Ben Nadel's)">
	<cfargument name="path" type="string" required="true" hint="Dot notation path to a component within the coyote folder" />
 
	<!--- Return the created component. --->
	<cfset var local = {}>
	
	<cftry>
		<cfset local.com = createObject("component", arguments.path)/>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="catcher">
			<cfthrow type="application" message="Could not create #arguments.path# by proxy - #cfcatch.Message#">
		</cfcatch>
	</cftry>

	<cfreturn local.com>
</cffunction>