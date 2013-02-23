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

	<cffunction name="install" returntype="struct" access="public">
		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<html>
					<head>
						<link rel="stylesheet" href="/res/glacier/css/glacier.css"></link>
					</head>
	
					<body>
						<div style="padding:20px">
							<div style="float:left"><img src="/res/coyote/img/coyote.jpg"></div>
							<div style="float:left">
								<h1>Coyote/Glacier Install</h1>

								<h2>Creating tables</h2>
								<cfquery datasource="#getSetting('glacier_ds')#" name="local.crt">
									DROP TABLE IF EXISTS `folder`;
								</cfquery>
								<cfquery datasource="#getSetting('glacier_ds')#" name="local.crt">
									CREATE TABLE `folder` (
										`id` INT(11) NOT NULL AUTO_INCREMENT,
										`title` VARCHAR(255) DEFAULT NULL,
										`path` VARCHAR(255) DEFAULT NULL,
										`parent_folder_id` INT(11) DEFAULT NULL,
										`template` VARCHAR(255) DEFAULT NULL,
										PRIMARY KEY (`id`)
									);
								</cfquery>
								<cfquery datasource="#getSetting('glacier_ds')#" name="local.crt">
									INSERT INTO `folder`(`id`,`title`,`path`,`parent_folder_id`,`template`) VALUES (1,'Sample',NULL,0,NULL)
								</cfquery>
								<cfquery datasource="#getSetting('glacier_ds')#" name="local.get">
									SELECT * from folder
								</cfquery>
								<cfdump var="#local.get#" expand="false" label="Root folder">

								<cfquery datasource="#getSetting('glacier_ds')#" name="local.crt">
									DROP TABLE IF EXISTS `page`;
								</cfquery>

								<cfquery datasource="#getSetting('glacier_ds')#" name="local.crt">
									CREATE TABLE `page` (
									  `id` INT(11) NOT NULL AUTO_INCREMENT,
									  `path` VARCHAR(255) DEFAULT NULL,
									  `folder_id` INT(11) NOT NULL,
									  `title` VARCHAR(255) NOT NULL,
									  `headline` VARCHAR(255) DEFAULT NULL,
									  `body` TEXT,
									  `code_call` VARCHAR(255) DEFAULT NULL,
									  `side_title` VARCHAR(255) DEFAULT NULL,
									  `side_body` TEXT,
									  `side_code_call` VARCHAR(255) DEFAULT NULL,
									  PRIMARY KEY (`id`)
									)
								</cfquery>

								<cfquery datasource="#getSetting('glacier_ds')#" name="local.crt">
									DROP TABLE IF EXISTS `sessions`;
								</cfquery>

								<cfquery datasource="#getSetting('glacier_ds')#" name="local.crt">
									CREATE TABLE `sessions` (
									  `id` INT(11) NOT NULL AUTO_INCREMENT,
									  `session_id` VARCHAR(255) DEFAULT NULL,
									  `user_id` INT(11) DEFAULT NULL,
									  `auth_detail` VARCHAR(255) DEFAULT NULL,
									  PRIMARY KEY (`id`)
									)
								</cfquery>

								<cfquery datasource="#getSetting('glacier_ds')#" name="local.crt">
									DROP TABLE IF EXISTS `users`;
								</cfquery>

								<cfquery datasource="#getSetting('glacier_ds')#" name="local.crt">
									CREATE TABLE `users` (
									  `id` INT(11) NOT NULL AUTO_INCREMENT,
									  `username` VARCHAR(255) NOT NULL,
									  `password` VARCHAR(255) NOT NULL,
									  `root_folder_id` INT(11) DEFAULT NULL,
									  PRIMARY KEY (`id`)
									)
								</cfquery>

								<cfquery datasource="#getSetting('glacier_ds')#" name="local.crt">
									INSERT  INTO `users`(`id`,`username`,`password`,`root_folder_id`) VALUES (1,'admin','admin',1);
								</cfquery>
							</div>
						</div>
					</body>
				</html>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

</cfcomponent>