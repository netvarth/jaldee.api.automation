# import pycurl,os,sys
import os
try:
    from io import StringIO  ## for Python 3
except ImportError:
    from StringIO import StringIO ## for Python 2
import json
import requests
import mimetypes
import traceback
import logging
from RequestsLibrary.utils import is_file_descriptor
from robot.api import logger
from faker import Faker
from Keywordspy import second_password, log_response, log_request
from db import ecrypt_data, decrypt_data, Set_TZ_Header
BASE_URL = __import__(os.environ['VARFILE']).BASE_URL
HOST = __import__(os.environ['VARFILE']).HOSTED_IP
SA_BASE_URL = "http://"+HOST+"/superadmin/rest/mgmt"
# itmImg='/ebs/TDD/upload.png'
# itmppts='/ebs/TDD/proper.json'

# pptsofs='/ebs/TDD/Service.json'
# imgofs='/ebs/TDD/upload.png'

# ppts1='/ebs/TDD/Gallery.json'
# imgs='/ebs/TDD/uploadimage.jpg'

# pptslogo='/ebs/TDD/logo.json'
# imglogo='/ebs/TDD/uploadlogo.jpg'

# pptslogo='/ebs/TDD/logo.json'
# imglogo='/ebs/TDD/uploadlogo.jpg'

# bprof= '/ebs/TDD/data.json'
# bimg='/ebs/TDD/image.jpg'
# bprop='/ebs/TDD/properties.json'

# comfile='/ebs/TDD/image.jpg'

# # sample input for fileswithcaption
# #fileswithcaption=[{"file":"/ebs/TDD/image.jpg","caption":"This is caption 1"},{"file":"/ebs/TDD/upload.png","caption":"This is caption 2"}]

# ----------------------------------------------------------------------------------------------
# New Functions with Session and Request

pic1='/ebs/TDD/upload.png'
pic2='/ebs/TDD/uploadimage.jpg'
pic3='/ebs/TDD/small.jpg'
pic4='/ebs/TDD/large.jpeg'
logoimg='/ebs/TDD/uploadlogo.jpg'
profpic='/ebs/TDD/image.jpg'
itempty='/ebs/TDD/proper.json'
servicepty='/ebs/TDD/Service.json'
gallerypty='/ebs/TDD/Gallery.json'
logopty='/ebs/TDD/logo.json'
bprofdata= '/ebs/TDD/data.json'
bprofpty='/ebs/TDD/properties.json'
itemdata='/ebs/TDD/auth.json'
signpty='/ebs/TDD/sign.json'
prescriptionpty='/ebs/TDD/prescription.json'
clinicalnotespty='/ebs/TDD/clinicalnotes.json'
# cimg='/ebs/TDD/image.jpg'
# cprop='/ebs/TDD/proper.json'

# def log_response(response):
#     logger.info("%s Response : url=%s \n " % (response.request.method.upper(),
#                                               response.url) +
#                 "status=%s, reason=%s \n " % (response.status_code,
#                                               response.reason) +
#                 "headers=%s \n " % response.headers +
#                 "body=%s \n " % (response.text))


# def log_request(response):
#     request = response.request
#     if response.history:
#         original_request = response.history[0].request
#         redirected = '(redirected) '
#     else:
#         original_request = request
#         redirected = ''
#     logger.info("%s Request : " % original_request.method.upper() +
#                 "url=%s %s\n " % (original_request.url, redirected) +
#                 "path_url=%s \n " % original_request.path_url +
#                 "headers=%s \n " % original_request.headers +
#                 "body=%s \n " % (original_request.body))

# Service Provider Login
def spLogin(phno,pswd,countrycode=91):
    s = requests.Session()
    # url = BASE_URL+'/provider/login'
    url = BASE_URL+'/provider/login/encrypt'
    try:
        headers = {
                'Content-type': "application/json",
                'Accept': "application/json",
            }
        jsondata = json.dumps({"loginId": str(phno), "password":str(pswd), "countryCode":str(countrycode)})
        encrypted_data=  ecrypt_data(jsondata)
        data= json.dumps(encrypted_data)
        r = s.post(url, data=data, headers=headers)
        # print s.cookies
        # print "--------------"
        # print s.cookies.get_dict()
        log_request(r)
        log_response(r)
        cookie_dict = s.cookies.get_dict()
        return cookie_dict,r
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


# Android Service Provider Login
def AndroidspLogin(phno,pswd,countrycode=91):
    s = requests.Session()
    url = BASE_URL+'/provider/login'
    try:
        headers = {
                'Content-type': "application/json",
                'User-Agent': "android",
                'booking_req_from':"SP_APP",
                'sec-ch-ua-platform':"Android"
            }
        data = json.dumps({"loginId": str(phno), "password":str(pswd), "countryCode":str(countrycode)})
        r = s.post(url, data=data, headers=headers)
        # print s.cookies
        # print "--------------"
        # print s.cookies.get_dict()
        log_request(r)
        log_response(r)
        cookie_dict = s.cookies.get_dict()
        return cookie_dict,r
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


# Consumer Login
def conLogin(phno,pswd,countrycode=91):
    s = requests.Session()
    url = BASE_URL+'/consumer/login'
    try:
        headers = {
                'Content-type': "application/json",
                'Accept': "application/json",
            }
        data = json.dumps({"loginId": str(phno), "password":str(pswd), "countryCode":str(countrycode)})
        r = s.post(url, data=data, headers=headers)
        # print s.cookies
        # print "--------------"
        # print s.cookies.get_dict()
        log_request(r)
        log_response(r)
        cookie_dict = s.cookies.get_dict()
        return cookie_dict,r
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


# Android Consumer Login
def AndroidconLogin(phno,pswd,countrycode=91):
    s = requests.Session()
    url = BASE_URL+'/consumer/login'
    try:
        headers = {
                'Content-type': "application/json",
                # 'Accept': "application/json",
                'User-Agent': "android",
                'booking_req_from':"CONSUMER_APP",
                'sec-ch-ua-platform':"Android"
            }
        data = json.dumps({"loginId": str(phno), "password":str(pswd), "countryCode":str(countrycode)})
        r = s.post(url, data=data, headers=headers)
        # print s.cookies
        # print "--------------"
        # print s.cookies.get_dict()
        log_request(r)
        log_response(r)
        cookie_dict = s.cookies.get_dict()
        return cookie_dict,r
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



