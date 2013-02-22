<cfcomponent displayName="genericEditor" hint="CONTROLLER">

	<cffunction name="init" returntype="genericEditor" access="public">
		<cfset variables.credentials = {}>
		<cfset variables.credentials.recantha = {username="recantha", password="tngds9voy2"}>

		<cfreturn this />
	</cffunction>

	<cffunction name="default" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="false">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset getFactory("genericEditor.model").start(arguments.scope.datasource, arguments.scope.database, arguments.scope.table, arguments.scope.username, arguments.scope.password)>
		<!--- <cfset local.result.output = getFactory("glacier.messages").success("Thank you", "Go to generic editor", "/index.cfm/genericEditor/list", 0).output> --->

		<cfset local.result.output = list().output>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="list" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="false">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfparam name="arguments.scope.order_by" default="">
		<cfset local.data = getFactory("genericEditor.model").getMultiple(order_by=arguments.scope.order_by)>

		<cfset local.result.output = getFactory("genericEditor.view").list(local.data).output>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="add" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="false">

		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.result.title = "Adding record">

		<cfset local.result.output = getFactory("genericEditor.view").edit(mode="add").output>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="edit" returntype="struct" access="public">
 		<cfargument name="scope" type="struct" required="false">
 
 		<cfset var local = {}>
 		<cfset local.result = getResult()>
		<cfset local.result.title = "Editing record #arguments.scope.id#">

		<cfset local.result.output = getFactory("genericEditor.view").edit(mode="edit", id=arguments.scope.id).output>
 
 		<cfreturn local.result>
 	</cffunction>

	<cffunction name="update" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="false">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfif arguments.scope.mode eq "edit">
			<cfset local.sqlRes = getFactory("genericEditor.model").update(arguments.scope)>

		<cfelseif arguments.scope.mode eq "add">
			<cfset local.sqlRes = getFactory("genericEditor.model").add(arguments.scope)>
		</cfif>

		<cfif local.sqlRes.success>
			<cflocation url="#getFactory('genericEditor.model').getScriptRoot()#/list" addtoken="false">
		<cfelse>
			<cfset local.result.output = "<h3>Error</h3>#local.sqlRes.output#">
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="delete" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="false">

		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.result.title = "Deleting record #arguments.scope.id#">

		<cfset local.delRes = getFactory("genericEditor.model").delete(arguments.scope.id)>
		
		<cfif local.delRes.success>
			<cflocation url="#getFactory('genericEditor.model').getScriptRoot()#/list" addtoken="false">
		<cfelse>
			<cfset local.result.output = "<h3>Error</h3>#local.delRes.output#">
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="mirror_schema_tables" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="false">

		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfsetting requesttimeout="99999">

		<cfset local.table_list = "columns,key_column_usage,schemata,table_constraints,tables">

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<cfloop list="dsEcch,dsProductImport" index="local.dsSetting">
					<cftry>
						<cfset local.datasource = getSetting(local.dsSetting)>
						<h2>Datasource #local.dsSetting# / #local.datasource#</h2>
	
						<cfloop list="#local.table_list#" index="local.tbl">
							<cftry>
								<cfquery datasource="#local.datasource#" name="local.mirror">
									DROP TABLE schema_#local.tbl#;
								</cfquery>
								<cfcatch type="any"></cfcatch>
							</cftry>
		
							<cftry>
								<cfquery datasource="#local.datasource#" name="local.getCreate">
									SHOW CREATE TABLE `information_schema`.`#local.tbl#`;
								</cfquery>
								
								<cfset local.crSQL = local.getCreate["CREATE TABLE"]>
								<cfset local.crSQL = Replace(local.crSQL, "CREATE TEMPORARY TABLE `", "CREATE TABLE `schema_")>
								
								<cfquery datasource="#local.datasource#" name="local.cre">
									#preserveSingleQuotes(local.crSQL)#
								</cfquery>
			
								<cfquery datasource="#local.datasource#" name="local.mirror">
									ALTER TABLE schema_#local.tbl# DISABLE KEYS;
								</cfquery>
			
								<cfquery datasource="#local.datasource#" name="local.mirror">
									INSERT INTO schema_#local.tbl# SELECT * FROM `information_schema`.`#local.tbl#`;
								</cfquery>
								<cfquery datasource="#local.datasource#" name="local.mirror">
									ALTER TABLE schema_#local.tbl# ENABLE KEYS;
								</cfquery>
			
								<cfquery datasource="#local.datasource#" name="local.original">
									select count(*) as `count`
									FROM `information_schema`.`#local.tbl#`;
								</cfquery>
								<cfquery datasource="#local.datasource#" name="local.mirror">
									select count(*) as `count`
									FROM schema_#local.tbl#;
								</cfquery>
								<p>Updated table #local.tbl# - #local.original.count# in original / #local.mirror.count# in mirror</p>
		
								<cfcatch type="any">
									<div class="error">#local.crSQL#</div>
									<cfdump var="#cfcatch#" expand="false" label="catch">
									<cfrethrow>
								</cfcatch>
							</cftry>
		
						</cfloop>
						
						<cfcatch type="any">
							<div class="error">Datasource not updated - might not exist</div>
						</cfcatch>
					</cftry>
				</cfloop>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

</cfcomponent>