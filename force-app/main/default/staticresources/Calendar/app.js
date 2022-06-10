/* global
  $
  PARAMETERS
  FullCalendar
  CalendarController
*/

/* eslint
  no-unused-vars: "warn",
  no-empty: "off"
*/

(function() {
  'use strict';

  const ELEMENT = document.getElementById('calendar');

  let CALENDAR;
  let businessHours = [];

  let eventSource = {
    id: 'events',
    display: 'block',
    color: PARAMETERS.eventColor,
    events: function(info, onSuccess, onFailure) {
      CalendarController.getEvents(
        PARAMETERS.calendarId,
        info.start.getTime(),
        info.end.getTime(),
        (response, event) => {
          if (event.status) {
            onSuccess(response);
          } else {
            onFailure(event);
          }
        }
      );
    },
    success: function(response) {
      return response.map(v => {
        return {
          id: v.Id,
          start: v.StartDateTime,
          end: v.EndDateTime,
          title: v.Subject || v.Description,
          allDay: v.IsAllDayEvent
        };
      });
    },
    failure: function(event) {
      // showAlert(event.type, event.message);
    }
  };

  let holidaySource = {
    id: 'holidays',
    display: 'block',
    color: 'purple',
    events: function(info, onSuccess, onFailure) {
      CalendarController.getHolidays(
        info.start.getTime(),
        info.end.getTime(),
        (response, event) => {
          if (event.status) {
            onSuccess(response);
          } else {
            onFailure(event.message);
          }
        }
      );
    },
    success: function(response) {
      return Object.keys(response).map(v => {
        return {
          id: response[v].Id,
          start: parseInt(v) + getTzo(v), // dont want fullcal to parse these with timezone
          title: decodeHtml(response[v].Name),
          allDay: response[v].IsAllDay,
          isEditable: false //# this is not available in the eventClick???
        };
      });
    },
    failure: function(event) {
      // showAlert(event.type, event.message);
    }
  };

  const CONFIG = {
    allDaySlot: PARAMETERS.allDaySlot,
    businessHours: businessHours,
    buttonText: {
      today: 'Today',
      month: 'Month',
      week: 'Week',
      day: 'Day',
      list: 'List'
    },
    dayMaxEventRows: true,
    dayPopoverFormat: {
      day: 'numeric',
      month: 'long',
      weekday: 'long'
    },
    defaultTimedEventDuration: '00:30:00',
    editable: PARAMETERS.editable,
    eventClick: onEventClick,
    eventDrop: onEventDropResize,
    eventResize: onEventDropResize,
    eventDurationEditable: PARAMETERS.editable,
    eventSources: [
      eventSource,
      holidaySource
    ],
    forceEventDuration: true,
    handleWindowResize: true,
    headerToolbar: {
      left: 'prev,next today',
      center: 'title',
      right: 'dayGridMonth,timeGridWeek,timeGridDay,listMonth'
    },
    height: '100%',
    initialDate: new Date(),
    initialView: PARAMETERS.initialView,
    moreLinkClick: 'popover',
    navLinks: true,
    nowIndicator: true,
    select: onSelect,
    selectable: PARAMETERS.selectable,
    slotMinTime: PARAMETERS.minTimeSlot,
    slotMaxTime: PARAMETERS.maxTimeSlot,
    themeSystem: 'bootstrap',
    weekNumbers: PARAMETERS.weekNumbers
  };

  //* Business hours

  function getBusinessHours() {
    return new Promise((resolve, reject) => {
      CalendarController.getBusinessHours(
        PARAMETERS.businessHoursId,
        (response, event) => {
          if (event.status) {
            resolve(response);
          } else {
            reject(event);
          }
        }
      );
    });
  }

  function setBusinessHours(r) {
    businessHours.push(
      {
        daysOfWeek: [0],
        startTime: convertValue(r.SundayStartTime),
        endTime: convertValue(r.SundayEndTime)
      },
      {
        daysOfWeek: [1],
        startTime: convertValue(r.MondayStartTime),
        endTime: convertValue(r.MondayEndTime)
      },
      {
        daysOfWeek: [2],
        startTime: convertValue(r.TuesdayStartTime),
        endTime: convertValue(r.TuesdayEndTime)
      },
      {
        daysOfWeek: [3],
        startTime: convertValue(r.WednesdayStartTime),
        endTime: convertValue(r.WednesdayEndTime)
      },
      {
        daysOfWeek: [4],
        startTime: convertValue(r.ThursdayStartTime),
        endTime: convertValue(r.ThursdayEndTime)
      },
      {
        daysOfWeek: [5],
        startTime: convertValue(r.FridayStartTime),
        endTime: convertValue(r.FridayEndTime)
      },
      {
        daysOfWeek: [6],
        startTime: convertValue(r.SaturdayStartTime),
        endTime: convertValue(r.SaturdayEndTime)
      }
    );
    // salesforce returns 0 for all day and null/undefined for no hours
    // so we need to convert this to something fullcalendar understands
    function convertValue(value) {
      // a business hour thats undefined should be blocked all day (No Hours)
      if (value === undefined) {
        return 0;
      }
      // a business hour thats 0 should be available all day (24 Hours)
      if (value === 0) {
        return null;
      }
      return value
    }
  }

  //* Fullcalendar events

  function onEventClick(info) {
    if (!CONFIG.editable) {
      return;
    }
    if (info.event.extendedProps.isEditable !== false) {
      showModal(info);
    }
  }

  function onEventDropResize(info) {
    let id = info.event.id;
    let title = info.event.title;
    let startTs = info.event.start.getTime();
    let endTs = info.event.end.getTime();
    updateEvent(id, title, startTs, endTs)
      .catch(e => {
        info.revert();
        showAlert(e.type, e.message);
      });
  }

  function onSelect(info) {
    console.dir(info);
    if (!CONFIG.selectable) {
      return;
    }
    // no business hours just show the modal
    if (businessHours.every(v => !v.startTime && !v.endTime)) {
      showModal(info);
      return;
    }
    let startDay = info.start.getDay();
    let startHour = info.start.getHours();
    let businessHour = businessHours.find(v => v.daysOfWeek[0] === startDay);
    if (startHour >= getHour(businessHour.startTime) && startHour < getHour(businessHour.endTime)) {
      showModal(info);
    }
  }

  //* Create/update events

  function createEvent(title, startTs, endTs) {
    return new Promise((resolve, reject) => {
      CalendarController.createEvent(
        title, startTs, endTs,
        (response, event) => {
          if (event.status) {
            CALENDAR.addEvent({
              id: response.Id,
              start: response.StartDateTime,
              end: response.EndDateTime,
              title: response.Subject
            });
            CALENDAR.render();
            resolve(response);
          } else {
            reject(event);
          }
        }
      );
    });
  }

  function updateEvent(id, title, startTs, endTs) {
    return new Promise((resolve, reject) => {
      CalendarController.updateEvent(
        id, title, startTs, endTs,
        (response, event) => {
          if (event.status) {
            let e = CALENDAR.getEvents().find(a => a.id === id);
            e.setDates(startTs, endTs);
            e.setProp('title', title);
            resolve(response);
          } else {
            reject(event);
          }
        }
      );
    });
  }

  //* Utilities

  function decodeHtml(html) {
    let txt = document.createElement('textarea');
    txt.innerHTML = html;
    return txt.value;
  }

  function getTzo(ms) {
    let date = ms ? new Date(parseInt(ms)) : new Date();
    return date.getTimezoneOffset() * 60000;
  }

  function getHour(ms) {
    return (parseInt(ms) / 1000 / 60 / 60);
  }

  function showModal(info) {
    info = info.event || info;
    let startTs = info.start.getTime();
    let endTs = info.end.getTime();
    $('#title').val(info.title);
    $('#starts-at')[0].valueAsNumber = startTs - getTzo(startTs); // to local time
    $('#ends-at')[0].valueAsNumber = endTs - getTzo(endTs);
    $('.modal').modal('show');
    $('#title').focus();
    $('#save-button').attr('data-id', info.id);
  }

  function showAlert(title, message) {
    $('#alert-title').text(title);
    $('#alert-message').text(message);
    $('.alert').css('display', 'block');
  }

  //* Initialize

  document.addEventListener('DOMContentLoaded', function() {
    getBusinessHours()
      .then(r => {
        setBusinessHours(r);
        CALENDAR = new FullCalendar.Calendar(ELEMENT, CONFIG);
        CALENDAR.render();
      })
      .catch(e => {
        showAlert(e.type, e.message);
      });
  });

  //* Listeners

  $('#alert-dismiss').on('click', function(e) {
    e.preventDefault();
    $('.alert').css('display', 'none');
  });

  $('#save-button').on('click', function(e) {
    e.preventDefault();
    let id = $('#save-button').attr('data-id') || null;
    let title = $('#title').val();
    let startTs = $('#starts-at')[0].valueAsNumber + getTzo(); // back to utc
    let endTs = $('#ends-at')[0].valueAsNumber + getTzo();
    if (!id) {
      createEvent(title, startTs, endTs)
        .then(() => $('.modal').modal('hide'))
        .catch(e => showAlert(e.type, e.message));
    } else {
      updateEvent(id, title, startTs, endTs)
        .then(() => $('.modal').modal('hide'))
        .catch(e => showAlert(e.type, e.message));
    }
  });

  //* Interval

  setInterval(() => {
    CALENDAR.refetchEvents();
  }, 5 * 60 * 1000);

}());