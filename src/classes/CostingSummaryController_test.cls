@isTest
public class CostingSummaryController_test {

      static testMethod void Tests() {
          
          Account a = new Account(Name='Test Account');
          insert a;
          
          
            Opportunity Opp = new Opportunity();
            Opp.Name = 'Test Opportiunity ';
            Opp.AccountId = a.id;
            Opp.CloseDate = System.today();
            Opp.StageName = 'Qualified';
            Opp.LeadSource = 'Web';
         	Opp.Entity__c = 'Arkan';
            Opp.Type = 'New Customer - New Business';
            insert Opp;
    	
          Costing_Summary__c CS = New Costing_Summary__c();
          
          CS.Name='CS-DXB Entertainments - v3.0';
          CS.Account__c = a.id ; 
          CS.Geography__c = 'Abu Dhabi' ; 
          CS.Remarks__c ='' ; 
          CS.Mark_Up__c =0 ; 
          CS.Opportunity__c =Opp.id ;         
          CS.Project__c = '';
          CS.SOW__c = '';
          
          Insert CS;
          
          
          Summary_Details__c SD =  New Summary_Details__c();
          
              SD.Name='Management';
          	  SD.Costing_Summary__c=CS.id;
              SD.Cost_Month__c= 115517.28 ; 
              SD.Cost_Year__c= 1386207.36; 
              SD.Mark_Up__c= 0; 
              SD.Mark_Up_VAT__c=0 ;
              SD.Priority__c= 1 ;
              SD.Selling_Price__c=1386207.36; 
              SD.Family__c='Manpower CTC';
              SD.Category__c= 'Management';
          
          insert SD;
          
           Summary_Details__c SD1 =  New Summary_Details__c();
          
              SD1.Name='Management';
          	  SD1.Costing_Summary__c=CS.id;
              SD1.Cost_Month__c= 115517.28 ; 
              SD1.Cost_Year__c= 1386207.36; 
              SD1.Mark_Up__c= 0; 
              SD1.Mark_Up_VAT__c=0 ;
              SD1.Priority__c= 1 ;
              SD1.Selling_Price__c=1386207.36; 
              SD1.Family__c='Manpower CTC';
              SD1.Category__c= 'Management';
          
          insert SD1;
          
              
           Apexpages.StandardController SC = New Apexpages.StandardController(CS);
        
        	CostingSummaryController controller = new CostingSummaryController(SC);
          
          	
      }
    
}