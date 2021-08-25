# sfdx-email-services

Salesforce Email Services. Sample use case is "Email to Quote".


## Development

To work on this project in a scratch org:

1. [Set up CumulusCI](https://cumulusci.readthedocs.io/en/latest/tutorial.html)
2. Run `cci flow run dev_org --org dev` to deploy this project. This will fail initially when pushing the project with: [Failed]: Update of EmailServicesFunction QuoteEmailService: Error: In field: Username - no User named 
3. In emailservices/QuoteEmailService.xml-meta.xml, update username in <runAsUser>test-0w9ph3tfrjxj@example.com</runAsUser> to use the scratch org username.
4. Run `cci task run dx_push -o extra -f --org dev` to push the project to the scratch org again. 
5. Run `cci org browser dev` to open the org in your browser.