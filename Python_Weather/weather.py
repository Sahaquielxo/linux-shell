#!/usr/bin/python

#You should not run this script more then 1 time per 10 minutes.
#If you will, I will get restrict for the requests, and ban for 24h next.
#Used API from https://openweathermap.org/api

import json
import requests
import time
import datetime 

def WeatherCheck():
    retdict = {}
    url='api.openweathermap.org/data/2.5/weather'
    CITY_ID='524901' #Moscow
    API_KEY='1ae45d04ee34f34b90b82f7cbad5553a' #@sahaquielx

    payload = {'id': CITY_ID, 'APPID': API_KEY, 'units': 'metric' }
    r = requests.get('http://api.openweathermap.org/data/2.5/weather', params=payload)

    resp = (r.json())
    
    #begins from lowercase letter, will replace
    preWeatherGroup = resp['weather'][0]['description'] 
    #Snow/Wind/Rain/etc.
    WeatherGroup = str(preWeatherGroup.replace(preWeatherGroup[0], preWeatherGroup[0].upper(), 1)) 
    #Temperature in Celsius.
    Temperature = str(resp['main']['temp'])
    #Humidity in percents.
    Humidity = str(resp['main']['humidity'])
    #Wind Speed in meter/sec.
    WindSpeed = str(resp['wind']['speed']) 
    #Cloudiness in percents.
    Cloudiness = str(resp['clouds']['all']) 
    #Date in YYYY-mm-dd HH:MM:SS format.
    Datenow = str(datetime.datetime.fromtimestamp(int(resp['dt'])).strftime('%Y-%m-%d %H:%M:%S'))
    #Pressure in millimeter of mercury.
    Pressure = str(int(resp['main']['pressure']) * 0.75) 

#Output format:
#Datenow, Temperature, WeatherGroup, WindSpeed, Humidity, Cloudiness, Pressure
#Example:
#['2017-11-22 19:00:00', '-1.5', 'Light snow', '7', '74', '90', '756.75']
    
    retdict = {'Date': Datenow, 'Temp': Temperature, 'Weather': WeatherGroup, 'WindSpeed': WindSpeed, 'Humidity': Humidity, 'Cloudiness': Cloudiness, 'Pressure': Pressure}
    print (retdict)
    return retdict

WeatherCheck()
