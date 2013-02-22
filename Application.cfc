<cfcomponent output="true">
	<cfset this.name = "pottonvineyardchurch">

	<cfset this.mappings.com = getDirectoryfrompath(getCurrenttemplatepath())  & "com">

	<cfset this.applicationTimeout = "#createTimeSpan(1,0,0,0)#"/>
	<cfset this.sessionTimeout = "#createTimeSpan(0,1,0,0)#"/>
	<cfset this.clientManagement = "false"/>
	<cfset this.sessionManagement = "true"/>
	<cfset this.clientStorage = "registry"/>
	<cfset this.loginStorage = "session"/>
	<cfset this.setClientCookies = "true"/>
	<cfset this.setDomainCookies = "false"/>
	<cfset this.scriptProtect = "false"/>
	
	<cffunction name="onApplicationStart">
		<cfset application.dateInitialized = now()>
		<cfset addGlobalFunctions()/>
		<cfset setup()/>
	</cffunction>
	
	<cffunction name="onRequestStart">
		<cfset var local = {}>
		<cfset local.debug = StructKeyExists(url, "debugapp")>
	
		<cfset addGlobalFunctions()/>
	
		<cftry>
			<cfif StructKeyExists(url, "reloadApplication")>
				<cfif local.debug><cfoutput><p>ORS1: #now()#</p></cfoutput></cfif>
				<cfset setup()/>
				<cfif local.debug><cfoutput><p>ORS2: #now()#</p></cfoutput></cfif>
			</cfif>
	
			<cftry>
				<!--- Wait for it to be ready --->
				<cflock name="coyote_setup" type="readonly" timeout="10">
				</cflock>
	
				<cfcatch type="lock"><cfrethrow></cfcatch>
			</cftry>
			
			<cfcatch type="lock">
				<cfthrow type="application" message="Timed out waiting for read lock on Coyote">
			</cfcatch>
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="Error in onRequestStart()"><cfabort>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="onRequestEnd" output="true">
		<cfset var local = {}>
		<cfset local.debug = StructKeyExists(url, "debugapp")>
	
		<cfsetting enablecfoutputonly="true">
	
		<cfif local.debug><cfoutput><p>ORE1: #now()#</p></cfoutput></cfif>
		<cfset local.content = Trim(getPageContext().getOut().getString())>
		<cfif NOT local.debug><cfset getPageContext().getOut().clearBuffer()></cfif>
		<cfcontent reset="true">
	
		<cfif local.debug><cfoutput><p>ORE2: #now()#</p></cfoutput></cfif>
	
		<cfif local.debug><cfoutput><hr>#local.content#<hr></cfoutput></cfif>
	
		<cftry>
			<cfset local.glacierResult = getFactory("glacier.model").onRequestEnd(local.content)>
	
			<cfcatch type="any">
				<cfdump var="#cfcatch#"><cfabort>
			</cfcatch>
		</cftry>
	
		<cfif local.debug><cfoutput><p>ORE3: #now()#</p></cfoutput></cfif>
	
		<cfprocessingdirective suppressWhitespace="true">
			<!--- create new content --->
			<cfset writeOutput("#local.glacierResult.output#")>
		</cfprocessingdirective>
	
		<!--- <cfset getPageContext().getOut().flush()> --->
	</cffunction>
	
	<cffunction name="setup">
		<cfset var local = {}>
		<cfset local.debug = StructKeyExists(url, "debugapp")>
		
		<cfset local.dtc = createObject("component", "com.coyote.util.dataTypeConvert").init()>
	
		<cfparam name="request.coyote_setup_run" default="0">
		<cfset request.coyote_setup_run++>
	
		<cfoutput>coyote setup run #request.coyote_setup_run#</cfoutput>
	
		<cfif local.debug><cfoutput><p>PLa(#request.coyote_setup_run#): #now()#</p></cfoutput></cfif>
	
		<cfif request.coyote_setup_run eq 1>
			<cfif local.debug><cfoutput><p>PLb(#request.coyote_setup_run#): #now()#</p></cfoutput></cfif>
			<cfif local.debug><cfoutput><p>PLc: #now()#</p></cfoutput></cfif>
	
			<!--- We need to create a DTC to start with - we need something to work with --->
			<!--- <cfset local.dtc = createObjectByProxy("coyote.util.DataTypeConvert").init()> --->
			<cfif local.debug><cfoutput><p>PLd: #now()#</p></cfoutput></cfif>
	
			<cfset local.settings = {}>
			<cfif local.debug><cfoutput><p>PLe: #now()#</p></cfoutput></cfif>
	
			<!--- Config paths for COYOTE Settings and Components --->
			<cfset local.settings.coyote_config_path = 					"/com/coyote/config">
			<cfset local.settings.coyote_config_path_settings = 		"#local.settings.coyote_config_path#/settings.xml">
	
			<!--- Config paths for GLACIER Settings --->
			<cfset local.settings.glacier_config_path = 				"/com/glacier/config">
			<cfset local.settings.glacier_config_path_settings = 		"#local.settings.glacier_config_path#/settings.xml">
	
			<!--- Config paths for APPLICATION Settings and Components --->
			<cfset local.settings.application_config_path = 			"/com/#application.ApplicationName#/config">
			<cfset local.settings.application_config_path_settings = 	"#local.settings.application_config_path#/settings.xml">

			<cfif local.debug><cfoutput><p>SU1a: #now()#</p></cfoutput></cfif>
			<!--- Collate the file-configured settings --->
			<cfloop list="coyote_config_path_settings,glacier_config_path_settings,application_config_path_settings" index="local.key">
				<cfset local.path = ExpandPath(local.settings[local.key])>
	
				<cfif local.debug><cfoutput><p>Trying to load #local.path# (#fileExists(local.path)#)</p></cfoutput></cfif>
				<cfif FileExists(local.path)>
					<cfif local.debug><cfoutput><p>Loading...</p></cfoutput></cfif>
	
					<cfset local.tmp_settings = local.dtc.ensureIsArray(local.dtc.xmlFileToStruct(local.path).settings.setting)>
	
					<cfloop from="1" to="#ArrayLen(local.tmp_settings)#" index="local.i">
						<cfset local.set = local.tmp_settings[local.i]>

						<cfif StructKeyExists(local.settings, local.set.name)>
							<cfabort showerror="Setting #local.set.name# already exists when processing file #local.path#">
						<cfelse>
							<cfset local.settings[local.set.name] = local.set.value>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
	
			<cfset local.settings.coyote_config_path_components = 		"#local.settings.coyote_config_path#/components.xml">
			<cfset local.settings.glacier_config_path_components = 		"#local.settings.glacier_config_path#/components.xml">
			<cfset local.settings.application_config_path_components = 	"#local.settings.application_config_path#/components.xml">
	
			<cfset application.settings = local.settings>
	
			<!--- Collate the components --->
			<!--- This has to be an array because we need to control the order that the components are init()d --->
			<cfset local.components = []>
			<cfset local.family_list = "">
	
			<cfif local.debug><cfoutput><p>SU1b: #now()#</p></cfoutput></cfif>
			<cfloop list="coyote_config_path_components,application_config_path_components" index="local.key">
				<cfset local.path = ExpandPath(local.settings[local.key])>
	
				<cfif local.debug><cfoutput><p>Trying to load components #local.path# (#fileexists(local.path)#)</p></cfoutput></cfif>
	
				<cfif FileExists(local.path)>
					<cfset local.tmp_components = local.dtc.ensureIsArray(local.dtc.xmlFileToStruct(local.path).components.family)>
					<cfloop from="1" to="#ArrayLen(local.tmp_components)#" index="local.i">
						<cfset local.comp = local.tmp_components[local.i]>
	
						<cfif ListFindNoCase(local.family_list, local.comp.name)>
							<cfabort showerror="Component family #local.comp.name# already exists when processing file #local.path#">
						<cfelse>
							<cfset ArrayAppend(local.components, local.comp)>
							<cfset local.family_list = ListAppend(local.family_list, local.comp.name)>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
	
			<cftry>
				<cflock name="coyote_setup" type="exclusive" timeout="10">
					<!--- Now create the framework, init it with lots of lovely settings --->
					<cfif local.debug><cfoutput><p>SU1z: #now()#</p></cfoutput></cfif>
					<cfset application.coyote = createObject("component", "com.coyote.model.coyote").init(local.settings)>
					<cfif local.debug><cfoutput><p>SU2: #now()#</p></cfoutput></cfif>
	
					<!--- Load the factory with components --->
					<cfif local.debug><cfoutput><p>SU3: #now()#</p></cfoutput></cfif>
					<cfset application.coyote.load(local.components)>
					<cfif local.debug><cfoutput><p>SU4: #now()#</p></cfoutput></cfif>
				</cflock>
	
				<cfcatch type="lock">
					<cfthrow type="application" message="Timed out waiting for exclusive lock on Coyote">
				</cfcatch>
				<cfcatch type="any">
					<cfdump var="#cfcatch#" label="Error in onRequestStart()">
					<cfrethrow>
				</cfcatch>
			</cftry>
		</cfif>
	
	</cffunction>
	
	<cffunction name="addGlobalFunctions">
		<!--- Add global functions so that they are available globally --->
		<cfset structAppend(url, createObject("component", "com.coyote.model.globalFunctions"))/>
	</cffunction>
	
	<cffunction name="onError">
		<cfoutput><h1>Standard onError() page</h1></cfoutput>
		<cfdump var="#arguments#"><cfabort>
	</cffunction>
</cfcomponent>