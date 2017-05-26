public with sharing class Post_Chat_Form_Controller {

public Live_Chat_Feedback__c lcf {get; set;}
public Boolean renderFeedback {get; set;}
public String messages {get; set;}
public String errorMessages {get; set;}
public Boolean renderMessages {get; set;}
public Boolean renderErrorMessages {get; set;}
public String partner_abbrev {get; set;}

public Post_Chat_Form_Controller() {
    
    this.lcf = new Live_Chat_Feedback__c();
    this.lcf.Transcript_ChatKey__c = ApexPages.currentPage().getParameters().get('chatKey');
    this.renderFeedback = true;
    this.renderMessages = false;
    this.renderErrorMessages = false;
    this.partner_abbrev = ApexPages.currentPage().getParameters().get('partner_abbrev');
    
}

public void saveFeedback() {
    Boolean moveahead = false;
    if(this.partner_abbrev != null && this.partner_abbrev == 'DEL'){
        if(this.lcf.Overall_Chat_Experience__c != null && this.lcf.Experience_with_Chat_Agent__c != null){
            moveahead = true;
        }
    }else{
        if(this.lcf.Overall_Chat_Experience__c != null && this.lcf.Experience_with_Chat_Agent__c != null && this.lcf.Alternate_Contact_Method__c != null){
            moveahead = true;
        }
    }
    
    
    if(moveahead)
    {
        
        try{
        
            insert this.lcf;
            this.renderFeedback = false;
            this.messages = System.Label.LiveChat_Feedback_ThankYou;
            this.renderMessages = true;
            this.renderErrorMessages = false;
            
        }catch (Exception e) {
            System.debug(e+'');
            this.errorMessages = System.Label.LiveChat_Feedback_Error;
            this.renderErrorMessages = true;
        }
    
    }
    else
    {
        this.errorMessages = System.Label.LiveChat_Feedback_AnswerAllQuestions;
        this.renderErrorMessages = true;
    }
    
} 

}