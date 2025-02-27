import asyncio
import icalendar
from icalendar import Calendar
from pathlib import Path


ics_path = Path('./assets/example.ics')


# get all events from the calendar with their start/end time and desctiption
async def getCalendarEvents():
    events = []
    with ics_path.open('r') as file:
        calendar = Calendar.from_ical(file.read())
    for event in calendar.walk('vevent'):
        events.append({
            'summary': str(event.get('summary')),
            'start': event.get('dtstart').dt,
            'end': event.get('dtend').dt,
            'description': str(event.get('description'))
        })
    return events


# add a new event/log to the calendar
async def addEventToCalendar(summary, start, end, description):
    with ics_path.open('r') as file:
        calendar = Calendar.from_ical(file.read())
    event = icalendar.Event()
    event.add('summary', summary)
    event.add('dtstart', start)
    event.add('dtend', end)
    event.add('description', description)
    calendar.add_component(event)
    with ics_path.open('wb') as file:
        file.write(calendar.to_ical())    


async def main():
    events = await getCalendarEvents()
    for event in events:
        print(event)
        print(event['start'].strftime('%Y-%m-%d %H:%M:%S')) # format the date yyyy-mm-dd hh:mm:ss

    asd = input('summary: ')
    asd2 = input('start: ')
    asd3 = input('end: ')
    asd4 = input('description: ')
    await addEventToCalendar(asd, asd2, asd3, asd4)

    
    events = await getCalendarEvents()
    for event in events:
        print(event)
        print(event['start'].strftime('%Y-%m-%d %H:%M:%S')) # format the date yyyy-mm-dd hh:mm:ss    

if __name__ == '__main__':
    asyncio.run(main())