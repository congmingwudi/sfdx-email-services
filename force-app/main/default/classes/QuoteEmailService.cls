global class QuoteEmailService implements Messaging.InboundEmailHandler {
      
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        System.debug('QuoteEmailService > handleInboundEmail - email: ' + email + ', envelope: ' + envelope);

        String fromAddress = email.fromAddress;

        User user = [SELECT Id, Name FROM User where Name = 'User User' LIMIT 1];

        Contact contact = [SELECT Id, Name, Title FROM Contact where Email = :fromAddress Limit 1];

        String content = 'From: ' + fromAddress;
        content += '\nSubject: ' + email.subject;
        content += '\nBody: ' + email.plainTextBody;

        Task task = new Task();
        task.OwnerId = user.Id;
        task.Subject = 'Email Received: ' + email.subject;
        task.ActivityDate = Date.today();
        task.Description = content;
        task.WhoId = contact.Id;
        insert task;


        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        return result;
        
    } // end handleInboundEmail
    
} // end QuoteEmailService