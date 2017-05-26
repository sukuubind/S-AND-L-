public with sharing class getOpportunitiesByViewController {

    public string fld {get; set;}

    public getOpportunitiesByViewController(ApexPages.StandardSetController controller) {
        //controller.setPageNumber(2);
        /*fld = String.valueOf(controller.getResultSize());*/
        fld = '';
        controller.setPageSize(2000);
        List<Opportunity> allRecords = new List<Opportunity>();
        allRecords.addAll((List<Opportunity>)controller.getRecords());
        
        while (controller.getHasNext()){            
            controller.next();    
            allRecords.addAll((List<Opportunity>)controller.getRecords());
        } 
        
        for(Opportunity op : allRecords){
            fld += op.Id + ',';
        }
    }

}