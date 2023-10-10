# import pycurl
import random
try:
    from io import StringIO  ## for Python 3
except ImportError:
    from StringIO import StringIO ## for Python 2
import json
import datetime
import requests
import traceback
import logging
import mimetypes
from robot.api import logger

HOST='54.215.5.201:8181'
BASE_URL='http://'+HOST+'/superadmin/rest/mgmt'
csv='TDD/data.csv'

def log_response(response):
    logger.info("%s Response : url=%s \n " % (response.request.method.upper(),
                                              response.url) +
                "status=%s, reason=%s \n " % (response.status_code,
                                              response.reason) +
                "headers=%s \n " % response.headers +
                "body=%s \n " % (response.text))


def log_request(response):
    request = response.request
    if response.history:
        original_request = response.history[0].request
        redirected = '(redirected) '
    else:
        original_request = request
        redirected = ''
    logger.info("%s Request : " % original_request.method.upper() +
                "url=%s %s\n " % (original_request.url, redirected) +
                "path_url=%s \n " % original_request.path_url +
                "headers=%s \n " % original_request.headers +
                "body=%s \n " % (original_request.body))

# def makeaccount(sector,subSector):
#     c = pycurl.Curl()
#     buffer = StringIO()
#     url = BASE_URL + '/account/makeAccount'
#     c.setopt(c.POST, 1)
#     c.setopt(c.USERAGENT, 'Curl')
#     #    c.setopt(c.VERBOSE, 1)

#     c.setopt(c.URL, url)
#     c.setopt(c.WRITEDATA, buffer)
#     c.setopt(c.COOKIEFILE, 'cookies.txt')
#     c.setopt(c.HTTPHEADER, ['Content-Type: multipart/form-data'])
#     data = [
#         ('sector', sector), 
#         ('subSector', subSector),
#         ('files', (
#             c.FORM_FILE, csv,
# 	    c.FORM_CONTENTTYPE, 'text/csv'            )) 
#         ] 
           
#     c.setopt(c.HTTPPOST, data)
#     c.perform()
#     resp=buffer.getvalue()
#     code= c.getinfo(c.RESPONSE_CODE)
#     c.close()
#     if resp == 'Session Expired' :
# 	    return code
#     else :
# 	    return  json.loads(resp),code

def makeaccount(cookie_dict,sector,subSector,csv_file=csv):
    s = requests.Session()
    url = BASE_URL+'/account/makeAccount'
    try:
        dom_dict = {"sector":str(sector), "subSector":str(subSector)}
        mimetype, encoding = mimetypes.guess_type(csv_file)
        data = {
        'files': (csv_file, open(csv_file, 'rb'), mimetype), 
        'captions': (None, json.dumps(dom_dict), 'application/json')
        }
    
        # print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

# def pysuperadminlogin(email,pswd):
#     buffer = StringIO()
#     url = BASE_URL+'/login'
#     data = json.dumps({"loginId": str(email), "password":str(pswd), "secondPassword":str(second_password())})
#     c = pycurl.Curl()
#     c.setopt(c.URL, url)
#     c.setopt(c.HTTPHEADER, ['Content-type: application/json','Accept: application/json'])
#     c.setopt(c.POSTFIELDS, data)
#     c.setopt(c.COOKIEJAR, 'cookies.txt')
#     c.perform()
#     resp=buffer.getvalue()
#     code= c.getinfo(c.RESPONSE_CODE)
#     c.close()
#     return code

def pysuperadminlogin(email,pswd):
    s = requests.Session()
    url = BASE_URL+'/login'
    try:
        headers = {
                'Content-type': "application/json",
                'Accept': "application/json",
            }
        data = json.dumps({"loginId": str(email), "password":str(pswd), "secondPassword":str(second_password())})
        r = s.post(url, data=data, headers=headers)
        log_request(r)
        log_response(r)
        cookie_dict = s.cookies.get_dict()
        return cookie_dict,r
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



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

