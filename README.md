# sf-calendar

A configurable drop-in calendar for Salesforce.

# Prerequisites

* Grab my [apex-core-utils](https://github.com/MJ12358/apex-core-utils) (HolidayUtil is necessary)
* Deploy using the button below
* Assign the "Calendar" permission set to anyone who needs access

# Deploy

<a href="https://githubsfdeploy.herokuapp.com?owner=MJ12358&repo=sf-calendar&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

# Usage

* In the lightning app builder, edit the page of your choice
* Find the "Calendar" component under "Custom"
* Drag and drop it on the page

# Configuration

* You can configure the following:
  - Business Hours
  - The calendar to show (defaults to the current user)
  - The height of the calendar
  - The initial view (defaults to "dayGridMonth")
  - The all day slot
  - Whether the calendar is editable
  - Whether the calendar is selectable
  - Whether to show week numbers
  - The minimum time slot shown
  - The maximum time slot shown

# Images

![Screenshot](images/Capture.PNG)

## View by Week

![Screenshot_Week_View](images/Capture_Week_View.PNG)

## View by Day

![Screenshot_Day_View](images/Capture_Day_View.PNG)

## Customize your event colors

![Screenshot_Custom_Color](images/Capture_Custom_Color.PNG)

## All customizations

![Screenshot_Customizations](images/Capture_Customizations.PNG)
