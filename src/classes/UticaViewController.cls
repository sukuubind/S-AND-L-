public with sharing class UticaViewController 
{
	public list<Document> docList {get; set;}
	public Integer selectedTab {get; set;}
	
	
	public UticaViewController()
	{
		selectedTab = 1;
		loadDocuments();
		
	}
	
	private void loadDocuments()
	{
		docList = [Select Id, Name, Description, CreatedDate, LastModifiedDate, Type From Document Where Folder.Name = 'Utica Documents'];
	}
	

	public void updateTab() {}
}