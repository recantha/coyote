<cfcomponent displayname="glacier">
	
	<cffunction name="init" returntype="glacier" access="public">
		<cfset var local = {}>
		<cfset local.debug = structKeyExists(url, "debugapp")>

		<cfif local.debug><cfoutput><p>GMI1: #now()#</p></cfoutput></cfif>

		<cfset local.tmp_settings = getFactory("dataTypeConvert").xmlFileToStruct(ExpandPath("/com/glacier/config/settings.xml")).settings>

		<cfif local.debug><cfoutput><p>GMI2: #now()#</p></cfoutput></cfif>
		<cfset variables.settings = getFactory("dataTypeConvert").arrayOfStructsToStructWithKey(local.tmp_settings.setting, "name")>

		<cfif local.debug><cfoutput><p>GMI3: #now()#</p></cfoutput></cfif>

		<cfreturn this/>
	</cffunction>

	<!--- model/queries --->
	<cffunction name="getBlankPage" returntype="struct" access="public">
		<cfset var local = {page=structNew()}>

		<cfloop list="path,folder_id,title,headline,body,code_call,side_title,side_body,side_code_call,full_url,end_url" index="local.fld">
			<cfset local.page[local.fld] = "">
		</cfloop>
		<cfset local.page.id = -1>

		<cfreturn local.page>
	</cffunction>

	<cffunction name="getPage" returntype="struct" access="public">
		<cfargument name="path" type="string" required="false" default="">
		<cfargument name="id" type="numeric" required="false" default="-1">
		<cfargument name="folder_id" type="numeric" required="false" default="-1">

		<cfset var local = {}>
		<cfset local.pages = getPages(path=arguments.path, id=arguments.id, folder_id=arguments.folder_id)>

		<cfif ArrayLen(local.pages) eq 1>
			<cfset local.page = local.pages[1]>
			<cfset local.page.folder = getFolder(local.page.folder_id)>
		<cfelse>
			<cfset local.page = getBlankPage()>
			<cfset local.page.success = false>
		</cfif>
		<cfreturn local.page>
	</cffunction>

	<cffunction name="getPages" returntype="array" access="public">
		<cfargument name="path" type="string" required="false" default="">
		<cfargument name="id" type="numeric" required="false" default="-1">
		<cfargument name="folder_id" type="numeric" required="false" default="-1">

		<cfset var local = {}>
		<cfquery datasource="#getSetting('glacier_ds')#" name="local.pageQry" username="#getSetting('glacier_ds_username')#" password="#getSetting('glacier_ds_password')#">
			select *
			from page
			where 1=1
			<cfif arguments.id gt 0>
				and id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#">
			<cfelse>
				<cfif Len(arguments.path)>
					and path = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.path#">
				</cfif>
				<cfif arguments.folder_id gt -1>
					and folder_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.folder_id#">
				</cfif>
			</cfif>
			order by path
		</cfquery>

		<cfset local.pages = getFactory("dataTypeConvert.model").queryToArray(local.pageQry)>

		<cfset local.sort_pages = []>
		<cfloop from="1" to="#ArrayLen(local.pages)#" index="local.p">
			<cfset local.pg = local.pages[local.p]>

			<cfset local.pg.success = true>

			<!--- Get the whole URL for the page --->
			<cfset local.next_folder_id = local.pg.folder_id>
			<cfset local.flds = []>
			<cfset local.max_depth = 30>
			<cfset local.cur_depth = 0>
			<cfloop condition="local.next_folder_id neq 0">
				<cfset local.cur_depth++>

				<cfset local.fld = getFolder(local.next_folder_id)>
				<cfif NOT local.fld.success>
					<cfabort showerror="Folder #local.next_folder_id# not found">
				<cfelse>
					<cfset ArrayPrepend(local.flds, local.fld)>
					<cfset local.next_folder_id = local.fld.parent_folder_id>
				</cfif>

				<cfif local.cur_depth eq local.max_depth>
					<cfabort showerror="Max depth exceeded">
				</cfif>
			</cfloop>

			<cfset local.pg.end_url = "">
			<cfloop from="1" to="#ArrayLen(local.flds)#" index="local.f">
				<cfset local.pg.end_url = local.pg.end_url & local.flds[local.f].path & "/">
			</cfloop>

			<cfset local.pg.end_url = local.pg.end_url & local.pg.path>
			<cfset local.pg.full_url = "/index.cfm" & local.pg.end_url>

			<cfif local.pg.path eq "index">
				<cfset ArrayPrepend(local.sort_pages, local.pg)>
			<cfelse>
				<cfset ArrayAppend(local.sort_pages, local.pg)>
			</cfif>

			<cfset local.pages[local.p] = local.pg>
		</cfloop>

		<cfreturn local.sort_pages>
	</cffunction>

	<cffunction name="addPage" returntype="struct" access="public">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = {}>
		<cfset local.result=getResult()>

		<cftry>
			<cfquery datasource="#getSetting('glacier_ds')#" name="local.add" username="#getSetting('glacier_ds_username')#" password="#getSetting('glacier_ds_password')#">
				insert into page (
					path, folder_id,
					title, headline, body, code_call,
					side_title, side_body, side_code_call
				)
				values (
					<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.path#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.data.folder_id#">,
					<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.title#">,
					<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.headline#">,
					<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.body#">,
					<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.code_call#">,
					<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.side_title#">,
					<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.side_body#">,
					<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.side_code_call#">
				)
			</cfquery>
			<cfcatch type="any">
				<cfset local.result.output = "Error with add - #cfcatch.Message#">
				<cfset local.result.success = false>
