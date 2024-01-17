/**
 * Created on Jan 5 2021
 *
 * Copyright (c) 2021 MJ12358
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *    are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *    this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *    this list of conditions and the following disclaimer in the documentation 
 *    and/or other materials provided with the distribution.
 * - Neither the name of the company, software or the names of its contributors 
 *    may be used to endorse or promote products derived from this software without 
 *    specific prior written permission.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 *  TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, TORT (INCLUDING NEGLIGENCE) OR OTHERWISE, 
 *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE USE OF THIS SOFTWARE OR OTHER DEALINGS IN THE SOFTWARE, 
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

/**
 *  This class and its methods must be "global"
 *    this is because the VF page is inside of an iframe
 *    https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_js_remoting_scope_visibility.htm
 */

global with sharing class CalendarController {

  @RemoteAction
  global static BusinessHours getBusinessHours(Id recordId) {
    return [
      SELECT Id, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, 
        TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, 
        ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, 
        SaturdayStartTime, SaturdayEndTime 
      FROM BusinessHours 
      WHERE Id = :recordId 
      LIMIT 1
    ];
  }

  @RemoteAction
  global static Map<Date, Holiday> getHolidays(Long startTs, Long endTs) {
    Datetime startDate = Datetime.newInstance(startTs);
    Datetime endDate = Datetime.newInstance(endTs);
    return HolidayUtil.getBetweenDates(startDate, endDate);
  }

  @RemoteAction
  global static List<Event> getEvents(String calendarId, Long startTs, Long endTs) {
    Id ownerId;

    if (calendarId == 'currentuser') {
      ownerId = System.UserInfo.getUserId();
    } else {
      ownerId = calendarId;
    }

    Datetime startDate = Datetime.newInstance(startTs);
    Datetime endDate = Datetime.newInstance(endTs);

    return [
      SELECT Subject, Description, StartDateTime, EndDateTime, IsAllDayEvent, Type 
      FROM Event 
      WHERE (StartDateTime >= :startDate AND EndDateTime <= :endDate) AND OwnerId = :ownerId
    ];
  }

  @RemoteAction
  global static Event createEvent(String title, Long startTs, Long endTs) {
    Event evt = new Event();
    evt.StartDateTime = Datetime.newInstance(startTs);
    evt.EndDateTime = Datetime.newInstance(endTs);
    evt.Subject = title;
    insert evt;
    return evt;
  }
  
  @RemoteAction
  global static void updateEvent(Id recordId, String title, Long startTs, Long endTs) {
    Event evt = [SELECT StartDateTime, EndDateTime, Subject FROM Event WHERE Id = :recordId];
    evt.StartDateTime = Datetime.newInstance(startTs);
    evt.EndDateTime = Datetime.newInstance(endTs);
    evt.Subject = title;
    update evt;
  }

}