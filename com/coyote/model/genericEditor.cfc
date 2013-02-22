<cfcomponent displayName="genericEditor" hint="MODEL">

	<cffunction name="init" returntype="genericEditor" access="public">
		<cfset variables.sessions = {}>
		<cfreturn this />
	</cffunction>

	<cffunction name="start" returntype="void" access="public">
		<cfargument name="datasource" type="string" required="true">
		<cfargument name="database" type="string" required="true">
		<cfargument name="table" type="string" required="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">

		<cfset variables.sessions[session.sessionID] = {
				datasource = arguments.datasource,
				database = arguments.database,
				table = arguments.table,
				username = arguments.username,
				password = arguments.password
		}>

		<cfset variables.sessions[session.sessionID].table = getTableInfo()>
	</cffunction>

	<cffunction name="getSession" returntype="struct" access="public">
		<cfreturn variables.sessions[session.sessionID]>
	</cffunction>

	<cffunction name="add" access="public" returntype="struct">
		<cfargument name="data" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.debug = false>

		<cfset local.sess = getSession()>

		<cftry>
			<cfquery datasource="#local.sess.datasource#" name="local.insert_generic">
				insert into #local.sess.table.name# (
					<cfloop from="1" to="#ListLen(local.sess.table.field_names_for_insert)#" index="local.i">
						`#ListGetAt(local.sess.table.field_names_for_insert, local.i)#`
						<cfif local.i neq ListLen(local.sess.table.field_names_for_insert)>,</cfif>
					</cfloop>
				) values (
					<cfloop from="1" to="#ListLen(local.sess.table.field_names_for_insert)#" index="local.i">
						<cfset local.fld = ListGetAt(local.sess.table.field_names_for_insert, local.i)>

						<cfif FindNoCase("CHAR", local.sess.table.fields[local.fld].column_type)
								OR FindNoCase("TEXT", local.sess.table.fields[local.fld].column_type)
						>
							<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data[local.fld]#" null="#Len(arguments.data[local.fld]) eq 0#">
						<cfelseif FindNoCase("DATETIME", local.sess.table.fields[local.fld].column_type)>
							<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.data[local.fld]#">
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data[local.fld]#" null="#Len(arguments.data[local.fld]) eq 0#">
						</cfif>
						
						<cfif local.i neq ListLen(local.sess.table.field_names_for_insert)>
						,
						</cfif>
					</cfloop>
				)
			</cfquery>
			
			<cfset local.result.output = "Added new #local.sess.table.name# record">
			
			<cfcatch type="any">
				<cfset local.result.success = false>
				<cfset local.result.output = "Problem with query - #cfcatch.message#">
				<cfdump var="#cfcatch#">
				<cfdump var="#arguments.table#">
				<cfdump var="#arguments.data#">
				<cfabort>
			</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="update" access="public" returntype="struct">
		<cfargument name="data" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset local.sess = getSession()>
		<cfset local.data = getFactory("genericEditor.model").getBlank()>

		<cfloop list="#StructKeyList(local.data)#" index="local.fld">
			<cfif structKeyExists(arguments.data, local.fld)>
				<cfset local.data[local.fld] = arguments.data[local.fld]>
			</cfif>
		</cfloop>

		<cftry>
			<cfquery datasource="#local.sess.datasource#" name="local.updateDF">
				update `#local.sess.database#`.`#local.sess.table.name#`
				set 
					<cfloop from="1" to="#ListLen(local.sess.table.field_names_for_insert)#" index="local.i">
						<cfset local.fld = ListGetAt(local.sess.table.field_names_for_insert, local.i)>

						<cfif ListFindNoCase("CHAR,VARCHAR,TEXT", local.sess.table.fields[local.fld].data_type)>
							`#local.fld#` = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data[local.fld]#" null="#Len(arguments.data[local.fld]) eq 0#">

						<cfelseif ListFindNoCase("DATETIME,TIMESTAMP", local.sess.table.fields[local.fld].data_type)>
							`#local.fld#` = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.data[local.fld]#" null="#Len(arguments.data[local.fld]) eq 0#">

						<cfelseif ListFindNoCase("DECIMAL", local.sess.table.fields[local.fld].data_type)>
							`#local.fld#` = <cfqueryparam cfsqltype="cf_sql_float" value="#arguments.data[local.fld]#" null="#Len(arguments.data[local.fld]) eq 0#">

						<cfelseif ListFindNoCase("TINYINT,INT", local.sess.table.fields[local.fld].data_type)>
							`#local.fld#` = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data[local.fld]#" null="#Len(arguments.data[local.fld]) eq 0#">
						<cfelse>
							<cfabort showerror="Datatype of #local.fld# which is #local.sess.table.fields[local.fld].data_type# not handled in genericEditor.model.update()">
						</cfif>
						
						<cfif local.i neq ListLen(local.sess.table.field_names_for_insert)>
						,
						</cfif>
					</cfloop>
				WHERE #local.sess.table.primary_key# = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.data.id#">
			</cfquery>

			<cfset local.result.output = "Updated #local.sess.table.name# record">

			<cfcatch type="any">
				<cfset local.result.success = false>
				<cfset local.result.output = "Problem with query - #cfcatch.message#">
