public with sharing class Log_An_Activity_Controller {

public String htmlContent {get;set;}
public String pageTitle {get;set;}
public List<String> paramList {get; set;}

public Log_An_Activity_Controller()
{
	
	this.pageTitle = Apexpages.currentPage().getParameters().get('pageTitle');
	
	if(this.pageTitle == null || this.pageTitle == '')
	{
		this.pageTitle = 'Log an Activity';
	}
	
	this.paramList = new List<String>();
	Map<String,String> params = Apexpages.currentPage().getParameters();
	System.debug('params >---> '+params);
	for(String s : params.keySet())
	{
		this.paramList.add(s+'='+params.get(s));
		System.debug('param >---> '+s+'='+params.get(s));
		if(s == 'save_new_url')
		{
			String s2 = EncodingUtil.urlDecode(params.get(s), 'UTF-8');
			List<String> s2List = s2.split('&');
			
			for(String s3 : s2List)
			{
				if(s3.contains('pageTitle='))
				{
					this.paramList.add(s3);
					this.pageTitle = s3.replace('pageTitle=','');
				}
			}
			
		}
		
		
	}
	
	String query = String.join(this.paramList,'&');
	
	PageReference p = new PageReference('/00T/e?' + query);
	
	if(!System.Test.isRunningTest())
	{
		this.htmlContent = p.getContent().toString();
	}
	else
	{
		this.htmlContent = '';
	}
	
	this.htmlContent = this.htmlContent.replace('>Log a Call</h1>','>' + this.pageTitle + '</h1>');
	
	this.htmlContent = this.htmlContent.replace('00T/e','apex/Log_An_Activity');
	
	this.htmlContent = this.htmlContent.replace('apex/Log_An_Activity?','apex/Log_An_Activity?pageTitle=' + this.pageTitle + '&');
	
	String tabTitleJS = 'if(sforce.console.isInConsole()){sforce.console.setTabTitle(\'' + this.pageTitle + '\');}';
    
    String 	tabRefreshJS = 'var refreshPrimaryTabByIdResult = function refreshPrimaryTabByIdResult(result) {';
            tabRefreshJS += 'if(redirectToTask){redirectToLogAChatTask();}'; 
            tabRefreshJS += '};';
        	tabRefreshJS += 'var enclosingPrimaryTabIdResult = function enclosingPrimaryTabIdResult(result) {';
            tabRefreshJS += 'var primaryTabId = result.id;';
            tabRefreshJS += 'sforce.console.refreshPrimaryTabById(primaryTabId, true, refreshPrimaryTabByIdResult);';
        	tabRefreshJS += '};';
        	tabRefreshJS += 'if(sforce.console.isInConsole()){sforce.console.getEnclosingPrimaryTabId(enclosingPrimaryTabIdResult);}';
		
	System.debug('htmlContent >---> '+ this.htmlContent);
	
	if(this.htmlContent.contains('/00T') && !this.htmlContent.contains('</body>'))
	{
		refreshTabInConsole(tabRefreshJS);
	}
	else
	{
		this.htmlContent = this.htmlContent.replace('</body>','<script>' + tabTitleJS + '</script></body>');
	}
	
	System.debug('htmlContent >---> '+ this.htmlContent);
	
	//disabling clickjacking javascript
	//this.htmlContent = this.htmlContent.replace('w=self','w=top');
	
}

public void refreshTabInConsole(String tabRefreshJS) {
	
		Integer indexOf00T = this.htmlContent.indexOf('00T');
		String newTaskId = '';
		if(indexOf00T > -1)
		{
			this.htmlContent.substring(indexOf00T, indexOf00T+15);
		}
		
		this.htmlContent = this.htmlContent.replaceFirst('<script>','<scriptkeep>');
		this.htmlContent = this.htmlContent.replace('<script>','');
		this.htmlContent = this.htmlContent.replace('</script>','');
		this.htmlContent = this.htmlContent.replace('</head>','}</script></head>');
		this.htmlContent = this.htmlContent.replace('<scriptkeep>','<script>function redirectToLogAChatTask(){');
		this.htmlContent = this.htmlContent.replace('</head>','</head><body><script>var redirectToTask = true;' + tabRefreshJS + '</script>');
	
}


}