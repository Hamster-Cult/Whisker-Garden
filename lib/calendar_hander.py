import asyncio
import icalendar
from icalendar import Calendar
from pathlib import Path

async def getCalendarEvents():
    events = []
    ics_path = Path('./assets/example.ics')
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

async def main():
    events = await getCalendarEvents()
    for event in events:
        print(event)

if __name__ == '__main__':
    asyncio.run(main())