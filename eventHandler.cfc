<cfcomponent extends="mura.cfobject" output="true">
	<cffunction name="onGlobalRequestStart" access="public" output="false" returntype="any">
		<cfargument name="$" hint="mura scope" />
		
		<cfif not application.configBean.getCurrentUser().isSuperUser() 
			and listFindNoCase("cSettings.editPlugin,cSettings.deployPlugin,cSettings.updatePlugin,cSettings.updatePluginVersion", $.event('muraAction'))>
			<cfset var s = structNew()>
			<cfset s.error = "This install does not support plugins.">
			<cfset application.userManager.getCurrentUser().setValue("errors", s)>
			<cflocation url="?muraAction=cSettings.list" addtoken="false">
		</cfif>

	</cffunction>

	<cffunction name="onAdminHTMLHeadRender" access="public" output="false" returntype="any">
		<cfargument name="$" hint="mura scope" />
		<cfset var returnVar = "">

		<cfif not application.configBean.getCurrentUser().isSuperUser()>
			<cfsavecontent variable="returnVar">
				<script>
					$(document).ready(function(){
						$('##tabModules .block-content:first').html('<div class="alert alert-error">This install does not support configuration of modules.</div>')
					});
				</script>
			</cfsavecontent>
		</cfif>

		<cfreturn returnVar>
	</cffunction>	
</cfcomponent>