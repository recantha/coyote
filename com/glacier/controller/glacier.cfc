<cfcomponent displayname="glacier">
	
	<cffunction name="init" returntype="glacier" access="public">
		<cfreturn this/>
	</cffunction>

	<!--- controllers --->
	<cffunction name="default" returntype="struct" access="public">
		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfif getFactory("glacier.model").isLoggedIn()>
			<cfset local.root_id = session.user.root_folder_id>
	
			<cfset local.map = getFactory("glacier.model").getSiteMap(local.root_id)>
			<cfset local.result.output = getFactory("glacier.view").default(local.root_id, local.map).output>

		<cfelse>
			<cfset local.result = login()>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="isLoggedIn" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.result.restrictOutput = true>

		<cfif getFactory("glacier.model").isLoggedIn()>
			<cfset local.result.output = 1>
		<cfelse>
			<cfset local.result.output = 0>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="addPage" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset local.scope = arguments.scope>

		<cfif NOT StructKeyExists(local.scope, "submit")>
			<cfset local.page = getFactory("glacier.model").getBlankPage()>
			<cfset local.page.folder_id = local.scope.folder_id>
			<cfset local.folders = getFactory("glacier.model").getFolders()>

			<cfset local.result.output = getFactory("glacier.view").addPage(local.page, local.folders).output>

		<cfelse>
			<cfset local.page = getFactory("glacier.model").getBlankPage()>
			<cfloop list="#structKeyList(local.page)#" index="local.fld">
				<cfif structKeyExists(local.scope, local.fld)>
					<cfset local.page[local.fld] = local.scope[local.fld]>
				</cfif>
			</cfloop>

			<cfif getFactory("glacier.model").pageExists(local.page)>
				<cfset local.result.output = getFactory("glacier.messages").failure(
						"A page with that name/url already exists",
						"Return to site map",
						getSetting('glacier_url_root')
				).output>

			<cfelse>
				<cfset local.addResult = getFactory("glacier.model").addPage(local.page)>
				<cfif local.addResult.success>
					<cfset local.result.output = getFactory("glacier.messages").success(
							"You have successfully added the page",
							"Return to site map",
							getSetting('glacier_url_root'), 0
					).output>

				<cfelse>
					<cfset local.result.output = getFactory("glacier.messages").failure(
							"There was a problem adding the page (#local.addResult.output#)",
							"Return to site map",
							getSetting('glacier_url_root')
					).output>
				</cfif>
			</cfif>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="editPage" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset local.scope = arguments.scope>

		<cfif StructKeyExists(local.scope, "id")>
			<cfset local.page = getFactory("glacier.model").getPage(id=local.scope.id)>
			<cfset local.page.template = getFactory("glacier.model").getPageTemplate(local.page)>

			<cfif NOT StructKeyExists(local.scope, "submit")>
				<cfset local.folders = getFactory("glacier.model").getFolders()>
				<cfset local.result.output = getFactory("glacier.view").editPage(local.page, local.folders).output>	

			<cfelse>
				<cfloop list="#structKeyList(local.page)#" index="local.fld">
					<cfif structKeyExists(local.scope, local.fld)>
						<cfset local.page[local.fld] = local.scope[local.fld]>
					</cfif>
				</cfloop>

				<cfset local.updResult = getFactory("glacier.model").updatePage(id=local.page.id, data=local.page)>

				<cfif local.updResult.success>
					<cfset local.result.output = getFactory("glacier.messages").success(
							"You have successfully updated the page",
							"Return to site map",
							getSetting('glacier_url_root'), 0
					).output>
				<cfelse>
					<cfset local.result.output = getFactory("glacier.messages").failure(
							"There was a problem updating the page (#local.updResult.output#)",
							"Return to site map",
							getSetting('glacier_url_root')
					).output>
				</cfif>
			</cfif>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="deletePage" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset local.delRes = getFactory("glacier.model").deletePage(id=arguments.scope.id)>

		<cfif local.delRes.success>
			<cfset local.result.output = getFactory("glacier.messages").success(
					"Page deleted",
					"Return to site map",
					getSetting("glacier_url_root")
			).output>

		<cfelse>
			<cfset local.result.output = getFactory("glacier.messages").failure(
					"Unable to delete page - #local.delRes.output#",
					"Return to site map",
					getSetting("glacier_url_root")
			).output>
		</cfif>

		<cfreturn local.result>		
	</cffunction>

	<cffunction name="addFolder" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset local.scope = arguments.scope>

		<cfset local.folder = getFactory("glacier.model").getBlankFolder()>
		<cfif NOT StructKeyExists(local.scope, "submit")>
			<cfset local.folder.parent_folder_id = local.scope.parent_folder_id>

			<cfset local.folders = getFactory("glacier.model").getFolders()>

			<cfset local.result.output = getFactory("glacier.view").addFolder(local.folder, local.folders).output>

		<cfelse>
			<cfloop list="#structKeyList(local.folder)#" index="local.fld">
				<cfif structKeyExists(local.scope, local.fld)>
					<cfset local.folder[local.fld] = local.scope[local.fld]>
				</cfif>
			</cfloop>

			<cfset local.addResult = getFactory("glacier.model").addFolder(local.folder)>
			<cfif local.addResult.success>
				<cfset local.result.output = getFactory("glacier.messages").success(
						"You have successfully added the folder",
						"Return to site map",
						getSetting('glacier_url_root'), 0
				).output>

			<cfelse>
				<cfset local.result.output = getFactory("glacier.messages").failure(
						"There was a problem adding the folder (#local.addResult.output#)",
						"Return to site map",
						getSetting('glacier_url_root')
				).output>
			</cfif>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="editFolder" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset local.scope = arguments.scope>

		<cfif StructKeyExists(local.scope, "id")>
			<cfset local.folder = getFactory("glacier.model").getFolder(id=local.scope.id)>
			<cfset local.folders = getFactory("glacier.model").getFolders()>

			<cfif NOT StructKeyExists(local.scope, "submit")>
				<cfset local.result.output = getFactory("glacier.view").editFolder(local.folder, local.folders).output>

			<cfelse>
				<cfloop list="#structKeyList(local.folder)#" index="local.fld">
					<cfif structKeyExists(local.scope, local.fld)>
						<cfset local.folder[local.fld] = local.scope[local.fld]>
					</cfif>
				</cfloop>

				<cfset local.updResult = getFactory("glacier.model").updateFolder(id=local.folder.id, data=local.folder)>

				<cfif local.updResult.success>
					<cfset local.result.output = getFactory("glacier.messages").success(
							"You have successfully updated the folder",
							"Return to site map",
							getSetting('glacier_url_root'), 0
					).output>
				<cfelse>
					<cfset local.result.output = getFactory("glacier.messages").failure(
							"There was a problem updating the folder (#local.updResult.output#)",
							"Return to site map",
							getSetting('glacier_url_root')
					).output>
				</cfif>
			</cfif>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="deleteFolder" returntype="struct" access="public">
		<cfargument name="scope" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset local.delRes = getFactory("glacier.model").deleteFolder(id=arguments.scope.id)>

		<cfif local.delRes.success>
			<cfset local.result.output = getFactory("glacier.messages").success(
					"Folder deleted",
					"Return to site map",
					getSetting("urls").glacier_root
			).output>

		<cfelse>
			<cfset local.result.output = getFactory("glacier.messages").failure(
					"Unable to delete folder - #local.delRes.output#",
					"Return to site map",
					getSetting("urls").glacier_root
			).output>
		</cfif>

		<cfreturn local.result>		
	</cffunction>

	<cffunction name="login" returntype="struct" access="public">
		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.scope = getScope()>
		
		<cfif NOT StructKeyExists(local.scope, "submit")>
			<cfsavecontent variable="local.result.output">
				<cfoutput>
					<form action="/index.cfm/glacier/login" method="post" id="cmsLogin" name="cmsLogin">
						<div class="fieldlabel">Username</div>
						<div class="fieldinput"><input type="text" name="username" value="" id="username"></div>
						<div class="fieldlabel">Password</div>
						<div class="fieldinput"><input type="password" name="password" value="" id="password"></div>
						<div class="fieldlabel"></div>
						<div class="fieldinput"><input type="submit" name="submit" value="login" id="submit" class="submit"></div>
						<div class="clear"></div>
					</form>
	
					#getFactory("jQueryUtil").genericJqueryValidation(formID="cmsLogin", requiredFields="username,password").output#
				</cfoutput>
			</cfsavecontent>

		<cfelse>
			<cfset local.auth = getFactory("glacier.model").login(
					username=local.scope.username, password=local.scope.password
			)>

			<cfif local.auth.success>
				<cfset local.result.output = "<a href='#getSetting('glacier_url_root')#'>Proceed to Glacier</a>">
				<cfset local.result.output = getFactory("glacier.messages").success(
						"You are logged in",
						"Enter Glacier",
						getSetting('glacier_url_root'), 0
				).output>
			<cfelse>
				<cfset local.result.output = "Login failed">
			</cfif>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="logout" returntype="struct" access="public">
		<cfset var local = {}>
		<cfset local.result=getResult()>

		<cfset getFactory("glacier.model").logout()>

		<cfset local.result.output = getFactory("glacier.messages").success(
				"You logged out",
				"Return to Glacier",
				getSetting('glacier_url_root'), 0
		).output>

		<cfreturn local.result>
	</cffunction>

</cfcomponent>