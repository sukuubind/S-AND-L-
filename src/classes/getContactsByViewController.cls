public with sharing class getContactsByViewController {

    public string fld {get; set;}

    public getContactsByViewController(ApexPages.StandardSetController controller) {
        //controller.setPageNumber(2);
        /*fld = String.valueOf(controller.getResultSize());*/
        fld = '';
        controller.setPageSize(2000);
        List<Contact> allRecords = new List<Contact>();
        allRecords.addAll((List<contact>)controller.getRecords());
        
        while (controller.getHasNext()){            
            controller.next();    
            allRecords.addAll((List<Contact>)controller.getRecords());
        } 
        
        for(Contact c : allRecords){
            fld += c.Id + ',';
        }
    }

}