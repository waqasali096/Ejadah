@isTest
public class SaveAsPdfExtensionTest {
    
    static testMethod void Tests() {
        
        Test.startTest();
        SaveAsPdfExtension controller = new SaveAsPdfExtension(null);
        
        String test1 = controller.renderedContentType;
        controller.saveToPdf();
        controller.renderingAsHtml();
        controller.sanitizeFileName('test');
        controller.renderedFileName = 'hello';
        String test2 = controller.renderedFileName ;
                String test4 = controller.renderedContentType;

        String test3 = controller.renderingService ;
        Test.stopTest();
        
    }
    
}