<cfdump var="#cfcatch#"><cfabort>

			</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="updatePage" returntype="struct" access="public">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = {}>
		<cfset local.result =getResult()>

		<cftry>
			<cfquery datasource="#getSetting('glacier_ds')#" name="local.add" username="#getSetting('glacier_ds_username')#" password="#getSetting('glacier_ds_password')#">
				update page
					set
						path = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.path#">,
						folder_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.folder_id#">,
						title = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.title#">,
						headline = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.headline#">,
						body = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.data.body#">,
						code_call = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.code_call#">,
						side_title = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.side_title#">,
						side_body = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.data.side_body#">,
						side_code_call = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.side_code_call#">
					where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#">
			</cfquery>
			<cfcatch type="any">
				<cfdump var="#cfcatch#">
				<cfset local.result.output = "Error with update - #cfcatch.Message#">
				<cfset local.result.success = false>
			</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="deletePage" returntype="struct" access="public">
		<cfargument name="id" type="numeric" required="true">

		<cfset var local = {}>
		<cfset local.result =getResult()>

		<cftry>
			<cfquery datasource="#getSetting('glacier_ds')#" name="local.del" username="#getSetting('glacier_ds_username')#" password="#getSetting('glacier_ds_password')#">
				delete from page
				where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#">
			</cfquery>
			<cfcatch type="any">
				<cfset local.result.output = "Error with delete - #cfcatch.Message#">
				<cfset local.result.success = false>
			</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="pageExists" returntype="boolean" access="public">
		<cfargument name="page" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.pg = arguments.page>

		<cfset local.check = getPage(folder_id=local.pg.folder_id, path=local.pg.path)>

		<cfif local.check.success>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="getBlankFolder" returntype="struct" access="public">
		<cfset var local = {}>
		<cfset local.folder = {
				id=-1,
				title="",
				path="",
				parent_folder_id=-1,
				template=""
		}>

		<cfreturn local.folder>
	</cffunction>

	<cffunction name="getFolder" returntype="struct" access="public">
		<cfargument name="id" type="numeric" required="false" default="-1">
		<cfargument name="parent_folder_id" type="numeric" required="false" default="-2">
		<cfargument name="path" type="string" required="false" default="" hint="To key the path column of the folder table">

		<cfset var local = {}>

		<!--- Request caching for the template finding --->
		<cfparam name="request.glacier_get_folder_cache" default="#StructNew()#">
		<cfif arguments.id gt -1 AND StructKeyExists(request.glacier_get_folder_cache, arguments.id)>
			<cfset local.folder = request.glacier_get_folder_cache[arguments.id]>

		<cfelse>
			<cfif arguments.id eq 0>
				<cfset local.folder = getBlankFolder()>
				<cfset local.folder.url = "/">
			<cfelse>
				<cfset local.folders = getFolders(id=arguments.id, parent_folder_id=arguments.parent_folder_id, path=arguments.path)>
		
				<cfif ArrayLen(local.folders) eq 1>
					<cfset local.folder = local.folders[1]>
					<cfset local.folder.url = getFolderURL(local.folder)>
		
				<cfelse>
					<cfset local.folder = getBlankFolder()>
					<cfset local.folder.success = false>
				</cfif>
			</cfif>
	
			<!--- And cache it --->
			<cfset request.glacier_get_folder_cache[arguments.id] = local.folder>
		</cfif>

		<cfreturn local.folder>
	</cffunction>

	<cffunction name="getFolders" returntype="array" access="public">
		<cfargument name="id" type="numeric" required="false" default="-1">
		<cfargument name="parent_folder_id" type="numeric" required="false" default="-2">
		<cfargument name="path" type="string" required="false" default="" hint="To key the path column of the folder table">

		<cfset var local = {}>

		<!--- SAFETY --->
		<cfparam name="request.glacier_get_folders" default="0">
		<cfset request.glacier_get_folders++>
		<cfif request.glacier_get_folders eq 1000>
			<cfabort showerror="Too many folders - hit upper limit in glacier.model.getFolders()">
		</cfif>

		<cfquery datasource="#getSetting('glacier_ds')#" name="local.get" username="#getSetting('glacier_ds_username')#" password="#getSetting('glacier_ds_password')#">
			select *
			from folder
			where 1=1
			<cfif arguments.id gt 0>
				and id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#">
			<cfelseif arguments.parent_folder_id neq -2>
				and parent_folder_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.parent_folder_id#">
			</cfif>
			<cfif Len(arguments.path)>
				AND path = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.path#">
			</cfif>
			order by parent_folder_id, path
		</cfquery>

		<cfset local.folders = getFactory("dataTypeConvert.model").queryToArray(local.get)>

		<cfif isLoggedIn() AND getCurrentUser().root_folder_id eq 0 AND arguments.parent_folder_id eq -1>
			<cfset local.fld = getBlankFolder()>
			<cfset local.fld.id = 0>
			<cfset local.fld.title = "Root">
			<cfset ArrayPrepend(local.folders, local.fld)>
		</cfif>

		<cfloop from="1" to="#ArrayLen(local.folders)#" index="local.i">
			<cfset local.folders[local.i].success = true>
		</cfloop>

		<cfreturn local.folders>
	</cffunction>

	<cffunction name="getFolderURL" returntype="string" access="public">
		<cfargument name="folder" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.fld = arguments.folder>
		<cfset local.folder_url = "/index.cfm/#local.fld.path#/">
		
		<cfloop condition="local.fld.parent_folder_id gt 0">
			<cfset local.fld = getFolder(local.fld.parent_folder_id)>
			<cfif local.fld.success>
				<cfset local.folder_url = local.folder_url & local.fld.path & "/">
			</cfif>
		</cfloop>

		<cfreturn local.folder_url>
	</cffunction>

	<cffunction name="getPageTemplate" returntype="string" access="public">
		<cfargument name="page" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.page = arguments.page>

		<cfif Len(local.page.folder_id) eq 0>
			<cfset local.folder = {template=""}>
		<cfelse>
			<cftry>
				<cfset local.folder = getFolder(id=local.page.folder_id)>
				
				<cfcatch type="any">
					<cfoutput><p>getPageTemplate() failed</p></cfoutput>
					<cfdump var="#cfcatch#">
					<cfdump var="#local.page#"><cfabort>
				</cfcatch>
			</cftry>
	
			<cfset local.template = "">
	
			<cfparam name="request.glacier_getPageTemplate" default="0">
			<cfset request.glacier_getPageTemplate++>
			<cfif request.glacier_getPageTemplate eq 100>
				<cfabort showerror="glacier.model.getPageTemplate() broke hard limit">
			</cfif>
	
			<cfloop condition="Len(local.folder.template) eq 0 AND local.folder.id gt -1">
				<cfset local.folder = getFolder(id=local.folder.parent_folder_id)>
			</cfloop>
		</cfif>

		<cfif Len(local.folder.template) eq 0>
			<cfset local.folder.template = getSetting("default_template")>
		</cfif>

		<cfreturn local.folder.template>
	</cffunction>

	<cffunction name="addFolder" returntype="struct" access="public">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = {}>
		<cfset local.result=getResult()>

		<cftry>
			<cfquery datasource="#getSetting('glacier_ds')#" name="local.add" username="#getSetting('glacier_ds_username')#" password="#getSetting('glacier_ds_password')#">
				insert into folder (
					title, path, parent_folder_id
				) values (
					<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.title#">,
					<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.path#">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.parent_folder_id#">
				)
			</cfquery>
			<cfcatch type="any">
				<cfset local.result.output = "Error with add - #cfcatch.Message#">
				<cfset local.result.success = false>
			</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="updateFolder" returntype="struct" access="public">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = {}>
		<cfset local.result=getResult()>

		<cftry>
			<cfquery datasource="#getSetting('glacier_ds')#" name="local.add" username="#getSetting('glacier_ds_username')#" password="#getSetting('glacier_ds_password')#">
				update folder
					set
						title = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.title#">,
						path = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.path#">,
						parent_folder_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.parent_folder_id#">,
						template = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.template#">
					where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#">
			</cfquery>

			<cfcatch type="any">
				<cfdump var="#cfcatch#"><cfabort>

				<cfset local.result.output = "Error with update - #cfcatch.Message#">
				<cfset local.result.success = false>
			</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="deleteFolder" returntype="struct" access="public">
		<cfargument name="id" type="numeric" required="true">

		<cfset var local = {}>
		<cfset local.result=getResult()>

		<cftry>
			<cfquery datasource="#getSetting('glacier_ds')#" name="local.del" username="#getSetting('glacier_ds_username')#" password="#getSetting('glacier_ds_password')#">
				delete from folder
				where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#">
			</cfquery>
			<cfcatch type="any">
				<cfset local.result.output = "Error with delete - #cfcatch.Message#">
				<cfset local.result.success = false>
			</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="getSiteMap" returntype="struct" access="public">
		<cfargument name="parent_folder_id" type="numeric" required="true">

		<cfset var local = {}>
		<cfset local.map = {}>

		<cfset local.map.folders = getFolders(parent_folder_id=arguments.parent_folder_id)>
		<cfset local.map.pages = getPages(folder_id=arguments.parent_folder_id)>

		<cfloop from="1" to="#ArrayLen(local.map.folders)#" index="local.i">
			<cfif local.map.folders[local.i].id neq 0>
				<cfset local.subMap = getSiteMap(local.map.folders[local.i].id)>
				<cfset local.map.folders[local.i].folders = local.subMap.folders>
				<cfset local.map.folders[local.i].pages = local.subMap.pages>
			<cfelse>
				<cfset local.map.folders[local.i].folders = []>
				<cfset local.map.folders[local.i].pages = []>
			</cfif>
		</cfloop>

		<cfreturn local.map>
	</cffunction>

	<cffunction name="getContent" returntype="struct" access="public">
		<cfargument name="path" type="string" required="true">

		<cfset var local = {}>
		<cfset local.result =getResult()>
		<cfset local.debug = false>

		<cfset local.last_part = ListLast(arguments.path, "/")>
		<cfset local.base_parts = ListDeleteAt(arguments.path, ListLen(arguments.path, "/"), "/")>

		<!--- Get the root folder for the site --->
		<cfset local.folder = getFolder(parent_folder_id=0, path="")>

		<!--- Work out how many parts to the path --->
		<cfset local.part_count = ListLen(arguments.path, "/")>

		<cfif local.debug>
			<cfoutput><p>There are #local.part_count# parts to the path</p></cfoutput>
		</cfif>

		<cfloop from="1" to="#local.part_count#" index="local.i">
			<cfset local.part = ListGetAt(arguments.path, local.i, "/")>
			<cfif local.debug>
				<cfoutput><h4>Part #local.i#: #local.part#</h4></cfoutput>
			</cfif>

			<cfif local.i neq local.part_count>
				<!--- Not the last part, so it is a folder --->
				<cfif local.debug><cfoutput><h3>Not the last part</h3></cfoutput></cfif>

				<cfset local.folder = getFolder(parent_folder_id=local.folder.id, path=local.part)>

				<cfif NOT local.folder.success>
					<cfif local.debug><cfoutput>No folder<br></cfoutput></cfif>
					<cfset local.page = getBlankPage()>
					<cfset local.page.success = false>
					<cfbreak>
				</cfif>
				<!--- Then let it loop again --->

			<cfelse>
				<!--- Try and get a page with the folder_id of local.folder.id --->
				<cfset local.page = getPage(folder_id=local.folder.id, path=local.part)>

				<!--- If no page is found, try to find a folder with the parent_folder_id of local.folder.id --->
				<cfif NOT local.page.success>
					<!--- Then get the index page of that folder, if possible --->
					<cfif local.debug><cfoutput>Page not found, trying to get folder<br></cfoutput></cfif>
					<cfset local.folder = getFolder(parent_folder_id=local.folder.id, path=local.part)>
					<cfif local.folder.success>
						<cfif local.debug><cfoutput>Folder found, getting index page<br></cfoutput></cfif>
						<cfset local.page = getPage(folder_id=local.folder.id, path="index")>
						<cfif NOT local.page.success>
							<cfif local.debug><cfoutput>Index page not found in folder #local.part#<br></cfoutput></cfif>
						</cfif>
					<cfelse>
						<cfif local.debug><cfoutput>Folder not found<br></cfoutput></cfif>
					</cfif>
				<cfelse>
					<cfif local.debug><cfoutput>Page found<br></cfoutput></cfif>
				</cfif>
			</cfif>
			<cfif local.debug><cfoutput><hr></cfoutput></cfif>
		</cfloop>

		<cfset local.page.template = getPageTemplate(local.page)>

		<cfset local.safety = 0>

		<cfreturn local.page>
	</cffunction>

	<cffunction name="getTemplates" returntype="string" access="public">
		<cfset var local = {}>
		<cfset local.com = getFactory("template", true)>

		<cfreturn StructKeyList(local.com)>
	</cffunction>

	<cffunction name="isLoggedIn" access="public" returntype="boolean">
		<cfif StructKeyExists(session, "user") AND session.user.success>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="getCodeCallList" access="public" returntype="string">
		<cfreturn "Select if required,Contact form|plugin_contact.contactForm">
	</cffunction>

	<cffunction name="onRequestEnd" access="public" returntype="struct" hint="Handle Execution-by-Inference - DOES ALL THE WORK" output="true">
		<cfargument name="content" type="string" required="false" default="" hint="Any content you want to feed in to be added to the bottom of the EBI">

		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.result.success = false><!--- Default --->
		<cfset local.scope = getScope()>

		<!--- work out what page we are on --->
		<cfset local.original_path = cgi.PATH_INFO>

		<!--- Used for CMS content getting --->
		<cfset local.content_path = Replace(local.original_path, ".cfm", "")>
		<cfif Len(local.content_path) eq 0>
			<cfset local.content_path = "/">
		</cfif>
		<cfif Right(local.content_path, 1) eq "/">
			<cfset local.content_path = local.content_path & "index">
		</cfif>

		<cfset local.path_tail = Replace(local.original_path, "/index.cfm", "")>
		<cfif Len(local.path_tail) eq 0>
			<!--- Homepage --->
			<cfset local.path_tail = "/">
		<cfelse>
			<cfset local.path_tail = ReReplace(local.path_tail, "\/$", "")>
			<cfset local.path_tail = ReReplace(local.path_tail, "^\/", "")>
		</cfif>

		<!--- Execution-By-Inference section --->
		<cfif ListLen(local.path_tail, "/") ge 2>
			<cfset local.comp = ListGetAt(local.path_tail, 1, "/")>
			<cfset local.meth = ListGetAt(local.path_tail, 2, "/")>
		<cfelseif ListLen(local.path_tail, "/") eq 1>
			<cfset local.comp = ListGetAt(local.path_tail, 1, "/")>
			<cfset local.meth = "default">
		<cfelse>
			<cfset local.comp = "">
			<cfset local.meth = "">
		</cfif>

		<cfif Len(local.comp) AND getFactory("coyote").comExists("#local.comp#.controller")>
			<cftry>
				<cfinvoke component="#getFactory('#local.comp#.controller')#" method="#local.meth#" returnvariable="local.ebi">
					<cfinvokeargument name="scope" value="#local.scope#">
				</cfinvoke>

				<cfcatch type="any">
					<cfif FindNoCase("debugFactory", local.original_path)>
						<cfdump var="#cfcatch#"><cfabort>
					</cfif>

					<cfset local.ebi = getResult()>
					<cfset local.ebi.success = false>
					
					<cfsavecontent variable="local.ebi.output">
						<cfdump var="#local.ebi#" label="EBI failed">
						<cfdump var="#cfcatch#">
					</cfsavecontent>
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset local.ebi = getResult()>
			<cfset local.ebi.success = false>
			<cfset local.ebi.output = "#local.comp#.controller does not exist as a component in Coyote and cannot be EBId">
		</cfif>

		<cfset local.inc = getResult()>
		<cfset local.inc.output = arguments.content>

		<!--- Get content from CMS, add the EBI --->
		<cfset local.content = getContent(local.content_path)>
		<cfset local.combo = structNew()>
		<cfset local.combo.ebi = local.ebi>
		<cfset local.combo.content=local.content>
		<cfset local.combo.inc = local.inc>

		<cftry>
			<!--- Determine what template you are using --->
			<cfif local.comp eq "glacier">
				<cfset local.template = "glacier.template">
			<cfelseif NOT StructKeyExists(local.combo.content, "template") OR Len(local.combo.content.template) eq 0>
				<cfset local.template = "template." & getSetting("default_template")>
			<cfelse>
				<cfset local.template = "template.#local.combo.content.template#">
			</cfif>

			<cfset local.result.output = getFactory(local.template).wrapTemplate("default", local.combo).output>
			<cfset local.result.output = Trim(local.result.output)>
			<cfset local.result.output = REReplace(local.result.output, "^[[:space:]]+<", "<", "all" )>
			<cfset local.result.output = REReplace(local.result.output, ">[[:space:]]+$", ">", "all" )>
			<cfset local.result.output = REReplace(local.result.output, "^[[:space:]]+$", "", "all" )>
			
			<cfcatch type="any">
				<cfdump var="#local.combo#">
				<cfdump var="#cfcatch#"><cfabort>
			</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="login" returntype="struct" access="public">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
	
		<cfset var local = {}>
		<cfset local.result = getResult()>
	
		<cfquery datasource="#getSetting('glacier_ds')#" name="local.user" username="#getSetting('glacier_ds_username')#" password="#getSetting('glacier_ds_password')#">
			select *
			from users
			where username = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.username#">
			and password = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.password#">
		</cfquery>
	
		<cfif local.user.recordCount>
			<cfset local.tmp = getFactory("dataTypeConvert").queryToArray(local.user)>
			<cfset local.user = local.tmp[1]>
			<cfset local.user.success = true>
			<cfset session.user = local.user>
			
			<cfset local.result.success = true>

			<cfquery datasource="#getSetting('glacier_ds')#" name="local.del" username="#getSetting('glacier_ds_username')#" password="#getSetting('glacier_ds_password')#">
				DELETE FROM sessions
				where session_id = <cfqueryparam cfsqltype="cf_sql_char" value="#session.SessionID#">
			</cfquery>

			<cfquery datasource="#getSetting('glacier_ds')#" name="local.ins" username="#getSetting('glacier_ds_username')#" password="#getSetting('glacier_ds_password')#">
				INSERT INTO sessions (
					session_id, user_id, auth_detail
				) VALUES (
					<cfqueryparam cfsqltype="cf_sql_char" value="#session.SessionID#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#local.user.id#">,
					<cfqueryparam cfsqltype="cf_sql_char" value="#getSetting('glacier_ds')#|#getSetting('glacier_ds_username')#|#getSetting('glacier_ds_password')#">
				)
			</cfquery>

			<cfset local.enc_key = "879jnasdf89asdf8sda">

			<cfsavecontent variable="local.pkt"><cfoutput>
				<auth>
					<login>1</login>
					<si>#ToBase64(Encrypt(session.SessionID, local.enc_key))#</si>
					<ds>#ToBase64(Encrypt(getSetting('glacier_ds'), local.enc_key))#</ds>
					<un>#ToBase64(Encrypt(getSetting('glacier_ds_username'), local.enc_key))#</un>
					<pw>#ToBase64(Encrypt(getSetting('glacier_ds_password'), local.enc_key))#</pw>
				</auth>
			</cfoutput></cfsavecontent>

			<cfhttp url="http://#cgi.SERVER_NAME##getSetting('glacier_ckfinder_path')#/glacier_auth.cfm"
					method="post"
					result="local.ckfinder_auth"
					useragent="#cgi.HTTP_USER_AGENT#"
			>
				<cfhttpparam type="xml" value="#local.pkt.Trim()#">
			</cfhttp>

		<cfelse>
			<cfset local.result.success = false>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="logout" returntype="void" access="public">
		<cfset var local = {}>

		<cfset StructDelete(session, "user")>

		<cfset local.enc_key = "879jnasdf89asdf8sda">
		<cfsavecontent variable="local.pkt"><cfoutput>
			<auth>
				<logout>1</logout>
				<si>#ToBase64(Encrypt(session.SessionID, local.enc_key))#</si>
			</auth>
		</cfoutput></cfsavecontent>

		<cfhttp url="http://#cgi.SERVER_NAME##getSetting('glacier_ckfinder_path')#/glacier_auth.cfm"
				method="post"
				result="local.ckfinder_auth"
				useragent="#cgi.HTTP_USER_AGENT#"
		>
			<cfhttpparam type="xml" value="#local.pkt.Trim()#">
		</cfhttp>
	</cffunction>

	<cffunction name="getCurrentUser" returntype="struct" access="public">
		<cfreturn session.user>
	</cffunction>

</cfcomponent>