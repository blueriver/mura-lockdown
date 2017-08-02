# Mura CMS Lockdown Recommendations
Revised June 9, 2017
This checklist is meant to provide general recommendations for security settings and best practices when "locking down" Mura CMS.
Server environments will vary, as will security policies, and additional security steps may be required. 

## Coding Guidelines

### SQL Queries

1. Always param all queries variables.

```
<cfquery name="rs">
  select * from example where id=<cfqueryparam value="123" cfsqltype="cf_sql_varchar">
</cfquery>
```

```
rs=QueryExecute("select * from example where id = :id",{id={value="123",cfsqltype="cf_sql_varchar"}});
```

```
qs=new getQueryService();
qs.addParam(name="id", cfsqltype="cf_sql_varchar", value="123");
rs=qs.execute(sql="select * from example where id = :id").getResult();
```

## Variable Referencing

1. Always use used scoped variables (ie. url.myvar NOT myvar).

2. The only allowed exceptions are for locally scoped variables within functions and the variables scope.

## Escape all dynamically rendered variables

1. Never directly output a dynamic variables. 

### DO

```
<cfoutput>

#esapiEncode('html'.url.myvar)#

<div id="#esapiEncode('html_attr'.session.myvar)#">

<a href="?myvar=#esapiEncode('url',session.myvar)#">My Link</link>

<script>
    myvar="#esapiEncode('javascript',session.myvar)#"
</script>

</cfoutput>
```

### NOT!

```
<cfoutput>

#url.myvar#

<div id="#session.myvar#">

<a href="?myvar=#session.myvar#">My Link</link>

<script>
    myvar="#session.myvar#"
</script>

</cfoutput>
```

1. There can be exceptions, but they must only output variables that have a strong chain of custody.

2. This is restricted to variables that cannot be passed into the request dynamically. 

3. Since FORM, URL, CGI and COOKIE and Mura EVENT variables are able to be sent dynamically with each request you must never allow any exceptions from those scopes.

The most common example if outputting the body of a content node.

```
<cfoutput>
  #$.content('body')#
</cfoutput>
```

## Custom Endpoints

1. When adding custom url endpoints like proxy cfc place them under siteid either named remote.cfc under a directory named remote.  

2. This will prevent hackers from exploring urls looking files that were never intended to be directory accessed like includes.

3. It preferred way to add custom endpoint is to add model/bean/apihelper.cfc to your theme, content_type or display object/module directory and add a remote function:

{module_dir}/model/beans/apihelper.cfc

```
component extends="mura.bean.bean" {

  remote function heyThere(){
    return "Hello!";
  }

}
```

Accessed with:

http://domain.com/index.cfm/_api/json/v1/{siteid}/apihelper/heythere

## Environmental Guidlines

### Server-Side Adjustments

1. Configure Apache v-host
a. Configure ssl
b. Remove icons, cgi-bin, errors (any server defaults)
c. Enable .htaccess

2. Configure Lucee
a. Set strong password
b. Configure xmx
c. Restrict outside access via apache or other method

3. Configure /install MySQL
a. Add db specific user (don't use root)

4. Configure firewall
a. Web server only open on port 22, 80, 443
b. Database server to only accept connections from web server on port 3306       (ip address restriction)
	
5. Force ssl
a. Configure ssl-only in Apache /.htaccess


### Code Alterations

1. Add click jacking header in cfapplication.cfm
a. In application .cfm:	
<cfheader name="X-Frame-Options" value="SAMEORIGIN">
b. In .htaccess:
<ifModule mod_headers.c>
		Header always append X-Frame-Options SAMEORIGIN
</ifModule>
	
2. Disable insecure cookies
a. In cfapplication.cfm:
<cfset this.setClientCookies = false>
	
3. Disable access to /default/ folder:
a. Add file: /default/.htaccess, w/ rule to deny from all
	
4. Review and adjust security-related settings in settings.ini.cfm:
securecookies=true
rotatesessions=true
debuggingenabled=false
adminssl=true
errorTemplate=/message/error.cfm
stricthtml=true
allowSimpleHTMLForms=false
scriptProtectExceptions=
fmallowedextensions=7z,aiff,asf,avi,bmp,csv,doc,docx,fla,flv,gif,gz,gzip,jpeg,jpg,mid,mov,mp3,mp4,mpc,mpeg,mpg,ods,odt,pdf,png,ppt,pptx,ppsx,pxd,qt,ram,rar,rm,rmi,rmvb,rtf,sdc,sitd,sxc,sxw,tar,tgz,tif,tiff,txt,vsd,wav,wma,wmv,xls,xlsx,xml,zip,m4v,less
fmshowsitefiles=0
fmshowapplicationroot=0
autodiscoverplugins=false
fmallowedextensions=gif,jpeg,jpg,pdf,png
allowedmimetypes=image/gif,image/jpeg,application/pdf,image/png

5. Add setDynamicContent function override 
a. See function in example contentRenderer.cfc
b. Add function to site contentRenderer.cfc
   (This method restricts the [mura] tag to running functions defined in contentRenderer only)

6. Add plugin and module security to Mura admin sessions
a. See methods onGlobalRequestStart and onAdminHTMLRender in example eventHandler.cfc
b. Add methods to site eventHandler.cfc

7. Configure custom error handling, to avoid information disclosure
a. Example .htaccess rules (change ‘custom/error’ to your error file path)
	ErrorDocument 404 /404/
	ErrorDocument 500 /custom/error.cfm
	ErrorDocument 403 /custom/error.cfm


### Server-Side Adjustments

1. Set Mura admin to SSL only (force ssl)


### Recommendations for Testing

1. Use nmap to run a port scan against the web / database server:
	Web should only show ports 22, 80, 443 open
	DB should only show port 22

2. Use curl -I to test against the webserver:
	All cookies should show secure flag, no cookies should be passed insecure
	All insecure connections should be immediately redirected to secure (ssl)
	Look for X-Frame-Options header

3. Test and verify: 
	Mura admin is fully running on ssl
	Site errors only show the generic error message page
	Additional plugins can not be installed
	Malicious files can not be uploaded (test the allowedmimetypes setting)



