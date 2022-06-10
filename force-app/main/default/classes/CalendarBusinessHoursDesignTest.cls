@IsTest
public class CalendarBusinessHoursDesignTest {

  @IsTest
  static void testSuccess() {
    VisualEditor.DesignTimePageContext ctx = new VisualEditor.DesignTimePageContext();
    Test.startTest();
    CalendarBusinessHoursDesign cont = new CalendarBusinessHoursDesign(ctx);
    VisualEditor.DynamicPickListRows rows = cont.getValues();
    VisualEditor.DataRow row = cont.getDefaultValue();
    Test.stopTest();
    System.assertNotEquals(null, rows);
    System.assertNotEquals(null, row);
  }

}