#Upload Service Image
def serviceImgUpload(serviceId,cookie_dict,img=pic1,ppty=servicepty):
    url = BASE_URL + '/provider/services/serviceGallery/'+str(serviceId)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        # headers = {
        #     'Content-Type': "multipart/form-data",
        # }

        mimetype, encoding = mimetypes.guess_type(img)
        data = {
        'files': (img, open(img, 'rb'), mimetype), 
        'properties': (None, open(ppty, 'rb'), 'application/json')
        }
    
        # print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


# Item image upload
def itemImgUpload(itemId,cookie_dict,img=pic1,ppty=itempty):
    url = BASE_URL + '/provider/items/' + str(itemId) + '/image'
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        # headers = {
        #     'Content-Type': "multipart/form-data",
        # }

        mimetype, encoding = mimetypes.guess_type(img)
        data = {
        'files': (img, open(img, 'rb'), mimetypes), 
        'properties': (None, open(ppty, 'rb'), 'application/json')
        }
    
        # print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def ItemGroupImgUpload(itemgroupId,img,cookie_dict,ppty=itempty):
    url = BASE_URL + '/provider/items/itemGroup/' + str(itemgroupId) + '/image'
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        
        mimetype, encoding = mimetypes.guess_type(img)
        print (encoding)
        data = {
        'files': (img, open(img, 'rb'), mimetypes), 
        'properties': (None, open(ppty, 'rb'), 'application/json')
        }
    
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



# Catalog image upload
def CatalogImgUpload(catalogId,cookie_dict,img=pic1,ppty=itempty):
    url = BASE_URL + '/provider/catalog/' + str(catalogId) + '/image'
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        # headers = {
        #     'Content-Type': "multipart/form-data",
        # }

        mimetype, encoding = mimetypes.guess_type(img)
        data = {
        'files': (img, open(img, 'rb'), mimetypes), 
        'properties': (None, open(ppty, 'rb'), 'application/json')
        }
    
        # print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



#UPLOAD PROVIDER GALLERY IMAGE
def galleryImgUpload(cookie_dict,img=pic2,img1=pic3,img2=pic4,ppty=gallerypty,flag=1):
    url = BASE_URL + '/provider/gallery'
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        # headers = {
        #     'Content-Type': "multipart/form-data",
        # }
        if flag==1 :
            mimetype, encoding = mimetypes.guess_type(img)
            data = {
            'files': (img, open(img, 'rb'), mimetype), 
            'properties': (None, open(ppty, 'rb'), 'application/json')
            }
        else:
            mimetype1, encoding1 = mimetypes.guess_type(img1)
            mimetype2, encoding2 = mimetypes.guess_type(img2)
            data = {
            'files': (img1, open(img1, 'rb'), mimetype1), 
            'files': (img2, open(img2, 'rb'), mimetype2),
            'properties': (None, open(ppty, 'rb'), 'application/json')
            }
    
        # print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


#UPLOAD PROVIDER LOGO IMAGE
def uploadProviderLogo(cookie_dict,ppty=logopty,img=logoimg):
    url = BASE_URL + '/provider/logo'
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        # headers = {
        #     'Content-Type': "multipart/form-data",
        # }

        mimetype, encoding = mimetypes.guess_type(img)
        data = {
        'files': (img, open(img, 'rb'), mimetype), 
        'properties': (None, open(ppty, 'rb'), 'application/json')
        }
    
        # print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

#UPLOAD USER LOGO IMAGE
def uploadUserLogo(cookie_dict,providerId,ppty=logopty,img=logoimg):
    url = BASE_URL + '/provider/user/logo/'+str(providerId)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        # headers = {
        #     'Content-Type': "multipart/form-data",
        # }

        mimetype, encoding = mimetypes.guess_type(img)
        data = {
        'files': (img, open(img, 'rb'), mimetype), 
        'properties': (None, open(ppty, 'rb'), 'application/json')
        }
    
        # print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

# Delete Service Image
def DeleteServiceImg(serviceId,name,cookie_dict):
    url = BASE_URL + '/provider/services/serviceGallery/'+str(serviceId)+'/'+str(name)
    s = requests.Session()
    s.cookies.update(cookie_dict)
    try:
        resp = s.delete(url)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

# Delete Item Image
def DeleteItemImg(itemId,cookie_dict):
    url = BASE_URL + '/provider/items/' + str(itemId) + '/image'
    s = requests.Session()
    s.cookies.update(cookie_dict)
    try:
        resp = s.delete(url)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def DeleteItemImages(itemId,ImgName,cookie_dict):
    url = BASE_URL + '/provider/items/' + str(itemId) + '/image/' + str(ImgName)
    s = requests.Session()
    s.cookies.update(cookie_dict)
    try:
        resp = s.delete(url)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

# Delete Catalog Image
def DeleteCatalogImages(catalogId,ImgName,cookie_dict):
    url = BASE_URL + '/provider/catalog/' + str(catalogId) + '/image/' + str(ImgName)
    s = requests.Session()
    s.cookies.update(cookie_dict)
    try:
        resp = s.delete(url)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

        
# Delete Gallery Image
def deleteGalleryImg(name,cookie_dict):
    url = BASE_URL + '/provider/gallery/'+str(name)
    s = requests.Session()
    s.cookies.update(cookie_dict)
    try:
        resp = s.delete(url)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

# Delete Provider Logo
def deleteProviderLogo(name,cookie_dict):
    url = BASE_URL + '/provider/logo/'+str(name)
    s = requests.Session()
    s.cookies.update(cookie_dict)
    try:
        resp = s.delete(url)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

# Delete User Logo
def deleteUserLogo(providerId,name,cookie_dict):
    url = BASE_URL + '/provider/user/logo/'+str(providerId)+'/'+str(name)
    s = requests.Session()
    s.cookies.update(cookie_dict)
    try:
        resp = s.delete(url)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

# Get Provider Image
def getImg(name,cookie_dict):
    url = BASE_URL + '/provider/' +str(name)
    s = requests.Session()
    s.cookies.update(cookie_dict)
    try:
        resp = s.get(url)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

#Upload provider business profile image
def BprofileWithDP(method,cookie_dict,img=profpic,ppty=bprofpty,info=bprofdata):
    url = BASE_URL + '/provider/bProfile'
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        # headers = {
        #     'Content-Type': "multipart/form-data",
        # }
        data = {
            'data': (None, open(info, 'rb'), 'application/json'),
            'files': (img, open(img, 'rb'),'image/jpg'), 
            'properties': (None, open(ppty, 'rb'), 'application/json')
            }
        # print (data)
        if method == 'PUT' :
            resp = s.put(url, files=data)
        else:
            resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def createBProfile (cookie_dict):
    resp = BprofileWithDP('POST',cookie_dict)
    log_request(resp)
    log_response(resp)
    return resp

