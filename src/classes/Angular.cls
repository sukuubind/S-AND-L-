global class Angular {
     static String accountId =  ApexPages.currentPage().getParameters().get('Id');

    global static String getAccount() {
        return JSON.serialize([select name, billingstreet,
            billingcity, billingstate, billingpostalcode
            from account where id = :accountId][0]);
    }

    global static String getContacts() {
        return JSON.serialize([select id, name, email
            from contact where accountId = :accountId]);
    }

    global static String getContactList() {
        return JSON.serialize([select id, name, email,department
            from contact ]);
    }

     global static String getOpportunityList() {
        return JSON.serialize([select id, name, Amount
            from Opportunity ]);
    }
}