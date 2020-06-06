global class QuoteEmailService implements Messaging.InboundEmailHandler {

    global String emailIntakeName = 'QuoteEmailService'; // name of the custom meta data 'Email Intake" record name
      
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            System.debug('QuoteEmailService > handleInboundEmail - email: ' + email + ', envelope: ' + envelope);

            // email from contact
            Contact contact = getContact(email);

            // user to assign task
            // look up from custom metadata type 'Email Intake'
            // better to store the username in Context_User_Name__c and use it to look up the user
            // but storing the user full name for now to make it easier for scratch orgs
            User contextUser;
            List<Email_Intake__mdt> emailIntakes = [SELECT Context_User_Name__c FROM Email_Intake__mdt where DeveloperName = :emailIntakeName];
            System.debug('QuoteEmailService > handleInboundEmail - emailIntakes: ' + emailIntakes);
            if (emailIntakes.size() > 0) {
                String contextUserName = emailIntakes.get(0).Context_User_Name__c;
                List<User> users = [SELECT Id, Name FROM User where Name = :contextUserName];
                System.debug('QuoteEmailService > handleInboundEmail - users: ' + users);
                if (users.size() > 0) {
                    contextUser = users.get(0);
                }
            }

            // email content
            String content = 'From: ' + email.fromAddress;
            content += '\nSubject: ' + email.subject;
            content += '\n\nBody: ' + email.plainTextBody;

            // create task
            Task task = new Task();
            task.OwnerId = (contextUser != null) ? contextUser.Id : null;
            task.ActivityDate = Date.today();
            task.Status = 'Completed';
            task.WhoId = contact.Id;
            task.Type = 'Email';
            task.Subject = 'Email Received for Quote: ' + email.subject;
            task.Description = content;
            insert task;

            // attachments
            List<Attachment> attachments = new List<Attachment>();
            if(email.textAttachments != null) {
                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                    Attachment attachment = new Attachment();
                    attachment.Name = tAttachment.fileName;
                    attachment.Body = Blob.valueOf(tAttachment.body);
                    attachment.ParentId = task.Id;
                    attachments.add(attachment);
                }
            }
            if(email.binaryAttachments != null) {
                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                    Attachment attachment = new Attachment();
                    attachment.Name = bAttachment.fileName;
                    attachment.Body = bAttachment.body;
                    attachment.ParentId = task.Id;
                    attachments.add(attachment);
                }
            }
            if(attachments.size() > 0) {
                insert attachments;
            }
            result.success = true;

        } catch(Exception e) {
            System.debug('QuoteEmailService > handleInboundEmail - exception: ' + e);
            result.success = false;
            result.message = e.getMessage() + e.getStackTraceString();
        }

        return result;
        
    } // end handleInboundEmail

    private Contact getContact(Messaging.InboundEmail email) {

        Contact contact;
        List<Contact> contacts = [SELECT Id, Name, Title FROM Contact where Email = :email.fromAddress];
        if (contacts.size() > 0) {
            contact = contacts.get(0);
            System.debug('QuoteEmailService > handleInboundEmail - contact found: ' + contact);
        } else {
            // if not found, create a new contact
            contact = new Contact(Email = email.fromAddress);
            if (email.fromName != null) {
                List<String> toks = email.fromName.split(' ');
                if (toks.size() == 0) contact.LastName = 'Unknown';
                else if (toks.size() == 1) contact.LastName = toks.get(0);
                else if (toks.size() > 1) {
                    contact.FirstName = toks.get(0);
                    String lastName = '';
                    for (Integer i = 1; i < toks.size(); ++i) {
                        lastName += toks.get(i) + ' ';
                    }
                    contact.LastName = lastName.trim();
                }
            }
            insert contact;
            System.debug('QuoteEmailService > handleInboundEmail - contact created: ' + contact);
        }
        return contact;

    } // end getContact
    
} // end QuoteEmailService