def updateBProfile (cookie_dict):
    resp=BprofileWithDP('PUT',cookie_dict)
    log_request(resp)
    log_response(resp)
    return resp

def itemWithImage(method,cookie_dict,img=profpic,ppty=itempty,info=itemdata):
    url = BASE_URL + '/provider/items'
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        # headers = {
        #     'Content-Type': "multipart/form-data",
        # }
        
        mimetype, encoding = mimetypes.guess_type(img)
        data = {
            'item': (None, open(info, 'rb'), 'application/json'),
            'files': (img, open(img, 'rb'), mimetype), 
            'properties': (None, open(ppty, 'rb'), 'application/json')
            }
        # print (data)
        if method == 'PUT' :
            resp = s.put(url, files=data)
        else:
            resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def ItemCreation (cookie_dict):
    resp = itemWithImage('POST',cookie_dict)
    log_request(resp)
    log_response(resp)
    return resp


comfile='/ebs/TDD/image.jpg'

def providerWLCom(cookie_dict, uuid, msg, type, caption, msgid=None, file=None):
    
    url = BASE_URL + '/provider/waitlist/communicate/' + str(uuid)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        cap_dict = {"1":str(caption)}
        
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        if file in (None, '') or not file.strip():
            files_data = {
            'message': (None, json.dumps(msg_dict), 'application/json')
            # 'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            files_data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            'attachments': (file, open(file, 'rb'), mimetype),
            'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

comfile='/ebs/TDD/image.jpg'

def OrderImageUpload(cookie_dict, accId, caption, order, custHeaders, file=comfile, **kwargs):
    # url = BASE_URL + '/consumer/orders?account=' + str(accId)
    url = BASE_URL + '/consumer/orders'
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        # headers = {
        #     'Content-Type': "multipart/form-data",
        # }
        parameters = {'account': str(accId)}

        tzheaders, kwargs, locparam =Set_TZ_Header (**kwargs)
        custHeaders.update(tzheaders)
        parameters.update(locparam)
        print(custHeaders,parameters)

        cap_dict = {"0":str(caption)}

        if file in (None, '') or not file.strip():
            files_data = {
            'order': (None, json.dumps(order), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            files_data = {
                'attachments': (file, open(file, 'rb'), mimetype),
                'captions': (None, json.dumps(cap_dict), 'application/json'),
                'order': (None, json.dumps(order), 'application/json')
                }
        print (files_data) 
        resp = s.post(url, params=parameters, files=files_data, headers=custHeaders)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def OrderImageUploadByProvider(cookie_dict,  caption, order, file=comfile):
    url = BASE_URL + '/provider/orders'
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        cap_dict = {"0":str(caption)}

        if file in (None, '') or not file.strip():
            files_data = {
            'order': (None, json.dumps(order), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            files_data = {
                'attachments': (file, open(file, 'rb'), mimetype),
                'captions': (None, json.dumps(cap_dict), 'application/json'),
                'order': (None, json.dumps(order), 'application/json')
                }
        print (files_data) 
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def ShoppingCartUpload(cookie_dict,  accId, order, custHeaders, **kwargs):
    # url = BASE_URL + '/consumer/orders?account=' + str(accId)
    url = BASE_URL + '/consumer/orders'
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        
        parameters = {'account': str(accId)}
        files_data = {
            'order': (None, json.dumps(order), 'application/json')
            }
        print (files_data) 
        tzheaders, kwargs, locparam =Set_TZ_Header (**kwargs)
        custHeaders.update(tzheaders)
        parameters.update(locparam)
        print(custHeaders,parameters)
        resp = s.post(url, params=parameters, files=files_data, headers=custHeaders)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def AndroidShoppingCartUpload(cookie_dict,  accId, order):
    url = BASE_URL + '/consumer/orders?account=' + str(accId)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            # 'Content-Type': "multipart/form-data", 
            'User-Agent': "android",
            'booking_req_from':"CONSUMER_APP",
            'sec-ch-ua-platform':"Android"
        }
        print (headers)
        files_data = {
            'order': (None, json.dumps(order), 'application/json')
            }
        print (files_data) 
        resp = s.post(url, files=files_data, headers=headers)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def AndroidSPShoppingCartUpload(cookie_dict,  accId, order):
    url = BASE_URL + '/consumer/orders?account=' + str(accId)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            # 'Content-Type': "multipart/form-data", 
            'User-Agent': "android",
            'booking_req_from':"SP_APP",
            'sec-ch-ua-platform':"Android"
        }
        print (headers)
        files_data = {
            'order': (None, json.dumps(order), 'application/json')
            }
        print (files_data) 
        resp = s.post(url, files=files_data, headers=headers)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def OrderItemByProvider(cookie_dict,  order):
    
    url = BASE_URL + '/provider/orders'
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        files_data = {
            'order': (None, json.dumps(order), 'application/json')
            }
        print (files_data) 
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def providerOrderCommunication(cookie_dict, uuid, msg, type, msgid=None, *fileswithcaption ):
  
    url = BASE_URL + '/provider/orders/communicate/' + str(uuid)
    cap_dict={}
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        files_data = [
            ('message', (None, json.dumps(msg_dict), 'application/json'))
            ]
        
        print (fileswithcaption)
        if fileswithcaption:
            for i in range (len(fileswithcaption)):
                print (fileswithcaption[i])
                if fileswithcaption[i]['file']:
                    file= str(fileswithcaption[i]['file'])
                    mimetype, encoding = mimetypes.guess_type(file)
                    formfile= tuple((file, open(file, 'rb'), mimetype))
                    files_data.append(tuple(('attachments', formfile)))
                if fileswithcaption[i]['caption']:
                    j= i+1
                    cap_dict[str(j)] = str(fileswithcaption[i]['caption'])
            capdata= tuple((None, json.dumps(cap_dict), 'application/json'))
            files_data.append(tuple(('captions', capdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def consumerOrderCommunication(cookie_dict, accId, uuid, msg, type, msgid=None, *fileswithcaption ):
  
    url = BASE_URL + '/consumer/orders/communicate/' + str(uuid) + '?account=' + str(accId)
    cap_dict={}
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        files_data = [
            ('message', (None, json.dumps(msg_dict), 'application/json'))
            ]
        
        print (fileswithcaption)
        if fileswithcaption:
            for i in range (len(fileswithcaption)):
                print (fileswithcaption[i])
                if fileswithcaption[i]['file']:
                    file= str(fileswithcaption[i]['file'])
                    mimetype, encoding = mimetypes.guess_type(file)
                    formfile= tuple((file, open(file, 'rb'), mimetype))
                    files_data.append(tuple(('attachments', formfile)))
                if fileswithcaption[i]['caption']:
                    j= i+1
                    cap_dict[str(j)] = str(fileswithcaption[i]['caption'])
            capdata= tuple((None, json.dumps(cap_dict), 'application/json'))
            files_data.append(tuple(('captions', capdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


# digital sign
def digitalSignUpload(providerId,cookie_dict,img=pic1,ppty=signpty):
    url = BASE_URL + '/provider/user/digitalSign/'+ str(providerId) 
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        mimetype, encoding = mimetypes.guess_type(img)
        data = {
        'files': (img, open(img, 'rb'), mimetype), 
        'properties': (None, open(ppty, 'rb'), 'application/json')
        }
    
        # print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


# prescription image
def prescriptionImgUpload(mrId,cookie_dict,img=pic1,ppty=prescriptionpty):
    url = BASE_URL + '/provider/mr/uploadPrescription/'+ str(mrId) 
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        
        mimetype, encoding = mimetypes.guess_type(img)
        data = {
        'files': (img, open(img, 'rb'), mimetype), 
        'properties': (None, open(ppty, 'rb'), 'application/json')
        }
    
        # print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


# clinicalnotes image
def clinicalnotesImgUpload(mrId,cookie_dict,img=pic1,ppty=clinicalnotespty):
    url = BASE_URL + '/provider/mr/uploadClinicalNotes/'+ str(mrId) 
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        mimetype, encoding = mimetypes.guess_type(img)
        data = {
        'files': (img, open(img, 'rb'), mimetype), 
        'properties': (None, open(ppty, 'rb'), 'application/json')
        }
    
        # print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


# Delete prescription Image
def DeletePrescriptionImg(mrId,name,cookie_dict):
    url = BASE_URL + '/provider/mr/prescription/'+str(mrId)+'/'+str(name)
    s = requests.Session()
    s.cookies.update(cookie_dict)
    try:
        resp = s.delete(url)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def WaitlistNote(cookie_dict,  uuid, message, caption, file=comfile):
    url = BASE_URL + '/provider/waitlist/notes/'+ str(uuid) 
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        headers = {
            'Content-Type': "multipart/form-data"
        }
        cap_dict = {"0":str(caption)}

        if file in (None, '') or not file.strip():
            files_data = {
            'message': (None, json.dumps(message), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            data = {
            'attachments': (file, open(file, 'rb'), mimetype), 
            'captions': (None, json.dumps(cap_dict), 'application/json'),
            'message': (None, json.dumps(message), 'application/json')
            }
        print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def AppointmentNote(cookie_dict,  uuid, message, caption, file=comfile):
    url = BASE_URL + '/provider/appointment/note/'+ str(uuid) 
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        headers = {
            'Content-Type': "multipart/form-data"
        }
        cap_dict = {"1":str(caption)}

        if file in (None, '') or not file.strip():
            files_data = {
            'message': (None, json.dumps(message), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            data = {
            'attachments': (file, open(file, 'rb'), mimetype), 
            'captions': (None, json.dumps(cap_dict), 'application/json'),
            'message': (None, json.dumps(message), 'application/json')
            }
        print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def PWLAttachment(cookie_dict,  uuid, caption, file=comfile):
    url = BASE_URL + '/provider/waitlist/'+ str(uuid) +'/attachment' 
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        headers = {
            'Content-Type': "multipart/form-data"
        }
        cap_dict = {"0":str(caption)}

        mimetype, encoding = mimetypes.guess_type(file)
        data = {
        'attachments': (file, open(file, 'rb'), mimetype), 
        'captions': (None, json.dumps(cap_dict), 'application/json'),
        # 'message': (None, json.dumps(message), 'application/json')
        }
        print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def CWLAttachment(cookie_dict, acc_id, uuid, caption, file=comfile):
    url = BASE_URL + '/consumer/waitlist/'+ str(uuid) + '/attachment?account=' + str(acc_id)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        headers = {
            'Content-Type': "multipart/form-data"
        }
        cap_dict = {"0":str(caption)}

        mimetype, encoding = mimetypes.guess_type(file)
        data = {
        'attachments': (file, open(file, 'rb'), mimetype), 
        'captions': (None, json.dumps(cap_dict), 'application/json'),
        # 'message': (None, json.dumps(message), 'application/json')
        }
        print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def PApptAttachment(cookie_dict,  uuid, caption, file=comfile):
    url = BASE_URL + '/provider/appointment/'+ str(uuid) +'/attachment'
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        headers = {
            'Content-Type': "multipart/form-data",
        }
        cap_dict = {"0":str(caption)}

        mimetype, encoding = mimetypes.guess_type(file)
        data = {
        'attachments': (file, open(file, 'rb'), mimetype), 
        'captions': (None, json.dumps(cap_dict), 'application/json'),
        # 'message': (None, json.dumps(message), 'application/json')
        }
        print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def CApptAttachment(cookie_dict, acc_id, uuid, message, caption, file=comfile):
    url = BASE_URL + '/consumer/appointment/'+ str(uuid) +'/attachment?account=' + str(acc_id)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        headers = {
            'Content-Type': "multipart/form-data",
        }
        cap_dict = {"1":str(caption)}

        if file in (None, '') or not file.strip():
            files_data = {
            'message': (None, json.dumps(message), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            data = {
            'attachments': (file, open(file, 'rb'), mimetype), 
            'captions': (None, json.dumps(cap_dict), 'application/json'),
            'message': (None, json.dumps(message), 'application/json')
            }
        print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def GeneralCommunicationWithProvider(cookie_dict, accId, msg, type, caption, msgid=None, file=None):
    url = BASE_URL + '/consumer/communications?account=' + str(accId)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        headers = {
            'Content-Type': "multipart/form-data",
        }
        cap_dict = {"0":str(caption)}
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        if file in (None, '') or not file.strip():
            data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            # 'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            'attachments': (file, open(file, 'rb'), mimetype),
            'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def GeneralCommunicationWithConsumer(cookie_dict, consumerId, msg, type, caption, msgid=None, file=None):
    url = BASE_URL + '/provider/communications/' + str(consumerId)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        headers = {
            'Content-Type': "multipart/form-data",
        }
        cap_dict = {"0":str(caption)}
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        if file in (None, '') or not file.strip():
            data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            # 'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            'attachments': (file, open(file, 'rb'), mimetype),
            'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        print (data)
        # data = {
        # 'attachments': (file, open(file, 'rb'), 'image/jpg'), 
        # 'captions': (None, json.dumps(cap_dict), 'application/json'),
        # 'message': (None, json.dumps(message), 'application/json')
        # }
        # print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def GeneralUserCommunicationWithConsumer(cookie_dict, UserId, consumerId, msg, type, caption, msgid=None, file=None):
    url = BASE_URL + '/provider/communications/' + str(consumerId) + '?provider=' + str(UserId)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        headers = {
            'Content-Type': "multipart/form-data",
        }
        cap_dict = {"1":str(caption)}
        # if msgid is None:
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        if file in (None, '') or not file.strip():
            data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            # 'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            'attachments': (file, open(file, 'rb'), mimetype),
            'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def GeneralUserCommunicationWithProvider(cookie_dict, accId, UserId, msg, type, caption, msgid=None, file=None):
    url = BASE_URL + '/consumer/communications?account=' + str(accId) + '&provider=' + str(UserId)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        headers = {
            'Content-Type': "multipart/form-data",
        }
        cap_dict = {"1":str(caption)}
        # if msgid is None:
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        if file in (None, '') or not file.strip():
            data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            # 'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            'attachments': (file, open(file, 'rb'), mimetype),
            'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

# Service Provider Login
def  SALogin(usname,pswd):
    s = requests.Session()
    url = SA_BASE_URL+'/login'
    print (url)
    pass2 = second_password()
    print ("2nd pass "+str(pass2))
    try:
        headers = {
                'Content-type': "application/json",
                'Accept': "application/json",
            }
        data = json.dumps({"loginId": str(usname), "password":str(pswd), "secondPassword":str(pass2)})
        r = s.post(url, data=data, headers=headers)
        log_request(r)
        log_response(r)
        cookie_dict = s.cookies.get_dict()
        return cookie_dict,r
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


# qnrfile = '/ebs/TDD/sampleqnr.xlsx'
def UploadQuestionnaire(cookie_dict, accId, file):
    url = SA_BASE_URL + '/b2b/' + str(accId) + '/questionnaire/upload'
    s = requests.Session()
    s.cookies.update(cookie_dict)
    print (file)      
    try:
        # headers = {
        #     'Content-Type': "multipart/form-data",
        # }

        # files = {'file': (file, open(file, 'rb'),'text/csv')}
        # files = {'file': (file, open(file, 'rb'),'application/vnd.ms-excel')}

        mimetype, encoding = mimetypes.guess_type(file)
        print (mimetype)
        if mimetype == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
            mimetype = 'application/vnd.ms-excel'
            print (mimetype)
        data = {
        'files': (file, open(file, 'rb'), mimetype), 
        }
        print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def POrderCommunication(cookie_dict,  uuid, msg, type, caption, msgid=None, file=None):
    
    url = BASE_URL + '/provider/orders/communicate/' + str(uuid)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        cap_dict = {"1":str(caption)}
        # if msgid is None:
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        # if file is None:
        if file in (None, '') or not file.strip():
            files_data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            # 'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            files_data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            'attachments': (file, open(file, 'rb'), mimetype),
            'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


# def COrderCommunication(cookie_dict, uuid, accId, msg, type, caption, msgid=None, file=None):
    
#     url = BASE_URL + '/consumer/orders/communicate/' + str(uuid) + '?account=' + str(accId)
#     s = requests.Session()
#     s.cookies.update(cookie_dict)      
#     try:
#         headers = {
#             'Content-Type': "multipart/form-data",
#         }
#         cap_dict = {"1":str(caption)}
#         # if msgid is None:
#         if msgid in (None, '') or not msgid.strip():
#             msg_dict = {"msg": str(msg), "messageType":str(type)}
#         else:
#             msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

#         # if file is None:
#         if file in (None, '') or not file.strip():
#             files_data = {
#             'message': (None, json.dumps(msg_dict), 'application/json'),
#             # 'captions': (None, json.dumps(cap_dict), 'application/json')
#             }
#         else:
#             mimetype, encoding = mimetypes.guess_type(file)
#             files_data = {
#             'message': (None, json.dumps(msg_dict), 'application/json'),
#             'attachments': (file, open(file, 'rb'), mimetype),
#             'captions': (None, json.dumps(cap_dict), 'application/json')
#             }
#         print (files_data)
#         resp = s.post(url, files=files_data)
#         return resp
#     except Exception as e:
#         print ("Exception:", e)
        # print ("Exception at line no:", e.__traceback__.tb_lineno)


def CAppmntcomm(cookie_dict,  uuid, accId, msg, type, caption, msgid=None, file=None):
    
    url = BASE_URL + '/consumer/appointment/communicate/' + str(uuid) + '?account=' + str(accId)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        cap_dict = {"0":str(caption)}
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        if file in (None, '') or not file.strip():
            files_data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            # 'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            files_data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            'attachments': (file, open(file, 'rb'), mimetype),
            'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

        

def PAppmntComm(cookie_dict,  uuid, msg, type, caption, msgid=None, file=None): 
    url = BASE_URL + '/provider/appointment/communicate/' + str(uuid)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        cap_dict = {"1":str(caption)}
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        if file in (None, '') or not file.strip():
            files_data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            # 'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            files_data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            'attachments': (file, open(file, 'rb'), mimetype),
            'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



def CAppmntCommMultiFile(cookie_dict, uuid, accId, msg, type, msgid=None, *fileswithcaption):
    
    url = BASE_URL + '/consumer/appointment/communicate/' + str(uuid) + '?account=' + str(accId)
    cap_dict={}
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        # cap_dict = {"1":str(caption)}
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        files_data = [
            ('message', (None, json.dumps(msg_dict), 'application/json'))
            ]
        
        print (fileswithcaption)
        if fileswithcaption:
            for i in range (len(fileswithcaption)):
                print (fileswithcaption[i])
                if fileswithcaption[i]['file']:
                    file= str(fileswithcaption[i]['file'])
                    mimetype, encoding = mimetypes.guess_type(file)
                    formfile= tuple((file, open(file, 'rb'), mimetype))
                    files_data.append(tuple(('attachments', formfile)))
                if fileswithcaption[i]['caption']:
                    j= i+1
                    cap_dict[str(j)] = str(fileswithcaption[i]['caption'])
            capdata= tuple((None, json.dumps(cap_dict), 'application/json'))
            files_data.append(tuple(('captions', capdata)))
                

        # if file in (None, '') or not file.strip():
        #     files_data = {
        #     'message': (None, json.dumps(msg_dict), 'application/json'),
        #     # 'captions': (None, json.dumps(cap_dict), 'application/json')
        #     }
        # else:
        #     files_data = {
        #     'message': (None, json.dumps(msg_dict), 'application/json'),
        #     'attachments': (file, open(file, 'rb'), 'image/jpg'),
        #     'captions': (None, json.dumps(cap_dict), 'application/json')
        #     }
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def PAppmntCommMultiFile(cookie_dict, uuid, msg, type, msgid=None, *fileswithcaption ):
  
    url = BASE_URL + '/provider/appointment/communicate/' + str(uuid)
    cap_dict={}
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        files_data = [
            ('message', (None, json.dumps(msg_dict), 'application/json'))
            ]
        
        print (fileswithcaption)
        if fileswithcaption:
            for i in range (len(fileswithcaption)):
                print (fileswithcaption[i])
                if fileswithcaption[i]['file']:
                    file= str(fileswithcaption[i]['file'])
                    mimetype, encoding = mimetypes.guess_type(file)
                    formfile= tuple((file, open(file, 'rb'), mimetype))
                    files_data.append(tuple(('attachments', formfile)))
                if fileswithcaption[i]['caption']:
                    j= i+1
                    cap_dict[str(j)] = str(fileswithcaption[i]['caption'])
            capdata= tuple((None, json.dumps(cap_dict), 'application/json'))
            files_data.append(tuple(('captions', capdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



def ConsWLCommunication(cookie_dict, uuid, accId, msg, type, caption, msgid=None, file=None):
    
    url = BASE_URL + '/consumer/waitlist/communicate/' + str(uuid) + '?account=' + str(accId)
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        headers = {
            'Content-Type': "multipart/form-data",
        }
        cap_dict = {"1":str(caption)}
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        if file in (None, '') or not file.strip():
            files_data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            }
        else:
            mimetype, encoding = mimetypes.guess_type(file)
            files_data = {
            'message': (None, json.dumps(msg_dict), 'application/json'),
            'attachments': (file, open(file, 'rb'), mimetype),
            'captions': (None, json.dumps(cap_dict), 'application/json')
            }
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



def CWLSCommMultiFile(cookie_dict, accId, uuid, msg, type, msgid=None, *fileswithcaption ):
  
    url = BASE_URL + '/consumer/waitlist/communicate/' + str(uuid) + '?account=' + str(accId)
    cap_dict={}
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        if msgid in (None, '') or not msgid.strip():
            msg_dict = {"msg": str(msg), "messageType":str(type)}
        else:
            msg_dict = {"msg": str(msg), "replyMessageId":str(msgid), "messageType":str(type)}

        files_data = [
            ('message', (None, json.dumps(msg_dict), 'application/json'))
            ]
        
        print (fileswithcaption)
        if fileswithcaption:
            for i in range (len(fileswithcaption)):
                print (fileswithcaption[i])
                if fileswithcaption[i]['file']:
                    file= str(fileswithcaption[i]['file'])
                    mimetype, encoding = mimetypes.guess_type(file)
                    formfile= tuple((file, open(file, 'rb'), mimetype))
                    files_data.append(tuple(('attachments', formfile)))
                if fileswithcaption[i]['caption']:
                    j= i+1
                    cap_dict[str(j)] = str(fileswithcaption[i]['caption'])
            capdata= tuple((None, json.dumps(cap_dict), 'application/json'))
            files_data.append(tuple(('captions', capdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def CApptQAnsUpload(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/appointment/questionnaire/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def CWlQAnsUpload(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/waitlist/questionnaire/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def CDonationQAnsUpload(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/donation/questionnaire/submit/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def CApptResubmitQns(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/appointment/questionnaire/resubmit/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def CWlResubmitQns(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/waitlist/questionnaire/resubmit/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def CDonationResubmitQns(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/donation/questionnaire/resubmit/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def PApptQAnsUpload(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/appointment/questionnaire/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def PWlQAnsUpload(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/waitlist/questionnaire/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def PDonationQAnsUpload(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/donation/questionnaire/submit/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def PApptResubmitQns(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/appointment/questionnaire/resubmit/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def PWlResubmitQns(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/waitlist/questionnaire/resubmit/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def PDonationResubmitQns(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/donation/questionnaire/resubmit/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)






def PAppMassCommMultiFile( cookie_dict, msg_dict,  *fileswithcaption ):
  
    url = BASE_URL + '/provider/appointment/consumerMassCommunication' 
    cap_dict={}
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
    
        files_data = [
            ('communication', (None, json.dumps(msg_dict), 'application/json'))
            ]
        
        print (fileswithcaption)
        if fileswithcaption:
            for i in range (len(fileswithcaption)):
                print (fileswithcaption[i])
                if fileswithcaption[i]['file']:
                    file= str(fileswithcaption[i]['file'])
                    mimetype, encoding = mimetypes.guess_type(file)
                    formfile= tuple((file, open(file, 'rb'), mimetype))
                    files_data.append(tuple(('attachments', formfile)))
                if fileswithcaption[i]['caption']:
                    j= i+1
                    cap_dict[str(j)] = str(fileswithcaption[i]['caption'])
            capdata= tuple((None, json.dumps(cap_dict), 'application/json'))
            files_data.append(tuple(('captions', capdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



def providerWLMassCom( cookie_dict, msg_dict,  *fileswithcaption ):
  
    url = BASE_URL + '/provider/waitlist/consumerMassCommunication' 
    cap_dict={}
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
    
        files_data = [
            ('communication', (None, json.dumps(msg_dict), 'application/json'))
            ]
        
        print (fileswithcaption)
        if fileswithcaption:
            for i in range (len(fileswithcaption)):
                print (fileswithcaption[i])
                if fileswithcaption[i]['file']:
                    file= str(fileswithcaption[i]['file'])
                    mimetype, encoding = mimetypes.guess_type(file)
                    formfile= tuple((file, open(file, 'rb'), mimetype))
                    files_data.append(tuple(('attachments', formfile)))
                if fileswithcaption[i]['caption']:
                    j= i+1
                    cap_dict[str(j)] = str(fileswithcaption[i]['caption'])
            capdata= tuple((None, json.dumps(cap_dict), 'application/json'))
            files_data.append(tuple(('captions', capdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



def providerOrderMassCommunication( cookie_dict, msg_dict,  *fileswithcaption ):
  
    url = BASE_URL + '/provider/orders/consumerMassCommunication' 
    cap_dict={}
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
    
        files_data = [
            ('communication', (None, json.dumps(msg_dict), 'application/json'))
            ]
        
        print (fileswithcaption)
        if fileswithcaption:
            for i in range (len(fileswithcaption)):
                print (fileswithcaption[i])
                if fileswithcaption[i]['file']:
                    file= str(fileswithcaption[i]['file'])
                    mimetype, encoding = mimetypes.guess_type(file)
                    formfile= tuple((file, open(file, 'rb'), mimetype))
                    files_data.append(tuple(('attachments', formfile)))
                if fileswithcaption[i]['caption']:
                    j= i+1
                    cap_dict[str(j)] = str(fileswithcaption[i]['caption'])
            capdata= tuple((None, json.dumps(cap_dict), 'application/json'))
            files_data.append(tuple(('captions', capdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def POrderQAnsUpload(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/orders/questionnaire/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def POrderResubmitQns(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/orders/questionnaire/resubmit/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



def COrderQAnsUpload(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/orders/questionnaire/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def COrderResubmitQns(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/orders/questionnaire/resubmit/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)


def Uploadfiletojaldeedrive(cookie_dict, folderName, providerId, *fileswithcaption ):
    url = BASE_URL + '/provider/fileShare/upload/' + str(folderName) + '/'  + str(providerId)
    cap_dict={}
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (fileswithcaption)
        if fileswithcaption and fileswithcaption[0] not in (None, ''):
            print("Entered fileswithcaption if")
            for i in range (len(fileswithcaption)):
                print("Entered fileswithcaption for")
                print (fileswithcaption[i])
                if fileswithcaption[i]['file']:
                    print("Entered fileswithcaption file if")
                    file= str(fileswithcaption[i]['file'])
                    mimetype, encoding = mimetypes.guess_type(file)
                    formfile= tuple((file, open(file, 'rb'), mimetype))
                    files_data.append(tuple(('attachments', formfile)))
                if fileswithcaption[i]['caption']:
                    print("Entered fileswithcaption caption if")
                    j= i+1
                    cap_dict[str(j)] = str(fileswithcaption[i]['caption'])
            capdata= tuple((None, json.dumps(cap_dict), 'application/json'))
            files_data.append(tuple(('captions', capdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
         print ("Exception:", e)
         print ("Exception at line no:", e.traceback.tb_lineno)


def PServiceOptionsUpload(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/waitlist/serviceoption/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def PResubmitServiceOptions(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/waitlist/serviceoptoin/resubmit/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def PApptserviceoptionsUpload(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/appointment/serviceoption/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def PResubmitApptserviceoptionsUpload(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/appointment/serviceoption/resubmit/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def PSubmitServiceOptionsForOrder(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/orders/serviceoption/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def PResubmitServiceOptionsForOrder(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/orders/serviceoption/resubmit/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def CWlSerOptUpload(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/waitlist/serviceoption/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def CWlResubmitServiceOption(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/waitlist/serviceoption/resubmit/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def CApptSerOptUpload(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/appointment/serviceoption/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def CApptResubmitServiceOption(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/appointment/serviceoption/resubmit/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)





def uploadTaskAttachment( cookie_dict, taskuid, *fileswithcaption ):
      
    url = BASE_URL + '/provider/task/' + str(taskuid) + '/' + 'attachment'
    cap_dict={}
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
    
       
        print (fileswithcaption)
        if fileswithcaption and fileswithcaption[0] not in (None, ''):
            print("Entered fileswithcaption if")
            for i in range (len(fileswithcaption)):
                print("Entered fileswithcaption for")
                print (fileswithcaption[i])
                if fileswithcaption[i]['file']:
                    print("Entered fileswithcaption file if")
                    file= str(fileswithcaption[i]['file'])
                    mimetype, encoding = mimetypes.guess_type(file)
                    formfile= tuple((file, open(file, 'rb'), mimetype))
                    files_data.append(tuple(('attachments', formfile)))
                if fileswithcaption[i]['caption']:
                    print("Entered fileswithcaption caption if")
                    j= i+1
                    cap_dict[str(j)] = str(fileswithcaption[i]['caption'])
            capdata= tuple((None, json.dumps(cap_dict), 'application/json'))
            files_data.append(tuple(('captions', capdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
         print ("Exception:", e)
         print ("Exception at line no:", e.traceback.tb_lineno)



def ShareFilesInJaldeeDrive ( cookie_dict, sharedto, fileid_list, comm):
      
    
    url = BASE_URL + '/provider/fileShare/sharefiles' 
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        files_data = {
             'sharedto': (None, json.dumps(sharedto), 'application/json'),
             'attachments': (None, json.dumps(fileid_list), 'application/json'),
             'commun': (None, json.dumps(comm), 'application/json')
         
            #'sharedto': (None, fileid_list, 'application/json'),
           #'attachments': (None, sharedto, 'application/json')
        }
    
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def CSubmitSerOptForItem(cookie_dict, item, uuid, accId, data, *files):
  
    url = BASE_URL + '/consumer/orders/item/serviceoption/'+ str(item) + '/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def CResubmitSerOptForItem(cookie_dict, uuid, accId, data, *files):
  
    url = BASE_URL + '/consumer/orders/item/serviceoption/resubmit/'+ str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def PSubmitSerOptForItem(cookie_dict, item, uuid, data, *files):
  
    url = BASE_URL + '/provider/orders/item/serviceoption/'+ str(item) + '/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def PResubmitSerOptForItem(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/orders/item/serviceoption/resubmit/'+ '/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        
def CSubmitSerOptForOrder(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/orders/serviceoption/'+ '/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def CResubmitSerOptForOrder(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/orders/serviceoption/resubmit/'+ '/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def CSubmitSerOptForDonation(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/donation/serviceoption/submit/'+ '/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def CResubmitSerOptForDonation(cookie_dict, accId, uuid, data, *files):
  
    url = BASE_URL + '/consumer/donation/serviceoption/resubmit/'+ '/' + str(uuid) + '?account=' + str(accId)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)
    # s.headers.update({'Content-Type': "multipart/form-data"})      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        # resp = s.post(url, files=files_data, headers=headers)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def PLeadQAnsUpload(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/lead/questionnaire/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def PLeadResubmitQns(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/lead/questionnaire/resubmit/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def SalessubmitQns(cookie_dict, uuid, data, *files):
      
    url = BASE_URL + '/provider/lead/questionnaire/proceed/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.put(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



# def CreditrecommentedsubmitQns(cookie_dict, uuid, data, *files):
      
#     url = BASE_URL + '/provider/lead/status/questionnaire/' + str(uuid)
#     files_data = []
#     s = requests.Session()
#     s.cookies.update(cookie_dict)      
#     try:
#         headers = {
#             'Content-Type': "multipart/form-data",
#         }
        
#         print (files)
#         if files:
#             for i in range (len(files)):
#                 print (files[i])
#                 file= str(files[i])
#                 mimetype, encoding = mimetypes.guess_type(file)
#                 formfile= tuple((file, open(file, 'rb'), mimetype))
#                 files_data.append(tuple(('files', formfile)))
#         if data not in (None, ''):
#             ansdata= tuple((None, data, 'application/json'))
#             files_data.append(tuple(('question', ansdata)))
                
#         print (files_data)
#         resp = s.put(url, files=files_data)
#         log_request(resp)
#         log_response(resp)
#         return resp
#     except Exception as e:
#         print ("Exception:", e)
#         print ("Exception at line no:", e.__traceback__.tb_lineno)

def PLeadStatusQAnsUpload(cookie_dict, uuid, data, *files):
  
    url = BASE_URL + '/provider/lead/status/questionnaire/' + str(uuid)
    files_data = []
    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }
        
        print (files)
        if files:
            for i in range (len(files)):
                print (files[i])
                file= str(files[i])
                mimetype, encoding = mimetypes.guess_type(file)
                formfile= tuple((file, open(file, 'rb'), mimetype))
                files_data.append(tuple(('files', formfile)))
        if data not in (None, ''):
            ansdata= tuple((None, data, 'application/json'))
            files_data.append(tuple(('question', ansdata)))
                
        print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

qnrfile = '/ebs/TDD/CDL_BRANCHES.xlsx'
def ImportBranchesfromSuperAdmin(cookie_dict, accId, file=qnrfile):
    url = SA_BASE_URL + '/account/import/branches'
    s = requests.Session()
    s.cookies.update(cookie_dict)
    print (file)      
    try:
        headers = {
            'Content-Type': "multipart/form-data",
        }

        files_data = {
             
             'file': (file, open(file, 'rb'), 'application/vnd.ms-excel'),
             'accId': (None, json.dumps(accId), 'application/json')
        
        }

        # files = {'file': (file, open(file, 'rb'),'text/csv')}
        # files = {'file': (file, open(file, 'rb'),'application/vnd.ms-excel')}

        # mimetype, encoding = mimetypes.guess_type(file)
        # print (mimetype)
        # if mimetype == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        #     mimetype = 'application/vnd.ms-excel'
        #     print (mimetype)
        # data = {
        # 'files': (file, open(file, 'rb'), 'application/vnd.ms-excel'), 
        # }
        # print (files_data)
        resp = s.post(url, files=files_data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

# Loan digital sign
def loanDigitalSignUpload(cookie_dict,accId,loanApplicationUid,loanApplicationKycId,signType,caption,img=pic1):
    url = BASE_URL + '/provider/loanapplication/'+ str(loanApplicationUid) + '/kyc/' + str(loanApplicationKycId) +'/digitalsign'  + '?account=' + str(accId)
    

    s = requests.Session()
    s.cookies.update(cookie_dict)      
    try:

        cap_dict = {"caption":str(caption)}
        mimetype, encoding = mimetypes.guess_type(img)
        data = {
        'files': (img, open(img, 'rb'), mimetype), 
        'properties': (None, json.dumps(cap_dict), 'application/json')
        }
    
        # print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



# def IVRQAnsUpload(cookie_dict, uuid, data):
  
#     url = BASE_URL + '/provider/ivr/questionnaire/submit/' + str(uuid)
#     files_data = []
#     s = requests.Session()
#     s.cookies.update(cookie_dict)      
#     try:
#         headers = {
#             'Content-Type': "application/json",
#         }
        
#         ansdata= tuple((None, data, 'application/json'))
#         files_data.append(tuple(('question', ansdata)))
                
#         print (files_data)
#         resp = s.post(url, data=files_data, headers=headers)
#         log_request(resp)
#         log_response(resp)
#         return resp
#     except Exception as e:
#         print ("Exception:", e)
#         print ("Exception at line no:", e.__traceback__.tb_lineno)


def UploadQNRfiletoTempLocation(cookie_dict, proid, qnrid, caption, mimeType, keyName, urls, size, labelName):

    url = BASE_URL + '/provider/questionnaire/upload/file'
    s = requests.Session()
    s.cookies.update(cookie_dict)

    request = {"proId": proid,"questionnaireId": qnrid}
    files = [{"caption": caption,"mimeType": mimeType,"keyName": keyName,"url": urls,"size": size,"labelName": labelName}]

    try:
        data = {
        'requests': (None, json.dumps(request), 'application/json'), 
        'files': (None, json.dumps(files), 'application/json')
        }

        # data1= tuple((None,json.dumps() request, 'application/json'))
        # data2= tuple((None, files, 'application/json'))
        # files_data.append(tuple(('request', data1)('files', data2)))

        print (data)
        resp = s.post(url, files=data)
        log_request(resp)
        log_response(resp)
        return resp

    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)



def ProconLogin(phno,accId,token,countrycode=91):
    s = requests.Session()
    url = BASE_URL+'/consumer/login'
    try:
        headers = {
                'Content-type': "application/json",
                'Accept': "application/json",
                'Authorization': token
            }
        data = json.dumps({"loginId": str(phno), "accountId":str(accId), "countryCode":str(countrycode)})
        r = s.post(url, data=data, headers=headers)
        log_request(r)
        log_response(r)
        cookie_dict = s.cookies.get_dict()
        return cookie_dict,r
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)