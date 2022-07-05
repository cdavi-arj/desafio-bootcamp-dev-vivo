@RestResource(urlMapping='/address/*')
global class UpdateAddressAPI {

    @HttpPost
    global static void updateAddress() {
        Map<String, Object> response = new Map<String, Object>();
        AccountWrapper acctWrapper = new AccountWrapper();
        String payload = RestContext.request.requestBody.toString();
        
        try {
            acctWrapper = (AccountWrapper) JSON.deserialize(payload, AccountWrapper.class);
        } catch (Exception ex) {
            RestContext.response.statusCode = 400;
            return;
        }

        try {
            if(acctWrapper == null) {
                throw new IllegalArgumentException('Objeto null');
            }

            String code = acctWrapper.codigoIdentificador;
            Boolean upsertAccount = false;
            String msgErro = null;
            if(code != null) {
                if(code.length() == 11) {
                    if(Validate.isCPF(code)) {
                        upsertAccount = true;
                    } else {
                        msgErro = 'CPF informado inválido';
                    }
                } else if(code.length() == 14) {
                    if(Validate.isCNPJ(code)) {
                        upsertAccount = true;
                    } else {
                        msgErro = 'CNPJ informado inválido';
                    }
                } else {
                    msgErro = 'Código identificador com dígitos inválidos';
                }
            } else {
                msgErro = 'Código identificador não preenchido';
            }

            if(msgErro != null) {
                throw new IllegalArgumentException(msgErro);
            }

            if(upsertAccount) {
                Account acct = acctWrapper.mountAccount();
                upsert acct CodigoIdentificador__c;
                response.put('data', acct);
                response.put('status', true);
            }
        } catch (Exception ex) {
            response.put('msgErro', ex.getMessage());
            response.put('status', false);
        }

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    public class AccountWrapper {
        public String codigoIdentificador;
        public String rua;
        public String cidade;
        public String bairro;
        public String numero;
        public String cep;
        public String pais;
        public String codigoIbge;
        public String siafi;

        public Account mountAccount() {
            Account acct = new Account();
            acct.CodigoIdentificador__c = this.codigoIdentificador;
            acct.ShippingPostalCode = this.cep;
            acct.ShippingStreet = this.rua;
            acct.ShippingCountry = this.pais;

            return acct;
        }
    }
}