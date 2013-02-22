<cfcomponent displayname="glacier">
	
	<cffunction name="init" returntype="glacier" access="public">
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" returntype="struct" access="public">
		<cfargument name="root_id" type="numeric" required="true">
		<cfargument name="map" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset local.map = arguments.map>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<div class="heading">
					Your website
				</div>
				<div class="clear"></div>

				<div class="tool" style="margin-right:24px">
					#getFactory("iconUtil").icon(icon="folder_add", iconfolder=getSetting('glacier_iconfolder'), label="New folder", href="#getSetting('glacier_url_root')#/addFolder?parent_folder_id=#arguments.root_id#", tip="Add folder to the top level of the website").output#
				</div>
				<div class="tool">
					#getFactory("iconUtil").icon(icon="page_add", iconfolder=getSetting('glacier_iconfolder'), label="New page", href="#getSetting('glacier_url_root')#/addPage?folder_id=#arguments.root_id#", tip="Add page to the top level of the website").output#
				</div>
				<div class="clear"></div>

				<hr>
				#displaySiteMap(local.map).output#
				<div class="clear"></div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="displaySiteMap" returntype="struct" access="public">
		<cfargument name="map" type="struct" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.map = arguments.map>

		<cftry>
			<cfsavecontent variable="local.result.output">
				<cfoutput>
					<cfloop from="1" to="#ArrayLen(local.map.folders)#" index="local.f">
						<cfif local.map.folders[local.f].id neq 0>
							<cfif Len(local.map.folders[local.f].template)>
								<cfset local.template = "Pages in this folder use the #local.map.folders[local.f].template# template">
							<cfelse>
								<cfset local.template = "Pages in this folder use the parent template">
							</cfif>

							<a name="folder_bookmark_#local.f#"></a>
							<div class="folder_wrapper">
								<div class="folder_title fake_pointer floatleft">
									#getFactory("iconUtil").icon(
											icon="folder",
											iconfolder=getSetting('glacier_iconfolder'),
											label="#local.map.folders[local.f].title# (#local.map.folders[local.f].path#)",
											tip=local.template
									).output#
								</div>
								<div class="floatleft">
									#getFactory("iconUtil").icon(
											icon="folder_edit",
											iconfolder=getSetting('glacier_iconfolder'),
											href="#getSetting('glacier_url_root')#/editFolder?id=#local.map.folders[local.f].id#",
											tip="Edit this folder"
									).output#
								</div>
								<div class="clear"></div>
	
								<div class="folder_sub" style="display:none">
									<div style="padding-left:16px">
										<div class="folder_tool" style="padding-left:16px">
											#getFactory("iconUtil").icon(
													icon="folder_add",
													iconfolder=getSetting('glacier_iconfolder'),
													label="New folder",
													href="#getSetting('glacier_url_root')#/addFolder?parent_folder_id=#local.map.folders[local.f].id#",
													tip="Add a folder inside this folder"
											).output#
										</div>
										<div class="folder_tool">
											#getFactory("iconUtil").icon(
													icon="page_add",
													iconfolder=getSetting('glacier_iconfolder'),
													label="New page",
													href="#getSetting('glacier_url_root')#/addPage?folder_id=#local.map.folders[local.f].id#",
													tip="Add page to this folder"
											).output#
										</div>
										<div class="clear"></div>
	
										#displaySiteMap(local.map.folders[local.f]).output#
									</div>
									<div class="clear"></div>
								</div>
								<div class="clear"></div>
							</div>
							<div class="clear"></div>
						</cfif>
					</cfloop>
					<cfloop from="1" to="#ArrayLen(local.map.pages)#" index="local.p">
						<cfset local.pg = local.map.pages[local.p]>
						<cfif local.pg.id gt 0>
							<div class="page-line">
								<div class="toolbox" style="float:left">
									<div class="page-title">
										#getFactory("iconUtil").icon(icon="page", iconfolder=getSetting('glacier_iconfolder'), label="#local.pg.path# : #local.pg.title#").output#
									</div>
									<div class="tool">
										#getFactory("iconUtil").icon(icon="page_edit", iconfolder=getSetting('glacier_iconfolder'), href="#getSetting('glacier_url_root')#/editPage?id=#local.pg.id#", tip="Edit this page").output#
									</div>

									<div class="tool triggerDelete" href="#getSetting('glacier_url_root')#/deletePage?id=#local.pg.id#">
										#getFactory("iconUtil").icon(icon="page_delete", iconfolder=getSetting('glacier_iconfolder'), href="##", tip="Delete this page").output#
									</div>
									<div class="tool">
										#getFactory("iconUtil").icon(icon="page_search", iconfolder=getSetting('glacier_iconfolder'), href="#local.pg.full_url#", tip="View this page", target="_blank").output#
									</div>
									<div class="clear"></div>
								</div>
								<div class="clear"></div>
							</div>
							<div class="clear"></div>
						</cfif>
					</cfloop>
				</cfoutput>
			</cfsavecontent>

			<cfcatch type="any">
				<!---
					<cfset local.state.catch = cfcatch>
					<cfset monitor(note="Error", type="family.child" state=local.state)>
				--->
