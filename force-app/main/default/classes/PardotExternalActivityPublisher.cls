public with sharing class PardotExternalProspectPublisher {
    public static final Integer HTTP_REQUESTS_PER_BATCH = 50;
    //public static final String ONLY_ONE_BUSINESS_UNIT_ID = '0UvB00000004CC7KAM';
    public static final String NAMED_CREDENTIAL = 'APEX_Pardot_Credential';

    public class NewProspect {
        @InvocableVariable(label='Business Unit Id' required=true)
        public String businessUnitId;
        @InvocableVariable(label='Prospect Email' required=true)
        public String email;
    }

    @InvocableMethod(label='Send Prospect to Pardot')
    public static void sendProspectToPardot(List<NewProspect> prospects) {
        //Very quickly pass this request into the ASYNC Queue, eliminating delays for Users
        System.enqueueJob(new QueueablePardotCall(prospects));
    }

    /**
     * Handles Asynchronously firing each Prospect to Pardot
     */
    public class QueueablePardotCall implements System.Queueable, Database.AllowsCallouts {
        private List<NewProspect> prospects;

        public QueueablePardotCall(List<NewProspect> prospects) {
            this.prospects = prospects;
        }

        public void execute(System.QueueableContext ctx) {
            //depending on how many Prospects we are processing, we might hit the APEX limit of 100 Web Callouts
            List<NewProspect> remainingProspects = new List<NewProspect>();
            Integer processedCount = 0;

            for(NewProspect prospect : prospects) {
                if(processedCount < HTTP_REQUESTS_PER_BATCH ) {
                    HttpRequest req = new HttpRequest();
                    //req.setHeader('Pardot-Business-Unit-Id', ONLY_ONE_BUSINESS_UNIT_ID);
                    req.setHeader('Content-Type', 'application/json');
                    req.setHeader('Pardot-Business-Unit-Id', prospect.businessUnitId);
                    // prospect.businessUnitId=null;

                    //req.setEndpoint('callout:'+NAMED_CREDENTIAL+'/v5/objects/prospects/');
                    req.setEndpoint('callout:'+NAMED_CREDENTIAL+'/v5/prospects/do/upsertLatestByEmail');
                    req.setMethod('POST');
                    String body = System.JSON.serialize(prospect, true);
                    System.debug('Submitting: ' + body);
                    req.setBody(body);
                    Http http = new Http();
                    try {
                        http.send(req);
                    }
                    catch(Exception e) {
                        //we fire it off and don't do anything if there's an error
                        //probably not the best approach for Production, though it will
                        //be up to you how to handle it
                        System.debug('There was an error submitting the External Prospect');
                        System.debug('Message: ' + e.getMessage() + '\n' +
                                        'Cause: ' + e.getCause() + '\n' +
                                        'Stack trace: ' + e.getStackTraceString());
                    }
                    processedCount++;
                }
                else {
                    remainingProspects.add(prospect); //we will process this in the next batch of Payloads
                }
            }
            if(!remainingProspects.isEmpty()) {
                System.enqueueJob(new QueueablePardotCall (remainingProspects));
            }
        }
    }
}
