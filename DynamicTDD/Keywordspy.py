import pycurl
import random
try:
    from io import StringIO  ## for Python 3
except ImportError:
    from StringIO import StringIO ## for Python 2
import json
import datetime
HOST='54.215.5.201:8181'
BASE_URL='http://'+HOST+'/superadmin/rest/mgmt'
csv='TDD/data.csv'

def makeaccount(sector,subSector):
    c = pycurl.Curl()
    buffer = StringIO()
    url = BASE_URL + '/account/makeAccount'
    c.setopt(c.POST, 1)
    c.setopt(c.USERAGENT, 'Curl')
    #    c.setopt(c.VERBOSE, 1)

    c.setopt(c.URL, url)
    c.setopt(c.WRITEDATA, buffer)
    c.setopt(c.COOKIEFILE, 'cookies.txt')
    c.setopt(c.HTTPHEADER, ['Content-Type: multipart/form-data'])
    data = [
        ('sector', sector), 
        ('subSector', subSector),
        ('files', (
            c.FORM_FILE, csv,
	    c.FORM_CONTENTTYPE, 'text/csv'            )) 
        ] 
           
    c.setopt(c.HTTPPOST, data)
    c.perform()
    resp=buffer.getvalue()
    code= c.getinfo(c.RESPONSE_CODE)
    c.close()
    if resp == 'Session Expired' :
	    return code
    else :
	    return  json.loads(resp),code

def pysuperadminlogin(email,pswd):
    buffer = StringIO()
    url = BASE_URL+'/login'
    data = json.dumps({"loginId": str(email), "password":str(pswd), "secondPassword":str(second_password())})
    c = pycurl.Curl()
    c.setopt(c.URL, url)
    c.setopt(c.HTTPHEADER, ['Content-type: application/json','Accept: application/json'])
    c.setopt(c.POSTFIELDS, data)
    c.setopt(c.COOKIEJAR, 'cookies.txt')
    c.perform()
    resp=buffer.getvalue()
    code= c.getinfo(c.RESPONSE_CODE)
    c.close()
    return code



def second_password():
    try:
        t = datetime.datetime.now().time() 
        if t <= datetime.time(hour=12) :
            return 'morning'
        elif t <= datetime.time(hour=16) :
            return 'afternoon'
        elif t <= datetime.time(hour=19) :
            return 'evening'
        elif t <= datetime.time(hour=23,minute=59) :
            return 'night'
    except:
        return 0



def support_secondpassword():
    try:
        t = datetime.datetime.now().time()
        if t <= datetime.time(hour=12) :
                return 'breakfast'
        elif t <= datetime.time(hour=16) :
                return 'lunch'
        elif t <= datetime.time(hour=19) :
                return 'cupoftea'
        elif t <= datetime.time(hour=23,minute=59) :
                return 'dinner'
    except:
        return 0

def create_tz(tz):
    try:
        zone, *loc = tz.split('/')
        loc = random.choice(loc)
        return (zone+'/'+loc)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

