@RestResource(urlMapping='/accounts/*')
global class AccountAPI {
    
    @HttpPost
    global static void createAccount() {
        Map<String, Object> response = new Map<String, Object>();
        List<AccountWrapper> lstAcctWrapper = new List<AccountWrapper>();
        String payload = RestContext.request.requestBody.toString();

        try {
            lstAcctWrapper = (List<AccountWrapper>) JSON.deserialize(payload, List<AccountWrapper>.class);
        } catch (Exception ex) {
            RestContext.response.statusCode = 400;
            return;
        }

        try {
            if(lstAcctWrapper.isEmpty()) {
                throw new IllegalArgumentException('Lista está vázia');
            }

            List<Account> lstAccountToInsert = new List<Account>();
            List<AccountInvalidWrapper> lstAccountInvalidWrapper = new List<AccountInvalidWrapper>();

            for(AccountWrapper acctWrapper : lstAcctWrapper) {
                String code = acctWrapper.codigoIdentificador;
                AccountInvalidWrapper acctInvalid;
                if(code != null) {
                    if(code.length() == 11) {
                        if(Validate.isCPF(code)) {
                            lstAccountToInsert.add(acctWrapper.mountAccount());
                        } else {
                            acctInvalid = new AccountInvalidWrapper(code, 'CPF informado inválido');
                        }
                    } else if(code.length() == 14) {
                        if(Validate.isCNPJ(code)) {
                            lstAccountToInsert.add(acctWrapper.mountAccount());
                        } else {
                            acctInvalid = new AccountInvalidWrapper(code, 'CNPJ informado inválido');
                        }
                    } else {
                        acctInvalid = new AccountInvalidWrapper(code, 'Código identificador com dígitos inválidos');
                    }
                } else {
                    acctInvalid = new AccountInvalidWrapper('', 'Código identificador está vázio');
                }

                if(acctInvalid != null) {
                    lstAccountInvalidWrapper.add(acctInvalid);
                }
            }

            if(!lstAccountToInsert.isEmpty()) {
                Schema.SObjectField externalId = Account.Fields.CodigoIdentificador__c;
                List<DataBase.UpsertResult> saves = Database.upsert(lstAccountToInsert, externalId, false);
                response.put('data', saves);
            }

            if(!lstAccountInvalidWrapper.isEmpty()) {
                RestContext.response.statusCode = 207;
                response.put('erros', lstAccountInvalidWrapper);
            }

        } catch (Exception ex) {
            response.put('message', ex.getMessage());
        }

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    public class AccountWrapper {
        public String codigoIdentificador;
        public String razaoSocial;
        public String nome;
        public Date dataAniversario;
        public String telefone;
        public String rua;
        public String numero;
        public String cep;
        public String pais;
        public String setor;
        public Integer funcionarios;
        public Decimal rendaAnual;

        public AccountWrapper() {

        }

        public AccountWrapper(String codigoIdentificador, String cep, String rua) {
            this.codigoIdentificador = codigoIdentificador;
            this.cep = cep;
            this.rua = rua;
        }

        public Account mountAccount() {
            Account acct = new Account();
            acct.Name = this.nome;
            acct.CodigoIdentificador__c = this.codigoIdentificador;
            acct.DataAniversario__c = this.dataAniversario;
            acct.Phone = this.telefone;
            acct.ShippingPostalCode = this.cep;
            acct.ShippingStreet = this.rua;
            acct.ShippingCountry = this.pais;
            acct.NumberOfEmployees = this.funcionarios;
            acct.AnnualRevenue = this.rendaAnual;

            return acct;
        }
    }

    private class AccountInvalidWrapper {
        String codigoIdentificador;
        String msgErro;

        AccountInvalidWrapper(String codigoIdentificador, String msgErro) {
            this.codigoIdentificador = codigoIdentificador;
            this.msgErro = msgErro;
        }
    }
}