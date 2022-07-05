public class BirthdayEmail {
    private static String subject = 'Feliz Aniversário!';
    private static String textBody = 'Olá, {name}!\nDesejamos tudo de bom neste dia especial!';

    public static void send() {
        // Lembrar de ajustar Capacidade de entrega para todos os e-mails
        Date today = System.today(); // Data atual
        Integer day = today.day(); // Dia atual
        Integer month = today.month(); // Mês atual
        // Consultando contas aniversariantes
        List<Account> accountList = [SELECT Name, Email__c 
                                    FROM Account 
                                    WHERE CALENDAR_MONTH(DataAniversario__c) =: month 
                                    AND DAY_IN_MONTH(DataAniversario__c) =: day LIMIT 500];

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        if(accountList != null) {
            for(Account acct : accountList) {
                // Criando e-mail
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] address = new String[]{String.valueOf(acct.Email__c)};
    
                mail.setSubject(subject);
                mail.setplaintextbody(textBody.replace('{name}', acct.Name));
                mail.setToAddresses(address);
                emailList.add(mail);
            }
    
            if(!emailList.isEmpty()){
                // Enviando lista de e-mails
                Messaging.sendEmail(emailList);
            }
        }
    }
}