<cfdump var="#cfcatch#"><cfabort>

				<cfset local.result.output = "There has been an error">
			</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="addPage" returntype="struct" access="public">
		<cfargument name="page" type="struct" required="true">
		<cfargument name="folders" type="array" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfset arguments.page.template = getSetting("default_template")>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<div id="actionHeader">
					#getFactory("iconUtil").icon(icon="page_add", iconfolder=getSetting('glacier_iconfolder'), label="Add a page", style="font-weight:bold;font-size:14pt").output#
					<div class="clear"></div>
				</div>
				<hr>
				#editPageForm(arguments.page, arguments.folders).output#
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="editPage" returntype="struct" access="public">
		<cfargument name="page" type="struct" required="true">
		<cfargument name="folders" type="array" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				#getFactory("iconUtil").icon(icon="page_edit", iconfolder=getSetting('glacier_iconfolder'), label="Edit a page", style="font-weight:bold;font-size:14pt").output#
				#editPageForm(arguments.page, arguments.folders).output#
			</cfoutput>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>

	<cffunction name="editPageForm" returntype="struct" access="public">
		<cfargument name="page" type="struct" required="true">
		<cfargument name="folders" type="array" required="true">

		<cfset var local = {}>
		<cfset local.result =getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<form action="#getScope().script_name#" method="post" id="editPageForm" name="editPageForm">
					<input type="hidden" name="id" id="id" value="#arguments.page.id#">
					<div class="fieldlabel">Full page URL</div>
					<div class="fieldvalue">#arguments.page.full_url#</div>
					<div class="clear"></div>

					<div class="fieldlabel">Page URL</div>
					<div class="fieldinput"><input type="text" name="path" id="path" value="#arguments.page.path#"><br>
						e.g. index,contact,event,news<br>
						if the full URL is /example/testing, the page URL would be &quot;testing&quot;
					</div>
					<div class="clear"></div>

					<div class="fieldlabel">Folder</div>
					<div class="fieldinput">
						<select name="folder_id" id="folder_id">
							<option value="">Please select</option>
							<option value="0" <cfif arguments.page.folder_id eq 0>selected</cfif>>Root</option>
							<cfloop from="1" to="#ArrayLen(arguments.folders)#" index="local.f">
								<cfset local.fld = arguments.folders[local.f]>
								<option value="#local.fld.id#" <cfif local.fld.id eq arguments.page.folder_id>selected</cfif>>#local.fld.path# - #local.fld.title#</option>
							</cfloop>
						</select>
					</div>
					<div class="clear"></div>

					<h2>Main content</h2>
					<div class="fieldlabel">Title</div>
					<div class="fieldinput"><input type="text" name="title" id="title" value="#arguments.page.title#"></div>
					<div class="fieldlabel">Headline</div>
					<div class="fieldinput"><textarea name="headline" id="headline">#arguments.page.headline#</textarea></div>
					<div class="fieldlabel">Body</div>
					<div class="clear"></div>
					<div class="fieldinput">
						#wysiwyg(
								elementID="body",
								editorWidth="900",
								editorHeight="600",
								bodyClass="",
								cssFile="/res/#arguments.page.template#/css/main.css",
								toolbarAlignment="left",
								content="#arguments.page.body#"
						).output#
					</div>
					<div class="fieldlabel">Module</div>
					<div class="fieldinput">
						#codeCallSelect("code_call", arguments.page.code_call).output#
					</div>
					<div class="clear"></div>
	
					<h2>Related content</h2>
					<div class="fieldlabel">Title</div>
					<div class="fieldinput"><input type="text" name="side_title" id="side_title" value="#arguments.page.side_title#"></div>
					<div class="fieldlabel">Body</div>
					<div class="fieldinput">
						#wysiwyg(
								elementID="side_body",
								editorWidth="220",
								editorHeight="600",
								bodyClass="",
								cssFile="/css/glacier.css",
								toolbarAlignment="left",
								content="#arguments.page.side_body#"
						).output#
					</div>
					<div class="fieldlabel">Module</div>
					<div class="fieldinput">
						#codeCallSelect("side_code_call", arguments.page.side_code_call).output#
					</div>
					
					<div class="fieldlabel"></div>
					<div class="fieldinput"><input type="submit" name="submit" id="submit" value="submit" class="submit"></div>
					<div class="clear"></div>
				</form>

				#getFactory("jQueryUtil").genericJqueryValidation(formID="editPageForm", requiredFields="url,title").output#
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="addFolder" returntype="struct" access="public">
		<cfargument name="folder" type="struct" required="true">
		<cfargument name="folders" type="array" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.folder = arguments.folder>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				#getFactory("iconUtil").icon(icon="folder_add", iconfolder=getSetting('glacier_iconfolder'), label="Add a folder", style="font-weight:bold;font-size:14pt").output#
				#editFolderForm(local.folder, arguments.folders).output#
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="editFolder" returntype="struct" access="public">
		<cfargument name="folder" type="struct" required="true">
		<cfargument name="folders" type="array" required="true">

		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.folder = arguments.folder>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				#getFactory("iconUtil").icon(icon="folder_edit", iconfolder=getSetting('glacier_iconfolder'), label="Edit folder", style="font-weight:bold;font-size:14pt").output#
				#editFolderForm(local.folder, arguments.folders).output#
			</cfoutput>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>

	<cffunction name="editFolderForm" returntype="struct" access="public">
		<cfargument name="folder" type="struct" required="true">
		<cfargument name="folders" type="array" required="true">

		<cfset var local = {}>
		<cfset local.result=getResult()>

		<cfset local.templates = getFactory("glacier.model").getTemplates()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<form action="#getScope().script_name#" method="post" id="editfolderForm" name="editfolderForm">
					<input type="hidden" name="id" id="id" value="#arguments.folder.id#">
					<div class="fieldlabel">Folder name</div>
					<div class="fieldinput"><input type="text" name="title" id="title" value="#arguments.folder.title#"></div>
					<div class="clear"></div>

					<div class="fieldlabel">Folder path (part)</div>
					<div class="fieldinput"><input type="text" name="path" id="path" value="#arguments.folder.path#"></div>
					<div class="clear"></div>
					
					<div class="fieldlabel">Template</div>
					<div class="fieldinput">
						<select name="template" id="template">
							<option value="">Please select</option>
							<option value="" <cfif Len(arguments.folder.template) eq 0>selected</cfif>>No template</option>
							<cfloop list="#local.templates#" index="local.template">
								<option value="#local.template#" <cfif local.template eq arguments.folder.template>selected</cfif>>#local.template#</option>
							</cfloop>
						</select>
					</div>

					<div class="fieldlabel">Parent folder</div>
					<div class="fieldinput">
						<select name="parent_folder_id" id="parent_folder_id">
							<option value="">Please select</option>
							<option value="0" <cfif arguments.folder.parent_folder_id eq 0>selected</cfif>>No parent - this is a root folder</option>
							<cfloop from="1" to="#ArrayLen(arguments.folders)#" index="local.f">
								<cfset local.fld = arguments.folders[local.f]>
								<option value="#local.fld.id#" <cfif local.fld.id eq arguments.folder.parent_folder_id>selected</cfif>>#local.fld.path# - #local.fld.title#</option>
							</cfloop>
						</select>
					</div>
					
					<div class="fieldlabel"></div>
					<div class="fieldinput"><input type="submit" name="submit" id="submit" value="submit" class="submit"></div>
					<div class="clear"></div>
				</form>

				#getFactory("jQueryUtil").genericJqueryValidation(formID="editfolderForm", requiredFields="url,title").output#
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="codeCallSelect" returntype="struct" access="private">
		<cfargument name="fieldname" type="string" required="true">
		<cfargument name="currentValue" type="string" required="false" default="">

		<cfset var local = {}>
		<cfset local.result =getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<select name="#arguments.fieldname#" id="#arguments.fieldname#">
					<cfloop list="#getFactory('glacier.model').getCodeCallList()#" index="local.call">
						<cfset local.label = ListGetAt(local.call, 1, "|")>
						<cfif ListLen(local.call, "|") gt 1>
							<cfset local.value = ListGetAt(local.call, 2, "|")>
						<cfelse>
							<cfset local.value = "">
						</cfif>
						<option value="#local.value#" <cfif arguments.currentValue eq local.value>selected</cfif>>#local.label#</option>
					</cfloop>
				</select>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn local.result>
	</cffunction>

	<cffunction name="ckEditor" returntype="struct" access="private" hint="">
		<cfargument name="cssfile" 					required="false" refill="true" type="string" default="">
		<cfargument name="element" 					required="false" refill="true" type="string" default="content"> 
		<cfargument name="content" 					required="false" refill="false" type="string" default=""> 
		<cfargument name="csswidth" 				required="false" refill="true" type="string" default="520px"> 
		<cfargument name="cssheight" 				required="false" refill="true" type="string" default="350px">
		<cfargument name="path" 					required="false" refill="true" type="string" default="#getSetting('glacier_ckeditor_path')#">
		<cfargument name="language" 				required="false" refill="true" type="string" default="en">
		<cfargument name="gecko_spellcheck" 		required="false" refill="true" type="boolean" default="true">
		<cfargument name="body_class" 				required="false" refill="false" type="string" default="">
		<cfargument name="theme_advanced_toolbar_align" required="false" refill="true" type="string" default="left">
		<cfargument name="finder_path" 					required="false" refill="true" type="string" default="#getSetting('glacier_ckfinder_path')#">
		
		<cfset var local = {}>
		<cfset local.result = getResult()>
		<cfset local.body_id = arguments.element & "_cssid">

		<!--- put the base js in the html header ONCE --->
		<cfparam name="request.ckEditorCount" default="0">
		<cfif request.ckEditorCount eq 0>
			<cfsavecontent variable="local.wysHead">
				<cfoutput>
					<script type="text/javascript" src="#arguments.path#/ckeditor.js"></script>
					<script type="text/javascript" src="#arguments.finder_path#/ckfinder.js"></script>
					<script type="text/javascript" src="#arguments.path#/adapters/jquery.js"></script> 
					<script type="text/javascript">
						function hideAllToolbars() {
							for (instance in CKEDITOR.instances) {
								var editor = CKEDITOR.instances[instance];
								if (editor) {
									var toolbar = $("##cke_top_" + editor.name + " .cke_toolbox");
									if ($(toolbar).css('display') == "block") {
										$(toolbar).css('display', 'none');
										//editor.execCommand('toolbarCollapse');
									}
									CKFinder.setupCKEditor( editor, '#arguments.finder_path#' ) ;
								}
							}
						}

						$(document).ready(function() {
							CKEDITOR
								.addStylesSet( 'my_styles', [
									{ name : 'Heading 1', element : 'h1', styles: { '' : '' } },
									{ name : 'Heading 2', element : 'h2', styles: { '' : '' } },
									{ name : 'Heading 3', element : 'h3', styles: { '' : '' } },
									{ name : 'Heading 4', element : 'h4', styles: { '' : '' } },
									{ name : 'Heading 5', element : 'h5', styles: { '' : '' } },
									{ name : 'Heading 6', element : 'h6', styles: { '' : '' } }
								])
							;
						});
					</script>
				</cfoutput>
			</cfsavecontent>
			<cfhtmlhead text="#local.wysHead#">
			<cfset request.ckEditorCount++>
		</cfif>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<textarea class="jquery_ckeditor" id="#arguments.element#" name="#arguments.element#">#arguments.content#</textarea>

				<script type="text/javascript">
					$(document).ready(function() {
						var #arguments.element#_config = {
							toolbar: [
								{ name: 'utility', items : ['Print', 'Scayt']},
								{ name: 'clipboard',   items : [ 'Cut','Copy','Paste','PasteText','PasteFromWord','-','Undo','Redo' ] },
								{ name: 'links',	   items : [ 'Link','Unlink','Anchor' ] },
								{ name: 'insert',	  items : [ 'Image','Flash','Table','HorizontalRule','SpecialChar'] },
								'/',
								{ name: 'styles',	  items : [ 'Styles'] },
								{ name: 'basicstyles', items : [ 'Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
								{ name: 'justify', items : ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock']},
								{ name: 'paragraph',   items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote']},
								'/',
								{ name: 'editing',	 items : [ 'Find','Replace','-','SelectAll','-',] },
								{ name: 'document',	items : [ 'Source','-','Print','Maximize', 'ShowBlocks','-','About' ] }
							],
							bodyClass: '#arguments.body_class# ckEditorInstance',
							bodyId: '#local.body_id#',
							contentsCss: ['#arguments.cssfile#'],
							enterMode: CKEDITOR.ENTER_DIV,
							shiftEnterMode: CKEDITOR.ENTER_BR,
							height: '#arguments.cssheight#',
							width: '#arguments.csswidth#',
							toolbarCanCollapse: true,
							toolbarStartupExpanded: false,
							skin: 'office2003',
							removePlugins : 'elementspath',
							resize_enabled: false,
							stylesCombo_stylesSet: 'my_styles'
						};

						$('###arguments.element#').ckeditor(#arguments.element#_config, function() {
							<!--- no call back --->
						});


						var editor = $('###arguments.element#').ckeditorGet();
						editor.on('focus', function(event) {
							hideAllToolbars();
							var toolbox = $("##cke_top_" + event.editor.name + " .cke_toolbox");
							if ($(toolbox).css('display') == 'none') {
								$(toolbox).show();
								//event.editor.execCommand('toolbarCollapse');
							}
						});
					});
				</script>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="wysiwyg" returntype="struct" access="public" hint="Wrapper for wysiwyg editor - allows change of editor down the line">
		<!--- Used generic argument names so it is easier for developers to understand. Re-mapping done in master if statement below --->
		<cfargument name="elementID"				required="true" type="string">
		<cfargument name="cssfile" 					required="false" type="string" default="">
		<cfargument name="editorTheme" 				required="false" type="string" default="">
		<cfargument name="plugins" 					required="false" type="string" default=""> 
		<cfargument name="buttonList1" 				required="false" type="string" default=""> 
		<cfargument name="buttonList2" 				required="false" type="string" default=""> 
		<cfargument name="buttonList3" 				required="false" type="string" default=""> 
		<cfargument name="validTags"			 	required="false" type="string" default=""> 
		<cfargument name="content" 					required="false" type="string" default=""> 
		<cfargument name="editorWidth" 				required="false" type="string" default="300px"> 
		<cfargument name="editorHeight"				required="false" type="string" default="300px">
		<cfargument name="allowResizing"			required="false" type="boolean" default="false">
		<cfargument name="language"					required="false" type="string" default="">
		<cfargument name="spellCheck" 				required="false" type="boolean" default="true">
		<cfargument name="bodyClass"				required="false" type="string" default="">
		<cfargument name="toolbarAlignment"			required="false" type="string" default="left">

		<cfset var local = {}>
		<cfset local.editorType = "ckEditor">

		<!--- master if statement dependent on type of editor configured --->
		<cfif local.editorType eq "tinymce">
<!--- theme_advanced_styles=".headerBasket", --->
			<cfset local.result = tinymce(
					cssfile=arguments.cssfile,
					theme=arguments.editorTheme,
					element=arguments.elementID,
					plugins=arguments.plugins,
					theme_advanced_buttons1=arguments.buttonList1,
					theme_advanced_buttons2=arguments.buttonList2,
					theme_advanced_buttons3=arguments.buttonList3,
					extended_valid_elements=arguments.validTags,
					content=arguments.content,
					cssWidth=arguments.editorWidth,
					cssHeight=arguments.editorHeight,
					resizing=arguments.allowResizing,
					language=arguments.language,
					gecko_spellcheck=arguments.spellCheck,
					body_class=arguments.bodyClass
			)>
		<cfelseif local.editorType eq "ckEditor">
			<cfset local.result = ckEditor(
					cssfile=arguments.cssfile,
					theme=arguments.editorTheme,
					element=arguments.elementID,
					plugins=arguments.plugins,
					theme_advanced_buttons1=arguments.buttonList1,
					theme_advanced_buttons2=arguments.buttonList2,
					theme_advanced_buttons3=arguments.buttonList3,
					extended_valid_elements=arguments.validTags,
					content=arguments.content,
					cssWidth=arguments.editorWidth,
					cssHeight=arguments.editorHeight,
					resizing=arguments.allowResizing,
					language=arguments.language,
					gecko_spellcheck=arguments.spellCheck,
					body_class=arguments.bodyClass
			)>
		<cfelse>
			<cfthrow message="#local.editorType# Not implemented in cms.view as a wysiwyg editor type">
		</cfif>		

		<cfreturn local.result>
	</cffunction>

	<cffunction name="glacierIconRoot" returntype="struct" access="public">
		<cfreturn getFactory("iconUtil").icon(icon="glacier_logo", iconfolder=getSetting('glacier_iconfolder'), href=getSetting('glacier_url_root'))>
	</cffunction>

	<cffunction name="glacierIconEditPage" returntype="struct" access="public">
		<cfargument name="id" type="numeric" required="true">

		<cfset var local = {}>
		<cfset local.edit_url = getSetting("glacier_url_root") & "/editPage?id=#arguments.id#">
		<cfreturn getFactory("iconUtil").icon(icon="target", iconfolder=getSetting('glacier_iconfolder'), href=local.edit_url)>
	</cffunction>

</cfcomponent>