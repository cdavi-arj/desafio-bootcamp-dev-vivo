trigger AccountTrigger on Account (after insert) {
	List<Account> lstAccounts = Trigger.new;
    List<Contact> lstContactToInsert = new List<Contact>();

    for(Account acct : lstAccounts) {
        if(Validate.isCPF(acct.CodigoIdentificador__c)) {
            Contact ctt = new Contact(
                AccountId = acct.Id,
                LastName = acct.Name, 
                Birthdate = acct.DataAniversario__c,
                Phone = acct.Phone,
                MailingPostalCode = acct.ShippingPostalCode,
                MailingStreet = acct.ShippingStreet,
                MailingCountry = acct.ShippingCountry
            );

            lstContactToInsert.add(ctt);
        }
    }

    if(!lstContactToInsert.isEmpty()) insert lstContactToInsert;
}