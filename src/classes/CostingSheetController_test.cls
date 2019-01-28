@isTest(SeeAllData=true)
public class CostingSheetController_test {
    
    static testMethod void Tests() {
        
        Test.startTest();
        
        Account a = new Account(Name='Test Account');
        insert a;
        
        a = [SELECT Id,Name FROM Account a WHERE Id =: a.Id]; 
        system.assert(true,a.Id); 
        
        List<String> families = new list<String>{'Manpower CTC', 'Other Expenses', 'SSM', 'SP & Consumables', 'Tools & Equip'};
            for(String family: families){
                Product2 Prod =  new Product2();
                Prod.Name='PDA Device & Accessories 1';
                Prod.Unit_Cost__c=56.94;
                Prod.Family=family;
                Prod.Category__c='Others';
                Prod.Costing_Sheet_Priority__c=17;
                Prod.IsActive = true;
                Prod.Month__c = 1;
                Prod.Entity__c = 'Idama';
                Prod.Dummy_Checkbox__c = true;
                Prod.CTC_for_7_Days__c = 10;
                Insert Prod;
            }    
        Product2 Prod =  new Product2();
        Prod.Name='PDA Device & Accessories 1';
        Prod.Unit_Cost__c=56.94;
        Prod.Family='Other Expenses';
        Prod.Category__c='Others';
        Prod.Costing_Sheet_Priority__c=17;
        Prod.IsActive = true;
        Prod.Month__c = 1;
        
        
        Insert Prod;
        
        
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opportiunity ';
        Opp.AccountId = a.id;
        Opp.Manpower_Location__c='Dubai';
        Opp.CloseDate = System.today();
        Opp.StageName = 'Qualified';
        Opp.LeadSource = 'Web';
        Opp.Entity__c = 'Arkan';
        Opp.Type = 'New Customer - New Business';
        //Opp.Pricebook2Id=standardPrice.id;
        Opp.Pricebook2Id=pricebookId;  
        opp.Project_Name__c = 'My Project';
        insert Opp;
        
        
        OpportunityLineItem OppLim = new OpportunityLineItem();
        
        /* OppLim.Annual_Cost__c = ;
OppLim.Cost_Month__c= ;
OppLim.Cost_Year__c= ;
OppLim.Costing_Sheet_Priority__c= ;
OppLim.CreatedById= ;
OppLim.CTC_Month__c= ;
OppLim.ServiceDate= ;
OppLim.Depreciation_Year__c= ;
OppLim.Discount__c= ;
OppLim.Discount= ;
OppLim.Dummy_Checkbox__c= ;
OppLim.LastModifiedById= ;
OppLim.Description= ;
OppLim.ListPrice= ;
OppLim.Lump_Sum__c= ;
OppLim.Mark_Up__c= ;
OppLim.Month__c= ;
OppLim.Name__c= ;
OppLim.PPM_Frequency_Year__c= ;

OppLim.Product_Category__c= ;
OppLim.ProductCode= ;
OppLim.Product_Family__c= ;OppLim.Remarks__c= ;
OppLim.UnitPrice= ;
OppLim.Scope__cv
OppLim.Selling_Price__c= ;
OppLim.Source_of_Quotation__c= ;
OppLim.Subtotal= ;
OppLim.Supplier_Name__c= ;
OppLim.Threshold__c= ;

*/
        
        OppLim.OpportunityId= opp.Id ;
        OppLim.Quantity= 2;
        OppLim.TotalPrice= 1123;
        OppLim.Product2Id=Prod.Id ;
        OppLim.Month__c = 2;
        
        
        
        //Opp = [select id from Opportunity where id = :Opp.Id];
        //
        
        //	Insert Opplim;
        
        Apexpages.StandardController SC = New Apexpages.StandardController(Opp);
        
        CostingSheetController controller = new CostingSheetController(SC);
        controller.setTabBooleans(1);
        controller.setTabBooleans(2);
        controller.setTabBooleans(3);
        controller.setTabBooleans(4);
        controller.setTabBooleans(5);
        controller.setTabBooleans(6);
        controller.setTabBooleans(7);
        controller.showArkan = true;
        controller.tabNumber = 1;
        controller.setTabBooleans();
        controller.setTab();
        controller.tabNumber = 2;
        controller.setTabBooleans();
        controller.setTab();
        controller.tabNumber = 3;
        controller.setTabBooleans();
        controller.setTab();
        controller.tabNumber = 4;
        controller.setTabBooleans();
        controller.setTab();
        controller.tabNumber = 5;
        controller.setTabBooleans();
        controller.tabNumber = 6;
        controller.setTabBooleans();
        controller.setTab();
        controller.tabNumber = 7;
        //   controller.setTabBooleans();
        // controller.setTab();
        
        
        controller.SaveManpowerCTC();
        controller.SaveManpowerRequirement();
        controller.UpdateMapPowerReqList();
        for(String family: families){
            controller.getFamilywiseLineItem(family, Prod);
        }
        controller.SaveSPAndConsumables();
        controller.SaveToolsAndEquip();
        controller.SaveSSM();
        //controller.SaveOtherExpenses();
        controller.CreateCostingSummary();
        controller.SaveCostingSheet();
        //controller.ApplyMarkup();
        controller.SubmitForApproval();
        controller.GotoCostingSummary();
        controller.Nothing();
        controller.setTabBooleans(2);
        controller.setTabBooleans();
        controller.setTab();
        controller.fetchOppLineItems();
        //controller.getCosts(null, '', '');
        
        CostingSheetController.ProductCategory pc = new CostingSheetController.ProductCategory();
        pc.Category =  'test';
        pc.ProductsList = null; 
        pc.OppsLineItemsList = null;
        pc.SummaryLineItemsList = null;
        pc.totalAnnualCTC = 0; 
        pc.totalMonthCTC = 0;
        pc.totalQuantity =0;
        pc.totalSellingPrice =0;
        
        
        Test.stopTest();
        
    }
    
}