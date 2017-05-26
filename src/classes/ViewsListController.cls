public with sharing class ViewsListController {
    public String fld { get; set; }
    public void getViewsList(){
        fld ='';
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new List<Contact>());
        for(SelectOption op : ssc.getlistViewOptions()){
            fld += 'af:' + op.getValue() + ';Affiliation: ' + op.getLabel() + ',';
            
        }            
        
        ApexPages.StandardSetController sso = new ApexPages.StandardSetController(new List<Opportunity>());
        for(SelectOption op : sso.getlistViewOptions()){
            fld += 'op:' + op.getValue() + ';Opportunity: ' + op.getLabel() + ',';           
        }
        
    }
}