/**
 * Created by waqasali on 9/19/18.
 */

public with sharing class CostingSummaryController {
    public Costing_Summary__c costingSummary { get; set; }
    Map<String, List<Summary_Details__c>> MapFamilySummaryDetails {get;set;}
    public List<CostingSummaryController.ProductCategory> CategoryList {get;set;}

    public CostingSummaryController(ApexPages.standardController sc) {

        costingSummary = [
                SELECT Id, Name, Account__c, Closing_Date__c, Cost__c, Document_Date__c, Geography__c,Gross_Margin__c,Remarks__c,
                        Gross_Profit__c, Mark_Up__c,Opportunity__c,Opportunity__r.Name,Project__c, Selling_Price__c, SOW__c, Tender_bond__c
            			, (
                        SELECT Id, Name, Cost_Month__c, Cost_Year__c, Mark_Up__c, Mark_Up_VAT__c,Priority__c, Selling_Price__c, Family__c,Category__c
                        FROM Summary_Details__r
                        ORDER BY Priority__c ASC
               )
                FROM Costing_Summary__c
                WHERE Id = :sc.getId()
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];

        MapFamilySummaryDetails = new Map<String, List<Summary_Details__c>>();
        CategoryList = new List<CostingSummaryController.ProductCategory>();
        
        for(Summary_Details__c sd: costingSummary.Summary_Details__r){
            if(MapFamilySummaryDetails.containsKey(sd.Family__c)){
                List<Summary_Details__c> summaryDetails = MapFamilySummaryDetails.get(sd.Family__c);
                summaryDetails.add(sd);
                MapFamilySummaryDetails.put(sd.Family__c,summaryDetails);
            }else {
                List<Summary_Details__c> summaryDetails = new List<Summary_Details__c>();
                summaryDetails.add(sd);
                MapFamilySummaryDetails.put(sd.Family__c,summaryDetails);
            }
        }

        for (String family: MapFamilySummaryDetails.keySet()){
            ProductCategory  productCategory = new CostingSummaryController.ProductCategory();
            productCategory.Category = family;
            productCategory.SummaryLineItemsList = MapFamilySummaryDetails.get(family);
            CategoryList.add(productCategory);
        }
    }


    public class ProductCategory {
        public String Category {
            get;
            set;
        }
        public List<Summary_Details__c> SummaryLineItemsList {
            get;
            set;
        }

    }


}