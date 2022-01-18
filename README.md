# Pardot Pusher - APEX & Pardot API Implementation

Push records from the CRM to Pardot on demand
With process builder and an APEX class, we can create a way for prospects to be created in Pardot by having Salesforce automations (apex) fill out a Pardot Form Handler.

Example Process flow is
1. Add Lead/Contact to "Sync to Pardot" campaign
2. Process Builder sees this, checks to make sure we aren't already a Pardot Prospect.
3. If not currently a Prospect, kicks off APEX code
4. Apex Code used Pardot API to create record in Pardot
5. Pardot < - > Salesforce sync occurs, matches existing Lead/Contact, and syncs all the CRM fields to Pardot.
6. 
## Installation & Usage
It is important to note that this APEX code cannot work by itself. It requires a Named Credential properly configured to communicate with Pardot. If you aren't interested in reading the complete series of blog posts (recommended), then please at least follow the steps in our [Connecting to Pardot API from APEX](https://thespotforpardot.com/2021/02/02/pardot-api-and-getting-ready-with-salesforce-sso-users-part-3a-connecting-to-pardot-api-from-apex/) blog post which details those steps.

Once the Named credential is good to go, it is time to tweak the APEX code in this project, deploy, and then you are good to go.

## APEX Tweaks Required
At a minimum, you will need to modify the value of `ONLY_ONE_BUSINESS_UNIT_ID` to be **your** Pardot Business Unit Id. Making this change, this code base will support an org with only one Pardot Business Unit.

**Recommended** - you should take a look at the try/catch block to see how you will want to handle any potential API errors.

### Working with Multiple Business Units
This is where things get challenging, and your approach may vary depending on business case. Approaches may include:

- Include Business Unit ID as a Parameter to the Action, let the Flow designer worry about selecting the right one
- Iterate PardotTenant to find the correct Business Unit Id(s)

This code sample includes a set of commented-out code for handling the first approach. To leverage it, remove all code references to `ONLY_ONE_BUSINESS_UNIT_ID` and then un-comment-out the code that references `businessUnitId`. Once deployed, any Flows that existed prior will need to be modified.


## Salesforce Setup
### Process Builder
We need a triggering ‘something’ in the CRM to happen which we can build a Process Builder or Flow against. This example is a Salesforce Campaign such as “Send to Pardot” (or Contacts as New Pardot Prospects” as in the screen shot). 
We build the process builder from the Campaign Member Object looking for the Campaign name(s) or IDs plus the Contact Pardot URL is blank as well as the Lead Pardot URL being blank. On the Campaign Member object both the Contact and Lead both exist so it’s one of the few objects we can do this with.




### Alternatives
We can also make this work with Zapier to use the Pardot API method within Zapier to create the record. The Apex code talks to a Zapier Webhook, which then creates the record in Pardot. Or a different MAS platform.

https://github.com/sercante-llc/pardot-pusher 
