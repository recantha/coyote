<cfcomponent displayName="genericEditor" hint="VIEW">

	<cffunction name="init" returntype="genericEditor" access="public">
		<cfreturn this />
	</cffunction>

	<cffunction name="default" returntype="struct" access="public">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				You should not see this page
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="list" returntype="struct" access="public">
		<cfargument name="data" type="array" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.data = arguments.data>

		<cfset local.script_root = getFactory("genericEditor.model").getScriptRoot()>
		<cfset local.sess = getFactory("genericEditor.model").getSession()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
			<!--- <cfdump var="#arguments.data#"> --->
				<script type="text/javascript">
					$(document).ready(function() {
						$(document).keypress(function(e) {
							if (e.keyCode == '13') {
								window.location = $('.add_new_record').attr('href');
							}
						})
					})
				</script>

				#getFactory("iconUtil").icon(icon="page_add", href="#local.script_root#/add", label="Add").output#
				<div class="clear"></div>

				<table width="100%" cellpadding="4" cellspacing="0" border="1" class="data_edit_table">
					<tr>
						<cfloop list="#local.sess.table.field_list#" index="local.fld">
							<th><a href="#local.script_root#list/table/#local.sess.table.name#/datasource/#local.sess.datasource#/order_by/#local.sess.table.order_by#">#local.fld#</a></th>
						</cfloop>
						<th width="50">Edit/Del</th>
					</tr>

					<cfloop from="1" to="#ArrayLen(local.data)#" index="local.i">
						<tr>
							<cfloop list="#local.sess.table.field_list#" index="local.fld">
								<cfset local.field = local.sess.table.fields[local.fld]>

								<cfif local.field.is_lookup AND Len(local.data[local.i][local.fld])>
									<cftry>
									<cfset local.current_label = getFactory("matrix.model").foreignLookup(
											table=local.field.lookup_cfg.table,
											label_field=local.field.lookup_cfg.label_field,
											key_field=local.field.lookup_cfg.primary_key,
											key_value=local.data[local.i][local.fld]
									)>
									<cfcatch type="any">
										<cfset local.current_label = "#local.data[local.i][local.fld]#^;^Unable to get label from #local.field.lookup_cfg.table#">
									</cfcatch>
									</cftry>
								<cfelseif Len(local.data[local.i][local.fld]) eq 0>
									<cfset local.current_label = "null">
								<cfelse>
									<cfset local.current_label = local.data[local.i][local.fld]>
								</cfif>
								<td valign="top" align="left" <cfif local.current_label eq "null">style="color:lightgray"</cfif>>
									<cfif FindNoCase("char", local.field.column_type) AND Find('<', local.current_label)>
										#HTMLCodeFormat(local.current_label)#
									<cfelse>
										#Replace(local.current_label, "^;^", "<br>", "ALL")#
									</cfif>
								</td>
							</cfloop>
							<td width="50">
								<div style="float:left">
									#getFactory("iconUtil").icon(icon="page_edit", href="#local.script_root#/edit?id=#local.data[local.i][local.sess.table.primary_key]#").output#
								</div>
								<div id="deleteRecord_#local.data[local.i][local.sess.table.primary_key]#" class="fake_pointer" style="float:left">
									#getFactory("iconUtil").icon(icon="page_delete", href="#local.script_root#/delete?id=#local.data[local.i][local.sess.table.primary_key]#").output#
								</div>
								<div class="clear"></div>
							</td>
						</tr>
					</cfloop>
				</table>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="edit" returntype="struct" access="public">
		<cfargument name="mode" type="string" required="true" hint="add or edit">
		<cfargument name="id" type="numeric" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset local.sess = getFactory("genericEditor.model").getSession()>
		<cfset local.script_root = getFactory("genericEditor.model").getScriptRoot()>

		<cfif arguments.mode eq "add">
			<cfset local.data = getFactory("genericEditor.model").getBlank()>
		<cfelse>
			<cfset local.data = getFactory("genericEditor.model").get(id=arguments.id)>
		</cfif>

		<!--- Check for an auto-incremented primary key --->
		<cfif local.sess.table.fields[local.sess.table.primary_key].auto>
			<cfset local.nextID = -1>
		<cfelse>
			<cfset local.nextID = getFactory("dbUtil").getMaxID(
					local.sess.datasource, local.sess.database,
					local.sess.table,
					local.sess.username, local.sess.password
			) + 1>
		</cfif>

		<!--- Reinstate if necessary
		<cfloop list="#StructKeyList(arguments.scope.config.filter)#" index="local.f">
			<cfset local.blank[local.f] = arguments.scope.config.filter[local.f].value>
		</cfloop>
		 --->

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<form action="#local.script_root#/update" method="post" id="ge">
					<input type="hidden" name="mode" id="mode" value="#arguments.mode#">
					<div style="height:20px"></div>
					<div class="clear"></div>

					<cfif arguments.mode eq "add">
						<cfif local.sess.table.has_auto_increment>
							<h4>This record will be assigned an ID automatically</h4>
						<cfelse>
							<h3>There is no auto-increment ID - recommended id is #arguments.suggested_id#</h3>
						</cfif>

					<cfelseif arguments.mode eq "edit">
						<!--- if not auto-increment, id will show up as an editable field --->
						<input type="hidden" name="original_id" value="#local.data[local.sess.table.primary_key]#">
						<cfif local.sess.table.has_auto_increment>
							<input type="hidden" name="id" value="#local.data[local.sess.table.primary_key]#">
						<cfelse>
						</cfif>
					</cfif>

					<div style="height:20px"></div>
					<div class="clear"></div>

					<cfset local.input_field_count = 0>

					<cfloop from="1" to="#ListLen(local.sess.table.field_list)#" index="local.f">
						<cfset local.fld = ListGetAt(local.sess.table.field_list, local.f)>

						<cfset local.field = local.sess.table.fields[local.fld]>

						<cfif local.field.edit>
							<cfif Len(local.field.column_name) gt 15>
								<cfset local.wide = true>
							<cfelse>
								<cfset local.wide = false>
							</cfif>

							<cfif local.field.is_lookup>
								<cftry>
									#getFactory("formUtil").inputSelect(
										fieldname="#local.field.column_name#",
										fieldlabel="#local.field.column_name#<br><span style='font-size:smaller'>(#local.field.column_type#)</font>",
										fieldvalue=local.data[local.fld],
										fieldvalueslist=local.field.lookup.ordered_keys,
										fieldlabelslist=local.field.lookup.ordered_labels
									).output#

									<cfcatch type="any">
										<cfdump var="#local.field#">
										<cfabort>
									</cfcatch>
								</cftry>
							<cfelse>
								<cfset local.input_field_count++>
								<cfif isNumeric(local.field.character_maximum_length) AND local.field.character_maximum_length gt 256>
									#getFactory("formUtil").inputTextArea(
											fieldlabel="#local.field.column_name#<br><span style='font-size:smaller'>(#local.field.column_type#)</font>",
											fieldname="#local.field.column_name#", fieldvalue="#local.data[local.fld]#",
											class="generic_editor_field_#local.input_field_count#",
											comment="#local.field.view_comment#"
									).output#

								<cfelseif local.field.column_default eq "CURRENT_TIMESTAMP">
									#getFactory("formUtil").inputText(
											fieldlabel="#local.field.column_name#<br><span style='font-size:smaller'>(#local.field.column_type#)</font>",
											fieldname="___#local.field.column_name#", fieldvalue="Auto-filled with current datetime",
											class="generic_editor_field_#local.input_field_count#", readonly=true,
											comment="#local.field.view_comment#"
									).output#

								<cfelse>
									<div class="fieldlabel">#local.field.column_name# (#local.field.column_type#)</div>
									<div class="fieldinput">
										<input type="text" name="#local.field.column_name#" id="#local.field.column_name#" value="#local.data[local.field.column_name]#">
										<cfif Len(local.field.comment)><span style="font-size:9pt">#local.field.comment#</span></cfif>
									</div>
								</cfif>
							</cfif>
							<div class="clear"></div>
						</cfif>
					</cfloop>
					<div class="clear"></div>

					<div class="fieldlabel"></div>
					<div class="fieldinput"><input type="submit" value="Submit" id="submit_form" name="submit_form"></div>
					<div class="clear"></div>
				</form>

				<script type="text/javascript">
					$(document).ready(function() {
						$('.generic_editor_field_1').focus();
						$(document).keypress(function(e) {
							if (e.keyCode == '13') {
								$('##submit_form').trigger('click');
							}
						})
					})
				</script>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
</cfcomponent>