<cfdump var="#cfcatch#"><cfabort>

			</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="getBlank" returntype="struct" access="public">
		<cfset var local = {}>
		<cfset local.blank = {}>

		<cfset local.sess = getSession()>

		<cfloop from="1" to="#ListLen(local.sess.table.field_list)#" index="local.i">
			<cfset local.fld = ListGetAt(local.sess.table.field_list, local.i)>
			<cfset local.field = local.sess.table.fields[local.fld]>

			<cfset local.blank[local.fld] = local.field.default_value>
		</cfloop>

		<cfreturn local.blank>
	</cffunction>

	<cffunction name="get" returntype="struct" access="public">
		<cfargument name="id" type="numeric" required="true">

		<cfset var local = {}>
		<cfset local.data = getMultiple(id=arguments.id)>

		<cfif ArrayLen(local.data) gt 0>
			<cfset local.data = local.data[1]>
		<cfelse>
			<cfthrow type="application" message="Unable to get record - #arguments.id#">
		</cfif>	
		
		<cfreturn local.data>
	</cffunction>

	<cffunction name="getMultiple" returntype="array" access="public">
		<cfargument name="id" type="numeric" required="false" default="-1">
		<cfargument name="order_by" type="string" required="false" default="">

		<cfset var local = {}>

		<cfset local.sess = getSession()>

		<cftry>
			<cfset local.flds = "">
			<cfloop list="#local.sess.table.field_list#" index="local.f">
				<cfset local.fld = "`#local.f#`">
				<cfset local.flds = ListAppend(local.flds, local.fld)>
			</cfloop>

			<cfquery name="local.getData" datasource="#local.sess.table.datasource#">
				select #local.flds#
				from #local.sess.table.name#
				WHERE 1 = 1
				<cfif arguments.id gt 0>
					AND `#local.sess.table.primary_key#` = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
				</cfif>

				<cfloop from="1" to="#ArrayLen(local.sess.table.filter)#" index="local.ffld">
					<!--- If needed, repair this
					<cfset local.fld = local.sess.table.fields[local.ffld]>
					<cfif local.fld.data_type eq "int">
						AND `#local.fld.column_name#` = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.config.filter[local.ffld].value#">
					<cfelse>
						AND `#local.fld.column_name#` = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.config.filter[local.ffld].value#">
					</cfif>
					 --->
				</cfloop>

				<cfif Len(local.sess.table.order_by)>
				ORDER BY `#local.sess.table.order_by#`
				<cfelseif Len(local.sess.table.primary_key) eq 0>
				<cfelse>
				ORDER BY `#local.sess.table.primary_key#`
				</cfif>
			</cfquery>

			<cfcatch type="any">
				<cfoutput><p>Re-run the Schema build (System menu)</p></cfoutput>
				<cfdump var="#cfcatch#">
				<cfdump var="#local.sess.table#"><cfabort>
			</cfcatch>
		</cftry>

		<cfif local.getData.recordCount eq 0>
			<cfset local.data = []>
		<cfelse>
			<cfset local.data = getFactory("dataTypeConvert").queryToArray(local.getData)>
		</cfif>

		<cfreturn local.data>
	</cffunction>

	<cffunction name="delete" access="public" returntype="struct">
		<cfargument name="id" type="numeric" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset local.sess = getSession()>

		<cftry>
			<cfquery datasource="#local.sess.datasource#" name="local.delRecord">
				delete from `#local.sess.database#`.`#local.sess.table.name#`
				WHERE #local.sess.table.primary_key# = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			</cfquery>
			
			<cfset local.result.output = "Deleted #local.sess.table.name# record">

			<cfcatch type="any">
				<cfset local.result.success = false>
				<cfset local.result.output = "Problem with query - #cfcatch.message#">
				<cfdump var="#cfcatch#">
			</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="getForeignData" returntype="array" access="private">
		<cfargument name="datasource" type="string" required="true">
		<cfargument name="table" type="string" required="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfargument name="key_field" type="string" required="true">
		<cfargument name="label_field" type="string" required="true">
	
		<cfquery datasource="#arguments.datasource#" name="local.get" username="#arguments.username#" password="#arguments.passwoord#">
			SELECT #arguments.key_field# as `key`, #arguments.label_field# as `label`
			FROM #arguments.table#
		</cfquery>

		<cfif local.get.recordCount eq 0>
			<cfset local.data = []>
		<cfelse>
			<cfset local.data = getFactory("dataTypeConvert").queryToArray(local.get)>
		</cfif>

		<cfreturn local.data>
	</cffunction>

	<cffunction name="getTableInfo" returntype="struct" access="public">
		<cfset var local = {}>

		<cfset local.sess = getSession()>

		<cfset local.result = {
				datasource=local.sess.datasource,
				database=local.sess.database,
				name=local.sess.table,
				field_list="",
				order_by="",
				field_names_for_insert="",
				has_auto_increment=false
		}>

		<cfset local.pfx = "information_schema.">

		<cfquery datasource="#local.sess.datasource#" name="local.getInfo"
				username="#local.sess.username#" password="#local.sess.password#"
		>
			SELECT
					s.schema_name AS `dbName`,
					t.table_name,
					c.column_name, c.ORDINAL_POSITION, c.column_default, c.IS_NULLABLE,
					c.DATA_TYPE, c.COLUMN_TYPE, c.COLUMN_KEY, c.EXTRA, c.COLUMN_COMMENT, c.CHARACTER_MAXIMUM_LENGTH

			FROM #local.pfx#schemata s, #local.pfx#tables t, #local.pfx#columns c

			WHERE t.table_schema = s.schema_name
				AND c.TABLE_NAME = t.TABLE_NAME
				AND c.table_schema = s.SCHEMA_NAME
				AND c.table_schema = '#local.sess.database#'
				AND c.table_name = '#local.sess.table#'

			ORDER BY c.ordinal_position
		</cfquery>

		<cfset local.fields = {}>
		<cfloop query="local.getInfo">
			<cfset local.fld = getFactory("dataTypeConvert").queryRowToStruct(local.getInfo, local.getInfo.currentRow)>

			<cfset local.result.field_list = ListAppend(local.result.field_list, local.fld.column_name)>

			<cfif local.fld.extra eq "AUTO_INCREMENT">
				<cfset local.fld.edit = false>
				<cfset local.fld.auto = true>
				<cfset local.result.has_auto_increment = true>
			<cfelseif local.fld.column_default eq "CURRENT_TIMESTAMP">
				<cfset local.fld.edit = false>
			<cfelse>
				<cfset local.fld.edit = true>
				<cfset local.fld.auto = false>
			</cfif>

			<!--- Order by the first char column you reach --->
			<cfif Len(local.result.order_by) eq 0 AND FindNoCase("char", local.fld.column_type)>
				<cfset local.result.order_by = local.fld.column_name>
			</cfif>

			<cfif local.fld.column_key eq "PRI">
				<cfset local.result.primary_key = local.fld.column_name>
			</cfif>

			<cfif local.fld.edit>
				<cfset local.result.field_names_for_insert = ListAppend(local.result.field_names_for_insert, local.fld.column_name)>
			</cfif>

			<cfset local.fld.is_Lookup = false>
			<cfset local.fld.config = {type="default"}>
			<cfloop from="1" to="#ListLen(local.fld.column_comment, '|')#" index="local.c">
				<cfset local.val = ListGetAt(local.fld.column_comment, local.c, "|")>
				<cfif local.c eq 1>
					<cfset local.key = "type">
				<cfelseif local.fld.config.type eq "lookup">
					<cfif local.c eq 2>
						<cfset local.key = "table">
					<cfelseif local.c eq 3>
						<cfset local.key = "primary_key">
					<cfelseif local.c eq 4>
						<cfset local.key = "label_field">
					</cfif>
				</cfif>
				<cfset local.fld.config[local.key] = local.val>
			</cfloop>

			<cfif local.fld.config.type eq "lookup">
				<cfset local.fld.lookup = getForeignData(
						datasource=local.ds,
						table=local.fld.config.table,
						label_field=local.fld.config.label_field,
						key_field=local.fld.config.primary_key
				)>

				<!--- Make any blank value 'null' when it is displayed --->
				<cfloop from="1" to="#ArrayLen(local.fld.lookup.fields)#" index="local.ff">
					<cfif Len(local.fld.lookup.fields[local.ff].label) eq 0>
						<cfset local.fld.lookup.fields[local.ff].label = "null">
						<cfset local.fld.lookup.ordered_labels = ListInsertAt(local.fld.lookup.ordered_labels, local.ff, local.fld.lookup.fields[local.ff].label)>
					</cfif>
				</cfloop>
			</cfif>
			<cfif local.fld.is_lookup>
				<cfset local.fld.comment = "">
			<cfelse>
				<cfset local.fld.comment = local.fld.column_comment>
			</cfif>

			<cfif ListFindNoCase("VARCHAR,CHAR,TEXT", local.fld.data_type)>
				<cfset local.fld.default_value = "">

			<cfelseif FindNoCase("DATETIME", local.fld.data_type)>
				<cfset local.fld.default_value = DateFormat(now(), "d-mmm-yyyy")>

			<cfelse>
				<cfset local.fld.default_value = -1>
			</cfif>

			<cfset local.fields[local.fld.column_name] = local.fld>
		</cfloop>
		<cfset local.result.fields = local.fields>

		<!--- Order by primary key! --->
		<cfif Len(local.result.primary_key)>
			<cfset local.result.order_by = local.result.primary_key>
		</cfif>

		<!--- Just for now  --->
		<cfset local.result.filter = []>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="getScriptRoot" returntype="string" access="public">
		<cfreturn "/index.cfm/genericEditor">	
	</cffunction>

</cfcomponent>