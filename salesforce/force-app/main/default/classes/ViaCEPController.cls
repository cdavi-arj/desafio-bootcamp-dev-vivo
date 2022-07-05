public without sharing class ViaCEPController {

    @AuraEnabled(cacheable=true)
    public static ViaCep chamarServico(String cep) {
        return consultarCEP(cep);
    }

    @AuraEnabled
    public static String updateAccountAddress(String recordId, String cep, String logradouro, String bairro, String localidade, String uf) {
        String result;
        try {
            Account acct = new Account();
            acct.Id = recordId;
            acct.ShippingPostalCode = cep;
            acct.ShippingStreet = logradouro;
            acct.ShippingCity = localidade;
            acct.ShippingState = uf;
            update acct;

            // Start - Enviar para outra org
            // Account acct = [SELECT CodigoIdentificador__c FROM Account WHERE Id =: recordId];

            // List<AccountAPI.AccountWrapper> lstAcctWrapper = new List<AccountAPI.AccountWrapper>{
            //     new AccountAPI.AccountWrapper(acct.CodigoIdentificador__c, cep, logradouro)
            // };

            // String jsonText = JSON.serialize(lstAcctWrapper);

            // HttpRequest request = new HttpRequest();
            // request.setEndpoint('callout:SalesforceAccountsAPI/services/apexrest/accounts/');
            // request.setMethod('POST');
            // request.setHeader('Content-Type', 'application/json');
            // request.setBody(jsonText);
            // Http http = new Http();
            // HttpResponse res = http.send(request);
            
            // if(res.getStatusCode() == 200) {
            //     result = 'success';
            // } else {
            //     result = 'error';
            // }
            // End
        } catch (Exception ex) {
            result = 'error';
        }

        return result;
    }

    public static ViaCep consultarCEP(String cep) {
        Viacep result = new Viacep();
        HttpRequest request = new HttpRequest();
        // Não esquecer de cadastrar o viacep como site remoto
        request.setEndpoint('https://viacep.com.br/ws/' + cep + '/json/');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);

        try {
            Http http = new Http();
            HttpResponse res = http.send(request);
            
            if(res.getStatusCode() == 200) {
                result = parse(res.getBody());
            } else {
                result.erro = true;
            }
        } catch(Exception ex) {
            result.erro = true;
        }

        return result;
    }

    public static ViaCep parse(String json) {
        return (ViaCep) System.JSON.deserialize(json, ViaCep.class);
    }
    
    public class ViaCep {
        @AuraEnabled
        public String cep;
        @AuraEnabled
        public String logradouro;
        @AuraEnabled
        public String complemento;
        @AuraEnabled
        public String bairro;
        @AuraEnabled
        public String localidade;
        @AuraEnabled
        public String uf;
        @AuraEnabled
        public String unidade;
        @AuraEnabled
        public String ibge;
        @AuraEnabled
        public String gia;
        @AuraEnabled
        public Boolean erro;
    }
}