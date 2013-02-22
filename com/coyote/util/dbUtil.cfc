<cfcomponent>
	<cffunction name="init" returntype="dbUtil" access="public">
		<cfset variables.sessions = {}>

		<cfreturn this/>
	</cffunction>

	<cffunction name="getMaxID" returntype="numeric" access="public">
		<cfargument name="datasource" type="string" required="true">
		<cfargument name="database" type="string" required="true">
		<cfargument name="table" type="string" required="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">

		<cfset var local = {}>

		<cfquery datasource="#arguments.datasource#" name="local.getLastID" username="#arguments.username#" password="#arguments.password#">
			SELECT max(id) as `id`
			FROM `#arguments.database#`.`#arguments.table#`
		</cfquery>

		<cfreturn local.getLastID.id>
	</cffunction>

	<cffunction name="getSQLfromQuery" returntype="any" access="public">
		<cfargument name="theQuery" type="query" required="true">
		<cfargument name="pre" type="boolean" required="false" default="true">

		<cfset var local = {}>
		<cfset local.theSql = arguments.theQuery.getMetaData().getExtendedMetaData().sql/>

		<cftry>
			<cfset local.params = arguments.theQuery.getMetaData().getExtendedMetaData().sqlParameters>
			<cfcatch type="ANY">
				<cfset local.params = []>
			</cfcatch>
		</cftry>
		
		<cfset local.findQM = 1>

		<cfif ArrayLen(local.params)>
			<cfloop from="1" to="#ArrayLen(local.params)#" index="local.i">
				<cfset local.prm = local.params[local.i]>
				<cfset local.findQM = Find("?", local.theSql, local.findQM)>
				<cfif local.findQM gt 0>
					<cfset local.leftBit = Left(local.theSql, local.findQM-1)>
					<cfset local.rightBit = Mid(local.theSql, local.findQM+1, Len(local.theSql)-local.findQM)>

					<cfif NOT isNumeric(local.prm)>
						<cfset local.prm = "'#local.prm#'">
					</cfif>

					<cfset local.theSql = local.leftBit & local.prm & local.rightBit>
				</cfif>
			</cfloop>
		</cfif>

		<cfif arguments.pre>
			<cfset local.thesql = "<pre>#local.theSql#</pre>">
		</cfif>

		<cfreturn local.theSql>
	</cffunction>

</cfcomponent>