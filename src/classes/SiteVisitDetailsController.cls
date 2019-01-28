/**
 * Created by Pravin Chaudhari on 10-09-2018.
 */

public with sharing class SiteVisitDetailsController {

    public Opportunity opp { get; set; }
    Public Site_Visit__c SV {get; set;}

    public List <Site_Visit_Detail_List__c> SftSrvc { get; set; }
    public List <Site_Visit_Detail_List__c> AssrtSystm { get; set; }

    Public List<Site_Visit_Details__c> SVDLST { get; set;}
    Public List<Site_Visit_Details__c> Srvc { get; set;}

    Public Site_Visit_Details__c SVDLSTNM { get; set;}
    Public Site_Visit_Details__c SVDLSTSrvc { get; set;}

    public boolean showAsInput {get;set;}
    public boolean showAsOutput {get;set;}
    public boolean RenderAsPDF {get;set;}

    public String renderingService { get; private set; }

    Public Id svId {get;set;}
    Public Id OppID {get;set;}
    Public Id SvidPdf {get;set;}

    Public  String Entity  {get;set;}
    Public  Boolean Edit  {get;set;}
    //Version no
    //-----------------
    Public  String OppName  {get;set;}
    Public  String SV_Name  {get;set;}
     public List <Site_Visit__c> DocNo { get; set; }
    //--------------

    Public Set<Id> SVdetails {get;set;}

    Public String Category  {get;set;}

    public SiteVisitDetailsController(ApexPages.standardController sc) {


        if(apexpages.currentpage().getparameters()!=null && apexpages.currentpage().getparameters().get('oppid')!=null){
            OppID= apexpages.currentpage().getparameters().get('oppid');

           Entity = [Select Entity__c from Opportunity where ID = :apexpages.currentpage().getparameters().get('oppid') limit 1].Entity__c;
            
           OppName = [Select ID,Name from Opportunity where ID = :apexpages.currentpage().getparameters().get('oppid') limit 1].Name; 
            
           	DocNo =	[Select ID from Site_Visit__c where Opportunity__c = :apexpages.currentpage().getparameters().get('oppid')] ;
//
        }

        svId = sc.getId();

        If (svId != Null ){
            showAsInput = false ;
            showAsOutput = true;
            RenderAsPDF = true;
            Edit = true;

             SV = [Select 	XBR_1BR_Apartment__c,XBR_2BR_Apartment__c,XBR_3BR_Apartment__c,
                    Age_of_Building__c,Any_Restriction_for_Gender_of_Technician__c,Cleaning_Chemicals__c,Cleaning_Chemicals_Quantities__c,
                    Condition_of_Building__c,Consumables_Cost__c,Consumables_Quantities__c,Contact_details_of_Sup_Tech_at_site__c,
                    CreatedById,CurrencyIsoCode,Date_of_Visit__c,Dispensers_for_Toiletries_Installed__c,Equipment_Required__c,
                    General_Observations_Remarks__c,LastModifiedById,Location__c,Name,Name_of_the_building__c,No_Of_Female_Toilets_Cubicles__c,
                    No_of_Floors__c,No_Of_Male_Toilets_Cubicles__c,No_Of_Offcs_for_OffcMixed_Use_Bldg__c,No_Of_Tech_Suggstd_by_Vstr_to_run_Opn__c,
                    No_of_Technicians_Currently_on_site__c,No_of_Visitors_Foot_Fall_Day__c,Opportunity__c,Site_Visit_Name__c,
                    Size_of_Building_SQM_Approx__c,Studio_Apartment__c,Type_of_Cooling_System_Installed__c,Type_of_Floor__c,Working_Hours__c,Others__c,
                    User__c,Entity__c,Big_Remark__c,Building_Type__c,Other_BuildingnType__c ,User__r.Name,Contact_details_of_Sup_Tech_at_site__r.Name
             From Site_Visit__c where Id = :svId];


            SVDLST = [Select 	Capacity__c,CreatedById,CurrencyIsoCode,LastModifiedById, Make__c,Name,Name_of_Existing_Subcontractor__c,
                        No_of_Existing_Staff__c,No_of_Skips_for_WM__c,Present_at_Site_Yes_No__c,Quantity__c,Removal_Frequency_for_WM__c,
                        Site_Visit__c,Size_of_Skips_for_WM__c,Working_Hours__c
            From Site_Visit_Details__c where Site_Visit__c = :svId and Category__c = 'SpecializedSubcontractors'];


            Srvc = [Select 	Capacity__c,CreatedById,CurrencyIsoCode,LastModifiedById, Make__c,Name,Name_of_Existing_Subcontractor__c,
                    No_of_Existing_Staff__c,No_of_Skips_for_WM__c,Present_at_Site_Yes_No__c,Quantity__c,Removal_Frequency_for_WM__c,
                    Site_Visit__c,Size_of_Skips_for_WM__c,Working_Hours__c
            From Site_Visit_Details__c where Site_Visit__c = :svId  and Category__c = 'SoftService'];


        }else {

            showAsInput = true ;
            showAsOutput = false ;
            RenderAsPDF = false;
            Edit = false;

             Opp = [Select ID,Name,AccountId,Entity__c from Opportunity where ID = :OppID limit 1];

            AssrtSystm =[select name from Site_Visit_Detail_List__c where Category__c = 'Asset/System Name' order by Display_Order__c Asc];
            SftSrvc =[select name from Site_Visit_Detail_List__c where Category__c = 'Service Name' order by Display_Order__c Asc];

            SV = New Site_Visit__c(Opportunity__c = opp.id);
           // Entity = opp.Entity__c;

            SVDLST = new list<Site_Visit_Details__c>();
            Srvc = new list<Site_Visit_Details__c>();

            For (Site_Visit_Detail_List__c Svd : AssrtSystm){
                SVDLSTNM = new Site_Visit_Details__c ();
                SVDLSTNM.Name = Svd.name;
                SVDLSTNM.Category__c = 'SpecializedSubcontractors';
                SVDLST.add(SVDLSTNM);
           }

            For (Site_Visit_Detail_List__c Svd : SftSrvc){
                SVDLSTSrvc = new Site_Visit_Details__c ();
                SVDLSTSrvc.Name = Svd.name;
                SVDLSTSrvc.Category__c = 'SoftService';
                Srvc.add(SVDLSTSrvc);
            }

        }

    }

    public PageReference SaveItem() {
        try {

          
            If (SV.Other_BuildingnType__c == 'Others' && String.isBlank(SV.Other_BuildingnType__c)  == true ){
                ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, 'Please enter value for Other Building Type') );
                         
            }
            
            
              if (DocNo != Null){
                  	SV_Name = 'SV-'+ OppName +'-'+ 'V.1.'+DocNo.size();
                  SV.Name = SV_Name;
                   
                }else
                {
                    SV_Name = 'SV-'+ OppName+'-'+ 'V.1.0';
                    SV.Name = SV_Name;
                   
                    
                }

            If (svId == Null && Edit == false ){

                if (Entity != Null){
                    SV.Entity__c=Entity;
                }

                Upsert SV;

               SvidPdf = SV.id;

                For (Site_Visit_Details__c Svd : SVDLST){
                    Svd.Site_Visit__c = SV.id;
                }

                For (Site_Visit_Details__c Svd : Srvc){
                    Svd.Site_Visit__c = SV.id;
                }

                Upsert SVDLST;
                Upsert  Srvc;

            }else {

               // SvidPdf = SV.id;

                SV.Entity__c=Entity;

                Upsert SV;
                Upsert SVDLST;
                Upsert  Srvc;
            }


            showAsInput =false  ;
            showAsOutput = true ;
            RenderAsPDF = true;
            Edit = false;


//            PageReference ref = new PageReference('/' + SV.Id);
//            return ref;

//
//                    If (OppID != null){
//                        PageReference ref = new PageReference('/apex/VisitDetails?Id='+SV.id+'&oppid'+ OppID);
//                        ref.setRedirect(true);
//                        return ref;
//                    }else {
//                        PageReference ref = new PageReference('/apex/VisitDetails?Id='+SV.id+'&oppid'+ OppID);
//                        ref.setRedirect(true);
//                        return ref;
//                    }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, e.getMessage()+ '' + e.getLineNumber() ));
            System.debug('' + e.getMessage());
        }
        return null;
    }


    public PageReference EditRecord() {
        try {

            showAsInput = true ;
            showAsOutput = false ;
            RenderAsPDF = false;
            Edit = true;


        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPAges.Severity.ERROR, e.getMessage()+ '' + e.getLineNumber() ));
            System.debug('' + e.getMessage());
        }
        return null;
    }


    public PageReference saveToPdf() {
        PageReference ref ;

        If (SvidPdf != Null){
            ref = new PageReference('/apex/VisitDetailsPDF?Id='+SvidPdf );
        }else
        {
             ref = new PageReference('/apex/VisitDetailsPDF?Id='+svId );
        }

        ref.setRedirect(true);
        return ref;
    }

    public PageReference cancel() {
        PageReference ref = new PageReference('/' + OppID );
        //ref.setRedirect(true);
        return ref;
    }

}