@IsTest
public class CalendarControllerTest {

  @TestSetup
  static void testSetup() {
    Event evt = new Event();
    evt.Subject = 'Test Event';
    evt.StartDateTime = Datetime.now().addHours(-1);
    evt.EndDateTime = Datetime.now().addHours(1);
    insert evt;
  }

  @IsTest
  static void testGetBusinessHours() {
    Id recordId = [SELECT Id FROM BusinessHours WHERE IsDefault = true].Id;
    Test.startTest();
    BusinessHours result = CalendarController.getBusinessHours(recordId);
    Test.stopTest();
    System.assertNotEquals(null, result);
  }

  @IsTest
  static void testGetHolidays() {
    Long startTs = Datetime.now().addYears(-1).getTime();
    Long endTs = Datetime.now().getTime();
    Test.startTest();
    Map<Date, Holiday> result = CalendarController.getHolidays(startTs, endTs);
    Test.stopTest();
    System.assertNotEquals(null, result);
  }

  @IsTest
  static void testGetEvents() {
    Long startTs = Datetime.now().addMonths(-1).getTime();
    Long endTs = Datetime.now().addMonths(1).getTime();
    Test.startTest();
    List<Event> result = CalendarController.getEvents(System.UserInfo.getUserId(), startTs, endTs);
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertEquals(1, result.size());
  }

  @IsTest
  static void testSaveNewEvent() {
    Long startTs = Datetime.now().addHours(-1).getTime();
    Long endTs = Datetime.now().addHours(1).getTime();
    Test.startTest();
    Event result = CalendarController.saveEvent(null, 'Testing', startTs, endTs);
    Test.stopTest();
    System.assertEquals(2, [SELECT Count() FROM Event]);
    Event evt = [SELECT Id, StartDateTime, EndDateTime, Subject FROM Event ORDER BY CreatedDate DESC LIMIT 1];
    System.assertEquals(evt.Id, result.Id);
    System.assertEquals('Testing', result.Subject);
    System.assertEquals(evt.StartDateTime, result.StartDateTime);
    System.assertEquals(evt.EndDateTime, result.EndDateTime);
  }

  @IsTest
  static void testSaveExistingEvent() {
    Event evt = [SELECT Id, StartDateTime, EndDateTime, Subject FROM Event ORDER BY CreatedDate DESC LIMIT 1];
    Test.startTest();
    Event result = CalendarController.saveEvent(evt.Id, 'Testing', evt.StartDateTime.addHours(1).getTime(), evt.EndDateTime.addHours(1).getTime());
    Test.stopTest();
    System.assertEquals(1, [SELECT Count() FROM Event]);
    System.assertEquals(evt.Id, result.Id);
    System.assertEquals('Testing', result.Subject);
    System.assertEquals(evt.StartDateTime.addHours(1), result.StartDateTime);
    System.assertEquals(evt.EndDateTime.addHours(1), result.EndDateTime);
  }

  @IsTest
  static void testDesign() {
    VisualEditor.DesignTimePageContext ctx = new VisualEditor.DesignTimePageContext();
    Test.startTest();
    CalendarDesign cont = new CalendarDesign(ctx);
    VisualEditor.DynamicPickListRows rows = cont.getValues();
    VisualEditor.DataRow row = cont.getDefaultValue();
    Test.stopTest();
    System.assertNotEquals(null, rows);
    System.assertNotEquals(null, row);
  }

}
