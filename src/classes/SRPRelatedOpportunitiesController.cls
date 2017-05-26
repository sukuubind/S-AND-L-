public with sharing class SRPRelatedOpportunitiesController {

private final String recordTypeName {get;set;}
public List<Opportunity> relatedOpps {get; set;}
public Boolean renderRelOpps {get; set;}
public String testText {get; set;}

public SRPRelatedOpportunitiesController(ApexPages.StandardController stdController) {
        
        this.renderRelOpps = false;
        
        try {
        	
        	Id currOppId = stdController.getRecord().id;
        	
        	Opportunity currOpp = [SELECT RecordType.Name, DeltakSRP__Student__c, Student__c FROM Opportunity WHERE Id = :currOppId LIMIT 1];
        	
        	this.recordTypeName = currOpp.RecordType.Name;
        	
        	List<String> relOppFields = new List<String>();
        
        	for(Schema.FieldSetMember f : this.getRelatedOpportunityFields()) {
    		
    			relOppFields.add(f.getFieldPath());
    		
    		}
        
        	String relOppQuery = '';
        	Id studentId; 
        	
        	if(this.recordTypeName == 'SRP Opportunity' && currOpp.DeltakSRP__Student__c != null && currOpp.DeltakSRP__Student__c + '' != '')
        	{
        		studentId = currOpp.DeltakSRP__Student__c;
        		relOppQuery = 'SELECT ' + String.join(relOppFields,', ') + ' , Name, Id FROM Opportunity WHERE DeltakSRP__Student__c = :studentId AND Id != :currOppId';
        	}
        	else if(this.recordTypeName == 'Student Opportunity' && currOpp.Student__c != null && currOpp.Student__c + '' != '')
        	{
        		studentId = currOpp.Student__c;
        		relOppQuery = 'SELECT ' + String.join(relOppFields,', ') + ' , Name, Id FROM Opportunity WHERE Student__c = :studentId AND Id != :currOppId';
        	}
        	
        	if(relOppQuery != '')
        	{
        	
        		this.relatedOpps = Database.query(relOppQuery);
        	
        		if(this.relatedOpps != null && this.relatedOpps.size() > 0)
        		{
        			this.renderRelOpps = true;
        		}
        	}
        	else
        	{
        		this.renderRelOpps = false;
        	}
        
        } catch (Exception e) {
        	this.renderRelOpps = false;
        	this.testText = '' +e;
        }
        
        
        
}

public List<Schema.FieldSetMember> getRelatedOpportunityFields() {
	if(this.recordTypeName == 'Student Opportunity')
	{
        return SObjectType.Opportunity.FieldSets.Related_Opportunities.getFields();
	}
	else
	{
		return SObjectType.Opportunity.FieldSets.SRPRelated_Opportunities.getFields();
	}

}


}