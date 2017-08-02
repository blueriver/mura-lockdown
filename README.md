# mura-lockdown

This checklist is meant to provide general recommendations for security settings and best practices when "locking down" Mura CMS.
Server environments will vary, as will security policies, and additional security steps may be required. 


## Security Coding Guidelines

### SQL QUERIES

Always param all queries variables.

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

## VARIABLE REFERENCES

Always use used scoped variables (ie. url.myvar NOT myvar).

The only allowed exceptions are for locally scoped variables within functions and the variables scope.

## ESCAPE ALL RENDERED VARIABLES WITH ESAPIENCODE()

Never directly output a dynamic variables. 

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

There can be exceptions, but they must only output variables that have a strong chain of custody.

This is restricted to variables that cannot be passed into the request dynamically. 
 
Since FORM, URL, CGI and COOKIE and Mura EVENT variables are able to be sent dynamically with each request you must never allow any exceptions from those scopes.

The most common example if outputting the body of a content node.

```
<cfoutput>
  #$.content('body')#
</cfoutput>
```

## CUSTOM ENDPOINTS

When adding custom url endpoints like proxy cfc place them under siteid either named remote.cfc under a directory named remote.  
This will prevent hackers from exploring urls looking files that were never intended to be directory accessed like includes.

It preferred way to add custom endpoint is to add model/bean/apihelper.cfc to your theme, content_type or display object/module directory and add a remote function:

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


