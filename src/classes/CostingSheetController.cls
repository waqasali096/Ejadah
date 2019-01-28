/**
 * Created by waqasali on 9/9/18.
 */

public with sharing class CostingSheetController {

    public List<CostingEntity> ManpowerList { get; set; }
    public List<CostingEntity> ManpowerReqList { get; set; }
    public List<CostingEntity> SPAndConsumablesList { get; set; }
    public List<CostingEntity> ToolsAndEquipList { get; set; }
    public List<CostingEntity> SSMList { get; set; }
    public List<CostingEntity> OtherExpensesList { get; set; }
    public List<CostingEntity> CostingSummaryList { get; set; }

    public Map<Id, Product2> masterProductMap { get; set; }

    public Map<Id, OpportunityLineItem> mapOppLineItems;
    public Map<Id, PricebookEntry> mapPricebookEntries;

    List<OpportunityLineItem> oppsLineItemsToUpdate { get; set; }
    public Opportunity opp { get; set; }

    public String Idama = 'Idama';
    public String Arkan = 'Arkan';

    public boolean showMapPowerCtc { get; set; }
    public boolean showMapPowerRequirement { get; set; }
    public boolean showSPAndConsumables { get; set; }
    public boolean showToolsAndEquip { get; set; }
    public boolean showSSM { get; set; }
    public boolean showOtherExpenses { get; set; }
    public boolean showSummary { get; set; }

    public boolean showIdama { get; set; }
    public boolean showArkan { get; set; }
    public String costingSheetView { get; set; }

    public Decimal markupValue { get; set; }

    public boolean isSuccessful { get; set; }

    public Integer tabNumber { get; set; }

    public List<String> pageMessages { get; set; }
    public boolean CostingSheetSaved { get; set; }
    public Id CostingSummaryId { get; set; }
    
    public String location{get;set;}

    public CostingSheetController(ApexPages.StandardController sc) {
        isSuccessful = false;
        location = 'Dubai';
        CostingSheetSaved = false;
        masterProductMap = new Map<Id, Product2>();
        mapOppLineItems = new Map<Id, OpportunityLineItem>();
        mapPricebookEntries = new Map<Id, PricebookEntry>();
        pageMessages = new List<String>();
        opp = [SELECT Id, Name, Costing_Sheet_View__c, Manpower_Location__c ,StageName, AccountId, Account.Name, OwnerId, Owner.Name, Geographical_Area__c, SOW__c, Tender_Bond__c, Document_Date__c, CloseDate FROM Opportunity WHERE Id = :sc.getId()];
        setTabBooleans(1);
        fetchOppLineItems();
        ManpowerList = new List<CostingSheetController.CostingEntity>();
        ManpowerReqList = new List<CostingSheetController.CostingEntity>();
        SPAndConsumablesList = new List<CostingSheetController.CostingEntity>();
        ToolsAndEquipList = new List<CostingSheetController.CostingEntity>();
        SSMList = new List<CostingSheetController.CostingEntity>();
        OtherExpensesList = new List<CostingSheetController.CostingEntity>();
        CostingSummaryList = new List<CostingSheetController.CostingEntity>();


        costingSheetView = 'Both';
        if (opp.Costing_Sheet_View__c == null || opp.Costing_Sheet_View__c == 'Both') {
            showIdama = true;
            showArkan = true;
        }
        if(opp.Manpower_Location__c!=null){
            location = opp.Manpower_Location__c;
        }
      /**  if (opp.Costing_Sheet_View__c != null && opp.Costing_Sheet_View__c == 'Idama Only') {
            showIdama = true;
            showArkan = false;
            costingSheetView = opp.Costing_Sheet_View__c;
        }
        if (opp.Costing_Sheet_View__c != null && opp.Costing_Sheet_View__c == 'Arkan Only') {
            showIdama = false;
            showArkan = true;
            costingSheetView = opp.Costing_Sheet_View__c;
        }**/

        showIdama = true;
        showArkan = true;

        if (showIdama) {
            ManpowerList.add(FetchEntity(Idama, 'Manpower CTC'));
        }
        if (showArkan) {
            ManpowerList.add(FetchEntity(Arkan, 'Manpower CTC'));
        }
        showArkan = false;
    }

    public CostingEntity FetchEntity(String entity, String family) {
        CostingEntity costingEntity = new CostingEntity();
        costingEntity.EntityName = entity;
        if (family == 'Manpower CTC') {
            if (entity == Idama) {
                costingEntity.FieldSet = Schema.SObjectType.Product2.FieldSets.IdamaManpowerCTC.getFields();
            } else {
                costingEntity.FieldSet = Schema.SObjectType.Product2.FieldSets.ArkanManpowerCTC.getFields();
            }
        }
        costingEntity.CategoryList = FetchFamilyProducts(entity, family);

        if(family == 'SP & Consumables'){
            for (CostingSheetController.ProductCategory pc: costingEntity.CategoryList){
                if(pc.Category!= 'Maintenance'){
                    for (OpportunityLineItem opli: pc.OppsLineItemsList){
                        if(opli.UnitPrice == opli.UnitPrice__c ){
                            opli.UnitPrice__c = 0.00;
                        }
                    }
                }
            }

        }


        return CostingEntity;
    }

    public List<ProductCategory> FetchFamilyProducts(String entity, String family) {
        List<Product2> products = new List<Product2>();
        String query = 'Select ';
        Set<string> fieldSet = new set<string>();
        for (Schema.FieldSetMember f : Schema.SObjectType.Product2.FieldSets.AllFields.getFields()) {
            fieldSet.add(f.getFieldPath());
        }
        fieldSet.add('Id');
        if(family == 'Manpower CTC'){
            query += string.join(new List<string>(fieldSet), ',') + ' From Product2 Where isActive = true AND Entity__c = \'' + entity + '\'' + ' AND Location__c = \'' + location + '\'' + ' AND Family = \'' + family + '\'' + ' order by Costing_Sheet_Priority__c ASC limit 10000';
        }else {
            query += string.join(new List<string>(fieldSet), ',') + ' From Product2 Where isActive = true AND Family = \'' + family + '\'' + ' order by Costing_Sheet_Priority__c ASC limit 10000';
        }
        System.debug('Query--'+query);
        products = Database.query(query);
               System.debug('Query--'+products);

        Map<String, List<Product2>> mapCategoryProducts = new Map<String, List<Product2>>();

        for (Product2 p : products) {
            if (mapOppLineItems.containsKey(p.Id)) {
                p.Dummy_Checkbox__c = true;
            }
            if (mapCategoryProducts.containsKey(p.Category__c)) {
                List<Product2> tempProduct2s = mapCategoryProducts.get(p.Category__c);
                tempProduct2s.add(p);
                mapCategoryProducts.put(p.Category__c, tempProduct2s);
            } else {
                List<Product2> tempProduct2s = new List<Product2>();
                tempProduct2s.add(p);
                mapCategoryProducts.put(p.Category__c, tempProduct2s);
            }
            masterProductMap.put(p.Id, p);
        }
        List<ProductCategory> tempCategoryList = new List<ProductCategory>();
        for (String categoryName : mapCategoryProducts.keySet()) {
            ProductCategory pc = new ProductCategory();
            pc.Category = categoryName;
            pc.ProductsList = mapCategoryProducts.get(categoryName);
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            for (Product2 p : pc.ProductsList) {
                if (p.Dummy_Checkbox__c && mapOppLineItems.containsKey(p.Id)) {
                    OpportunityLineItem tempOpli = mapOppLineItems.get(p.Id);
                    oppLineItems.add(tempOpli);
                } else {
                    OpportunityLineItem opli = getFamilywiseLineItem(family, p);
                    oppLineItems.add(opli);
                }
            }
            if (oppLineItems.size() > 0) {
                pc.OppsLineItemsList = oppLineItems;
            }
            tempCategoryList.add(pc);
        }

        return tempCategoryList;
    }


    public OpportunityLineItem getFamilywiseLineItem(String family, Product2 p) {
        OpportunityLineItem opli = new OpportunityLineItem();
        opli.Product2Id = p.Id;
        opli.Name__c = p.Name;
        opli.OpportunityId = opp.Id;
        opli.Free_Entry__c = p.Free_Entry__c;
        opli.Price_Editable__c = p.Price_Editable__c;

        opli.Costing_Sheet_Priority__c = p.Costing_Sheet_Priority__c;
        opli.PricebookEntryId = mapPricebookEntries.get(p.Id).Id;

        switch on family {
            when 'Manpower CTC' {
                opli.UnitPrice__c = p.CTC_for_7_Days__c;
                opli.UnitPrice = p.CTC_for_7_Days__c;
                opli.Quantity = 1;
            }
            when 'SP & Consumables' {
                Decimal hardServicesTotal = 0;
                for (CostingEntity ce : ManpowerReqList) {
                    for (ProductCategory pc : ce.CategoryList) {
                        System.debug('# ' + pc.Category + ' ' + pc.totalAnnualCTC);
                        if (pc.Category == 'Hard Services') {
                            hardServicesTotal = pc.totalAnnualCTC;
                        }
                    }
                }
                opli.UnitPrice__c = hardServicesTotal;
                opli.UnitPrice = hardServicesTotal;
                opli.Quantity = 0;
                opli.Mark_Up__c = 14;
            }
            when 'Tools & Equip' {
                opli.UnitPrice__c = p.Unit_Cost__c;
                opli.UnitPrice = p.Unit_Cost__c;
                opli.Depreciation_Year__c = p.Depreciation_Year__c;
                opli.Quantity = 0;
                opli.Mark_Up__c = 14;

            }
            when 'SSM' {
                opli.UnitPrice__c = p.Unit_Cost__c;
                opli.UnitPrice = p.Unit_Cost__c;
                opli.Scope__c = p.Scope__c;
                opli.Quantity = 0;
                opli.Mark_Up__c = 14;
                opli.PPM_Frequency_Year__c = 0;

            }
            when 'Other Expenses' {
                opli.UnitPrice__c = p.Unit_Cost__c;
                opli.UnitPrice = p.Unit_Cost__c;
                opli.Month__c = p.Month__c;
                opli.Quantity = 0;
                opli.Mark_Up__c = 14;

            }
        }

        return opli;


    }


    public PageReference SaveManpowerCTC() {
        isSuccessful = false;
//        Integer total = masterProductMap.values().size();
//        for (Product2 p : masterProductMap.values()) {
//            if (p.Dummy_Checkbox__c) {
//                break;
//            } else {
//                total--;
//            }
//        }
//        if (total == 0) {
//            String message = 'Please select atleast one resource.';
//            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
//            return null;
//        }
        UpdateMapPowerReqList();
        setTabBooleans(2);
        isSuccessful = true;

        return null;
    }

    public PageReference SaveManpowerRequirement() {
        setTabBooleans(2);
        for (OpportunityLineItem opli : oppsLineItemsToUpdate) {
            opli.Selling_Price__c = (12 * opli.UnitPrice__c * opli.Quantity) + ((12 * opli.UnitPrice__c * opli.Quantity) * opli.Mark_Up__c) / 100;
        }
        upsert oppsLineItemsToUpdate;
        fetchOppLineItems();
        UpdateMapPowerReqList();

        return null;
    }
    public void UpdateMapPowerReqList() {
        oppsLineItemsToUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppsLineItemsToDelete = new List<OpportunityLineItem>();

        ManpowerReqList = new List<CostingSheetController.CostingEntity>();
        for (CostingEntity me : ManpowerList) {
            CostingEntity costingEntity = new CostingEntity();
            costingEntity.EntityName = me.EntityName;
            List<ProductCategory> tempCategoryList = new List<ProductCategory>();
            for (ProductCategory mc : me.CategoryList) {
                ProductCategory productCategory = new ProductCategory();
                productCategory.Category = mc.Category;
                productCategory.totalQuantity = 0;
                productCategory.totalMonthCTC = 0;
                productCategory.totalAnnualCTC = 0;
                productCategory.totalSellingPrice = 0;
                List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
                for (Product2 p : mc.ProductsList) {
                    if (p.Dummy_Checkbox__c) {
                        if (mapOppLineItems.containsKey(p.Id)) {
                            OpportunityLineItem tempOpli = mapOppLineItems.get(p.Id);
                            productCategory.totalQuantity = productCategory.totalQuantity + tempOpli.Quantity;
                            productCategory.totalMonthCTC = productCategory.totalMonthCTC + tempOpli.CTC_Month__c;
                            productCategory.totalAnnualCTC = productCategory.totalAnnualCTC + tempOpli.Annual_Cost__c;
                            productCategory.totalSellingPrice = productCategory.totalSellingPrice + tempOpli.Selling_Price__c;
                            oppLineItems.add(tempOpli);
                            oppsLineItemsToUpdate.add(tempOpli);
                        } else {
                            OpportunityLineItem opli = new OpportunityLineItem();
                            opli.Name__c = p.Name;
                            opli.UnitPrice__c = p.CTC_for_7_Days__c;
                            opli.UnitPrice= p.CTC_for_7_Days__c;
                            opli.Product2Id = p.Id;
                            opli.OpportunityId = opp.Id;
                            opli.Quantity = 1;
                            opli.Mark_Up__c = 14;
                            opli.Free_Entry__c = p.Free_Entry__c;
                            opli.Price_Editable__c = p.Price_Editable__c;
                            opli.Costing_Sheet_Priority__c = p.Costing_Sheet_Priority__c;
                            opli.PricebookEntryId = mapPricebookEntries.get(p.Id).Id;
                            productCategory.totalQuantity = productCategory.totalQuantity + 1;
                            productCategory.totalMonthCTC = productCategory.totalMonthCTC + p.CTC_for_7_Days__c;
                            productCategory.totalAnnualCTC = productCategory.totalAnnualCTC + (12 * p.CTC_for_7_Days__c);
                            productCategory.totalSellingPrice = productCategory.totalAnnualCTC;
                            oppLineItems.add(opli);
                            oppsLineItemsToUpdate.add(opli);
                        }
                    } else {
                        if (mapOppLineItems.containsKey(p.Id)) {
                            OpportunityLineItem tempOpli = mapOppLineItems.get(p.Id);
                            oppsLineItemsToDelete.add(mapOppLineItems.get(p.Id));
                        }
                    }
                }

                if (oppLineItems.size() > 0) {
                    productCategory.OppsLineItemsList = oppLineItems;
                    tempCategoryList.add(productCategory);
                }
            }
            costingEntity.CategoryList = tempCategoryList;
            ManpowerReqList.add(costingEntity);

        }
        if (oppsLineItemsToDelete.size() > 0) {
            delete oppsLineItemsToDelete;
        }
    }

    public PageReference SaveSPAndConsumables() {
        pageMessages.clear();
        List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLineItemsToDelete = new List<OpportunityLineItem>();
        for (CostingEntity ce : SPAndConsumablesList) {
            for (ProductCategory pc : ce.CategoryList) {
                if (pc.Category == 'Maintenance') {
                    for (OpportunityLineItem opli : pc.OppsLineItemsList) {
                        opli.Quantity = 1;
                        System.debug('# Discount = ' + opli.Discount__c + ' ' + opli.Lump_Sum__c);
                        if (opli.Discount__c != null && opli.Discount__c > 0 && opli.Lump_Sum__c != null && opli.Lump_Sum__c > 0) {
                            pageMessages.add('Please fill up only one field from Percentage % or Lump sum.');
                            isSuccessful = false;
                            return null;
                        }

                        if ((opli.Discount__c != null && opli.Discount__c > 0) || (opli.Lump_Sum__c != null && opli.Lump_Sum__c > 0)) {
                            opli.Dummy_Checkbox__c = true;
                            if (opli.Lump_Sum__c != null && opli.Lump_Sum__c > 0) {
                                opli.Cost_Year__c = opli.Lump_Sum__c ;
                            } else {
                                opli.Cost_Year__c = (opli.UnitPrice__c * opli.Discount__c) / 100 ;
                            }
                            opli.Selling_Price__c = opli.Cost_Year__c + (opli.Cost_Year__c * opli.Mark_Up__c) / 100;
                            opli.Cost_Month__c = opli.Cost_Year__c / 12 ;
                            oppLineItemsToUpdate.add(opli);
                        }
                        if ((opli.Discount__c == null || opli.Discount__c == 0) && (opli.Lump_Sum__c == null || opli.Lump_Sum__c == 0)) {
                            if (mapOppLineItems.containsKey(opli.Product2Id)) {
                                opli.Dummy_Checkbox__c = false;
                                opli.Cost_Year__c = null ;
                                opli.Cost_Month__c = null ;
                                opli.Selling_Price__c = null;
                                opli.Remarks__c = null;
                                oppLineItemsToDelete.add(opli);
                            }
                        }
                    }
                } else {
                    for (OpportunityLineItem opli : pc.OppsLineItemsList) {
                        System.debug('# Quantity = ' + opli.Quantity);
                        if (opli.Quantity != null && opli.Quantity > 0) {
                            opli.Dummy_Checkbox__c = true;
                            opli.Cost_Year__c = (opli.UnitPrice__c * opli.Quantity)  ;
                            opli.Selling_Price__c = opli.Cost_Year__c + (opli.Cost_Year__c * opli.Mark_Up__c) / 100;
                            opli.Cost_Month__c = opli.Cost_Year__c / 12 ;
                            oppLineItemsToUpdate.add(opli);
                        }
                        if (opli.Quantity == null || opli.Quantity == 0) {
                            if (mapOppLineItems.containsKey(opli.Product2Id)) {
                                opli.Dummy_Checkbox__c = false;
                                opli.Cost_Year__c = null ;
                                opli.Cost_Month__c = null ;
                                opli.Selling_Price__c = null;
                                opli.Remarks__c = null;
                                oppLineItemsToDelete.add(opli);
                            }
                        }
                    }
                }

            }
        }
        if (oppLineItemsToDelete.size() > 0) {
            delete oppLineItemsToDelete;
        }
        if (oppLineItemsToUpdate.size() > 0) {
            upsert oppLineItemsToUpdate;
        }
        fetchOppLineItems();
        SPAndConsumablesList = new List<CostingSheetController.CostingEntity>();
        if (showIdama) {
            SPAndConsumablesList.add(FetchEntity(Idama, 'SP & Consumables'));
        }
        if (showArkan) {
            SPAndConsumablesList.add(FetchEntity(Arkan, 'SP & Consumables'));
        }

        return null;
    }

    public PageReference SaveToolsAndEquip() {
        List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLineItemsToDelete = new List<OpportunityLineItem>();
        for (CostingEntity ce : ToolsAndEquipList) {
            for (ProductCategory pc : ce.CategoryList) {
                for (OpportunityLineItem opli : pc.OppsLineItemsList) {
                    if (opli.Quantity != null && opli.Quantity > 0) {
                        opli.Dummy_Checkbox__c = true;
                        opli.Cost_Year__c = opli.Quantity * opli.UnitPrice__c / opli.Depreciation_Year__c ;
                        opli.Cost_Month__c = opli.Cost_Year__c / 12 ;
                        opli.Selling_Price__c = opli.Cost_Year__c + (opli.Cost_Year__c * opli.Mark_Up__c) / 100;
                        oppLineItemsToUpdate.add(opli);
                    } else {
                        if (mapOppLineItems.containsKey(opli.Product2Id)) {
                            opli.Dummy_Checkbox__c = false;
                            opli.Cost_Year__c = null ;
                            opli.Cost_Month__c = null ;
                            opli.Selling_Price__c = null;
                            opli.Remarks__c = null;
                            oppLineItemsToDelete.add(opli);
                        }
                    }
                }
            }
        }
        if (oppLineItemsToDelete.size() > 0) {
            delete oppLineItemsToDelete;
        }

        if (oppLineItemsToUpdate.size() > 0) {
            upsert oppLineItemsToUpdate;
        }
        fetchOppLineItems();
        ToolsAndEquipList = new List<CostingSheetController.CostingEntity>();
        if (showIdama) {
            ToolsAndEquipList.add(FetchEntity(Idama, 'Tools & Equip'));
        }
        if (showArkan) {
            ToolsAndEquipList.add(FetchEntity(Arkan, 'Tools & Equip'));
        }


        return null;
    }
    public PageReference SaveSSM() {
        List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLineItemsToDelete = new List<OpportunityLineItem>();
        for (CostingEntity ce : SSMList) {
            for (ProductCategory pc : ce.CategoryList) {
                for (OpportunityLineItem opli : pc.OppsLineItemsList) {
                    if (opli.Quantity != null && opli.Quantity > 0) {
                        opli.Dummy_Checkbox__c = true;
                        opli.Cost_Year__c = opli.Quantity * opli.UnitPrice__c * opli.PPM_Frequency_Year__c;
                        opli.Selling_Price__c = opli.Cost_Year__c + (opli.Cost_Year__c * opli.Mark_Up__c) / 100;
                        oppLineItemsToUpdate.add(opli);
                    } else {
                        if (mapOppLineItems.containsKey(opli.Product2Id)) {
                            opli.Dummy_Checkbox__c = false;
                            opli.Cost_Year__c = null;
                            opli.Selling_Price__c = null;
                            oppLineItemsToDelete.add(opli);
                        }
                    }
                }
            }
        }
        if (oppLineItemsToDelete.size() > 0) {
            delete oppLineItemsToDelete;
        }

        if (oppLineItemsToUpdate.size() > 0) {
            upsert oppLineItemsToUpdate;
        }

        fetchOppLineItems();
        SSMList = new List<CostingSheetController.CostingEntity>();
        if (showIdama) {
            SSMList.add(FetchEntity(Idama, 'SSM'));
        }
        if (showArkan) {
            SSMList.add(FetchEntity(Arkan, 'SSM'));
        }
        return null;
    }
    public PageReference SaveOtherExpenses() {
        List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLineItemsToDelete = new List<OpportunityLineItem>();
        for (CostingEntity ce : OtherExpensesList) {
            for (ProductCategory pc : ce.CategoryList) {
                for (OpportunityLineItem opli : pc.OppsLineItemsList) {
                    if (opli.Quantity != null && opli.Quantity > 0) {
                        opli.Dummy_Checkbox__c = true;
                        opli.Cost_Year__c = opli.Quantity * opli.UnitPrice__c * opli.Month__c;
                        opli.Selling_Price__c = opli.Cost_Year__c + (opli.Cost_Year__c * opli.Mark_Up__c) / 100;
                        oppLineItemsToUpdate.add(opli);
                    } else {
                        if (mapOppLineItems.containsKey(opli.Product2Id)) {
                            opli.Dummy_Checkbox__c = false;
                            opli.Cost_Year__c = null ;
                            opli.Selling_Price__c = null;
                            opli.Remarks__c = null;
                            oppLineItemsToDelete.add(opli);
                        }
                    }
                }
            }
        }
        if (oppLineItemsToDelete.size() > 0) {
            delete oppLineItemsToDelete;
        }
        if (oppLineItemsToUpdate.size() > 0) {
            upsert oppLineItemsToUpdate;
        }
        fetchOppLineItems();
        OtherExpensesList = new List<CostingSheetController.CostingEntity>();
        if (showIdama) {
            OtherExpensesList.add(FetchEntity(Idama, 'Other Expenses'));
        }
        if (showArkan) {
            OtherExpensesList.add(FetchEntity(Arkan, 'Other Expenses'));
        }
        return null;
    }

    public List<CostingEntity> CreateCostingSummary() {
        Map<String, Summary_Details__c> MapSummaryDetails = new Map<String, Summary_Details__c>();
        Costing_Summary__c existingCostingSummary = null;
        try {
//            existingCostingSummary = [
//                    SELECT Id, Name, Account__c, Closing_Date__c, Cost__c, Document_Date__c, Geography__c,Gross_Margin__c, Remarks__c,
//                            Gross_Profit__c, Mark_Up__c,Opportunity__c,Opportunity__r.Name,Project__c, Selling_Price__c, SOW__c, Tender_bond__c, (
//                            SELECT Id, Name, Cost_Month__c, Cost_Year__c, Mark_Up__c, Mark_Up_VAT__c,Priority__c, Selling_Price__c, Family__c,Category__c
//                            FROM Summary_Details__r
//                            ORDER BY Priority__c ASC
//                    )
//                    FROM Costing_Summary__c
//                    WHERE Opportunity__c = :opp.Id
//                    ORDER BY CreatedDate DESC
//                    LIMIT 1
//            ];
            if (CostingSummaryId != null) {
                existingCostingSummary = [
                        SELECT Id, Remarks__c
                        FROM Costing_Summary__c
                        WHERE Id = :CostingSummaryId
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                ];
            }

//            for (Summary_Details__c summaryDetails : existingCostingSummary.Summary_Details__r) {
//                MapSummaryDetails.put(summaryDetails.Family__c + '' + summaryDetails.Category__c, summaryDetails);
//            }
        } catch (Exception e) {
        }
//        existingCostingSummary = null;

        List<Costing_Summary_Definition__c> DefinitionList = [
                select name, Family__c, Category__c
                from Costing_Summary_Definition__c
                order by Priority__c ASC
        ];

        AggregateResult[] groupedResults = [
                Select Product2.Family, Product2.Category__c, SUM(CTC_Month__c),
                        SUM(Annual_Cost__c),SUM(Cost_Month__c), SUM(Cost_Year__c), SUM(Selling_Price__c)
                from OpportunityLineItem
                where OpportunityId = :opp.Id
                GROUP BY Product2.Family, Product2.Category__c
        ];

        Map<String, List<String>> MapFamilyCategory = new Map<String, List<String>>();
        for (Costing_Summary_Definition__c definition : DefinitionList) {
            List<String> categoriesList ;
            if (MapFamilyCategory.containsKey(definition.Family__c)) {
                categoriesList = MapFamilyCategory.get(definition.Family__c);
            } else {
                categoriesList = new List<String>();
            }
            categoriesList.add(definition.Category__c);
            MapFamilyCategory.put(definition.Family__c, categoriesList);
        }

        List<CostingEntity> CostingEntities = new List<CostingSheetController.CostingEntity>();
        CostingEntity costingEntity = new CostingEntity();
//        if (existingCostingSummary != null) {
//            costingEntity.CostingSummary = existingCostingSummary;
//        } else {
        Integer versionNumber = 0;
        try {
            versionNumber = [SELECT COUNT() from Costing_Summary__c WHERE Opportunity__c = :opp.Id];
        } catch (Exception e) {
            versionNumber = 0;
        }
        versionNumber = versionNumber + 1;
        Costing_Summary__c costingSummary = new Costing_Summary__c();
        costingSummary.Name = 'CS-' + opp.Name + ' - v' + versionNumber + '.0';
        costingSummary.Account__c = opp.AccountId;
        costingSummary.Mark_Up__c = 0;
        costingEntity.CostingSummary = costingSummary;
        costingSummary.Project__c = opp.Name;
        costingSummary.Opportunity__c = opp.Id;
        costingSummary.Geography__c = opp.Geographical_Area__c;
        costingSummary.Tender_bond__c = opp.Tender_bond__c;
        costingSummary.Document_Date__c = opp.Document_Date__c;
        costingSummary.SOW__c = opp.SOW__c;
        costingSummary.Closing_Date__c = opp.CloseDate;
        if (CostingSheetSaved && existingCostingSummary != null) {
            costingSummary.Remarks__c = existingCostingSummary.Remarks__c;
        }
//        }

        List<ProductCategory> CategoryList = new List<CostingSheetController.ProductCategory>();
        Decimal Priority = 1;
        for (String family : MapFamilyCategory.keySet()) {
            ProductCategory pc = new ProductCategory();
            pc.Category = family;
            List<Summary_Details__c> summaryDetailsList = new List<Summary_Details__c>();
            for (String category : MapFamilyCategory.get(family)) {
                Decimal ctcMonth = 0;
                Decimal annualCost = 0;
                Decimal costMonth = 0;
                Decimal costYear = 0;
                Decimal sellingPrice = 0;
                AggregateResult ar = getCosts(groupedResults, family, category);
                if (ar != null) {
                    ctcMonth = (Decimal) ar.get('expr0');
                    annualCost = (Decimal) ar.get('expr1');
                    costMonth = (Decimal) ar.get('expr2');
                    costYear = (Decimal) ar.get('expr3');
                    sellingPrice = (Decimal) ar.get('expr4');
                }
                Summary_Details__c summaryDetail = null;

//                if (MapSummaryDetails.containsKey(family + '' + category)) {
//                    summaryDetail = MapSummaryDetails.get(family + '' + category);
//                } else {
                summaryDetail = new Summary_Details__c();
                summaryDetail.Mark_Up_VAT__c = 0;
//                }
                summaryDetail.Name = category;
                if (family == 'Manpower CTC') {
                    summaryDetail.Cost_Month__c = ctcMonth;
                    summaryDetail.Cost_Year__c = annualCost;
                } else {
                    summaryDetail.Cost_Month__c = costMonth;
                    summaryDetail.Cost_Year__c = costYear;
                }


                summaryDetail.Selling_Price__c = sellingPrice;
                summaryDetail.Mark_Up__c = 0;
                if (summaryDetail.Selling_Price__c != null) {
                    summaryDetail.Mark_Up__c = summaryDetail.Selling_Price__c - summaryDetail.Cost_Year__c ;
                    summaryDetail.Mark_Up_VAT__c = 0;
                    if (summaryDetail.Selling_Price__c > 0)
                        summaryDetail.Mark_Up_VAT__c = (summaryDetail.Mark_Up__c / summaryDetail.Cost_Year__c) * 100;
                }
                summaryDetail.Priority__c = Priority;
                summaryDetail.Family__c = family;
                summaryDetail.Category__c = category;
                Priority = Priority + 1;
                summaryDetailsList.add(summaryDetail);
            }
            pc.SummaryLineItemsList = summaryDetailsList;
            CategoryList.add(pc);
        }

        costingEntity.CategoryList = CategoryList;

        CostingEntities.add(costingEntity);
        return CostingEntities;
    }

    public AggregateResult getCosts(AggregateResult[] groupedResults, String family, String category) {
        for (AggregateResult ar : groupedResults) {
            String familyAr = (String) ar.get('Family');
            String categoryAr = (String) ar.get('Category__c');
            if (familyAr == family && categoryAr == category) {
                return ar;
            }

        }
        return null;
    }
    public PageReference SaveCostingSheet() {
        CostingSheetSaved = false;
        List<Summary_Details__c> summaryLineItems = new List<Summary_Details__c>();
        for (CostingEntity ce : CostingSummaryList) {
            Costing_Summary__c cs = ce.CostingSummary;
            if (cs.Opportunity__c == null) {
                cs.Opportunity__c = opp.Id;
            }
            upsert cs;
            CostingSummaryId = cs.Id;
            for (ProductCategory pc : ce.CategoryList) {
                for (Summary_Details__c sli : pc.SummaryLineItemsList) {
                    if (sli.Costing_Summary__c == null) {
                        sli.Costing_Summary__c = cs.Id;
                    }
                    summaryLineItems.add(sli);
                }
            }
        }
        if (summaryLineItems.size() > 0) {
            upsert summaryLineItems;
        }
        pageMessages.add('Costing Sheet has been saved successfully.');
        CostingSheetSaved = true;
        CostingSummaryList = CreateCostingSummary();
        return null;
    }

    public PageReference ApplyMarkup() {
        for (CostingEntity ce : CostingSummaryList) {
            ce.CostingSummary.Mark_Up__c = markupValue;
            for (ProductCategory pc : ce.CategoryList) {
                for (Summary_Details__c sli : pc.SummaryLineItemsList) {
                    sli.Mark_Up_VAT__c = ce.CostingSummary.Mark_Up__c;
                    sli.Mark_Up__c = sli.Cost_Year__c * sli.Mark_Up_VAT__c / 100;
                    sli.Selling_Price__c = sli.Cost_Year__c + sli.Mark_Up__c;
                }
            }
        }

        return null;

    }

    public PageReference SubmitForApproval() {
        try {
            List<Summary_Details__c> summaryLineItems = new List<Summary_Details__c>();
            for (CostingEntity ce : CostingSummaryList) {
                Costing_Summary__c cs = ce.CostingSummary;
                if (cs.Opportunity__c == null) {
                    cs.Opportunity__c = opp.Id;
                }
                cs.Submit_For_Approval__c = true;
                upsert cs;
            }
        } catch (Exception e) {

        }


        return null;
    }
    public PageReference GotoCostingSummary() {
        return new PageReference('/' + CostingSummaryId);
    }
    public PageReference Nothing() {
        System.debug('Testing');
        return new PageReference('/' + opp.Id);
//        return null;
    }

    public void setTabBooleans(Integer tabNumber) {
        pageMessages.clear();
        showMapPowerCtc = false;
        showMapPowerRequirement = false;
        showSPAndConsumables = false;
        showToolsAndEquip = false;
        showSSM = false;
        showOtherExpenses = false;
        showSummary = false;
        switch on tabNumber {
            when 1 {
                showMapPowerCtc = true;
            }
            when 2 {
                showMapPowerRequirement = true;
            }
            when 3 {
                showSPAndConsumables = true;
            }
            when 4 {
                showToolsAndEquip = true;
            }
            when 5 {
                showSSM = true;
            }
            when 6 {
                showOtherExpenses = true;
            }
            when 7 {
                showSummary = true;
            }

        }
    }
    public void setTabBooleans() {
        isSuccessful = true;
        switch on tabNumber {
            when 2 {
                SaveManpowerCTC();
            }
            when 3 {
                SaveManpowerRequirement();
                SPAndConsumablesList = new List<CostingSheetController.CostingEntity>();
                if (showIdama) {
                    SPAndConsumablesList.add(FetchEntity(Idama, 'SP & Consumables'));
                }

                if (showArkan) {
                    SPAndConsumablesList.add(FetchEntity(Arkan, 'SP & Consumables'));
                }


            }
            when 4 {
                SaveSPAndConsumables();
                if (ToolsAndEquipList == null || ToolsAndEquipList.size() == 0) {
                    if (showIdama) {
                        ToolsAndEquipList.add(FetchEntity(Idama, 'Tools & Equip'));
                    }
                    if (showArkan) {
                        ToolsAndEquipList.add(FetchEntity(Arkan, 'Tools & Equip'));
                    }
                }
            }
            when 5 {
                SaveToolsAndEquip();
                if (SSMList == null || SSMList.size() == 0) {
                    if (showIdama) {
                        SSMList.add(FetchEntity(Idama, 'SSM'));
                    }
                    if (showArkan) {
                        SSMList.add(FetchEntity(Arkan, 'SSM'));
                    }
                }
            }
            when 6 {
                SaveSSM();
                if (OtherExpensesList == null || OtherExpensesList.size() == 0) {
                    if (showIdama) {
                        OtherExpensesList.add(FetchEntity(Idama, 'Other Expenses'));
                    }
                    if (showArkan) {
                        OtherExpensesList.add(FetchEntity(Arkan, 'Other Expenses'));
                    }
                }
            }
            when 7 {
                SaveOtherExpenses();
                CostingSummaryList = CreateCostingSummary();
            }
        }
        if (isSuccessful)
            setTabBooleans(tabNumber);
    }

    public void setTab() {
        switch on tabNumber {

            when 2 {
                SaveManpowerCTC();
            }
            when 3 {
                SaveManpowerCTC();
                SPAndConsumablesList = new List<CostingSheetController.CostingEntity>();
                if (showIdama) {
                    SPAndConsumablesList.add(FetchEntity(Idama, 'SP & Consumables'));
                }
                if (showArkan) {
                    SPAndConsumablesList.add(FetchEntity(Arkan, 'SP & Consumables'));
                }

            }
            when 4 {
                if (ToolsAndEquipList == null || ToolsAndEquipList.size() == 0) {
                    if (showIdama) {
                        ToolsAndEquipList.add(FetchEntity(Idama, 'Tools & Equip'));
                    }
                    if (showArkan) {
                        ToolsAndEquipList.add(FetchEntity(Arkan, 'Tools & Equip'));
                    }
                }
            }
            when 5 {
                if (SSMList == null || SSMList.size() == 0) {
                    if (showIdama) {
                        SSMList.add(FetchEntity(Idama, 'SSM'));
                    }
                    if (showArkan) {
                        SSMList.add(FetchEntity(Arkan, 'SSM'));
                    }
                }
            }
            when 6 {
                if (OtherExpensesList == null || OtherExpensesList.size() == 0) {
                    if (showIdama) {
                        OtherExpensesList.add(FetchEntity(Idama, 'Other Expenses'));
                    }
                    if (showArkan) {
                        OtherExpensesList.add(FetchEntity(Arkan, 'Other Expenses'));
                    }
                }
            }
            when 7 {
                CostingSummaryList = CreateCostingSummary();
            }
        }
        setTabBooleans(tabNumber);
    }

    public void fetchOppLineItems() {
        mapOppLineItems = new Map<Id, OpportunityLineItem>();
        mapPricebookEntries = new Map<Id, PricebookEntry>();
        try {
            for (OpportunityLineItem opli : [
                    SELECT Id, Name__c, Name, Discount, Discount__c, Product2Id, Quantity, Description, UnitPrice__c, UnitPrice, Remarks__c, CTC_Month__c, Annual_Cost__c,
                            Cost_Month__c, Cost_Year__c, Depreciation_Year__c, Supplier_Name__c, PPM_Frequency_Year__c, Scope__c, Threshold__c,
                            Source_of_Quotation__c, Month__c, Mark_Up__c, Selling_Price__c, Lump_Sum__c, Free_Entry__c,Price_Editable__c
                    from OpportunityLineItem
                    where OpportunityId = :opp.Id
            ]) {
                mapOppLineItems.put(opli.Product2Id, opli);
            }
            for (PricebookEntry pe : [
                    SELECT Id, Product2Id
                    from PricebookEntry
            ]) {
                mapPricebookEntries.put(pe.Product2Id, pe);
            }
        } catch (Exception e) {
        }

    }

    Public class CostingEntity {
        public String EntityName {
            get;
            set;
        }
        public Costing_Summary__c CostingSummary {
            get;
            set;
        }
        public List<Schema.FieldSetMember> FieldSet {
            get;
            set;
        }
        public List<ProductCategory> CategoryList { get; set; }

        public CostingEntity() {

        }

    }
    public class ProductCategory {
        public String Category {
            get;
            set;
        }
        public Decimal totalQuantity {
            get;
            set;
        }
        public Decimal totalMonthCTC {
            get;
            set;
        }
        public Decimal totalAnnualCTC {
            get;
            set;
        }
        public Decimal totalSellingPrice {
            get;
            set;
        }
        public List<Product2> ProductsList {
            get;
            set;
        }
        public List<OpportunityLineItem> OppsLineItemsList {
            get;
            set;
        }
        public List<Summary_Details__c> SummaryLineItemsList {
            get;
            set;
        }

    }

    public class SummaryCost {
        public String categoryName ;
        public Decimal ctcMonth ;
        public Decimal annualCost ;
        public Decimal costMonth ;
        public Decimal costYear ;

    }

}