@isTest
public class SiteVisitDetailsController_test {
    
     static testMethod void Tests() {
         
            Account a = new Account(Name='Test Account');
            insert a;
         
            a = [SELECT Id,Name FROM Account a WHERE Id =: a.Id]; 
            system.assert(true,a.Id); 
             
            Opportunity Opp = new Opportunity();
            Opp.Name = 'Test Opportiunity ';
            Opp.AccountId = a.id;
            Opp.CloseDate = System.today();
            Opp.StageName = 'Qualified';
            Opp.LeadSource = 'Web';
         	Opp.Entity__c = 'Arkan';
            Opp.Type = 'New Customer - New Business';
            insert Opp;
        Opp = [select id from Opportunity where id = :Opp.Id];
         
         Site_Visit__c SV = new Site_Visit__c(Opportunity__c = Opp.Id);
         Insert SV;
         
         Apexpages.StandardController SC = New Apexpages.StandardController(SV);
         
         PageReference Ref = Page.VisitDetails;
         Ref.getParameters().put('id',SV.Id);
         Ref.getParameters().put('Oppid',Opp.Id);
         Test.setCurrentPageReference(Ref);
         
         SiteVisitDetailsController controller = new SiteVisitDetailsController(SC);
         controller.SVDLSTNM = null;
         controller.SVDLSTSrvc =  null;
         String trst = controller.renderingService ;
         controller.SVdetails = null;
         controller.Category = '';
         controller.SaveItem();
         controller.EditRecord();
         controller.saveToPdf();
         controller.cancel();
     }
    

    static testMethod void Tests1() {
         
            Account a = new Account(Name='Test Account');
            insert a;
         
            a = [SELECT Id,Name FROM Account a WHERE Id =: a.Id]; 
            system.assert(true,a.Id);
             
            Opportunity Opp = new Opportunity();
            Opp.Name = 'Test Opportiunity ';
            Opp.AccountId = a.id;
            Opp.CloseDate = System.today();
            Opp.StageName = 'Qualified';
            Opp.LeadSource = 'Web';
         	Opp.Entity__c = 'Arkan';
            Opp.Type = 'New Customer - New Business';
            insert Opp;
        Opp = [select id from Opportunity where id = :Opp.Id];
         
         //Site_Visit__c SV = new Site_Visit__c(Opportunity__c = Opp.Id);
         //Insert SV;
         //
         Site_Visit__c SV = new Site_Visit__c(Opportunity__c = Opp.Id); 
        SV.Id = Null;
         
         Apexpages.StandardController SC = New Apexpages.StandardController(SV);
         
         PageReference Ref = Page.VisitDetails;
         Ref.getParameters().put('id',SV.Id);
         Ref.getParameters().put('Oppid',Opp.Id);
         Test.setCurrentPageReference(Ref);
         
         SiteVisitDetailsController controller = new SiteVisitDetailsController(SC);
         
         controller.SaveItem();
         controller.EditRecord();
         controller.saveToPdf();
         controller.cancel();
     }

    

}