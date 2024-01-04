import MySQLdb
# import pymysql
# import mysql.connector
import time
import subprocess
import shlex
import sys
import datetime
import os
import calendar
import csv
import random
import json
import string
import inspect
import collections as col
from collections import defaultdict
from faker import Faker
# from datetime import datetime
from datetime import timedelta
import requests 
import mimetypes
import traceback
# import xml.etree.ElementTree as ET
from dateutil import parser
import phonenumbers
from phonenumbers import geocoder
from phonenumbers.phonenumberutil import (
    region_code_for_country_code,
    region_code_for_number,
)

# from timezonefinder import TimezoneFinder
from robot.api import logger

from base64 import b64encode, b64decode
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
import socket
from Keywordspy import create_tz


if os.environ['SYSTEM_ENV'] == 'Microsoft WSL':
    # db_host = "host.docker.internal"
    db_host = subprocess.getoutput("cat /etc/resolv.conf | grep nameserver | cut -d' ' -f 2 | tr -d '\n'")
else:
    db_host = "127.0.0.1"
    

# db_host = "127.0.0.1"
db_user = "root"
db_passwd = "netvarth"
db = "ynw"
loclist=[]



addressfile='/ebs/TDD/locations.csv'
fname='/ebs/TDD/pan.txt'
licjson='/ebs/ynwconf/licenseConfig.json'
bizjson= '/ebs/ynwconf/businessDomainConfig.json'
def_profile='/ebs/TDD/defaultpaymentprofile.txt'
queue_service_metric_id=20
multiuser_metric_id=21

def connect_db(host, user, passwd, db):
    try:
        return MySQLdb.connect(host=host,
                               user=user,
                               passwd=passwd,
                               db=db)
    except MySQLdb.Error as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def get_Host_name_IP():
    try:
        host_name = socket.gethostname()
        host_ip = socket.gethostbyname(host_name)
        print("Hostname :  ", host_name)
        print("IP : ", host_ip)
        print(socket.gethostbyaddr(socket.gethostname())[0])
    except:
        print("Unable to get Hostname and IP")


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

# def connect_db(host, user, passwd, db):
#     try:
#         return pymysql.connect(host=host,
#                                user=user,
#                                passwd=passwd,
#                                db=db)
#     except Exception as e:
#         print ("Exception:", e)
#         print ("Exception at line no:", e.__traceback__.tb_lineno)

# def connect_db(host, user, passwd, db):
#     try:
#         return pymysql.connect(host=host,
#                                user=user,
#                                passwd=passwd,
#                                db=db)
#     except Exception as e:
#         print ("Exception:", e)
#         print ("Exception at line no:", e.__traceback__.tb_lineno)

# def connect_db(host, user, passwd, db):
#     try:
#         return mysql.connector.connect (host=host,
#                                user=user,
#                                passwd=passwd,
#                                db=db)
#     except mysql.connector.Error as e:
#         print ("Exception:", e)
        # print ("Exception at line no:", e.__traceback__.tb_lineno)


def verify_accnt(email,purpose):
    if str(email).isdigit() and str(email).startswith('55'):
        print ("if:")
        return 55555
    else:
        print ("else:")
        dbconn = connect_db(db_host, db_user, db_passwd, db)
        try:
            with dbconn.cursor() as cur:
                # cur = dbconn.cursor()
                # select_stmt = "SELECT * FROM employees WHERE emp_no = %(emp_no)s"
                # cursor.execute(select_stmt, { 'emp_no': 2 })
                select_stmt = ("SELECT sharedkey FROM access_key_tbl WHERE login_id='%s' and otp_purpose='%s'")
                print ('Executing Query:',(select_stmt %(email,purpose)))
                cur.execute(select_stmt %(email,purpose))
                row = cur.fetchone()
                return row[0]
        except Exception as e:
            print ("Exception:", e)
            print ("Exception at line no:", e.__traceback__.tb_lineno)
            return 0
        finally:
            if dbconn is not None:
                dbconn.close()



def get_id(email):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            if str(email).isdigit() :
                cur.execute("SELECT id FROM user_tbl WHERE primary_mobile_no='%s'" % email)
            else:
                if(email!=' '):
                    cur.execute("SELECT id FROM user_tbl WHERE email='%s'" % email)
            row = cur.fetchone()
        # dbconn.close()
        return row[0]
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


def get_aid(number):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM account_info_tbl WHERE acct_linked_ph_no='%s'" % number)
            row = cur.fetchone()
            # dbconn.close()
            return row[0]
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


def get_acc_id(email):
    print("In function: ", inspect.stack()[0].function)
    uid= get_id(email)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT account FROM local_user_tbl WHERE id='%s'" % uid)
            row = cur.fetchone()
            # dbconn.close()
            return row[0]
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()

def get_uid(ph):
    print("In function: ", inspect.stack()[0].function)
    acid =  get_acc_id(ph) 
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:

        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT uid FROM account_tbl WHERE id='%s'" % acid)
            row = cur.fetchone()
            # dbconn.close()
            return row[0]
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()

def get_debit(ph):
    print("In function: ", inspect.stack()[0].function)
    acid =  get_acc_id(ph) 
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:

        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT debit FROM acc_credit_debit_tbl WHERE account='%s'" % acid)
            row = cur.fetchone()
            # dbconn.close()
            return row[0]
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


def get_ser_id(email):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM user_tbl WHERE email='%s'" % email)
            row = cur.fetchone()
            uid = row[0]
            cur.execute("SELECT id FROM service_tbl WHERE created_by='%s'" % uid)
            row = cur.fetchall()
            # dbconn.close()
            L=[]
            for index in range(len(row)):
                L.append(int(row[index][0]))
            return L
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


# def delete_entry(table,field,value):
#     dbconn = connect_db(db_host, db_user, db_passwd, db)
#     try:
#         # cur = dbconn.cursor()
#         with dbconn.cursor() as cur:
#             cur.execute("delete from %s where %s ='%s'" % (table,field,value))
#             dbconn.commit()
#             # dbconn.close()
#     except Exception as e:
#         print ("Exception:", e)
        # print ("Exception at line no:", e.__traceback__.tb_lineno)
#         return 0
#     finally:
#         if dbconn is not None:
#             dbconn.close()

def delete_entry(table,field,value,cur):
    try:
        cur.execute("delete from %s where %s ='%s';" % (table,field,value))
        print(table, 'cleared')
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def delete_entry_2Fields(table,field1,value1,field2,value2,cur):
    try:
        cur.execute("delete from %s where %s ='%s' and %s ='%s';" % (table,field1,value1,field2,value2))
        print(table, 'cleared')
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
            

# def select_entry(table,field,value):
#     dbconn = connect_db(db_host, db_user, db_passwd, db)
#     try:
#         # cur = dbconn.cursor()
#         with dbconn.cursor() as cur:
#             cur.execute("select * from %s where %s ='%s'" % (table,field,value))
#             row = cur.fetchall()
#             print (row)
#             dbconn.commit()
#             # dbconn.close()
#     except Exception as e:
#         print ("Exception:", e)
        # print ("Exception at line no:", e.__traceback__.tb_lineno)
#         return 0
#     finally:
#         if dbconn is not None:
#             dbconn.close()

def select_entry(table,field,value,cur):
    try:
        cur.execute("select * from %s where %s ='%s';" % (table,field,value))
        print('Everything selected from ', field, 'for value', value,' in', table)
        row = cur.fetchall()
        return row
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def select_specific_entry(table,sfield,field,value,cur):
    try:
        cur.execute("select %s from %s where %s ='%s';" % (sfield,table,field,value))
        print(sfield, 'selected from ', field, 'for value', value,' in', table)
        row = cur.fetchall()
        return row
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def select_specific_entry_2Fields(table,sfield,field1,value1,field2,value2,cur):
    try:
        cur.execute("select %s from %s where %s ='%s' and %s ='%s';" % (sfield,table,field1,value1,field2,value2))
        print(sfield, 'selected for condition ', field1, '=', value1, 'and', field2, '=', value2, ' in', table)
        row = cur.fetchall()
        return row
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

# def update_entry(table,field,value,wfield,wid):
#     dbconn = connect_db(db_host, db_user, db_passwd, db)
#     try:
#         # cur = dbconn.cursor()
#         with dbconn.cursor() as cur:
#             cur.execute("UPDATE %s SET %s=%s WHERE %s='%s';" % (table,field,value,wfield,wid))
#             dbconn.commit()
#             # dbconn.close()
#     except Exception as e:
#         print ("Exception:", e)
        #   print ("Exception at line no:", e.__traceback__.tb_lineno)
#         return 0
#     finally:
#         if dbconn is not None:
#             dbconn.close()

def update_entry(table,field,value,wfield,wid,cur):
    try:
        cur.execute("UPDATE %s SET %s=%s WHERE %s='%s';" % (table,field,value,wfield,wid))
        print(field, 'updated with ', value, ' in', table)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def update_entry_2Fields(table,wfield,wid,field1,value1,field2,value2,cur):
    try:
        cur.execute("UPDATE %s SET %s=%s WHERE %s='%s' and %s ='%s';" % (table,wfield,wid,field1,value1,field2,value2))
        print(wfield, 'updated with ', wid, ' in', table)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def delete_queue_service(aid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM queue_tbl WHERE account='%s'" % aid)
            row = [str(item[0]) for item in cur.fetchall()]
            for i in range(len(row)) :
                cur.execute("DELETE FROM queue_service_tbl WHERE queue_id ='%s'" % (row[i]))
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


def delete_sequence_generator(aid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM queue_tbl WHERE account='%s'" % aid)
            row = [str(item[0]) for item in cur.fetchall()]
            for i in range(len(row)) :
                cur.execute("DELETE FROM sequence_generator_tbl WHERE queue ='%s'" % (row[i]))
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0    
    finally:
        if dbconn is not None:
            dbconn.close() 


def delete_ML_table(aid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM queue_tbl WHERE account='%s'" % aid)
            row = [str(item[0]) for item in cur.fetchall()]
            for i in range(len(row)) :
                cur.execute("DELETE FROM ml_tbl WHERE queue ='%s'" % (row[i]))
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0   
    finally:
        if dbconn is not None:
            dbconn.close() 


def delete_queue_stats_table(aid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM queue_tbl WHERE account='%s'" % aid)
            row = [str(item[0]) for item in cur.fetchall()]
            for i in range(len(row)) :
                cur.execute("DELETE FROM acct_queue_stats_tbl WHERE queue ='%s'" % (row[i]))
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0 
    finally:
        if dbconn is not None:
            dbconn.close()


def clear_queue (usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=get_acc_id(usrid)    
    uid = get_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('wl_state_tbl','account',aid,cur)
            delete_entry('wl_state_tbl','created_by',uid,cur)
            delete_entry('provider_note_tbl','account',aid,cur)
            delete_entry('wl_rating_tbl','account',aid,cur)
            delete_entry('wl_history_tbl','account',aid,cur)
            delete_entry('wl_history_tbl','created_by',uid,cur)
            delete_entry('wl_history_tbl','consumer_id',uid,cur)
            delete_entry('wl_cache_tbl','account',aid,cur)
            delete_entry('wl_cache_tbl','created_by',uid,cur)
            delete_entry('wl_cache_tbl','consumer_id',uid,cur)
            delete_queue_service(aid)
            delete_queue_stats_table(aid)
            delete_ML_table(aid)
            delete_entry('queue_tbl','account',aid,cur)
            delete_entry('holidays_tbl','account',aid,cur)
            reset_metric_usage(aid)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()
    
    
def clear_waitlist(email):
    print("In function: ", inspect.stack()[0].function)
    uid = get_id(email)
    aid = get_acc_id(email)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('wl_state_tbl','account',aid,cur)
            delete_entry('wl_state_tbl','created_by',uid,cur)
            # delete_entry('wl_provider_note_tbl','account',aid,cur)
            delete_entry('wl_rating_tbl','account',aid,cur)
            delete_entry('wl_history_tbl','account',aid,cur)
            delete_entry('wl_history_tbl','created_by',uid,cur)
            delete_entry('wl_history_tbl','consumer_id',uid,cur)
            delete_entry('wl_cache_tbl','account',aid,cur)
            delete_entry('wl_cache_tbl','created_by',uid,cur)
            delete_entry('wl_cache_tbl','consumer_id',uid,cur)
            delete_queue_stats_table(aid)
            delete_entry('holidays_tbl','account',aid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def delete_schedule_service(aid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM service_tbl WHERE account='%s'" % aid)
            row = [str(item[0]) for item in cur.fetchall()]
            for i in range(len(row)) :
                cur.execute("DELETE FROM schedule_service_tbl WHERE service_id ='%s'" % (row[i]))
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0  
    finally:
        if dbconn is not None:
            dbconn.close()


def delete_donation_service(usrid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    aid=get_acc_id(usrid)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM service_tbl WHERE account='%s'" % aid)
            row = [str(item[0]) for item in cur.fetchall()]
            for i in range(len(row)) :
                cur.execute("DELETE FROM donation_service_tbl WHERE id ='%s'" % (row[i]))
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0  
    finally:
        if dbconn is not None:
            dbconn.close()



def delete_virtual_service(usrid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    aid=get_acc_id(usrid)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM service_tbl WHERE account='%s'" % aid)
            row = [str(item[0]) for item in cur.fetchall()]
            for i in range(len(row)) :
                cur.execute("DELETE FROM virtual_service_tbl WHERE id ='%s'" % (row[i]))
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0 
    finally:
        if dbconn is not None:
            dbconn.close() 


def clear_service (usrid):
    print("In function: ", inspect.stack()[0].function)
    # clear_appt_service(usrid)
    # print  ("In clear_service")
    clear_waitlist(usrid)
    aid=get_acc_id(usrid)
    uid = get_id(usrid)
    delete_queue_service(aid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('queue_tbl','account',aid,cur)
            delete_entry('wl_rating_tbl','account',aid,cur)
            delete_entry('wl_history_tbl','account',aid,cur)
            delete_entry('wl_history_tbl','created_by',uid,cur)
            delete_entry('wl_history_tbl','consumer_id',uid,cur)
            delete_entry('donation_tbl','account',aid,cur)
            delete_entry('appmnt_archive_tbl','account',aid,cur)
            delete_entry('appt_rating_tbl','account',aid,cur)
            delete_entry('appt_tbl','account',aid,cur)
            delete_schedule_service(aid)
            cur.execute("SELECT id FROM service_tbl WHERE account='%s'" % aid)
            row = cur.fetchall()
            print (row) 
            # dbconn.commit()
            # dbconn.close()
    
            for index in range(len(row)):
                    delete_entry('virtual_service_tbl','id',int(row[index][0]),cur)
                    delete_entry('donation_service_tbl','id',int(row[index][0]),cur)
                    delete_entry('transaction_payment_tbl',"JSON_UNQUOTE(JSON_EXTRACT(`service`, '$.id'))",int(row[index][0]),cur)
                    delete_entry('wl_cache_tbl','service_id',int(row[index][0]),cur)
                    delete_entry('donation_tbl','service_id',int(row[index][0]),cur)
                    delete_entry('questionnaire_tbl','transaction_id',int(row[index][0]),cur)
                    delete_entry('virtual_service_tbl','id',int(row[index][0]),cur)
                    delete_entry('queue_service_tbl','service_id',int(row[index][0]),cur)
                    # delete_entry('schedule_service_tbl','service_id',int(row[index][0]),cur)
                    # delete_entry('appmnt_archive_tbl','service_id',int(row[index][0]),cur)
                    # delete_entry('appt_tbl','service_id',int(row[index][0]),cur)
                    # delete_entry('transaction_payment_tbl','service_id',int(row[index][0]),cur)
                    # delete_entry('service_tbl','id',int(row[index][0]),cur)
                    # delete_entry('appt_rating_tbl','service',int(row[index][0]),cur)
                    # delete_entry('service_tbl','id',int(row[index][0]),cur)
            # delete_entry('appmnt_archive_tbl','account',aid,cur)
            
            delete_entry('service_tbl','account',aid,cur)
            reset_metric_usage(aid)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


def reset_metric_usage(aid) :
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    # cur = dbconn.cursor()
    try :
        with dbconn.cursor() as cur:
            cur.execute("SELECT metric_usage FROM account_matrix_usage_tbl WHERE id='%s'" % aid)
            jsonVal = cur.fetchone()
        
            data= json.loads(jsonVal[0])
            ntm=data['nonTransientMetrics']
            for i in range(len(ntm)):
                if ntm[i]['metricId']==queue_service_metric_id:
                    ntm[i]['usage']=0
            data=json.dumps(data)
            cur.execute("update account_matrix_usage_tbl set metric_usage='%s' where id='%s';" % (data,aid))
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0 
    finally:
        if dbconn is not None:
            dbconn.close()


def clear_provider_msgs (usrid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    aid=get_acc_id(usrid)
    try:
        with dbconn.cursor() as cur:
            # cur = dbconn.cursor()
            ii = cur.execute("delete from provider_msg_tbl where account=%s" % aid)
            dbconn.commit()
            # dbconn.close()
            return ii
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0 
    finally:
        if dbconn is not None:
            dbconn.close()


def clear_consumer_msgs (usrid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    aid=get_id(usrid)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            ii = cur.execute("delete from consumer_msg_tbl where id=%s"% aid)
            dbconn.commit()
            # dbconn.close()
            return ii
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0  
    finally:
        if dbconn is not None:
            dbconn.close()       
     
def clear_location (usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=get_acc_id(usrid)
    clear_queue(usrid)
    clear_Rating(usrid)
    clear_appt_schedule(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try :
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            update_entry('account_info_tbl','base_location','NULL','id',aid,cur)
            delete_search(aid)
            delete_schedule_service(aid)
            delete_entry('transaction_payment_tbl','account',aid,cur)
            delete_entry('donation_tbl','account',aid,cur)
            
            # cur.execute("SELECT id FROM location_tbl WHERE account='%s'" % aid)
            # row = cur.fetchall()
            # print (row) 
            # for index in range(len(row)):
            #     delete_entry('appt_schedule_tbl','location_id',int(row[index][0]),cur)
            
            delete_entry('location_tbl','account',aid,cur)
            dbconn.commit()
        # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()
    
    
def clear_Consumermsg(usrid):
    print("In function: ", inspect.stack()[0].function)
    cid=get_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('consumer_msg_tbl','id',cid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()

def clear_Providermsg(usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=get_acc_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('provider_msg_tbl','account',aid,cur)
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()

def clear_Item(usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=get_acc_id(usrid)
    id=get_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('catalog_item_tbl','account',aid,cur) 
            delete_entry('item_tbl','account',aid,cur)
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()
   

def clear_Catalog(usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=get_acc_id(usrid)
    id=get_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('catalog_item_tbl','account',aid,cur)
            delete_entry('item_tbl','account',aid,cur)
            delete_entry('order_archive_tbl','account',aid,cur)
            delete_entry('order_tbl','account',aid,cur)
            delete_entry('catalog_tbl','account',aid,cur)
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()
    
    
def clear_Coupon(usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=get_acc_id(usrid)
    id=get_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('acc_coupon_tbl','account',aid,cur)
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()  

def clear_Discount(usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=get_acc_id(usrid)
    id=get_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('acc_discount_tbl','account',aid,cur) 
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()   
      
def clear_Bill(usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=  get_acc_id(usrid)
    uid=  get_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('bill_tbl','account_id',aid,cur)
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()

def clear_invoice(usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=get_acc_id(usrid)
    uid=get_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('invoice_details_tbl','created_by',uid,cur)
            delete_entry('invoice_tbl','account',aid,cur)
            delete_entry('acc_credit_debit_tbl','account',aid,cur)
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def clear_Rating(usrid):
    print("In function: ", inspect.stack()[0].function)
    uid=get_id(usrid)
    aid=get_acc_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('wl_rating_tbl','provider',uid,cur)
            ii = cur.execute("UPDATE account_rating_tbl SET avg_rating =0, count_of_rating=0 WHERE id=%s" %  aid)
            dbconn.commit()
            # dbconn.close()
            return ii
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0 
    finally:
        if dbconn is not None:
            dbconn.close()  

def clear_Family(uid): 
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:   
            delete_entry('wl_cache_tbl','waitlisting_for',uid,cur)  
            delete_entry('wl_history_tbl','waitlisting_for',uid,cur)
            delete_entry('user_tbl','id',uid,cur)  
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close() 

def clear_FamilyMember(consumer_id):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('bill_tbl','consumer_id',consumer_id,cur)    
            delete_entry('family_member_tbl','pro_con_parent_id',consumer_id,cur) 
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close() 

def clear_Alert (aid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('alert_tbl','account',aid,cur)
            delete_entry('alert_tbl','account',1,cur)
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close() 

def clear_favorite_provider (usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=get_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('favorite_local_user_tbl','account_id',aid,cur)
            cur.execute("SELECT id FROM favorite_local_user_tbl WHERE account_id='%s'" % aid)
            row = [str(item[0]) for item in cur.fetchall()]
            for i in range(len(row)) :
                cur.execute("DELETE FROM favorite_local_user_tbl WHERE id ='%s'" % (row[i]))
        dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()

def clear_Auditlog (usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=get_acc_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('audit_log_tbl','account',aid,cur)
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()
    
def clear_licence (aid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('account_license_tbl','account',aid,cur)
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()
   
def clear_Addon (usrid):
    print("In function: ", inspect.stack()[0].function)
    acid =  get_acc_id(usrid) 
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            ii = cur.execute("delete from account_license_tbl where base=0 and account='%s'" % acid)
            dbconn.commit()
            # dbconn.close()
            return ii
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def clear_Adword (acid):
    print("In function: ", inspect.stack()[0].function)
    # delete_entry('adword_tbl','account',acid,cur)
    # delete_entry('account_matrix_usage_tbl','id',acid,cur)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('adword_tbl','account',acid,cur)
            delete_entry('account_matrix_usage_tbl','id',acid,cur)
            # ii = cur.execute("update account_info_tbl set metric_usage =NULL where id='%s'" % acid)
            dbconn.commit()
            # dbconn.close()
            return 1
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0 
    finally:
        if dbconn is not None:
            dbconn.close()


def get_claim_id(name):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("select id from account_info_tbl where business_name ='%s'" %(name))
            row = cur.fetchone()
            cur.execute("select id from location_tbl where account ='%s'" %(row[0]))
            row1 = cur.fetchone()
            # dbconn.close()
            return  (str(row[0])+'-'+str(row1[0]))
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()



def clear_claims(name):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("select id from account_info_tbl where business_name ='%s'" %(name))
            row = cur.fetchone()
            cur.execute("select id from location_tbl where account ='%s'" %(row[0]))
            row1 = cur.fetchone()
            cur.execute("INSERT INTO search_data_tbl(intent,account,id) VALUES (2,%s,%s) ON DUPLICATE KEY UPDATE intent=2" % (row[0],row1[0]))
            delete_entry('account_info_tbl','id',row[0],cur)
            delete_entry('location_tbl','account',row[0],cur)
            delete_entry('account_tbl','id',row[0],cur)
            dbconn.commit()
            # dbconn.close()    
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()
    


def clear_claim():
    clear_claims('Netvarth Hospital')
    clear_claims('Netvarth Hotel')


def clear_jaldeecoupon (code):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('jc_tbl','coupon_code',code,cur)
            delete_entry('jc_live_stat_tbl','coupon_code',code,cur)
            delete_entry('jc_provider_stats_tbl','coupon_code',code,cur)
            delete_entry('jc_live_tbl','coupon_code',code,cur)
            delete_entry('provider_jc_tbl','coupon',code,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def clear_tax_gstNum (usrid):
    print("In function: ", inspect.stack()[0].function)
    acid =  get_acc_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('ynw.tax_tbl','tax_percentage',acid,cur)
            delete_entry('ynw.tax_tbl','gst_number',acid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def clear_corporate (uid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('corporate_tbl','corporate_uid',uid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()

def clear_branch (code):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('branch_tbl','branch_code',code,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()

def clear_JaldeeAlerts (usrid):
    print("In function: ", inspect.stack()[0].function)
    acid =  get_acc_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('alert_tbl','account',acid,cur)
            delete_entry('alert_tbl','account',1,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()

def clear_Department (usrid):
    print("In function: ", inspect.stack()[0].function)
    acid =  get_acc_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('department_tbl','account',acid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()

def get_time():
    BASE_URL = __import__(os.environ['VARFILE']).BASE_URL
    URL = BASE_URL + '/provider/server/date'
    r = requests.get(url = URL)
    log_request(r)
    log_response(r)
    data = r.json()
    date,time= data.split()
    try:
        time1= datetime.datetime.strptime(time, '%H:%M:%S').time()
        t= time1.strftime("%I:%M %p")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def add_time(h,m):
    try:
        t= get_time()
        time2= datetime.datetime.strptime(t, '%I:%M %p').time()
        d= get_date()
        d1= datetime.datetime.strptime(d, '%Y-%m-%d').date()
        a= datetime.datetime.combine(d1, time2)
        b= a + datetime.timedelta(hours=int(h),minutes=int(m))
        t = b.strftime("%I:%M %p")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def subtract_time(h,m):
    try:
        t= get_time()
        time2= datetime.datetime.strptime(t, '%I:%M %p').time()
        d= get_date()
        d1= datetime.datetime.strptime(d, '%Y-%m-%d').date()
        a= datetime.datetime.combine(d1, time2)
        b= a- datetime.timedelta(hours=int(h),minutes=int(m))
        t = b.strftime("%I:%M %p")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def get_date():
    BASE_URL = __import__(os.environ['VARFILE']).BASE_URL
    URL = BASE_URL + '/provider/server/date'
    r = requests.get(url = URL)
    log_request(r)
    log_response(r)
    data = r.json()
    date,time= data.split()
    try:
        b= datetime.datetime.strptime(date, '%Y-%m-%d').date()
        date = b.strftime("%Y-%m-%d")
        return date
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
       
def add_date(days):
    try:
        t= get_time()
        time2= datetime.datetime.strptime(t, '%I:%M %p').time()
        d= get_date()
        d1= datetime.datetime.strptime(d, '%Y-%m-%d').date()
        a= datetime.datetime.combine(d1, time2)
        b= a + datetime.timedelta(days=int(days))
        date = b.strftime("%Y-%m-%d")
        return date
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def subtract_date(days):
    try:
        t= get_time()
        time2= datetime.datetime.strptime(t, '%I:%M %p').time()
        d= get_date()
        d1= datetime.datetime.strptime(d, '%Y-%m-%d').date()
        a= datetime.datetime.combine(d1, time2)
        b= a - datetime.timedelta(days=int(days))
        date = b.strftime("%Y-%m-%d")
        return date
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

# def get_weekday():
#     user=os.environ['USERNAME']
#     hostip=os.environ['IP_ADDRESS']
#     userpass=os.environ['SSHPASS']
#     try:
#         command1= "date +%u"
#         command="echo "+userpass+" |sshpass  -p "+userpass+" ssh -tt "+user+"@"+hostip+" sudo -S "+command1
#         proc=subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
#         out, err= proc.communicate()
#         print out
#         print err
#         d=int(out)
#         if d==7:
#             return 1
#         else:
#             return d+1
#     except:
#         return 0

def get_weekday():
    
    try:
        d= get_date()
        d1= datetime.datetime.strptime(d, '%Y-%m-%d').isoweekday()
        day=int(d1)
        if day==7:
            return 1
        else:
            return day+1
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def get_weekday_by_date(date):
    
    try:
        d= datetime.datetime.strptime(date, '%Y-%m-%d').isoweekday()
        day=int(d)
        if day==7:
            return 1
        else:
            return day+1
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0


def SetMerchantId(accNo,mid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            uu=cur.execute("update account_payment_settings_tbl set payu_merchant_id='%s' where id ='%s'  "% (mid,accNo))
            dbconn.commit()
            # dbconn.close()
            return uu
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


def change_system_time(h,m):
    user=os.environ['USERNAME']
    hostip=os.environ['IP_ADDRESS']
    userpass=os.environ['SSHPASS']
    try:
        command2="echo "+userpass+" |sshpass  -p "+userpass+" ssh -tt "+user+"@"+hostip+" sudo -S timedatectl set-ntp 0"
        subprocess.call(command2, shell=True)
        t = datetime.datetime.now()
        t += datetime.timedelta(hours=int(h),minutes=int(m))
        str=t.strftime("%m%d%H%M%y.%S")
        command="echo "+userpass+" |sshpass  -p "+userpass+" ssh -tt "+user+"@"+hostip+" sudo -S date "+str
        # os.system(command)
        subprocess.call(command, shell=True)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno) 
        return 0

def resetsystem_time():
    user=os.environ['USERNAME']
    hostip=os.environ['IP_ADDRESS']
    userpass=os.environ['SSHPASS']
    try:
        command1="echo "+userpass+" |sshpass  -p "+userpass+" ssh -tt "+user+"@"+hostip+" sudo -S hwclock --hctosys"
        a=subprocess.call(command1,shell=True)
        if a==1:
            command2="echo "+userpass+" |sshpass  -p "+userpass+" ssh -tt "+user+"@"+hostip+" sudo -S timedatectl set-ntp 1"
            subprocess.call(command2, shell=True)    
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno) 
        return 0

def change_system_date(d):
    user=os.environ['USERNAME']
    print ("USERNAME:", user)
    hostip=os.environ['IP_ADDRESS']
    print ("hostip:", hostip)
    userpass=os.environ['SSHPASS']
    print ("userpass:", userpass)
    try:
        command2="echo "+userpass+" |sshpass  -p "+userpass+" ssh -tt "+user+"@"+hostip+" sudo -S timedatectl set-ntp 0"
        subprocess.call(command2, shell=True)
        t = datetime.datetime.now()
        t += datetime.timedelta(days=int(d))
        str=t.strftime("%m%d%H%M%y.%S")
        command="echo "+userpass+" |sshpass  -p "+userpass+" ssh -tt "+user+"@"+hostip+" sudo -S date "+str+" |sleep 2"
        subprocess.call(command, shell=True)
    #   os.system(command)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0


def bill_cycle():
    # date = datetime.date.today()
    d = get_date()
    date= datetime.datetime.strptime(d, '%Y-%m-%d').date()
    mo= date.month
    ye= date.year
    try:
        if (mo==12):
            d= date.replace(year=ye+1,month=1)
        else :
            d= date.replace(month=mo+1)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        a= calendar.monthrange(ye,mo+1)
        d= date.replace(month=mo+1,day=a[1])
    return str(d)
    

def change_date(date):
    # date= datetime.datetime.strptime(date, '%Y-%m-%d').date()
    y,m,d=date.split("-")
    # t = datetime.datetime.now()
    time2= get_time()
    t= datetime.datetime.strptime(time2, '%I:%M %p').time()
    t = datetime.datetime(year=int(y),month=int(m),day=int(d),hour=t.hour,minute=t.minute)
    str=t.strftime("%m%d%H%M%y.%S")
    user=os.environ['USERNAME']
    hostip=os.environ['IP_ADDRESS']
    userpass=os.environ['SSHPASS']
    # os.system("sudo date '%s'" %str)
    command2="echo "+userpass+" |sshpass  -p "+userpass+" ssh -tt "+user+"@"+hostip+" sudo -S timedatectl set-ntp 0"
    subprocess.call(command2, shell=True)
    command="echo "+userpass+" |sshpass  -p "+userpass+" ssh -tt "+user+"@"+hostip+" sudo -S date "+str
    subprocess.call(command, shell=True)

def bill_cycle_annual():
    d = get_date()
    # date = datetime.date.today()
    date= datetime.datetime.strptime(d, '%Y-%m-%d').date()
    mo= date.month
    ye= date.year
    try:
        d= date.replace(year=ye+1)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        a= calendar.monthrange(ye+1,mo)
        d=date.replace(year=ye+1,day=a[1])
    return str(d)

    
def payuVerify(accNo):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("update account_payment_settings_tbl set payu_verified=true where account ='%s'" % accNo)
            # cur.execute("update account_payment_settings_tbl set is_default_account=false  where id ='%s'" % accNo)
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


def get_days(sdate,edate):
    sdate= datetime.datetime.strptime(sdate , '%Y-%m-%d')
    edate= datetime.datetime.strptime(edate , '%Y-%m-%d')
    return  (edate-sdate).days

def pay_invoice(uid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("update invoice_tbl set invoice_status=0  where uuid ='%s'" % uid)
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


def delete_search(aid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM location_tbl WHERE account='%s'" % aid)
            row = [str(item[0]) for item in cur.fetchall()]
            for i in range(len(row)) :
                cur.execute("INSERT INTO search_data_tbl(intent,id,account) VALUES (2,%s,%s) ON DUPLICATE KEY UPDATE intent=2" % (row[i],aid))
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
    finally:
        if dbconn is not None:
            dbconn.close()



#def clear_reimburseReport(usrid):
    #aid=  get_acc_id(usrid)
    #uid=  get_id(usrid)

    #cur.execute("delete FROM payment_tbl")
    #cur.execute("delete FROM reimburse_payment_tbl")
    #cur.execute("delete FROM reimburse_invoice_tbl")
    #cur.execute("delete FROM bill_tbl")
    #cur.execute("delete FROM jc_provider_stats_tbl")
    #cur.execute("delete FROM jc_live_stat_tbl")
    #dbconn.commit()
    #dbconn.close()
    #except:
        #return 0  

def clear_payment_invoice (usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=  get_acc_id(usrid)
    uid=  get_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('payment_tbl','account_id',aid,cur)   
            delete_entry('reimburse_payment_tbl','account',1,cur)  
            delete_entry('reimburse_invoice_tbl','account',aid,cur) 
            delete_entry('bill_tbl','account_id',aid,cur)
            delete_entry('jc_provider_stats_tbl','provider_id',aid,cur)
            delete_entry('jc_live_stat_tbl','provider_id',aid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()

    
def add_time24(h,m):
    BASE_URL = __import__(os.environ['VARFILE']).BASE_URL
    URL = BASE_URL + '/provider/server/date'
    r = requests.get(url = URL)
    log_request(r)
    log_response(r)
    data = r.json()
    # print data
    try:
        a= datetime.datetime.strptime(data, '%Y-%m-%d %H:%M:%S')        
        b= a + datetime.timedelta(hours=int(h),minutes=int(m))
        t = b.strftime("%Y-%m-%d %H:%M:%S")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0   



def replce_date_claim():
    with open('TDD/data.csv','r', encoding="utf-8") as f:
        old=f.read()
    new = old.replace('DATE',time.strftime("%d-%m-%Y"))
    with open('TDD/data.csv','w', encoding="utf-8") as f:
        f.write(new)

def restore_date_claim():
    with open('TDD/data.csv','r', encoding="utf-8") as f:
        old=f.read()
    new = old.replace(time.strftime("%d-%m-%Y"),'DATE')
    with open('TDD/data.csv','w', encoding="utf-8") as f:
        f.write(new)

def roundval(fval,preci):
    return round(float(fval),int(preci))

def get_place() :       
    # with open(pfile,'r', encoding="utf-8") as data:
    with open(addressfile,'r', encoding="utf-8") as data:
        csv_reader=csv.DictReader(data)
        k=list(csv_reader)
        random_row = random.choice(k)
        # place = random_row['Area']
        place = random_row['Place']
        for place in loclist:
            random_row = random.choice(k)
            # place = random_row['Area']
            place = random_row['Place']
        else:
            loclist.append(place)
    return place

def get_latitude() :
    # with open(pfile,'r', encoding="utf-8") as data:
    with open(addressfile,'r', encoding="utf-8") as data:
        csv_reader=csv.DictReader(data)
        k=list(csv_reader)
        random_row = random.choice(k)
        lat = random_row['Latitude']
    return lat

def get_longitude() :
    # with open(pfile,'r', encoding="utf-8") as data:
    with open(addressfile,'r', encoding="utf-8") as data:
        csv_reader=csv.DictReader(data)
        k=list(csv_reader)
        random_row = random.choice(k)
        lon = random_row['Longitude']
    return lon

def get_lat_long() :
    # with open(pfile,'r', encoding="utf-8") as data:
    with open(addressfile,'r', encoding="utf-8") as data:
        csv_reader=csv.DictReader(data)
        k=list(csv_reader)
        random_row = random.choice(k)
        lat = random_row['Latitude']
        lon = random_row['Longitude']
    return lat,lon


def get_lat_long_city() :
    # with open(pfile,'r', encoding="utf-8") as data:
    with open(addressfile,'r', encoding="utf-8") as data:
        csv_reader=csv.DictReader(data)
        k=list(csv_reader)
        random_row = random.choice(k)
        lat = random_row['Latitude']
        lon = random_row['Longitude']
        place = random_row['Place']
    return lat,lon,place

def get_lat_long_city_pin() :
    # with open(pfile,'r', encoding="utf-8") as data:
    with open(addressfile,'r', encoding="utf-8") as data:
        csv_reader=csv.DictReader(data)
        k=list(csv_reader)
        random_row = random.choice(k)
        lat = random_row['Latitude']
        lon = random_row['Longitude']
        place = random_row['Place']
        pin = random_row['Pincode']
    return lat,lon,place,str(pin)

def get_pincode() :
    # with open(pfile,'r', encoding="utf-8") as data:
    with open(addressfile,'r', encoding="utf-8") as data:
        csv_reader=csv.DictReader(data)
        k=list(csv_reader)
        random_row = random.choice(k)
        pin = random_row['Pincode']
    return str(pin)

# def get_address() :
#     with open(pfile,'r', encoding="utf-8") as data:
#         csv_reader=csv.DictReader(data)
#         k=list(csv_reader)
#         random_row = random.choice(k)
#         add = random_row['Address']
#     return add.strip()

def get_address() :
    with open(addressfile,'r', encoding="utf-8") as data:
        csv_reader=csv.DictReader(data)
        k=list(csv_reader)
        random_row = random.choice(k)
        add = random_row['Place'] + ',' + random_row['District'] + ',' + random_row['State']+ '-' + str(random_row['Pincode'])
    return add.strip()

def get_loc_details() :
    # with open(pfile,'r', encoding="utf-8") as data:
    with open(addressfile,'r', encoding="utf-8") as data:
        csv_reader=csv.DictReader(data)
        k=list(csv_reader)
        random_row = random.choice(k)
        lat = random_row['Latitude']
        lon = random_row['Longitude']
        pin = random_row['Pincode']
        place = random_row['Place']
        district = random_row['District']
        state = random_row['State']
        add = random_row['Place'] + ',' + random_row['District'] + ',' + random_row['State']+ '-' + str(random_row['Pincode'])
    return lat,lon,str(pin),place,district,state,add.strip()

def get_pin_loc() :
    # with open(pfile,'r', encoding="utf-8") as data:
    with open(addressfile,'r', encoding="utf-8") as data:
        csv_reader=csv.DictReader(data)
        k=list(csv_reader)
        random_row = random.choice(k)
        pin = random_row['Pincode']
        place = random_row['Place']
        district = random_row['District']
        state = random_row['State']
    return pin,place,district,state

def get_lat_long_add_pin() :
    # with open(pfile,'r', encoding="utf-8") as data:
    with open(addressfile,'r', encoding="utf-8") as data:
        csv_reader=csv.DictReader(data)
        k=list(csv_reader)
        random_row = random.choice(k)
        lat = random_row['Latitude']
        lon = random_row['Longitude']
        pin = random_row['Pincode']
        add = random_row['Place'] + ',' + random_row['District'] + ',' + random_row['State']+ '-' + str(random_row['Pincode'])
    return lat,lon,str(pin),add.strip()

def get_Subdomainfields(datas) :
    fake = Faker()
    # data= json.loads(datas)
    data= datas
    fields= {}
    fields_list= []
    virtual_fields= {}
    for i in range(len(data)):
            name = data[i]['name']
            print ('name: ', name)
            if data[i]['mandatory'] == True:
                if 'Columns' in data[i]:
                    c= len(data[i]['Columns'])
                    for j in range(c):                           
                            key_name =  data[i]['Columns'][j]['key']
                            if  data[i]['Columns'][j]['type'] == 'Enum':
                                index_len= len(data[i]['Columns'][j]['enumeratedConstants'])
                                rand_idx = random.randrange(index_len)
                                key_value = data[i]['Columns'][j]['enumeratedConstants'][rand_idx]['name']
                                fields[key_name]=key_value
                            elif  data[i]['Columns'][j]['type'] == 'TEXT':
                                key_value = Generate_random_value(3,string.ascii_uppercase)
                                fields[key_name]=key_value
                            elif  data[i]['Columns'][j]['type'] == 'DT_Month':
                                key_value = fake.month_name()
                                fields[key_name]=key_value
                            elif  data[i]['Columns'][j]['type'] == 'DT_Year':
                                key_value = fake.year()
                                fields[key_name]=key_value 
                    fields_list.append(fields)
                    virtual_fields[name] = fields_list
                elif 'Columns' not in data[i]:
                    if data[i]['dataType'] == 'TEXT':
                        virtual_fields[name] =fake.name()
                    elif data[i]['dataType'] == 'Gender':
                        index_len= len(data[i]['enumeratedConstants'])
                        rand_idx = random.randrange(index_len)
                        virtual_fields[name] = data[i]['enumeratedConstants'][rand_idx]['name']
                    elif data[i]['dataType'] == 'EnumList':
                        index_len= len(data[i]['enumeratedConstants'])
                        rand_idx = random.randrange(index_len)
                        virtual_fields[name] = data[i]['enumeratedConstants'][rand_idx]['name']

                # return virtual_fields
            # else:
            #     if 'Columns' in data[i]:
            #         c= len(data[i]['Columns'])
            #         for j in range(c):                           
            #                 key_name =  data[i]['Columns'][j]['key']
            #                 if  data[i]['Columns'][j]['type'] == 'Enum':
            #                     index_len= len(data[i]['Columns'][j]['enumeratedConstants'])
            #                     rand_idx = random.randrange(index_len)
            #                     key_value = data[i]['Columns'][j]['enumeratedConstants'][rand_idx]['name']
            #                     fields[key_name]=key_value
            #                 elif  data[i]['Columns'][j]['type'] == 'TEXT':
            #                     key_value = Generate_random_value(3,string.ascii_uppercase)
            #                     fields[key_name]=key_value
            #                 elif  data[i]['Columns'][j]['type'] == 'DT_Month':
            #                     key_value = fake.month_name()
            #                     fields[key_name]=key_value
            #                 elif  data[i]['Columns'][j]['type'] == 'DT_Year':
            #                     key_value = fake.year()
            #                     fields[key_name]=key_value 
            #         fields_list.append(fields)
            #         virtual_fields[name] = fields_list
            #     elif 'Columns' not in data[i]:
            #         if data[i]['dataType'] == 'TEXT':
            #             virtual_fields[name] =fake.name()
            #         elif data[i]['dataType'] == 'Gender':
            #             index_len= len(data[i]['enumeratedConstants'])
            #             rand_idx = random.randrange(index_len)
            #             virtual_fields[name] = data[i]['enumeratedConstants'][rand_idx]['name']
            #         elif data[i]['dataType'] == 'EnumList':
            #             index_len= len(data[i]['enumeratedConstants'])
            #             rand_idx = random.randrange(index_len)
            #             virtual_fields[name] = data[i]['enumeratedConstants'][rand_idx]['name']

                # return virtual_fields
                # return random.choice((virtual_fields,{}))


    return virtual_fields

def get_Subdomainfields_OfUser(datas) :
    fake = Faker()
    # data= json.loads(datas)
    data= datas
    fields= {}
    fields_list= []
    virtual_fields= {}
    for i in range(len(data)):
            name = data[i]['name']
            if 'Columns' in data[i]:
                c= len(data[i]['Columns'])
                for j in range(c):                           
                    key_name =  data[i]['Columns'][j]['key']
                    if  data[i]['Columns'][j]['type'] == 'Enum':
                        e= len(data[i]['Columns'][j]['enumeratedConstants'])
                        key_value = data[i]['Columns'][j]['enumeratedConstants'][0]['name']
                        fields[key_name]=key_value
                    elif  data[i]['Columns'][j]['type'] == 'TEXT':
                        key_value = Generate_random_value(3,string.ascii_uppercase)
                        fields[key_name]=key_value
                    elif  data[i]['Columns'][j]['type'] == 'DT_Month':
                        key_value = fake.month_name()
                        fields[key_name]=key_value
                    elif  data[i]['Columns'][j]['type'] == 'DT_Year':
                        key_value = fake.year()
                        fields[key_name]=key_value 
                fields_list.append(fields)
                virtual_fields[name] = fields_list
            elif 'Columns' not in data[i]:
                if data[i]['dataType'] == 'TEXT':
                    virtual_fields[name] =fake.name()
                elif data[i]['dataType'] == 'Gender':
                    virtual_fields[name] = data[i]['enumeratedConstants'][0]['name']

    return virtual_fields

def get_Domainfields(datas) :
    fake = Faker()
    # data= json.loads(datas)
    data= datas
    fields= {}
    fields_sub= {}
    fields_list= []
    sub_list= []
    for i in range(len(data)):
            name = data[i]['name']
            if  data[i]['dataType'] == 'TEXT':
                key_value = Generate_random_value(3,string.ascii_uppercase)
                fields[name]=key_value
            elif  data[i]['dataType'] == 'TEXT_MED':
                key_value = fake.word()
                fields[name]=key_value
            elif  data[i]['dataType'] == 'Enum':
                e= len(data[i]['enumeratedConstants'])
                key_value = data[i]['enumeratedConstants'][0]['name']          
                fields[name]=key_value     
            elif  data[i]['dataType'] == 'DataGrid':
                c= len(data[i]['Columns'])
                for j in range(c):                           
                            key_name =  data[i]['Columns'][j]['key']
                            if  data[i]['Columns'][j]['type'] == 'TEXT':
                                key_value = Generate_random_value(3,string.ascii_uppercase)
                                fields_sub[key_name]=key_value
                            elif  data[i]['Columns'][j]['type'] == 'DT_Month':
                                key_value = fake.month_name()
                                fields_sub[key_name]=key_value
                            elif  data[i]['Columns'][j]['type'] == 'DT_Year':
                                key_value = fake.year()
                                fields_sub[key_name]=key_value 
                fields_list.append(fields_sub)  
                # print (fields_list)
                fields[name]=fields_list
            elif  data[i]['dataType'] == 'URL':
                key_value = fake.url()
                fields[name]=key_value
            elif  data[i]['dataType'] == 'EnumList':
                e= len(data[i]['enumeratedConstants'])
                # print (e)
                for k in range(e): 
                    key_value = data[i]['enumeratedConstants'][k]['name']
                    sub_list.append(key_value)  
                # print (sub_list)
                fields[name]=sub_list
    return fields

def get_Specializations(datas):
    values= {}
    fields_list= []
    # data= json.loads(datas)
    data= datas
    for i in range(len(data)):
        fields_list.append(data[i]['name'])
    values['specialization']= fields_list
    return values

def get_Languagespoken(datas):
    values= {}
    fields_list= []
    # data= json.loads(datas)
    data= datas
    for i in range(len(data)):
        fields_list.append(data[i]['name'])
    values= fields_list
    return values

def get_specs(datas):
    values= {}
    fields_list= []
    # data= json.loads(datas)
    data= datas
    for i in range(len(data)):
        fields_list.append(data[i]['name'])
    values= fields_list
    return values

def Parking_Types(datas):
    fields_list= []
    # data= json.loads(datas)
    data= datas
    for i in range(len(data)):
        fields_list.append(data[i])
    return fields_list


def clear_Provider_Notification_Settings (usrid):
    print("In function: ", inspect.stack()[0].function)
    acid =  get_acc_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('ynw.notification_settings_tbl','account',acid, cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def compare_json_data(source_data_a,source_data_b):

	def compare(data_a,data_b):
		# type: list
		if (type(data_a) is list):
			# is [data_b] a list and of same length as [data_a]?
			if (
				(type(data_b) != list) or
				(len(data_a) != len(data_b))
			):
				return False

			# iterate over list items
			for list_index,list_item in enumerate(data_a):
				# compare [data_a] list item against [data_b] at index
				if (not compare(list_item,data_b[list_index])):
					return False

			# list identical
			return True


		if (type(data_a) is dict):
			# is [data_b] a dictionary?
			if (type(data_b) != dict):
				return False

			# iterate over dictionary keys
			for dict_key,dict_value in data_a.items():
				# key exists in [data_b] dictionary, and same value?
				if (
					(dict_key not in data_b) or
					(not compare(dict_value,data_b[dict_key]))
				):
					return False

			# dictionary identical
			return True

		# simple value - compare both value and type for equality
		return (
			(data_a == data_b) and
			(type(data_a) is type(data_b))
		)

	# compare a to b, then b to a
	return (
		compare(source_data_a,source_data_b) and
		compare(source_data_b,source_data_a)
	)


def Generate_random_value(size=1, chars=string.ascii_uppercase + string.digits) :
    # Generate a random alphanumeric value based on upper case alphabets and digits of the given size
    return (''.join(random.choice(chars) for _ in range(size)))

def Compare_data_from_file(val,fname) :
    # Compare passed data with contents of file.
    try:
        f=open(fname,"a+")
        contents=f.readline()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return True
    if (contents == ""):
            return True               
    else:
        for x in contents:
            if ( val != x ):
                    return True
            else:
                    return False
    f.close

def Generate_pan_number() :
    # Generates unique pan number in comparison to values in pan.txt, stores it in pan.txt and returns pan number
        status=['A','B','C','F','G','H','L','J','P','T','E']
        random_val1= Generate_random_value(3,string.ascii_uppercase)
        stat= random.choice(status)
        namefl= Generate_random_value(1,string.ascii_uppercase)
        random_val2= Generate_random_value(4,string.digits)
        checksum= Generate_random_value(1,string.ascii_uppercase)
        pan= str(random_val1)+str(stat)+str(namefl)+str(random_val2)+str(checksum)
        if os.path.isfile(fname) and os.access(fname, os.R_OK):
            val_exists= Compare_data_from_file(pan,fname)            
        else:
            val_exists= True
        if val_exists:
                f=open(fname,'a+')
                f.write(pan+"\n")
                f.close
                return (pan)
        else:
                Generate_pan_number()

def Generate_gst_number(cid):
    #Generates unique GST Number using pan number
    val3= Generate_random_value()
    pan= Generate_pan_number()
    gstnum= str(cid)+str(pan)+'1Z'+str(val3)
    return [gstnum, pan]

def Generate_ifsc_code() :
    #Generates IFSC code for bank
    bankcode= Generate_random_value(4,string.ascii_uppercase)
    branchcode= Generate_random_value(4,string.digits)
    ifsccode= str(bankcode)+'000'+str(branchcode)
    return ifsccode


def get_metric_license(metric):
    print("In function: ", inspect.stack()[0].function)
    #find the license package id where the the given metric has the given value
    metric_id=0
    with open(licjson, 'r', encoding="utf-8") as f:
        data=json.load(f)
    
    for i in range(len(data['metrics'])):
        if str(data['metrics'][i]['name']) == str(metric):
            metric_id=  data['metrics'][i]['id']
            
    liclist=[]        
    for j in range(len(data['licensablePackages'])):
        for k in range(len(data['licensablePackages'][j]['metrics'])):
            if data['licensablePackages'][j]['metrics'][k]['id'] == metric_id:
                if (data['licensablePackages'][j]['metrics'][k]['anyTimeValue']) or data['licensablePackages'][j]['metrics'][k]['anyTimeValue'] > 0 :
                    licdict={"id": data['licensablePackages'][j]['pkgId'], "license": data['licensablePackages'][j]['pkgName']}
                    liclist.append(licdict)
    return liclist

     
def get_highest_license_pkg():
    #Getting the highest license package from basic packages in license config
    with open(licjson,'r', encoding="utf-8") as datas:
        data= json.load(datas)
    l= len(data['basePackages'])
    id= str(data['basePackages'][l-1]['id'])
    name= str(data['basePackages'][l-1]['name'])
    return [id, name]

def get_lowest_license_pkg():
    #Getting the lowest license package from basic packages in license config
    with open(licjson,'r', encoding="utf-8") as datas:
        data= json.load(datas)
    id= str(data['basePackages'][0]['id'])
    name= str(data['basePackages'][0]['name'])
    return [id, name]

def get_billable_domain():
    try:
        with open(bizjson,'r', encoding="utf-8") as f:
            data=json.load(f)
    except IOError:
        print ('File',bizjson,'not accessible')
    domlist=[]
    subdomlist=[]
    for i in range(len(data['businessDomains'])):        
        if data['businessDomains'][i]['subDomains'][0]['serviceBillable'] == True:
            domlist.append(data['businessDomains'][i]['domain'])
            subdomlist.append(data['businessDomains'][i]['subDomains'][0]['subDomain'])
    return [domlist, subdomlist]

def get_mutilocation_domains():
    try:
        with open(bizjson,'r', encoding="utf-8") as f:
            data=json.load(f)
    except IOError:
        print ('File',bizjson,'not accessible')
    domlist=[]
    for i in range(len(data['businessDomains'])):
        if data['businessDomains'][i]['multipleLocation'] == True:
            subdomlist=[]
            for j in range(len(data['businessDomains'][i]['subDomains'])):
                if data['businessDomains'][i]['subDomains'][j]['multipleLocation'] == True:
                    subdomlist.append(data['businessDomains'][i]['subDomains'][j]['subDomain'])
            if len(subdomlist) == 0:
                continue
            domdict={"domain": data['businessDomains'][i]['domain'], "subdomains": subdomlist}
            domlist.append(domdict)
    return domlist

def check_is_multilocation_subdomain(domain,subdomain):
    try:
        with open(bizjson,'r', encoding="utf-8") as f:
            data=json.load(f)
    except IOError:
        print ('File',bizjson,'not accessible')
    for i in range(len(data['businessDomains'])):        
        if str(data['businessDomains'][i]['domain'])==str(domain):
            for j in range(len(data['businessDomains'][i]['subDomains'])):
                if str(data['businessDomains'][i]['subDomains'][j]['subDomain'])==str(subdomain):
                    status= data['businessDomains'][i]['subDomains'][j]['multipleLocation']
    return status

def check_is_multilocation(domain):
    try:
        with open(bizjson,'r', encoding="utf-8") as f:
            data=json.load(f)
    except IOError:
        print ('File',bizjson,'not accessible')
    for i in range(len(data['businessDomains'])):        
        if str(data['businessDomains'][i]['domain'])==str(domain):
            status= data['businessDomains'][i]['multipleLocation']
    return status

def get_maxpartysize_subdomain():
    try:
        with open(bizjson,'r', encoding="utf-8") as f:
            data=json.load(f)
    except IOError:
        print ('File',bizjson,'not accessible')         
    for i in range(len(data['businessDomains'])):
        for a in range(len(data['businessDomains'][i]['subDomains'])):
            if data['businessDomains'][i]['subDomains'][a]['maxPartySize'] > 1:
                domdict={"Domainid": data['businessDomains'][i]['id'], "domain": data['businessDomains'][i]['domain'], 
                "subdomainid": data['businessDomains'][i]['subDomains'][a]['id'], "subdomain": data['businessDomains'][i]['subDomains'][a]['subDomain']}
                exit
    return domdict

def add_two(h,m):	
    try:
        att1 = datetime.datetime.strptime(h, "%I:%M %p")
        result = att1 + datetime.timedelta(minutes=int(m))
        return result.strftime("%I:%M %p")
    except:
        return 0

def sub_two(h,m):	
    try:
        att1 = datetime.datetime.strptime(h, "%I:%M %p")
        result = att1 - datetime.timedelta(minutes=int(m))
        return result.strftime("%I:%M %p")
    except:
        return 0

def clear_Label (usrid):
    print("In function: ", inspect.stack()[0].function)
    acid =  get_acc_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('ynw.label_tbl','account_id',acid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()

def clear_Statusboard (usrid):
    print("In function: ", inspect.stack()[0].function)
    acid =  get_acc_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('ynw.account_matrix_usage_tbl','id',acid,cur)
            delete_entry('ynw.wl_sb_tbl','account_id',acid,cur)
            delete_entry('ynw.sb_dimension_tbl','account_id',acid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()
    

def get_jaldeekeyword_pkg():
    print("In function: ", inspect.stack()[0].function)
    #get Jaldee-Keyword addon Id from licconfig gile
    try:
        with open(licjson,'r', encoding="utf-8") as datas:
            data= json.load(datas)
        kwmetric=data['metrics']
        for metric in kwmetric:
            if metric['name']=='Jaldee_Keywords':
                metricId= metric['id']
                break
        addondata=data['addonsMetaData']
        for metric in addondata:
            if metric['metricId']==str(metricId):
                kk=len(metric['addons'])
                ran= random.randint(0,kk-1)
                return metric['addons'][ran]['addonId']
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def get_statusboard_addonId():
    print("In function: ", inspect.stack()[0].function)
    #get Jaldee-Keyword addon Id from licconfig gile
    try:
        with open(licjson,'r', encoding="utf-8") as datas:
            data= json.load(datas)
        kwmetric=data['metrics']
        for metric in kwmetric:
            if metric['name']=='QBoard':
                metricId= metric['id']
                break
        addondata=data['addonsMetaData']
        for metric in addondata:
            if metric['metricId']==str(metricId):
                kk=len(metric['addons'])
                ran= random.randint(2,kk-1)
                return metric['addons'][ran]['addonId']
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
            

def clear_jdn (usrid):
    print("In function: ", inspect.stack()[0].function)
    acid =  get_acc_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('jdn_disc_tbl','id',acid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def clear_corporate (cname):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("select corporate_id from corporate_tbl where corporate_name ='%s'" %(cname))
            row = cur.fetchone()
            print (int(row[0]))
            cur.execute("select branch_id from account_tbl where corporate_id ='%s'" %(int(row[0])))
            row1 = cur.fetchone()
            print (row1)
            for i in len(row1):
                cur.execute("DELETE FROM branch_tbl WHERE branch_id ='%s'" %(int(row1[i])))

            cur.execute("DELETE FROM corporate_license_tbl WHERE corporate_id ='%s'" % (int(row[0])))
            cur.execute("DELETE FROM corporate_license_subscription_tbl WHERE corporate_id ='%s'" % (int(row[0])))
            cur.execute("DELETE FROM corporate_tbl WHERE corporate_id ='%s'" % (int(row[0])))
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0 
    finally:
        if dbconn is not None:
            dbconn.close()

def clear_consumer_notification_settings (usrid):
    print("In function: ", inspect.stack()[0].function)
    acid =  get_acc_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('consumer_notification_settings_tbl','account',acid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def roundoff(num):
    if isinstance(num, (int, float)):
        val=round(num,2)
        # print('roundedval=',val)
    else:
        try:
            val=float("{:.2f}".format(num))
            # print('convertedval=',val)
        except ValueError:
            return 0
    return val


def get_time_secs():
    BASE_URL = __import__(os.environ['VARFILE']).BASE_URL
    URL = BASE_URL + '/provider/server/date'
    r = requests.get(url = URL)
    log_request(r)
    log_response(r)
    data = r.json()
    date,time= data.split()
    try:
        time1= datetime.datetime.strptime(time, '%H:%M:%S').time()
        t= time1.strftime("%I:%M:%S %p")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0


def add_time_sec(h,m,s):
    try:
        t= get_time_secs()
        time2= datetime.datetime.strptime(t, '%I:%M:%S %p').time()
        d= get_date()
        d1= datetime.datetime.strptime(d, '%Y-%m-%d').date()
        a= datetime.datetime.combine(d1, time2)
        b= a + datetime.timedelta(hours=int(h),minutes=int(m),seconds=int(s))
        t = b.strftime("%I:%M:%S %p")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0   


def clear_ScTable(phno):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('sc_tbl','primary_phone_no',phno)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def clear_ScRepTable(sc_id):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM sc_rep_tbl WHERE sc_id='%s'" % sc_id)
            row = [str(item[0]) for item in cur.fetchall()]
            for i in range(len(row)) :
                cur.execute("DELETE FROM sc_rep_tbl WHERE id ='%s'" % (row[i]))
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0  
    finally:
        if dbconn is not None:
            dbconn.close()  


def clear_ssc_code(phone):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    id =  get_acc_id(phone)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("UPDATE account_info_tbl  SET sales_channel_code =NULL  WHERE  id=%s" % id)
            cur.execute("DELETE FROM provider_sales_channel_tbl WHERE id=%s" % id)
            dbconn.commit()
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0  
    finally:
        if dbconn is not None:
            dbconn.close()   


def check_is_corp(subdomain):
    # print (subdomain)
    try:
        with open(bizjson, 'r', encoding="utf-8") as f:
            data=json.load(f)
    except IOError:
        print ('File',bizjson,'not accessible')

    try:
        for i in range(len(data['businessDomains'])):      
            for j in range(len(data['businessDomains'][i]['subDomains'])):   
                if str(data['businessDomains'][i]['subDomains'][j]['subDomain'])==str(subdomain):
                    status= data['businessDomains'][i]['subDomains'][j]['isCorp']
        # print (status)
        return status
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def get_iscorp_subdomains(flag):
    print("In function: ", inspect.stack()[0].function)
    # print (flag)
    try:
        with open(bizjson,'r', encoding="utf-8") as f:
            data=json.load(f)
    except IOError:
        print ('File',bizjson,'not accessible')
    domlist=[]
    dflag = True if int(flag) == 1 else False
    # print (dflag)
    try:
        for i in range(len(data['businessDomains'])):
            for j in range(len(data['businessDomains'][i]['subDomains'])):
                # print  "Domain: " + str(data['businessDomains'][i]['domain']) + str(i)
                # print  "Sub Domain: " + str(data['businessDomains'][i]['subDomains'][j]['subDomain']) + str(j)
                if dflag is True and data['businessDomains'][i]['subDomains'][j]['isCorp'] == dflag:
                    domdict={"domainId": data['businessDomains'][i]['id'], "domain": data['businessDomains'][i]['domain'], "subdomains": data['businessDomains'][i]['subDomains'][j]['subDomain'], "subdomainId": data['businessDomains'][i]['subDomains'][j]['id'], "userSubDomainId": data['businessDomains'][i]['subDomains'][j]['userSubDomainId']}
                    domlist.append(domdict)
                elif dflag is False and data['businessDomains'][i]['subDomains'][j]['isCorp'] == dflag:
                    domdict={"domainId": data['businessDomains'][i]['id'], "domain": data['businessDomains'][i]['domain'], "subdomains": data['businessDomains'][i]['subDomains'][j]['subDomain'], "subdomainId": data['businessDomains'][i]['subDomains'][j]['id']}
                    domlist.append(domdict)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
    return domlist


def get_iscorp_subdomains_with_maxpartysize(flag):
    print("In function: ", inspect.stack()[0].function)
    try:
        with open(bizjson,'r',encoding="utf-8") as f:
            data=json.load(f)
    except IOError:
        print ('File',bizjson,'not accessible')
    domlist=[]
    dflag = True if int(flag) == 1 else False
    # print (dflag)
    for i in range(len(data['businessDomains'])):
        for j in range(len(data['businessDomains'][i]['subDomains'])):
            # print  "Domain: " + str(data['businessDomains'][i]['domain']) + str(i)
            # print  "Sub Domain: " + str(data['businessDomains'][i]['subDomains'][j]['subDomain']) + str(j)
            if data['businessDomains'][i]['subDomains'][j]['isCorp'] == dflag:
                if data['businessDomains'][i]['subDomains'][j]['maxPartySize'] > 1:
                    domdict={"domain": data['businessDomains'][i]['domain'], "subdomains": data['businessDomains'][i]['subDomains'][j]['subDomain'], "subdomainId": data['businessDomains'][i]['subDomains'][j]['id']}
                    domlist.append(domdict)

    return domlist

def get_notiscorp_subdomains_with_no_multilocation(flag):
    print("In function: ", inspect.stack()[0].function)
    try:
        with open(bizjson,'r',encoding="utf-8") as f:
            data=json.load(f)
    except IOError:
        print ('File',bizjson,'not accessible')
    domlist=[]
    dflag = True if int(flag) == 1 else False
    # print (dflag)
    for i in range(len(data['businessDomains'])):
        for j in range(len(data['businessDomains'][i]['subDomains'])):
            # print  "Domain: " + str(data['businessDomains'][i]['domain']) + str(i)
            # print  "Sub Domain: " + str(data['businessDomains'][i]['subDomains'][j]['subDomain']) + str(j)
            if data['businessDomains'][i]['subDomains'][j]['isCorp'] == dflag:
                if data['businessDomains'][i]['multipleLocation'] == False:
                    domdict={"domain": data['businessDomains'][i]['domain'], "subdomains": data['businessDomains'][i]['subDomains'][j]['subDomain'], "subdomainId": data['businessDomains'][i]['subDomains'][j]['id']}
                    domlist.append(domdict)

    return domlist

# def clear_users(ph_no):
#     uid=  get_id(ph_no)
#     dbconn = connect_db(db_host, db_user, db_passwd, db)
#     try:
#         # cur = dbconn.cursor()
#         with dbconn.cursor() as cur:
#             delete_entry('login_tbl','id',uid,cur) 
#             delete_entry('local_user_tbl','id',uid,cur)  
#             delete_entry('login_history_tbl','user_id',uid,cur)
#             delete_entry('user_tbl','id',uid,cur)  
#             dbconn.commit()
#     except Exception as e:
#         print ("Exception:", e)
        # print ("Exception at line no:", e.__traceback__.tb_lineno)  
#     finally:
#         if dbconn is not None:
#             dbconn.close()

def clear_users(ph_no):
    print("In function: ", inspect.stack()[0].function)
    uid=  get_id(ph_no)
    print ("uid:", uid, "ph no:", ph_no)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    # print ("2:", dbconn)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('login_tbl','id',uid,cur) 
            delete_entry('wl_history_tbl','provider',uid,cur)    
            delete_entry('appmnt_archive_tbl','provider',uid,cur)
            delete_entry('service_tbl','provider',uid,cur)  
            delete_entry('user_team_tbl','local_user_id',uid,cur)  
            delete_entry('schedule_service_tbl','service_id',uid,cur)  
            delete_entry('local_user_tbl','id',uid,cur)  
            delete_entry('login_history_tbl','user_id',uid,cur)
            delete_entry('crm_lead_tbl','generated_by_id',uid,cur)
            delete_entry('user_tbl','id',uid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()

def Generate_scid() :
	scid= Generate_random_value(3,string.digits )
	return (scid)

def commaformatNumber(x):
    return  '{:,.2f}'.format(x)

def Generate_discount_coupon() :
    #Generates discount code for subscriptiondiscount type
    discode= Generate_random_value(5,string.ascii_uppercase + string.digits )
    return (discode)

def timeto24hr(t):
    t=time.strptime(t,"%I:%M %p")
    s=time.strftime("%H:%M",t)
    return s

def get_slot_length(timedur, apptdur) :
    rm=timedur%apptdur
    # rm=round(rm)
    if rm > 0:
        return  int(timedur/apptdur+1)
    else:
        return  int(timedur/apptdur)

def get_item_metrics_value(metric,pkgId):
    print("In function: ", inspect.stack()[0].function)
    #get license packag id from licconfig file
    metric_id=0
    with open(licjson, 'r', encoding="utf-8") as f:
        data=json.load(f)
    
    for i in range(len(data['metrics'])):
        if str(data['metrics'][i]['name']) == str(metric):
            metric_id=  data['metrics'][i]['id']
            # print (metric_id)
            
    liclist=[]        
    for j in range(len(data['licensablePackages'])):
        for k in range(len(data['licensablePackages'][j]['metrics'])):
            if data['licensablePackages'][j]['metrics'][k]['id'] == metric_id:
                if str(data['licensablePackages'][j]['pkgId']) == str(pkgId):
                    value=data['licensablePackages'][j]['metrics'][k]['anyTimeValue']
    return value

def convert_time(time):     
    # Checking if last two elements of time 
    # is AM and first two elements are 12 
    if time[-2:] == "AM" and time[:2] == "12": 
        return "00" + time[2:] 
    elif  time[-2:] == "AM" and time[1:2] != ":":
        if int(time[:2]) > 12:
            return str(int(time[:2]) - 12) + time[2:]
        else:
            return str(time)
    else:
        return str(time)

def convert_12AM(time):     
    # Checking if last two elements of time 
    # is AM and first two elements are 00 
    if time[-2:] == "AM" and time[:2] == "00": 
        return "12" + time[2:] 
    elif  time[-2:] == "AM" and time[1:2] != ":":
        if int(time[:2]) > 12:
            return str(int(time[:2]) - 12) + time[2:]
        else:
            return str(time)
    else:
        return str(time)

def twodigitfloat(x):
    return '{:.2f}'.format(x)

# def clear_appt_service(usrid):
#     print ("In clear_appt_service")
#     dbconn = connect_db(db_host, db_user, db_passwd, db)
#     try :
#         # cur = dbconn.cursor()
#         with dbconn.cursor() as cur:
#             cur.execute("SELECT id FROM account_info_tbl WHERE acct_linked_ph_no='%s'" % usrid)
#             row1 = cur.fetchone()
#             aid = row1[0]
#             cur.execute("SELECT id FROM service_tbl WHERE account='%s'" % aid)
#             row = cur.fetchall()
#             print (row) 
#             for index in range(len(row)):
#                     delete_entry('virtual_service_tbl','id',int(row[index][0]),cur)
#                     delete_entry('queue_service_tbl','service_id',int(row[index][0]),cur)
#                     delete_entry('schedule_service_tbl','service_id',int(row[index][0]),cur)
#                     delete_entry('appmnt_archive_tbl','service_id',int(row[index][0]),cur)
#                     delete_entry('appt_tbl','service_id',int(row[index][0]),cur)
#                     delete_entry('transaction_payment_tbl','service_id',int(row[index][0]),cur)
#                     delete_entry('service_tbl','id',int(row[index][0]),cur)
#                     delete_entry('appt_rating_tbl','service',int(row[index][0]),cur)
#             delete_entry('appmnt_archive_tbl','account',aid,cur)
#             delete_entry('appt_rating_tbl','account',aid,cur)
#             delete_entry('appt_tbl','account',aid,cur)
#             # clear_service(usrid)
#             # reset_metric_usage(aid)
#             dbconn.commit()
#             # dbconn.close()
#     except Exception as e:
#         print ("Exception:", e)
        # print ("Exception at line no:", e.__traceback__.tb_lineno)
#         return 0
#     finally:
#         if dbconn is not None:
#             dbconn.close()


def clear_appt_schedule(usrid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try :
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM account_info_tbl WHERE acct_linked_ph_no='%s'" % usrid)
            row1 = cur.fetchone()
            print (row1)
            aid = row1[0]
            print (aid)
            cur.execute("SELECT uid FROM appt_tbl WHERE account='%s'" % aid)
            apptid = cur.fetchall()
            print (apptid)
            cur.execute("SELECT id FROM appt_schedule_tbl WHERE account='%s'" % aid)
            apptschid = cur.fetchall()
            print (apptschid)
            
            for index in range(len(apptid)):
                delete_entry('appt_livetrack_tbl','uuid',apptid[index][0],cur) 
                delete_entry('appt_tbl','uid',apptid[index][0],cur)
            for index in range(len(apptschid)):
                delete_entry('schedule_service_tbl','schedule_id',int(apptschid[index][0]),cur)
                delete_entry('transaction_payment_tbl','schedule_id',int(apptschid[index][0]),cur)
            delete_entry('appmnt_archive_tbl','account',aid,cur)
            delete_entry('appt_daily_schedule_tbl','account',aid,cur)
            delete_entry('appt_queueset_tbl','account_id',aid,cur)
            delete_entry('appt_tbl','account',aid,cur)
            delete_entry('appt_schedule_tbl','account',aid,cur)
            delete_entry('appt_state_tbl','account',aid,cur)
            delete_entry('holidays_tbl','account',aid,cur)
            reset_metric_usage(aid)
            dbconn.commit()
                    # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()

def clear_appt_schedule_user(user_num, branch_num):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try :
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM account_info_tbl WHERE acct_linked_ph_no='%s'" % branch_num)
            row1 = cur.fetchone()
            # print (row1)
            aid = row1[0]
            # print (aid)
            uid= get_id(user_num)
            # print (uid)
            cur.execute("SELECT uid FROM appt_tbl WHERE account='%s' and provider='%s'" % (aid,uid))
            apptid = cur.fetchall()
            # print (apptid)
            cur.execute("SELECT id FROM appt_schedule_tbl WHERE account='%s' and provider='%s'" % (aid,uid))
            apptschid = cur.fetchall()
            # print (apptschid)
            
            for index in range(len(apptid)):
                delete_entry('appt_livetrack_tbl','uuid',apptid[index][0],cur) 
                delete_entry('appt_tbl','uid',apptid[index][0],cur)
            for index in range(len(apptschid)):
                delete_entry('schedule_service_tbl','schedule_id',int(apptschid[index][0]),cur)
                delete_entry('transaction_payment_tbl','schedule_id',int(apptschid[index][0]),cur)
            delete_entry_2Fields('appmnt_archive_tbl','account',aid,'provider',uid,cur)
            delete_entry('appt_daily_schedule_tbl','account',aid,cur)
            delete_entry('appt_queueset_tbl','account_id',aid,cur)
            delete_entry_2Fields('appt_tbl','account',aid,'provider',uid,cur)
            delete_entry_2Fields('appt_schedule_tbl','account',aid,'provider',uid,cur)
            delete_entry('appt_state_tbl','account',aid,cur)
            delete_entry_2Fields('holidays_tbl','account',aid,'provider',uid,cur)
            reset_metric_usage(aid)
            dbconn.commit()
                    # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()

def addons_all_license_applicable(addonlist):
    print("In function: ", inspect.stack()[0].function)
    # data= json.loads(addonlist)
    data= addonlist
    alist=[]
    for i in range(len(data)):
        metric_list=[]
        for a in range(len(data[i]['addons'])):
            if data[i]['addons'][a]['minLicPkgLevel'] == 1:
                if data[i]['addons'][a]['maxLicPkgLevel'] == 9:
                    addon={"addon_id": data[i]['addons'][a]['addonId'], "addon_name": data[i]['addons'][a]['addonName']}
                    metric_list.append(addon)
        if metric_list != []:
            alist.append(metric_list)
    return alist
    
def all_license_applicable_addonids(addonlist):
    print("In function: ", inspect.stack()[0].function)
    # data= json.loads(addonlist)
    data= addonlist
    alist=[]
    for i in range(len(data)):
        for a in range(len(data[i]['addons'])):
            if data[i]['addons'][a]['minLicPkgLevel'] == 1:
                if data[i]['addons'][a]['maxLicPkgLevel'] == 9:
                    addon=data[i]['addons'][a]['addonId']
                    alist.append(addon)
    return alist

def apptfor(*argv):
    print("In function: ", inspect.stack()[0].function)
    apptfor_dict = {}
    apptfor_list = []
    for arg in argv:
        print  (arg)
        if (not isinstance(arg,int) and "-" in arg):
            print  ('slot if:', arg)
            t1= arg.split("-")[0].replace('"','')
            t2= arg.split("-")[1].replace('"','')
            try:
                time.strptime(t1, '%H:%M')
                time.strptime(t2, '%H:%M')
                apptfor_dict['apptTime']= arg
                print  ('apptTime:', apptfor_dict)
            except Exception as e:
                print ('Exception:', e)
                pass
            
        elif (not isinstance(arg,int) and all(chr.isalpha() or chr.isspace() for chr in arg)):
            print  ('name if:', arg)
            apptfor_dict['firstName']= arg
            print  ('firstName:', apptfor_dict)

        else:
            try:
                print  ('id if:', arg)
                value = int(arg)
                apptfor_dict['id']= arg
            except Exception as e:
                print ('Exception:', e)
                pass
            
        if all(key in apptfor_dict for key in ('id', 'firstName', 'apptTime')):
            print  ('if all:', apptfor_dict)
            apptfor_list.append(apptfor_dict)
            apptfor_dict= {}
            print  ('appt for list:', apptfor_list)

    print (apptfor_list)
    if apptfor_dict:
        for key in ('id', 'firstName', 'apptTime'):  
            if key not in apptfor_dict:
                return "apptfor dictionary: "+ json.dumps(apptfor_dict) +", is missing, "+ json.dumps(key)
    
    else:
        return apptfor_list

# Sample input :- 
# print(apptfor('0','nem','"06:12 PM-06:20 PM"','fish','2','"06:20 PM-06:40 PM"','apple','"06:40 PM-07:00 PM"','5'))

def mins_diff(stime,etime):
    try:
        
        time1= datetime.datetime.strptime(stime, '%I:%M %p')
        time2= datetime.datetime.strptime(etime, '%I:%M %p')
        time_delta = (time2 - time1)
        # print (time_delta)
        total_seconds = time_delta.total_seconds()
        # print (total_seconds)
        minutes = total_seconds/60
        return int(minutes)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    
def convert_slot_12hr(slot):
    if "-" in slot:
        t1= slot.split("-")[0].replace('"','')
        # print t1
        t2= slot.split("-")[1].replace('"','')
        # print t2
        try:
            t1 = datetime.datetime.strptime(str(t1), "%H:%M").time()
            # print t1
            t1=t1.strftime('%I:%M %p')
            # print t1
            t2 = datetime.datetime.strptime(str(t2), "%H:%M").time()
            # print t2
            t2=t2.strftime('%I:%M %p')
            # print t2
            return t1+"-"+t2
        except Exception as e:
            print ("Exception:", e)
            print ("Exception at line no:", e.__traceback__.tb_lineno)
            return 0

def slot_12hr(slot):
    if "-" in slot:
        t1= slot.split("-")[0].replace('"','')
        # print t1
        t2= slot.split("-")[1].replace('"','')
        # print t2
        try:
            t1 = datetime.datetime.strptime(str(t1), "%H:%M").time()
            # print t1
            t1=t1.strftime('%I:%M %p')
            # print t1
            t2 = datetime.datetime.strptime(str(t2), "%H:%M").time()
            # print t2
            t2=t2.strftime('%I:%M %p')
            # print t2
            return t1+"-"+t2
        except Exception as e:
            print ("Exception:", e)
            print ("Exception at line no:", e.__traceback__.tb_lineno)
            return 0

            
def rounded(val):
    value=round(val)
    return value

def get_subdomains(domain):
    print("In function: ", inspect.stack()[0].function)
    try:
        with open(bizjson,'r', encoding="utf-8") as f:
            data=json.load(f)
    except IOError:
	    print ('File',bizjson,'not accessible')
    # domlist=[]
    subdomlist=[]
    for i in range(len(data['businessDomains'])):        
        if data['businessDomains'][i]['domain'] == domain:
            # domlist.append(data['businessDomains'][i]['domain'])
            for j in range(len(data['businessDomains'][i]['subDomains'])):
                subdomdict={"subdomain": data['businessDomains'][i]['subDomains'][j]['subDomain'], "subdomainId": data['businessDomains'][i]['subDomains'][j]['id']}
                subdomlist.append(subdomdict)
    return subdomlist



def clear_customer(phno):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM account_info_tbl WHERE acct_linked_ph_no='%s'" % phno)
            row1 = cur.fetchone()
            aid = row1[0]
            # print ("Acc id: "+ str(aid))
            cur.execute("SELECT id FROM provider_consumer_tbl WHERE account='%s'" % aid)
            conid = cur.fetchall()
            # print ("Cust id: "+  str(conid))
            # print ("Cust length: "+  str(len(conid)))
            # cur.execute("SELECT id FROM bill_tbl WHERE account_id='%s'" % aid)
            # probillid = cur.fetchall()
            # print "Bill id: "+  str(probillid)
            a=[]
            for value in conid:
                # print ("bill for: "+  str(value))
                cur.execute("SELECT id FROM bill_tbl WHERE consumer_id='%s'" % value)
                billid= cur.fetchall()
                # print ("billid: "+  str(billid))
                for i in range(len(billid)):
                    a.append(billid[i][0])

            # print ("billid List: "+  str(a))

            # dbconn.close()

            for i in range(len(a)):
                # print ("deleting bill: "+  str(a[i]))
                delete_entry('order_archive_tbl','bill',int(a[i]),cur)
                delete_entry('order_tbl','bill',int(a[i]),cur)
                delete_entry('transaction_payment_tbl','bill_id',int(a[i]),cur)

            # print  len(conid)
            for index in reversed(range(len(conid))):
                # print ("index: "+  str(index))
                # print ("deleting "+  str(conid[index][0]))
                # print('bill_tbl')
                delete_entry('bill_tbl','consumer_id',conid[index][0],cur)
                # print('wl_history_tbl') 
                delete_entry('wl_history_tbl','consumer_id',conid[index][0],cur)
                # print('wl_cache_tbl')
                delete_entry('wl_cache_tbl','consumer_id',conid[index][0],cur) 
                # print('wl_history_tbl')
                delete_entry('wl_history_tbl','waitlisting_for_id',conid[index][0],cur)
                # print('wl_rating_tbl')
                delete_entry('wl_rating_tbl','provider_cosumer',conid[index][0],cur)
                # select_entry('family_member_tbl','pro_con_parent_id',conid[index][0],cur)
                # print('family_member_tbl')
                delete_entry('family_member_tbl','pro_con_parent_id',conid[index][0],cur)
                # print('appmnt_archive_tbl')
                delete_entry('appmnt_archive_tbl','consumer_id',conid[index][0],cur)
                # print('appt_tbl')
                delete_entry('appt_tbl','consumer_id',conid[index][0],cur)
                # print('appt_rating_tbl')
                delete_entry('appt_rating_tbl','provider_cosumer',conid[index][0],cur)
                # print('appt_tbl')
                delete_entry('appt_tbl','appt_for_id',conid[index][0],cur)
                # print('medical_record_tbl')
                delete_entry('medical_record_tbl','consumer_id',conid[index][0],cur)
                # print('order_archive_tbl')
                delete_entry('order_archive_tbl','consumer_id',conid[index][0],cur)
                # print('order_rating_tbl')
                delete_entry('order_rating_tbl','provider_cosumer',conid[index][0],cur)
                # print('crm_lead_tbl')
                delete_entry('crm_lead_tbl','customer_id',conid[index][0],cur)
                # print('crm_enquire_tbl')
                delete_entry('crm_enquire_tbl','customer_id',conid[index][0],cur)
                # print('provider_consumer_tbl')
                delete_entry('crm_provider_task_tbl','customer_id',conid[index][0],cur) 
                delete_entry('lead_kyc_tbl','parent_id',conid[index][0],cur) 
                delete_entry('provider_consumer_tbl','parent_id',conid[index][0],cur)
                # print('order_tbl')
                delete_entry('order_tbl','order_for',conid[index][0],cur)
                # select_entry('provider_consumer_tbl','parent_id',conid[index][0],cur)
                # print('provider_consumer_tbl')
                delete_entry('provider_consumer_tbl','id',conid[index][0],cur)
                # print('provider_consumer_tbl')
            delete_entry('provider_consumer_tbl','account',aid,cur)
            dbconn.commit()

    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
    finally:
        if dbconn is not None:
            dbconn.close()
            

def clear_customer_fam(phno):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM account_info_tbl WHERE acct_linked_ph_no='%s'" % phno)
            row1 = cur.fetchone()
            aid = row1[0]
            # print ("Acc id: "+ str(aid))
            cur.execute("SELECT id FROM provider_consumer_tbl WHERE account='%s'" % aid)
            conid = cur.fetchall()
            # print ("Cust id: "+  str(conid))
            # print  (len(conid))
            # dbconn.close()

        # print  (len(conid))
        for index in range(len(conid)):
            # print ("deleting "+  str(conid[index][0]))
            # select_entry('family_member_tbl','pro_con_parent_id',conid[index][0],cur)
            delete_entry('family_member_tbl','pro_con_parent_id',conid[index][0],cur)
            # select_entry('provider_consumer_tbl','parent_id',conid[index][0],cur)
            delete_entry('provider_consumer_tbl','parent_id',conid[index][0],cur)
        
        dbconn.commit()

    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
    finally:
        if dbconn is not None:
            dbconn.close()



def get_date_time():
    BASE_URL = __import__(os.environ['VARFILE']).BASE_URL
    URL = BASE_URL + '/provider/server/date'
    r = requests.get(url = URL)
    log_request(r)
    log_response(r)
    data = r.json()
    date,time= data.split()
    try:
        a= datetime.datetime.strptime(data, '%Y-%m-%d %H:%M:%S')
        t = a.strftime("%Y-%m-%d %I:%M:%S %p")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0


def remove_secs(time):
    try:
        time1= datetime.datetime.strptime(time, '%I:%M:%S %p').time()
        t= time1.strftime("%I:%M %p")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def remove_date_time_secs(time):
    try:
        if time.endswith(("AM", "PM", "am", "pm")):
            time1= datetime.datetime.strptime(time, '%Y-%m-%d %I:%M:%S %p')
        else:
            time1= datetime.datetime.strptime(time, '%Y-%m-%d %H:%M:%S')
        t= time1.strftime("%Y-%m-%d %I:%M %p")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def convert_slot_12hr_first(slot):
    if "-" in slot:
        t1= slot.split("-")[0].replace('"','')
        # print t1
        t2= slot.split("-")[1].replace('"','')
        # print t2
        try:
            t1 = datetime.datetime.strptime(str(t1), "%H:%M").time()
            # print t1
            t1=t1.strftime('%I:%M %p')
            # print t1
            return t1
        except Exception as e:
            print ("Exception:", e)
            print ("Exception at line no:", e.__traceback__.tb_lineno)
            return 0


def Convert_hour_mins(time):
    try:
        #print (time) 
        Hours = int(time) / 60
        #print (Hours)
        minutes = int(time) % 60
        #print (minutes)
        return (Hours, minutes)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def convert_hour_minutes(time):
    try:
        Hours, minutes = divmod(time, 60)
        print (Hours, minutes)
        return (Hours, minutes)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

    
def clear_customer_groups(phno):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM account_info_tbl WHERE acct_linked_ph_no='%s'" % phno)
            row1 = cur.fetchone()
            aid = row1[0]
            # print ("Acc id: "+ str(aid))
            cur.execute("SELECT id FROM consumer_group_tbl WHERE account='%s'" % aid)
            grpid = cur.fetchall()
            # print ("Group id: "+  str(grpid))
            # print  (len(grpid))
            # dbconn.close() 
            delete_entry('consumer_group_tbl','account',aid,cur)
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
    finally:
        if dbconn is not None:
            dbconn.close()


def get_customers_from_group(grpid):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM provider_consumer_tbl WHERE JSON_CONTAINS(groups,JSON_QUOTE('%s'), '$')='%s'" % (grpid,grpid))
            conid = cur.fetchall()
            # print ("Cust ids: "+  str(conid))
            # print  (len(conid))
            # dbconn.close()
            customers=[]
            for index in range(len(conid)):
                # print ("Customer id "+ str(index) +" : "  + str(conid[index][0]))
                customers.append(conid[index][0])
            return (customers)
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
    finally:
        if dbconn is not None:
            dbconn.close()


def get_procon_id(pronum,custnum):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            cur.execute("SELECT id FROM account_info_tbl WHERE acct_linked_ph_no='%s'" % pronum)
            row1 = cur.fetchone()
            aid = row1[0]
            # print ("Acc id: "+ str(aid))
            if str(custnum).isdigit() :
                cur.execute("SELECT id FROM provider_consumer_tbl WHERE phone_no='%s' and account='%s'" % (custnum,aid))
            elif (custnum!=' '):
                cur.execute("SELECT id FROM provider_consumer_tbl WHERE email='%s' and account='%s'" % (custnum,aid))
            conid = cur.fetchall()
            # print ("Cust id: "+  str(conid))
            # print ("Cust length: "+  str(len(conid)))
            # dbconn.close()
            return conid[0][0]
        dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()

def getType(*files):
    print("In function: ", inspect.stack()[0].function)
    filetype={}
    for file in files:
        mimetype, encoding = mimetypes.guess_type(file)
        print ('file: ', file, 'mimetype: ', mimetype, ' - encoding: ', encoding)
        ext= mimetypes.guess_extension(mimetype)
        print ('Extension from mimetype: ', ext )
        filetype[file]= ext
    return  filetype



def addons_high_license_applicable(addonlist):
    print("In function: ", inspect.stack()[0].function)
    # data= json.loads(addonlist)
    data= addonlist
    alist=[]
    for i in range(len(data)):
        metric_list=[]
        for a in range(len(data[i]['addons'])):
            if data[i]['addons'][a]['minLicPkgLevel'] == 6:
                if data[i]['addons'][a]['maxLicPkgLevel'] == 9:
                    addon={"addon_id": data[i]['addons'][a]['addonId'], "addon_name": data[i]['addons'][a]['addonName']}
                    metric_list.append(addon)
        if metric_list != []:
            alist.append(metric_list)
    return alist


def QuestionnaireAnswers(qnrdata, proConId, **kwargs):
    print("In function: ", inspect.stack()[0].function)
    faker = Faker()      
    try:
        id = qnrdata['id']
        answerline=[]
        for i in range(len(qnrdata['labels'])):
            lblname= qnrdata['labels'][i]['question']['labelName']
            fieldDT= qnrdata['labels'][i]['question']['fieldDataType']
            dtdict={}
            ansdict={}
            if fieldDT == 'plainText':
                qnsid= qnrdata['labels'][i]['question']['id']
                try:
                    minans= qnrdata['labels'][i]['question']['plainTextPropertie']['minNoOfLetter']
                    minans = 1 if minans <=1 else minans
                    # print("min chars:",minans)
                    maxans= qnrdata['labels'][i]['question']['plainTextPropertie']['maxNoOfLetter']
                    # print("max chars:",maxans)
                    mytext= faker.text(max_nb_chars=maxans)
                    # print("text is:",mytext)
                    # print("length of text:",len(mytext))
                    if len(mytext) <= minans:
                        mytext= faker.text(max_nb_chars=maxans)
                        # print("length of text in if:",len(mytext))
                        # print("text in if:",mytext)
                except Exception as e:
                    # print ('Exception: ', e)
                    mytext= faker.text()
                # mytext= faker.text(max_nb_chars=maxans)
                mytext = mytext.replace('\n', '').replace('\r', '')
                # dtdict['plainText']= faker.text(max_nb_chars=maxans)
                dtdict['plainText']= mytext
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)

            elif fieldDT == 'list':
                labelvals= qnrdata['labels'][i]['question']['labelValues']
                qnsid= qnrdata['labels'][i]['question']['id']
                minans= qnrdata['labels'][i]['question']['listPropertie']['minAnswers']
                # print("min answers:",minans)
                minans = 1 if minans <=1 else minans
                maxans= qnrdata['labels'][i]['question']['listPropertie']['maxAnswers']
                # print("max answers:",maxans)
                rand_maxans = 1 if maxans == 1 else random.randrange(minans, maxans)
                dtlist= random.sample(labelvals, rand_maxans)
                dtdict['list']= dtlist
                # print("list answer:",dtdict)
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)
                # print("answerline in list:",answerline)

            elif fieldDT == 'bool':
                qnsid= qnrdata['labels'][i]['question']['id']
                dtdict['bool']= faker.pybool()
                # print("bool answer:",dtdict)
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)
                # print("answerline in bool:",answerline)

            elif fieldDT == 'date':
                qnsid= qnrdata['labels'][i]['question']['id']
                dtdict['date']= faker.date_between().strftime('%Y-%m-%d')
                # answer=[dtdict]
                # print("date answer:",dtdict)
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)
                # print("answerline in date:",answerline)

            elif fieldDT == 'number':
                qnsid= qnrdata['labels'][i]['question']['id']
                start=qnrdata['labels'][i]['question']['numberPropertie']['start']
                end=qnrdata['labels'][i]['question']['numberPropertie']['end']
                dtdict['number']= faker.random_int(min=start, max=end)
                # print("number answer:",dtdict)
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)
                # print("answerline in number:",answerline)

            elif fieldDT == 'fileUpload':
                qnsid= qnrdata['labels'][i]['question']['id']
                filetypes= qnrdata['labels'][i]['question']['filePropertie']['fileTypes']
                allowed_docs= qnrdata['labels'][i]['question']['filePropertie']['allowedDocuments']
                print ('allowed documents for', qnrdata['labels'][i]['question']['labelName'],' :', allowed_docs)
                fu_len= len(kwargs['fileupload'])
                for j in range(fu_len):
                    if any(c in filetypes for c in ('pdf', 'jpeg', 'png', 'jpg', 'docx', 'txt')) and any(c in filetypes for c in ('mp4', 'mov', 'avi', 'flv')) and any(c in filetypes for c in ('mp3', 'wav', 'wma', 'audio')) and "files" in kwargs['fileupload'][j].keys():
                        # print ('files if condition cleared.')
                        fudict={}
                        dtlist=[]
                        for k in range(len(kwargs['fileupload'][j]['files'])):
                            print ('file name in caption:', kwargs['fileupload'][j]['files'][k]['caption'])
                            if kwargs['fileupload'][j]['files'][k]['caption'] in allowed_docs:
                                # print ('caption if condition in nested for cleared.')
                                dtlist.append(kwargs['fileupload'][j]['files'][k])
                                print ('dtlist:', dtlist)
                                break
                            else:
                                continue
                    

                        dtdict['fileUpload']= dtlist
                        # print("fileupload file answer:",dtdict)
                        ansdict['labelName']= lblname
                        ansdict['id']= qnsid
                        ansdict['answer']= dtdict
                        answerline.append(ansdict) 
                        # print("answerline for fileupload:",answerline)  
                        break
                    elif any(c in filetypes for c in ('pdf', 'jpeg', 'png', 'jpg', 'docx', 'txt')) and "files" in kwargs['fileupload'][j].keys():
                        # print ('files if condition cleared.')
                        fudict={}
                        dtlist=[]
                        for k in range(len(kwargs['fileupload'][j]['files'])):
                            print ('file name in caption:', kwargs['fileupload'][j]['files'][k]['caption'])
                            if kwargs['fileupload'][j]['files'][k]['caption'] in allowed_docs:
                                # print ('caption if condition in nested for cleared.')
                                dtlist.append(kwargs['fileupload'][j]['files'][k])
                                print ('dtlist:', dtlist)
                                break
                            else:
                                continue
                    

                        dtdict['fileUpload']= dtlist
                        # print("fileupload file answer:",dtdict)
                        ansdict['labelName']= lblname
                        ansdict['id']= qnsid
                        ansdict['answer']= dtdict
                        answerline.append(ansdict) 
                        # print("answerline for fileupload:",answerline)  
                        break

                    elif any(c in filetypes for c in ('mp4', 'mov', 'avi', 'flv')) and "Videos" in kwargs['fileupload'][j].keys():
                        # print ('Videos if condition cleared.')
                        fudict={}
                        dtlist=[]
                        for k in range(len(kwargs['fileupload'][j]['Videos'])):
                            if kwargs['fileupload'][j]['Videos'][k]['caption'] in allowed_docs:
                                dtlist.append(kwargs['fileupload'][j]['Videos'][k])
                                # print ('dtlist:', dtlist)
                                break
                            else:
                                continue
                    
                        dtdict['fileUpload']= dtlist
                        # print("fileupload video answer:",dtdict)
                        qnsid= qnrdata['labels'][i]['question']['id']
                        ansdict['labelName']= lblname
                        ansdict['id']= qnsid
                        ansdict['answer']= dtdict
                        answerline.append(ansdict) 
                        # print("answerline for fileupload: ",answerline) 

                    elif any(c in filetypes for c in ('mp3', 'wav', 'wma', 'audio')) and "Audio" in kwargs['fileupload'][j].keys():
                        # print ('Audio if condition cleared.')
                        fudict={}
                        dtlist=[]
                        for k in range(len(kwargs['fileupload'][j]['Audio'])):
                            if kwargs['fileupload'][j]['Audio'][k]['caption'] in allowed_docs:
                                dtlist.append(kwargs['fileupload'][j]['Audio'][k])
                                # print ('dtlist:', dtlist)
                                break
                            else:
                                continue
                    
                        dtdict['fileUpload']= dtlist
                        # print("fileupload audio answer:",dtdict)
                        ansdict['labelName']= lblname
                        ansdict['id']= qnsid
                        ansdict['answer']= dtdict
                        answerline.append(ansdict) 
                        # print("answerline for fileupload: ",answerline)
                    else: 
                        print ('for labelname:', qnrdata['labels'][i]['question']['labelName'])
                        print ("index, caption and action are required.")

            elif fieldDT == 'dataGrid':
                qnsid= qnrdata['labels'][i]['question']['id']
                datagrid_len= qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns']
                dGC_list=[]
                dGC_dict={}
                
                for j in range(len(datagrid_len)):
                    colID= qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['columnId']
                    colDT= qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['dataType']
                    dGC_dict={}
                    coldtdict={}
                    
                    if colDT == 'plainText':
                        try:
                            minans= qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['plainTextPropertie']['minNoOfLetter']
                            # print("min chars:",minans)
                            minans = 1 if minans <=1 else minans
                            maxans= qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['plainTextPropertie']['maxNoOfLetter']
                            # print("max chars:",maxans)
                            mytext= faker.text(max_nb_chars=maxans)
                            # print("text is:",mytext)
                            # print("length of text:",len(mytext))
                            if len(mytext) <= minans:
                                mytext= faker.text(max_nb_chars=maxans)
                                # print("length of text in if:",len(mytext))
                                # print("text in if:",mytext)
                        except Exception as e:
                            # coldtdict['plainText']= faker.text()
                            mytext= faker.text()
                        mytext = mytext.replace('\n', '').replace('\r', '')
                        coldtdict['plainText']= mytext
                        dGC_dict['column']= coldtdict
                        dGC_dict['columnId']= colID
                        # print("Data Grid Dictionary for plainText:",dGC_dict)
                        dGC_list.append(dGC_dict)

                    elif colDT == 'list':
                        print("DataGrid - list:")
                        try:
                            labelvals= qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['listPropertie']['values']
                        except KeyError:
                            labelvals= None
                        print("list values:",labelvals)
                        try:
                            minans= qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['listPropertie']['minAnswers']
                            minans = 1 if minans <=1 else minans
                            print("min answers:",minans)
                            maxans= qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['listPropertie']['maxAnswers']
                            rand_maxans = 1 if maxans == 1 else random.randrange(minans, maxans)
                            print("max answers:",rand_maxans)
                            coldtdict['list']= faker.words(nb=rand_maxans, ext_word_list=labelvals)
                        except KeyError:
                            coldtdict['list']= faker.words(ext_word_list=labelvals)
                        dGC_dict['column']=coldtdict
                        dGC_dict['columnId']= colID
                        print("Data Grid Dictionary for list:",dGC_dict)
                        dGC_list.append(dGC_dict)

                    elif colDT == 'number':
                        start=qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['numberPropertie']['start']
                        # print("Data Grid number start:",start)
                        end=qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['numberPropertie']['end']
                        # print("Data Grid Dictionary number end:",end)
                        ran_num= random.randrange(int(start), int(end))
                        # print("Data Grid random number :",ran_num)
                        coldtdict['number']= str(ran_num)
                        dGC_dict['column']= coldtdict
                        # print("Data Grid Dictionary for number:",dGC_dict)
                        dGC_dict['columnId']= colID
                        dGC_list.append(dGC_dict)

                    elif colDT == 'date':
                        start_str=qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['dateProperties']['start']
                        # print("Data Grid date string start:",start_str)
                        start = parser.parse(start_str)
                        # print("Data Grid date start:",start)
                        end_str=qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['dateProperties']['end']
                        # print("Data Grid date string end:",end_str)
                        end = parser.parse(end_str)
                        # print("Data Grid date end:",end)
                        # dGC_dict['date']= faker.date_between_dates(date_start=start, date_end=end).strftime('%Y-%m-%d')
                        coldtdict['date']= faker.date_between_dates(date_start=start, date_end=end).strftime('%Y-%m-%d')
                        dGC_dict['column']= coldtdict
                        # print("Data Grid Dictionary for date:",dGC_dict)
                        dGC_dict['columnId']= colID
                        dGC_list.append(dGC_dict)

                    elif colDT == 'bool':
                        qnsid= qnrdata['labels'][i]['question']['id']
                        # dGC_dict['bool']= faker.pybool()
                        coldtdict['bool']= faker.pybool()
                        dGC_dict['column']= coldtdict
                        # print("Data Grid Dictionary for bool:",dGC_dict)
                        dGC_dict['columnId']= colID
                        dGC_list.append(dGC_dict)

                    elif colDT == 'fileUpload':
                        filetypes= qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['filePropertie']['fileTypes']
                        fu_len= len(kwargs['dGridfileupload'])
                        allowed_docs= qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['filePropertie']['allowedDocuments']
                        for j in range(fu_len):
                            if any(c in filetypes for c in ('pdf', 'jpeg', 'png', 'jpg', 'docx', 'txt')) and any(c in filetypes for c in ('mp4', 'mov', 'avi', 'flv')) and any(c in filetypes for c in ('mp3', 'wav', 'wma', 'audio')) and "files" in kwargs['dGridfileupload'][j].keys(): 
                                # print ('Data Grid files if condition cleared.')
                                dGC_dict={}
                                coldtlist=[]
                                for k in range(len(kwargs['dGridfileupload'][j]['files'])):
                                    if kwargs['dGridfileupload'][j]['files'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridfileupload'][j]['files'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue
                
                                # dGC_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGC_dict['column']= coldtdict
                                # print("fileupload file answer:",dGC_dict)
                                dGC_dict['columnId']= colID
                                dGC_list.append(dGC_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)  
                                break
                            elif any(c in filetypes for c in ('pdf', 'jpeg', 'png', 'jpg', 'docx', 'txt')) and "files" in kwargs['dGridfileupload'][j].keys(): 
                                # print ('Data Grid files if condition cleared.')
                                dGC_dict={}
                                coldtlist=[]
                                for k in range(len(kwargs['dGridfileupload'][j]['files'])):
                                    if kwargs['dGridfileupload'][j]['files'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridfileupload'][j]['files'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue
                
                                # dGC_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGC_dict['column']= coldtdict
                                # print("fileupload file answer:",dGC_dict)
                                dGC_dict['columnId']= colID
                                dGC_list.append(dGC_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)  
                                break

                            elif any(c in filetypes for c in ('mp4', 'mov', 'avi', 'flv')) and "Videos" in kwargs['dGridfileupload'][j].keys():
                                # print ('Data Grid Videos if condition cleared.')
                                dGC_dict={}
                                coldtlist=[]
                                for k in range(len(kwargs['dGridfileupload'][j]['Videos'])):
                                    if kwargs['dGridfileupload'][j]['Videos'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridfileupload'][j]['Videos'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue
                
                                # dGC_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGC_dict['column']= coldtdict
                                # print("fileupload video answer:",dGC_dict)
                                dGC_dict['columnId']= colID
                                dGC_list.append(dGC_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)  
                                break

                            elif any(c in filetypes for c in ('mp3', 'wav', 'wma', 'audio')) and "Audio" in kwargs['dGridfileupload'][j].keys():
                                # print ('Data Grid Audio if condition cleared.')
                                # colfudict={}
                                coldtlist=[]

                                for k in range(len(kwargs['dGridfileupload'][j]['Audio'])):
                                    if kwargs['dGridfileupload'][j]['Audio'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridfileupload'][j]['Audio'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue
                                    
                                # dGC_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGC_dict['column']= coldtdict
                                # print("fileupload audio answer:",dGC_dict)
                                dGC_dict['columnId']= colID
                                dGC_list.append(dGC_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)
                                break
                        else: 
                            print ('for labelname:', qnrdata['labels'][i]['question']['labelName'])
                            print ('data grid column labelname:', qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['label'])
                            print ("In data grid column, file upload datatype; index, caption and action are required.")

                # dtdict['dataGrid']= dGC_list
                dtdict['dataGrid']= [dict({'dataGridColumn': dGC_list})]
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)
                # print("answerline in datagrid:",answerline)
            
            elif fieldDT == 'dataGridList':
                print("Entered dataGridList")
                qnsid= qnrdata['labels'][i]['question']['id']
                datagridlist_len= qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns']
                dGL_list=[]
                # dGL_dict={}
                
                for j in range(len(datagridlist_len)):
                    colID= qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['columnId']
                    colDT= qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['dataType']
                    dGL_dict={}
                    coldtdict={}
                    
                    if colDT == 'plainText':
                        try:
                            minans= qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['plainTextPropertie']['minNoOfLetter']
                            # print("min chars:",minans)
                            minans = 1 if minans <=1 else minans
                            maxans= qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['plainTextPropertie']['maxNoOfLetter']
                            # print("max chars:",maxans)
                            mytext= faker.text(max_nb_chars=maxans)
                            # print("text is:",mytext)
                            # print("length of text:",len(mytext))
                            if len(mytext) <= minans:
                                mytext= faker.text(max_nb_chars=maxans)
                                # print("length of text in if:",len(mytext))
                                # print("text in if:",mytext)
                        except Exception as e:
                            # coldtdict['plainText']= faker.text()
                            mytext= faker.text()
                        mytext = mytext.replace('\n', '').replace('\r', '')
                        coldtdict['plainText']= mytext
                        dGL_dict['column']= coldtdict
                        dGL_dict['columnId']= colID
                        # print("Data Grid Dictionary for plainText:",dGL_dict)
                        dGL_list.append(dGL_dict)

                    elif colDT == 'list':
                        print("DataGrid List - list:")
                        try:
                            labelvals= qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['listPropertie']['values']
                        except KeyError:
                            labelvals= None
                        # print("list values:",labelvals)

                        try:
                            baseprice= qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['listPropertie']['basePrice']
                        except KeyError:
                            baseprice=None
                        # print("baseprice:",baseprice)
                        try:
                            minans= qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['listPropertie']['minAnswerable']
                            # minans = 1 if minans <=1 else minans
                            # print("min answers:",minans)
                        except KeyError:
                            minans=None
                        minans = 1 if not minans or minans <=1 else minans
                        # print("min answers:",minans)
                        try:
                            maxans= qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['listPropertie']['maxAnswerable']
                        except KeyError:
                            maxans=None
                        print("max answers:",maxans)
                        if not maxans:
                            rand_maxans = random.randrange(minans, len(labelvals))
                        elif maxans == 1:
                            rand_maxans= maxans
                        else:
                            rand_maxans = random.randrange(minans, maxans)
                        # rand_maxans = random.randrange(minans, len(labelvals)) if not maxans else 1 if maxans == 1 else random.randrange(minans, maxans)
                        print("rand max answers:",rand_maxans)
                        list_value= faker.words(nb=rand_maxans, ext_word_list=labelvals)
                        # print("list value:",list_value)
                        coldtdict['list']= list_value
                        # except KeyError:
                            # coldtdict['list']= faker.words(nb=1, ext_word_list=labelvals)
                        dGL_dict['column']=coldtdict
                        dGL_dict['columnId']= colID
                        dGL_dict['quantity']= 1
                        if baseprice:
                            print('list_value[0]: ', list_value[0])
                            item= list_value[0]
                            print('item: ', item)
                            # bprice = json.loads(json.dumps(baseprice))
                            y = baseprice.replace("{",'{"').replace(":",'":"').replace(", ",'", "').replace("}",'"}')
                            bprice = json.loads(y)
                            print("bprice:",bprice)
                            # print("baseprice type: ", type(bprice))
                            price= bprice[item]
                            # print('price: ', price)
                            dGL_dict['price']= price
                        print("Data Grid Dictionary for list:",dGL_dict)
                        dGL_list.append(dGL_dict)

                    elif colDT == 'number':
                        start=qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['numberPropertie']['start']
                        # print("Data Grid number start:",start)
                        end=qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['numberPropertie']['end']
                        # print("Data Grid Dictionary number end:",end)
                        ran_num= random.randrange(int(start), int(end))
                        # print("Data Grid random number :",ran_num)
                        coldtdict['number']= str(ran_num)
                        dGL_dict['column']= coldtdict
                        # print("Data Grid Dictionary for number:",dGC_dict)
                        dGL_dict['columnId']= colID
                        dGL_list.append(dGL_dict)

                    elif colDT == 'date':
                        start_str=qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['dateProperties']['start']
                        # print("Data Grid date string start:",start_str)
                        start = parser.parse(start_str)
                        # print("Data Grid date start:",start)
                        end_str=qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['dateProperties']['end']
                        # print("Data Grid date string end:",end_str)
                        end = parser.parse(end_str)
                        # print("Data Grid date end:",end)
                        # dGL_dict['date']= faker.date_between_dates(date_start=start, date_end=end).strftime('%Y-%m-%d')
                        coldtdict['date']= faker.date_between_dates(date_start=start, date_end=end).strftime('%Y-%m-%d')
                        dGL_dict['column']= coldtdict
                        # print("Data Grid Dictionary for date:",dGL_dict)
                        dGL_dict['columnId']= colID
                        dGL_list.append(dGL_dict)

                    elif colDT == 'bool':
                        qnsid= qnrdata['labels'][i]['question']['id']
                        # dGC_dict['bool']= faker.pybool()
                        coldtdict['bool']= faker.pybool()
                        dGL_dict['column']= coldtdict
                        # print("Data Grid Dictionary for bool:",dGC_dict)
                        dGL_dict['columnId']= colID
                        dGL_list.append(dGL_dict)

                    elif colDT == 'fileUpload':
                        print("Entered dataGridList fileUpload")
                        filetypes= qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['filePropertie']['fileTypes']
                        # print("filetypes: ",filetypes )
                        # print("dGridlistfileupload: ",kwargs['dGridlistfileupload'])
                        fu_len= len(kwargs['dGridlistfileupload'])
                        # print("dGridlistfileupload length: ",fu_len)
                        allowed_docs= qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['filePropertie']['allowedDocuments']
                        # print("dGridlistfileupload allowed docs: ",allowed_docs)
                        for j in range(fu_len):
                            if any(c in filetypes for c in ('pdf', 'jpeg', 'png', 'jpg', 'docx', 'txt')) and any(c in filetypes for c in ('mp4', 'mov', 'avi', 'flv')) and any(c in filetypes for c in ('mp3', 'wav', 'wma', 'audio')) and "files" in kwargs['dGridlistfileupload'][j].keys():
                                # print ('dataGridList files if condition cleared.')
                                dGL_dict={}
                                coldtlist=[]
                                for k in range(len(kwargs['dGridlistfileupload'][j]['files'])):
                                    if kwargs['dGridlistfileupload'][j]['files'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridlistfileupload'][j]['files'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue

                
                                # dGL_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGL_dict['column']= coldtdict
                                # print("fileupload file answer:",dGL_dict)
                                dGL_dict['columnId']= colID
                                dGL_list.append(dGL_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)  
                                break

                            elif any(c in filetypes for c in ('pdf', 'jpeg', 'png', 'jpg', 'docx', 'txt')) and "files" in kwargs['dGridlistfileupload'][j].keys(): 
                                # print ('dataGridList files if condition cleared.')
                                dGL_dict={}
                                coldtlist=[]
                                for k in range(len(kwargs['dGridlistfileupload'][j]['files'])):
                                    if kwargs['dGridlistfileupload'][j]['files'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridlistfileupload'][j]['files'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue

                
                                # dGL_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGL_dict['column']= coldtdict
                                # print("fileupload file answer:",dGL_dict)
                                dGL_dict['columnId']= colID
                                dGL_list.append(dGL_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)  
                                break

                            elif any(c in filetypes for c in ('mp4', 'mov', 'avi', 'flv')) and "Videos" in kwargs['dGridlistfileupload'][j].keys():
                                # print ('dataGridList Videos if condition cleared.')
                                dGL_dict={}
                                coldtlist=[]
                                for k in range(len(kwargs['dGridlistfileupload'][j]['Videos'])):
                                    if kwargs['dGridlistfileupload'][j]['Videos'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridlistfileupload'][j]['Videos'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue
                
                                # dGC_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGL_dict['column']= coldtdict
                                # print("fileupload video answer:",dGC_dict)
                                dGL_dict['columnId']= colID
                                dGL_list.append(dGL_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)  
                                break

                            elif any(c in filetypes for c in ('mp3', 'wav', 'wma', 'audio')) and "Audio" in kwargs['dGridlistfileupload'][j].keys():
                                # print ('dataGridList Audio if condition cleared.')
                                # colfudict={}
                                coldtlist=[]

                                for k in range(len(kwargs['dGridlistfileupload'][j]['Audio'])):
                                    if kwargs['dGridlistfileupload'][j]['Audio'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridlistfileupload'][j]['Audio'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue
                                    
                                # dGC_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGL_dict['column']= coldtdict
                                # print("fileupload audio answer:",dGL_dict)
                                dGL_dict['columnId']= colID
                                dGL_list.append(dGL_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)
                                break
                        else: 
                            print ('Entered Else.')
                            print ('for labelname:', qnrdata['labels'][i]['question']['labelName'])
                            print ('data grid column labelname:', qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['label'])
                            print ("In data grid column, file upload datatype; index, caption and action are required.")

                # dtdict['dataGrid']= dGC_list
                dtdict['dataGridList']= [dict({'dataGridListColumn': dGL_list})]
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)
                

        final_data={'questionnaireId': id, 'proConId': proConId, 'answerLine': answerline}
        final_data=json.dumps(final_data)
        # print (final_data)
        return  final_data
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def setPrice(questions, answers):
    print("In function: ", inspect.stack()[0].function)
    try:
        # print(answers)
        answers = json.loads(answers)
        ans_length= len(answers['answerLine'])
        for i in range(ans_length):
            GL_len= len(answers['answerLine'][i]['answer']['dataGridList'])
            if 'priceGridList' in questions['labels'][i]['question'] :
                GridListprice= questions['labels'][i]['question']['priceGridList']
                GL_price = json.loads(GridListprice)
            else:
                qn_len= len(questions['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'])
                for m in range(qn_len):
                    GridListprice= questions['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][m]['listPropertie']['basePrice']
                    y = GridListprice.replace("{",'{"').replace(":",'":"').replace(", ",'", "').replace("}",'"}')
                    # bprice = json.loads(y)
                    # GL_price = json.loads(GridListprice)
                    GL_price = json.loads(y)
            print("priceGridList:",GL_price)
            # price=0
            for j in range(GL_len):
                GLC_len= len(answers['answerLine'][i]['answer']['dataGridList'][j]['dataGridListColumn'])
                service={}
                print("--------------------------------------")
                for k in range(GLC_len):
                    print("Answer: ", answers['answerLine'][i]['answer']['dataGridList'][j]['dataGridListColumn'][k]['column'])
                    if 'list' in answers['answerLine'][i]['answer']['dataGridList'][j]['dataGridListColumn'][k]['column']:
                        list_len= len(answers['answerLine'][i]['answer']['dataGridList'][j]['dataGridListColumn'][k]['column']['list'])
                        print("list_len: ", list_len)
                        price=0
                        for l in range(list_len):
                            service[k]= answers['answerLine'][i]['answer']['dataGridList'][j]['dataGridListColumn'][k]['column']['list'][l]
                            print("service: ", service)
                            if k > 0:
                                col_id_key= answers['answerLine'][i]['answer']['dataGridList'][j]['dataGridListColumn'][k]['columnId']
                                print("col_id_key: ", col_id_key)
                                mainkey= service[0]
                                print("mainkey: ", mainkey)
                                subkey= service[k]
                                subkey= subkey.strip()
                                print("subkey: ", subkey)
                                print("GL_price: ",GL_price)
                                print("GL_price[mainkey]: ",GL_price[mainkey])
                                print("GL_price[mainkey][col_id_key]: ",GL_price[mainkey][col_id_key])
                                print("GL_price[mainkey][col_id_key][subkey]: ",GL_price[mainkey][col_id_key][subkey])
                                try:
                                    cost= GL_price[mainkey][col_id_key][subkey]
                                except KeyError:
                                    cost= GL_price[mainkey][col_id_key]
                                    # cost= GL_price[mainkey][subkey]
                                # cost= GL_price[mainkey][col_id_key][subkey]
                                print("service option cost for ", mainkey, "->", col_id_key, "->", subkey, "is :", cost)
                                converted_cost = int(cost)
                                price= price+converted_cost
                                print("price: ", price)
                                print("Total Price for ", mainkey, "->", col_id_key, "->", subkey, "is :", price)
                                answers['answerLine'][i]['answer']['dataGridList'][j]['dataGridListColumn'][k]['price']= price
                            # elif k==0 and list_len > 1:
                            elif k==0 :
                                mainkey= service[k]
                                print("GL_price: ",GL_price)
                                print("GL_price[mainkey]: ",GL_price[mainkey])
                                cost= GL_price[mainkey]
                                try: 
                                    if cost.isdigit():
                                        print("Cost for ", mainkey," is :", cost)
                                        converted_cost = int(cost)
                                        print("converted_cost for ", mainkey," is :", converted_cost)
                                        price= price+converted_cost
                                        answers['answerLine'][i]['answer']['dataGridList'][j]['dataGridListColumn'][k]['price']= price
                                    else:
                                        continue
                                except AttributeError:
                                    continue

        final_data=json.dumps(answers)
        return final_data
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def createFUDict(data, actionval, uid):
    print("In function: ", inspect.stack()[0].function)
    supported_filetypes= ['png', 'jpg', 'pdf', 'jpeg', 'bmp', 'flw', 'docx', 'txt']
    supported_videotypes= ['mp4', 'mov', 'flv', 'mkv', 'avi', 'webm'] 
    supported_audiotypes= ['mp3', 'wav', 'pcm']
    # all_filetypes= ['mp3', 'wav', 'pcm']
    final_data={}
    files_data= [] 
    video_data= [] 
    audio_data= []
    try:
        
        filetypes= data['filePropertie']['fileTypes']

    # print ('filetypes: ',filetypes)
    # check =  any(item in supported_filetypes for item in filetypes)
    # print('check if file:', check)
    # check =  any(item in supported_videotypes for item in filetypes)
    # print('check if video:', check)
    # check =  any(item in supported_audiotypes for item in filetypes)
    # print('check if audio:', check)
        if any(item in supported_filetypes for item in filetypes) and any(item in supported_audiotypes for item in filetypes) and any(item in supported_videotypes for item in filetypes):
            allowed_filedocs= data['filePropertie']['allowedDocuments'] 
            caption= random.choice(allowed_filedocs)
            print('IN all IF, Fileslist from base function: ', fileUploadDT.fileslist)
            for eachfile in fileUploadDT.fileslist:
                print("file: ", eachfile)
                mimetype, encoding = mimetypes.guess_type(eachfile)
                print('mimetype: ', mimetype)
                if mimetype != None:
                    mimestart = mimetype.split('/')[0]
                    # print('mimestart: ', mimestart)
                    # if mimestart == 'file':
                    if mimestart == 'application' or mimestart == 'image' or mimestart == 'text':
                        url= os.path.basename(eachfile)
                        mime= mimetype
                        file_size = os.stat(eachfile)
                        fileUploadDT.fileslist.remove(eachfile)
                        break
            else:
                defaultFileList = ["/ebs/TDD/sample.pdf", "/ebs/TDD/MP4file.mp4", "/ebs/TDD/MP3file.mp3"]
                defaultFile= random.choice(defaultFileList)
                print("IN all IF, defaultFile: ", defaultFile)
                mimetype, encoding = mimetypes.guess_type(defaultFile)
                url= os.path.basename(defaultFile)
                mime= mimetype
                file_size = os.stat(defaultFile)
                
            filedict= dict({'caption': caption, 'action':actionval, 'mimeType': mime, 'url': url, 'size': file_size.st_size, 'uid': uid})
            files_data.append(filedict)
            # print ('files_data: ',files_data)
            final_data['files']= files_data
            # print ('final_data: ',final_data)

        elif any(item in supported_filetypes for item in filetypes):
            # try:
            allowed_filedocs= data['filePropertie']['allowedDocuments'] 
            caption= random.choice(allowed_filedocs)
            
                # print ('allowed_filedocs: ',allowed_filedocs)
                # print ('caption: ',caption)
            # except Exception as e:
            #     print ("Exception:", e)
            #     print ("Exception at line no:", e.__traceback__.tb_lineno)
            print('IN files IF, Fileslist from base function: ', fileUploadDT.fileslist)
            for eachfile in fileUploadDT.fileslist:
                print("file: ", eachfile)
                mimetype, encoding = mimetypes.guess_type(eachfile)
                print('mimetype: ', mimetype)
                if mimetype != None:
                    mimestart = mimetype.split('/')[0]
                    # print('mimestart: ', mimestart)
                    # if mimestart == 'file':
                    if mimestart == 'application' or mimestart == 'image' or mimestart == 'text':
                        url= eachfile
                        mime= mimetype
                        file_size = os.stat(eachfile)
                        fileUploadDT.fileslist.remove(eachfile)
                        break
            else:
                defaultFile= '/ebs/TDD/sample.pdf'
                print("IN files IF, defaultFile: ", defaultFile)
                mimetype, encoding = mimetypes.guess_type(defaultFile)
                url= defaultFile
                mime= mimetype
                file_size = os.stat(defaultFile)

            filedict= dict({'caption': caption, 'action':actionval, 'mimeType': mime, 'url': url, 'size': file_size.st_size, 'uid': uid})
            files_data.append(filedict)
            # print ('files_data: ',files_data)
            final_data['files']= files_data
            # print ('final_data: ',final_data)

            # fileUploadDT.fileindex= fileUploadDT.fileindex + 1
        
        elif any(item in supported_videotypes for item in filetypes):
            
            # try:
            allowed_videos= data['filePropertie']['allowedDocuments'] 
            caption= random.choice(allowed_videos)
                # print ('allowed_videos: ',allowed_videos)
                # print ('caption: ',caption)
            # except Exception as e:
            #     print ("Exception:", e)
            #     print ("Exception at line no:", e.__traceback__.tb_lineno)

            # fileUploadDT.vidindex= fileUploadDT.vidindex + 1
            
            print('IN videos IF,Fileslist from base function: ', fileUploadDT.fileslist)
            for eachfile in fileUploadDT.fileslist:
                # print("file: ", eachfile)
                mimetype, encoding = mimetypes.guess_type(eachfile)
                # print('mimetype: ', mimetype)
                if mimetype != None:
                    mimestart = mimetype.split('/')[0]
                    # print('mimestart: ', mimestart)
                    if mimestart == 'video':
                        url= eachfile
                        mime= mimetype
                        file_size = os.stat(eachfile)
                        fileUploadDT.fileslist.remove(eachfile)
                        break
            else:
                defaultVideoFile= '/ebs/TDD/MP4file.mp4'
                print("IN videos IF, defaultFile: ", defaultVideoFile)
                mimetype, encoding = mimetypes.guess_type(defaultVideoFile)
                url= defaultVideoFile
                mime= mimetype
                file_size = os.stat(defaultVideoFile)

            viddict= dict({'caption': caption, 'action':actionval, 'mimeType': mime, 'url': url, 'size': file_size.st_size, 'uid': uid})
            video_data.append(viddict)
            # print ('video_data: ',viddict)
            final_data['Videos']= video_data
            # print ('final_data: ',final_data)

        elif any(item in supported_audiotypes for item in filetypes):
            
            # try:
            allowed_audios= data['filePropertie']['allowedDocuments'] 
            caption= random.choice(allowed_audios)
            # except Exception as e:
            #     print ("Exception:", e)
            #     print ("Exception at line no:", e.__traceback__.tb_lineno)

            # fileUploadDT.audindex= fileUploadDT.audindex + 1
            
            print('IN audio IF, Fileslist from base function: ', fileUploadDT.fileslist)
            for eachfile in fileUploadDT.fileslist:
                # print("file: ", eachfile)
                mimetype, encoding = mimetypes.guess_type(eachfile)
                # print('mimetype: ', mimetype)
                if mimetype != None:
                    mimestart = mimetype.split('/')[0]
                    # print('mimestart: ', mimestart)
                    if mimestart == 'audio':
                        url= eachfile
                        mime= mimetype
                        file_size = os.stat(eachfile)
                        fileUploadDT.fileslist.remove(eachfile)
                        break
            else:
                defaultAudioFile= '/ebs/TDD/MP3file.mp3'
                print("IN audio IF, defaultFile: ", defaultAudioFile)
                mimetype, encoding = mimetypes.guess_type(defaultAudioFile)
                url= defaultAudioFile
                file_size = os.stat(defaultAudioFile)
                mime= mimetype

            auddict= dict({'caption': caption, 'action':actionval, 'mimeType': mime, 'url': url, 'size': file_size.st_size, 'uid': uid})
            audio_data.append(auddict)
            # print ('audio_data: ',audio_data)
            final_data['Audio']= audio_data
            # print ('final_data: ',final_data)
                
        print('Going to return final_data: ',final_data)
        return  final_data

    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
    


def fileUploadDT(qnrdata, actionval, uid, *files):     
    print("In function: ", inspect.stack()[0].function)
    fileUploadDT.fileslist= list(files)
    supported_filetypes= ['png', 'jpg', 'pdf', 'jpeg', 'bmp', 'flw', 'docx', 'txt']
    supported_videotypes= ['mp4', 'mov', 'flv', 'mkv', 'avi', 'webm']
    supported_audiotypes= ['mp3', 'wav', 'pcm']
    # fileUploadDT.fileindex=0
    # fileUploadDT.fileDGindex=0
    # fileUploadDT.fileDGLindex=0
    # fileindex=0
    fileDGindex=0
    fileDGLindex=0
    final_data={}
    nongrid_data=[]
    grid_data=[]
    gridlist_data=[]
    try:
        for i in range(len(qnrdata['labels'])):
            lblname= qnrdata['labels'][i]['question']['labelName']
            fieldDT= qnrdata['labels'][i]['question']['fieldDataType']
            if fieldDT == 'fileUpload':
                print(lblname)
                nongrid_data.append(createFUDict(qnrdata['labels'][i]['question'], actionval , uid))
                # fileindex= fileindex + 1
            
            elif fieldDT == 'dataGrid':
                datagrid_len= len(qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'])
                print(lblname)
                for j in range(datagrid_len):
                    colDT= qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j]['dataType']
                    if colDT == 'fileUpload':
                        grid_data.append(createFUDict(qnrdata['labels'][i]['question']['dataGridProperties']['dataGridColumns'][j], actionval , uid))
                        # fileDGindex= fileindex + 1
            
            elif fieldDT == 'dataGridList':
                datagrid_len= len(qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'])
                print(lblname)
                for j in range(datagrid_len):
                    colDT= qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['dataType']
                    if colDT == 'fileUpload':
                        gridlist_data.append(createFUDict(qnrdata['labels'][i]['question']['dataGridListProperties']['dataGridListColumns'][j], actionval , uid))
                        # fileDGLindex= fileindex + 1

        final_data['fileupload']= nongrid_data
        final_data['dGridfileupload']= grid_data
        final_data['dGridlistfileupload']= gridlist_data
        return  final_data
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)                    
                      

                      
def clear_jcashoffer (name):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            cur.execute("SELECT consumer_id FROM jaldee_cash_tbl WHERE offer_name='%s'" % name)
            row1 = cur.fetchall()
            print (row1) 
            cur.execute("SELECT id FROM jaldee_cash_offer_tbl WHERE name='%s'" % name)
            row3 = cur.fetchone()
            print (row3) 
            cur.execute("SELECT jcash_offer_id FROM jaldee_cash_tbl WHERE offer_name='%s'" % name)
            row2 = cur.fetchall()
            print (row2) 
            for index in range(len(row2)):  
                    cur.execute("SELECT jcash_offer_id FROM jcash_offer_issue_stat_tbl WHERE jcash_offer_id='%s'" % int(row2[index][0]))
            row = cur.fetchall()
            print (row) 

            delete_entry('jcash_offer_issue_stat_tbl','jcash_offer_id',int(row3[0]),cur)
            delete_entry('jcash_txn_log_tbl','jcash_offer_id',int(row3[0]),cur) 
            delete_entry('jaldee_cash_tbl','offer_name',name,cur)   
            delete_entry('jaldee_cash_offer_tbl','id',int(row3[0]),cur)   
            # delete_entry('jcash_txn_log_tbl','offer_name',name,cur) 

            for index in range(len(row1)):  
                    delete_entry('wallet_tbl','id',int(row1[index][0]),cur)

            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def MultiUser_InternalStatus(statuses,accNo):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        print(statuses)
        with dbconn.cursor() as cur:
            uu=cur.execute("update account_settings_tbl set account_customized_json='%s'  where account ='%s'  "% (statuses,accNo))
            dbconn.commit()
            # dbconn.close()
            return uu
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


# def XMLtoDict(data):
#     root = ET.fromstring(data)
#     for item in root.findall("."):
#         print ("xml items: ", item)
#         fields = {}
#         for subitem in item:
#             print ("child of item ", item, "is: ", subitem)
#             # fields[child.tag] = child.text
#             # print attrName + '=' + attrValue
#             print("attrName: ", subitem, "attrValue: ", subitem.text)
#             for child in subitem:
#                 print ("child of subitem ", subitem, "is: ", child)
#                 fields[child.tag] = child.text.encode('utf8')
#                 print("dictonary: ", fields)

def random_phone_num_generator():
    while True:
        try:
        
            countrycode= str(random.randint(1, 99)).zfill(2)
            first = str(random.randint(100, 999))
            second = str(random.randint(1, 888)).zfill(3)
            last = (str(random.randint(1, 9998)).zfill(4))
            while last in ['1111', '2222', '3333', '4444', '5555', '6666', '7777', '8888']:
                last = (str(random.randint(1, 9998)).zfill(4))
            phone= '+'+countrycode+first+second+last
            print("phone number:"+ phone)
            phone_number = phonenumbers.parse(phone)
            print(phone_number)
            # print('country code is:'+ str(phone_number.country_code))
            print(phonenumbers.is_valid_number(phone_number))
            if phonenumbers.is_valid_number(phone_number):
                if phone_number.country_code != 91:
                    print(geocoder.description_for_number(phone_number, 'en'))
                    print(region_code_for_country_code(phone_number.country_code))
                    print("Going to return- country code: "+ str(phone_number.country_code) + " and phone number: "+ str(phone_number.national_number))
                    # valid_number= phone_number
                    # print("valid number: "+ str(valid_number))
                    return phone_number
                else:
                    continue
            else:
                # random_phone_num_generator()    
                continue
            
        except phonenumbers.NumberParseException as npe:
            # random_phone_num_generator()
            continue


def random_country_codes(number):
    
    # first = str(random.randint(100, 999))
    # second = str(random.randint(1, 888)).zfill(3)
    # last = (str(random.randint(1, 9998)).zfill(4))
    # while last in ['1111', '2222', '3333', '4444', '5555', '6666', '7777', '8888']:
    #     last = (str(random.randint(1, 9998)).zfill(4))
    country_code_list=[]
    counter=0
    while True:
        try:
        
            countrycode= str(random.randint(1, 99)).zfill(2)
            phone= '+'+countrycode+str(number)
            print("phone number:"+ phone)
            phone_number = phonenumbers.parse(phone)
            print(phone_number)
            # print('country code is:'+ str(phone_number.country_code))
            print(phonenumbers.is_valid_number(phone_number))
            if phonenumbers.is_valid_number(phone_number):
                if (phone_number.country_code != 91  
                   and phone_number.national_number == number  
                #    and phone_number.country_code not in country_code_list
                   ):
                    print(geocoder.description_for_number(phone_number, 'en'))
                    print(region_code_for_country_code(phone_number.country_code))
                    print("Going to return- country code: "+ str(phone_number.country_code) + " and phone number: "+ str(phone_number.national_number))
                    country_code_list.append(phone_number.country_code)
                    if counter<5:
                        counter+=1
                        continue
                    return country_code_list
                else:
                    continue
            else:
                # random_phone_num_generator()    
                continue
            
        except phonenumbers.NumberParseException as npe:
            # random_phone_num_generator()
            continue


def country_code_numbers(countrycode):
    
    number_list=[]
    counter=0
    while True:
        try:
        
            first = str(random.randint(100, 999))
            second = str(random.randint(1, 888)).zfill(3)
            last = (str(random.randint(1, 9998)).zfill(4))
            while last in ['1111', '2222', '3333', '4444', '5555', '6666', '7777', '8888']:
                last = (str(random.randint(1, 9998)).zfill(4))
            # countrycode= str(random.randint(1, 99)).zfill(2)
            phone= '+'+countrycode+first+second+last
            print("phone number:"+ phone)
            phone_number = phonenumbers.parse(phone)
            print(phone_number)
            # print('country code is:'+ str(phone_number.country_code))
            print(phonenumbers.is_valid_number(phone_number))
            if phonenumbers.is_valid_number(phone_number):
                # if (phone_number.country_code != 91  
                #    and phone_number.national_number == number  
                # #    and phone_number.country_code not in country_code_list
                #    ):
                    print(geocoder.description_for_number(phone_number, 'en'))
                    print(region_code_for_country_code(phone_number.country_code))
                    print("Going to return- country code: "+ str(phone_number.country_code) + " and phone number: "+ str(phone_number.national_number))
                    number_list.append(phone_number.national_number)
                    if counter<5:
                        counter+=1
                        continue
                    return number_list
                # else:
                #     continue
            else:
                # random_phone_num_generator()    
                continue
            
        except phonenumbers.NumberParseException as npe:
            # random_phone_num_generator()
            continue


    
def payTmVerify(accNo):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            cur.execute("update account_payment_settings_tbl set paytm_verified=true  where account ='%s'" % accNo)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


def razorpayVerify(accNo):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            cur.execute("update account_payment_settings_tbl set razorpay_verified=true  where account ='%s'" % accNo)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


def payment_profiles(statuses,accNo):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        print(statuses)
        with dbconn.cursor() as cur:
            uu=cur.execute("update account_settings_tbl set payment_profile_json='%s'  where account ='%s'  "% (statuses,accNo))
            dbconn.commit()
            return uu
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


def jaldee_bank_profile() :       
    with open(def_profile,'r') as data:
        payment_profile = data.read()
        print(payment_profile)
    return json.loads(payment_profile)


def count_digits(number):
    try:
        count=len(str(abs(int(number))))
        return count
    except (ValueError):
        print ('Please enter only numbers.')
        return 0
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def get_robot_version():
    command1=["robot", "--version"]
    proc1=subprocess.Popen(command1, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out1, err1 = proc1.communicate()
    exitcode1 = proc1.returncode
    print('robot --version output: ', out1)
    print('err1: ', err1,'\t exitcode1: ', exitcode1)

    # command2=["python3", "-m", "pip", "show", "robotframework"]
    # proc2=subprocess.Popen(command2, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    # out2, err2 = proc2.communicate()
    # exitcode2 = proc2.returncode
    # print('python3 -m pip show robotframework output:', out2)



def categorytype(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_category_tbl(account,name,status,type_enum,created_by,created_date,modified_by)
                           VALUES (%s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [(account,'Task Category 1',0,1,1,date,0),
                                 (account,'Task Category 2',0,1,1,date,0),
                                 (account,'Task Category 3',0,1,1,date,0),
                                 (account,'Lead Category 1',0,2,1,date,0),
                                 (account,'Lead Category 2',0,2,1,date,0),
                                 (account,'Lead Category 3',0,2,1,date,0),
                                 (account,'Enquire Category 1',0,3,1,date,0),
                                 (account,'Enquire Category 2',0,3,1,date,0),
                                 (account,'Enquire Category 3',0,3,1,date,0),
                                 (account,'Electronics',0,4,1,date,0),
                                 (account,'Home Loan',0,4,1,date,0),
                                 (account,'Loan Application Category 1',0,4,1,date,0),
                                 (account,'Loan Application Category 2',0,4,1,date,0),
                                 (account,'Loan Category 1',0,5,1,date,0),
                                 (account,'Loan Category 2',0,5,1,date,0)]
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def tasktype(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_type_tbl(account,name,status,type_enum,created_by,created_date,modified_by)
                           VALUES (%s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [(account,'Task Type 1',0,1,1,date,0),
                                 (account,'Task Type 2',0,1,1,date,0),
                                 (account,'Task Type 3',0,1,1,date,0),
                                 (account,'Lead Type 1',0,2,1,date,0),
                                 (account,'Lead Type 2',0,2,1,date,0),
                                 (account,'Lead Type 3',0,2,1,date,0),
                                 (account,'EnquiryType 1',0,3,1,date,0),
                                 (account,'EnquiryType 2',0,3,1,date,0),
                                 (account,'EnquiryType 3',0,3,1,date,0),
                                 (account,'Loan Application Type 1',0,4,1,date,0),
                                 (account,'Loan Application Type 2',0,4,1,date,0),
                                 (account,'Loan Type 1',0,5,1,date,0),
                                 (account,'Loan Type 2',0,5,1,date,0)]
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def clear_category(account):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            date= get_date()
            delete_entry('crm_category_tbl','account',account,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def clear_drive(account):
    print("In function: ", inspect.stack()[0].function)
    aid=get_acc_id(account)    
   # uid = get_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('drive_tbl','account',aid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def enquiryTemplate(account_id,en_temp_name,status_id,category_id=0,priority_id=5,type_id=0,creator_provider_id=1,modifier_provider_id=0,is_available=1,is_lead_autogenerate=1):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            mySql_insert_query = """INSERT INTO ynw.crm_enquire_master_tbl(account_id, origin_from, loan_nature, template_name, title, title_style, description, description_style, category_id, category_style, type_id, type_style, priority_id, priority_style, status_id, status_style, location_style, location_area_style, customer_style, customer_city_style, customer_district_style, customer_state_style, customer_pin_style, is_lead_autogenerate, available, tasks, attachments, notes, subtask, subtask_count, created_by, created_date, modified_by)
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) """

            # records_to_insert = (creator_provider_id,datetime.datetime.now(),modifier_provider_id,account_id,en_temp_name,en_temp_name,'{"fieldtype": 0,"datatype": 0,"iseditable": false,"isvisible": false}',en_temp_name+'Description','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}',category_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',priority_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',type_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','[]','[]','[]',is_available,is_lead_autogenerate,status_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": false,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 6,"iseditable": true,"isvisible": true}')
            records_to_insert = (account_id, 0, 0, en_temp_name, en_temp_name, '{"datatype": 0, "fieldtype": 0, "isvisible": false, "iseditable": false}', en_temp_name+'Description', '{"datatype": 0, "fieldtype": 0, "isvisible": false, "iseditable": true}', category_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}', type_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}', priority_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}', status_id,'{"datatype": 5, "fieldtype": 2, "isvisible": false, "iseditable": true, "ismandatory": false}', '{"datatype": 5, "fieldtype": 2, "isvisible": false, "iseditable": false}', '{"datatype": 0, "fieldtype": 0, "isvisible": true, "iseditable": true}', '{"datatype": 6, "fieldtype": 0, "isvisible": true, "iseditable": true, "ismandatory": true}', '{"datatype": 0, "fieldtype": 0, "isvisible": false, "iseditable": false, "ismandatory": false}', '{"datatype": 0, "fieldtype": 0, "isvisible": false, "iseditable": false, "ismandatory": false}', '{"datatype": 0, "fieldtype": 0, "isvisible": false, "iseditable": false, "ismandatory": false}', '{"datatype": 0, "fieldtype": 0, "isvisible": false, "iseditable": false, "ismandatory": false}', is_lead_autogenerate, is_available, '[]', '[]', '[]', 0, 0, creator_provider_id,datetime.datetime.now(),modifier_provider_id)
            cur.execute(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()


def leadTemplate(account_id, lead_temp_name,status_id,category_id=0,priority_id=5,type_id=0,creator_provider_id=1,modifier_provider_id=0,is_available=1):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            # date= get_date()
            mySql_insert_query = """INSERT INTO `ynw`.`crm_lead_master_tbl` (`created_by`,`created_date`,`modified_by`,`account_id`,`template_name`,`title`,`title_style`,`description`,`description_style`,`category_id`,`category_style`,`priority_id`,`priority_style`,`type_id`,`type_style`,`target_potential_style`,`target_result_style`,`attachments`,`notes`,`tasks`,`available`,`status_id`,`status_style`,`assignee_style`,`manager_style`,`location_style`,`location_area_style`,`customer_style`,`actual_result_style`,`actual_potential_style`) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) """

            # records_to_insert = [(creator_provider_id,datetime.datetime.now(),modifier_provider_id,account_id,'Home Loan','Home Loan','{"fieldtype": 0,"datatype": 0,"iseditable": false,"isvisible": false}','Home Loan Description','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}',category_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',priority_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',type_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 0,"datatype": 3,"iseditable": true,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}','[]','[]','[]',is_available,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": false,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 6,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 3,"iseditable": true,"isvisible": false}'),
            #                     (creator_provider_id,datetime.datetime.now(),modifier_provider_id,account_id,'Property Loan','Property Loan','{"fieldtype": 0,"datatype": 0,"iseditable": false,"isvisible": false}','Property Loan Description','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}',category_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',priority_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',type_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 0,"datatype": 3,"iseditable": true,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}','[]','[]','[]',is_available,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": false,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 6,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 3,"iseditable": true,"isvisible": false}'),
            #                     (creator_provider_id,datetime.datetime.now(),modifier_provider_id,account_id,'Business Loan','Business Loan','{"fieldtype": 0,"datatype": 0,"iseditable": false,"isvisible": false}','Business Loan Description','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}',category_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',priority_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',type_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 0,"datatype": 3,"iseditable": true,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}','[]','[]','[]',is_available,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": false,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 6,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 3,"iseditable": true,"isvisible": false}'),
            #                     (creator_provider_id,datetime.datetime.now(),modifier_provider_id,account_id,'Other Loans','Other Loans','{"fieldtype": 0,"datatype": 0,"iseditable": false,"isvisible": false}','Other Loans Description','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}',category_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',priority_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',type_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 0,"datatype": 3,"iseditable": true,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}','[]','[]','[]',is_available,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": false,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 6,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 3,"iseditable": true,"isvisible": false}')]
            records_to_insert = (creator_provider_id,datetime.datetime.now(),modifier_provider_id,account_id,lead_temp_name,lead_temp_name,'{"fieldtype": 0,"datatype": 0,"iseditable": false,"isvisible": false}',lead_temp_name+'Description','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}',category_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',priority_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',type_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 0,"datatype": 3,"iseditable": true,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}','[]','[]','[]',is_available, status_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": false,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 6,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 3,"iseditable": true,"isvisible": false}')
            cur.execute(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()


def taskTemplate(account_id, task_temp_name,status_id,origin_from=3,origin_id=0,is_subtask=1,category_id=0,priority_id=1,type_id=0,creator_provider_id=1,modifier_provider_id=0,is_available=1):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            # date= get_date()
            mySql_insert_query = """INSERT INTO `ynw`.`crm_task_master_tbl` (`created_by`,`created_date`,`modified_by`,`account`,`origin_from`,`origin_id`,`subtask`,`template_name`,`title`,`title_style`,`description`,`description_style`,`category`,`category_style`,`priority`,`priority_style`,`type`,`type_style`,`est_duration`,`est_duration_style`,`target_potential_style`,`target_result_style`,`attachments`,`notes`,`available`,`status`,`status_style`,`assignee_style`,`manager_style`,`location_style`,`location_area_style`,`due_date_style`,`actual_duration_style`,`actual_result_style`,`actual_potential_style`) 
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = (creator_provider_id,datetime.datetime.now(),modifier_provider_id,account_id,origin_from,origin_id,is_subtask,task_temp_name,task_temp_name,'{"fieldtype": 0,"datatype": 0,"iseditable": false,"isvisible": false}',task_temp_name+'Description','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}',category_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',priority_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}',type_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"days": 0, "hours": 0, "minutes": 0}','{"fieldtype": 0,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 0,"datatype": 3,"iseditable": true,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": false}','[]','[]',is_available, status_id,'{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": true}','{"fieldtype": 2,"datatype": 5,"iseditable": true,"isvisible": false}','{"fieldtype": 2,"datatype": 5,"iseditable": false,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 6,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 5,"iseditable": false,"isvisible": false}','{"fieldtype": 0,"datatype": 0,"iseditable": true,"isvisible": true}','{"fieldtype": 0,"datatype": 3,"iseditable": true,"isvisible": false}')
            cur.execute(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()


# def setOrigin(table,field,value,wfield1,wvalue1,wfield2,wvalue2):
#     dbconn = connect_db(db_host, db_user, db_passwd, db)
#     try:
#         with dbconn.cursor() as cur:
#             # update_query="UPDATE %s SET %s=%s WHERE %s='%s';"
#             cur.execute("UPDATE %s SET %s=%s WHERE %s='%s'and %s ='%s';" % (table,field,value,wfield,wvalue,wfield2,wvalue2))
#             # cur.execute(update_query, table, field, value, wfield, wvalue)           
#             dbconn.commit()
         
#     except Exception as e:
#         print ("Exception:", e)
#         print ("Exception at line no:", e.__traceback__.tb_lineno)
#         pass
#     finally:
#         if dbconn is not None:
#             dbconn.close()


def leadQnr(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_status_tbl(account,name,status,type_enum,created_by,created_date,modified_by,is_kycupdated,is_creditscoregenerated,is_salesfieldverified,is_editable,is_documentverified)
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [(0,'Login',0,2,1,date,0,0,0,0,0,1),
                                 (0,'Pending',0,1,1,date,0,1,0,0,1,0),
                                 (0,'Rejected',0,1,1,date,0,0,1,0,1,0),
                                 (0,'Proceed',0,1,1,date,0,0,0,1,1,0),
                                 (0,'Verified',0,1,1,date,0,0,0,0,0,1),
                                 (0,'KYC Updated',0,2,1,date,0,1,0,0,1,0),
                                 (0,'Credit Score Generated',0,2,1,date,0,0,1,0,1,0),
                                 (0,'Sales Verified',0,2,1,date,0,0,0,1,1,0)]
                                 
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()


def reset_user_metric(aid) :
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    # cur = dbconn.cursor()
    try :
        with dbconn.cursor() as cur:
            cur.execute("SELECT metric_usage FROM account_matrix_usage_tbl WHERE id='%s'" % aid)
            jsonVal = cur.fetchone()
        
            data= json.loads(jsonVal[0])
            ntm=data['nonTransientMetrics']
            print("ntm: ",ntm)
            for i in range(len(ntm)):
                if ntm[i]['metricId']==multiuser_metric_id:
                    print("ntm[i]: ",ntm[i])
                    ntm[i]['usage']=0
            data=json.dumps(data)
            cur.execute("update account_matrix_usage_tbl set metric_usage='%s' where id='%s';" % (data,aid))
            dbconn.commit()
            cur.execute("SELECT metric_usage FROM account_matrix_usage_tbl WHERE id='%s'" % aid)
            jsonVal = cur.fetchone()
            data= json.loads(jsonVal[0])
            ntm=data['nonTransientMetrics']
            print("ntm: ",ntm)
            # dbconn.close()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0 
    finally:
        if dbconn is not None:
            dbconn.close()

def CrifScore(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:

        with dbconn.cursor() as cur:

            mySql_insert_query = """INSERT INTO `ynw`.`thirdparty_setting_tbl` (`account_id`,`credit_score_bureau`,`crif_inquiry_setting`,`created_by`,`created_date`,`modified_by`) 
                        VALUES (%s, %s, %s, %s, %s, %s) """
            records_to_insert = (account,1,'{"url": "https://test.crifhighmark.com/Inquiry/doGet.service/requestResponseSync", "losName": "abc", "authFlag": "Y", "branchId": "3008", "kendraId": "1234", "losAppId": null, "memberId": "XXX", "testFlag": "HMTEST", "authTitle": "USER", "losVender": "cde", "resFormat": "XML/HTML", "urlMethod": "POST", "losVersion": "1.0", "reqVolType": "C01", "headerMbrid": "NBF0003084", "subMemberId": "MABEN NIDHI LIMITED", "headerUserId": "crif1_cpu_uat@mabennidhi.in", "reqActionType": "SUBMIT", "creditInqStage": "PRE-SCREEN", "headerPassword": "1B51710594270971FFBAEB703F8A1394C5987BFD", "headerReqVolType": "INDV", "headerProductType": "INDV", "creditInqPurpsType": "ACCT-ORIG", "headerProductVersion": "1.0", "creditInqPurpsTypeDesc": "JLG INDIVIDUAL"}',1,datetime.datetime.now(),0)
            print(records_to_insert)
            cur.execute(mySql_insert_query, records_to_insert)            
            dbconn.commit()

    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def fileUploadDTlead(qnrdata, actionval, *files):     
    print("In function: ", inspect.stack()[0].function)
    fileUploadDT.fileslist= list(files)
    supported_filetypes= ['png', 'jpg', 'pdf', 'jpeg', 'bmp', 'flw', 'docx', 'txt']
    supported_videotypes= ['mp4', 'mov', 'flv', 'mkv', 'avi', 'webm']
    supported_audiotypes= ['mp3', 'wav', 'pcm']
    # fileUploadDT.fileindex=0
    # fileUploadDT.fileDGindex=0
    # fileUploadDT.fileDGLindex=0
    fileindex=0
    fileDGindex=0
    fileDGLindex=0
    final_data={}
    nongrid_data=[]
    grid_data=[]
    gridlist_data=[]
    try:
        for i in range(len(qnrdata['questionAnswers'])):
            lblname= qnrdata['questionAnswers'][i]['question']['labelName']
            fieldDT= qnrdata['questionAnswers'][i]['question']['fieldDataType']
            if fieldDT == 'fileUpload':
                print(lblname)
                nongrid_data.append(createFUDict(qnrdata['questionAnswers'][i]['question'], fileindex ,actionval))
                fileindex= fileindex + 1
            
            elif fieldDT == 'dataGrid':
                datagrid_len= len(qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'])
                print(lblname)
                for j in range(datagrid_len):
                    colDT= qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['dataType']
                    if colDT == 'fileUpload':
                        grid_data.append(createFUDict(qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j], fileDGindex, actionval))
                        fileDGindex= fileindex + 1
            
            elif fieldDT == 'dataGridList':
                datagrid_len= len(qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'])
                print(lblname)
                for j in range(datagrid_len):
                    colDT= qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['dataType']
                    if colDT == 'fileUpload':
                        gridlist_data.append(createFUDict(qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j], fileDGLindex, actionval))
                        fileDGLindex= fileindex + 1

        final_data['fileupload']= nongrid_data
        final_data['dGridfileupload']= grid_data
        final_data['dGridlistfileupload']= gridlist_data
        return  final_data
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)                    
                      


def QuestionnaireAnswerslead(qnrdata, proConId, **kwargs):
    print("In function: ", inspect.stack()[0].function)
    faker = Faker()      
    try:
        id = qnrdata['questionnaireId']
        answerline=[]
        for i in range(len(qnrdata['questionAnswers'])):
            lblname= qnrdata['questionAnswers'][i]['question']['labelName']
            fieldDT= qnrdata['questionAnswers'][i]['question']['fieldDataType']
            dtdict={}
            ansdict={}
            if fieldDT == 'plainText':
                qnsid= qnrdata['questionAnswers'][i]['question']['id']
                try:
                    minans= qnrdata['questionAnswers'][i]['question']['plainTextPropertie']['minNoOfLetter']
                    minans = 1 if minans <=1 else minans
                    # print("min chars:",minans)
                    maxans= qnrdata['questionAnswers'][i]['question']['plainTextPropertie']['maxNoOfLetter']
                    # print("max chars:",maxans)
                    mytext= faker.text(max_nb_chars=maxans)
                    # print("text is:",mytext)
                    # print("length of text:",len(mytext))
                    if len(mytext) <= minans:
                        mytext= faker.text(max_nb_chars=maxans)
                        # print("length of text in if:",len(mytext))
                        # print("text in if:",mytext)
                except Exception as e:
                    # print ('Exception: ', e)
                    mytext= faker.text()
                # mytext= faker.text(max_nb_chars=maxans)
                mytext = mytext.replace('\n', '').replace('\r', '')
                # dtdict['plainText']= faker.text(max_nb_chars=maxans)
                dtdict['plainText']= mytext
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)

            elif fieldDT == 'list':
                labelvals= qnrdata['questionAnswers'][i]['question']['labelValues']
                qnsid= qnrdata['questionAnswers'][i]['question']['id']
                minans= qnrdata['questionAnswers'][i]['question']['listPropertie']['minAnswers']
                # print("min answers:",minans)
                minans = 1 if minans <=1 else minans
                maxans= qnrdata['questionAnswers'][i]['question']['listPropertie']['maxAnswers']
                # print("max answers:",maxans)
                rand_maxans = 1 if maxans == 1 else random.randrange(minans, maxans)
                dtlist= random.sample(labelvals, rand_maxans)
                dtdict['list']= dtlist
                # print("list answer:",dtdict)
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)
                # print("answerline in list:",answerline)

            elif fieldDT == 'bool':
                qnsid= qnrdata['questionAnswers'][i]['question']['id']
                dtdict['bool']= faker.pybool()
                # print("bool answer:",dtdict)
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)
                # print("answerline in bool:",answerline)

            elif fieldDT == 'date':
                qnsid= qnrdata['questionAnswers'][i]['question']['id']
                dtdict['date']= faker.date_between().strftime('%Y-%m-%d')
                # answer=[dtdict]
                # print("date answer:",dtdict)
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)
                # print("answerline in date:",answerline)

            elif fieldDT == 'number':
                qnsid= qnrdata['questionAnswers'][i]['question']['id']
                start=qnrdata['questionAnswers'][i]['question']['numberPropertie']['start']
                end=qnrdata['questionAnswers'][i]['question']['numberPropertie']['end']
                dtdict['number']= faker.random_int(min=start, max=end)
                # print("number answer:",dtdict)
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)
                # print("answerline in number:",answerline)

            elif fieldDT == 'fileUpload':
                qnsid= qnrdata['questionAnswers'][i]['question']['id']
                filetypes= qnrdata['questionAnswers'][i]['question']['filePropertie']['fileTypes']
                allowed_docs= qnrdata['questionAnswers'][i]['question']['filePropertie']['allowedDocuments']
                print ('allowed documents for', qnrdata['questionAnswers'][i]['question']['labelName'],' :', allowed_docs)
                fu_len= len(kwargs['fileupload'])
                for j in range(fu_len):
                    if any(c in filetypes for c in ('pdf', 'jpeg', 'png', 'jpg', 'docx', 'txt')) and any(c in filetypes for c in ('mp4', 'mov', 'avi', 'flv')) and any(c in filetypes for c in ('mp3', 'wav', 'wma', 'audio')) and "files" in kwargs['fileupload'][j].keys():
                        # print ('files if condition cleared.')
                        fudict={}
                        dtlist=[]
                        for k in range(len(kwargs['fileupload'][j]['files'])):
                            print ('file name in caption:', kwargs['fileupload'][j]['files'][k]['caption'])
                            if kwargs['fileupload'][j]['files'][k]['caption'] in allowed_docs:
                                # print ('caption if condition in nested for cleared.')
                                dtlist.append(kwargs['fileupload'][j]['files'][k])
                                print ('dtlist:', dtlist)
                                break
                            else:
                                continue
                    

                        dtdict['fileUpload']= dtlist
                        # print("fileupload file answer:",dtdict)
                        ansdict['labelName']= lblname
                        ansdict['id']= qnsid
                        ansdict['answer']= dtdict
                        answerline.append(ansdict) 
                        # print("answerline for fileupload:",answerline)  
                        break
                    elif any(c in filetypes for c in ('pdf', 'jpeg', 'png', 'jpg', 'docx', 'txt')) and "files" in kwargs['fileupload'][j].keys():
                        # print ('files if condition cleared.')
                        fudict={}
                        dtlist=[]
                        for k in range(len(kwargs['fileupload'][j]['files'])):
                            print ('file name in caption:', kwargs['fileupload'][j]['files'][k]['caption'])
                            if kwargs['fileupload'][j]['files'][k]['caption'] in allowed_docs:
                                # print ('caption if condition in nested for cleared.')
                                dtlist.append(kwargs['fileupload'][j]['files'][k])
                                print ('dtlist:', dtlist)
                                break
                            else:
                                continue
                    

                        dtdict['fileUpload']= dtlist
                        # print("fileupload file answer:",dtdict)
                        ansdict['labelName']= lblname
                        ansdict['id']= qnsid
                        ansdict['answer']= dtdict
                        answerline.append(ansdict) 
                        # print("answerline for fileupload:",answerline)  
                        break

                    elif any(c in filetypes for c in ('mp4', 'mov', 'avi', 'flv')) and "Videos" in kwargs['fileupload'][j].keys():
                        # print ('Videos if condition cleared.')
                        fudict={}
                        dtlist=[]
                        for k in range(len(kwargs['fileupload'][j]['Videos'])):
                            if kwargs['fileupload'][j]['Videos'][k]['caption'] in allowed_docs:
                                dtlist.append(kwargs['fileupload'][j]['Videos'][k])
                                # print ('dtlist:', dtlist)
                                break
                            else:
                                continue
                    
                        dtdict['fileUpload']= dtlist
                        # print("fileupload video answer:",dtdict)
                        qnsid= qnrdata['questionAnswers'][i]['question']['id']
                        ansdict['labelName']= lblname
                        ansdict['id']= qnsid
                        ansdict['answer']= dtdict
                        answerline.append(ansdict) 
                        # print("answerline for fileupload: ",answerline) 

                    elif any(c in filetypes for c in ('mp3', 'wav', 'wma', 'audio')) and "Audio" in kwargs['fileupload'][j].keys():
                        # print ('Audio if condition cleared.')
                        fudict={}
                        dtlist=[]
                        for k in range(len(kwargs['fileupload'][j]['Audio'])):
                            if kwargs['fileupload'][j]['Audio'][k]['caption'] in allowed_docs:
                                dtlist.append(kwargs['fileupload'][j]['Audio'][k])
                                # print ('dtlist:', dtlist)
                                break
                            else:
                                continue
                    
                        dtdict['fileUpload']= dtlist
                        # print("fileupload audio answer:",dtdict)
                        ansdict['labelName']= lblname
                        ansdict['id']= qnsid
                        ansdict['answer']= dtdict
                        answerline.append(ansdict) 
                        # print("answerline for fileupload: ",answerline)
                    else: 
                        print ('for labelname:', qnrdata['questionAnswers'][i]['question']['labelName'])
                        print ("index, caption and action are required.")

            elif fieldDT == 'dataGrid':
                qnsid= qnrdata['questionAnswers'][i]['question']['id']
                datagrid_len= qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns']
                dGC_list=[]
                dGC_dict={}
                
                for j in range(len(datagrid_len)):
                    colID= qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['columnId']
                    colDT= qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['dataType']
                    dGC_dict={}
                    coldtdict={}
                    
                    if colDT == 'plainText':
                        try:
                            minans= qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['plainTextPropertie']['minNoOfLetter']
                            # print("min chars:",minans)
                            minans = 1 if minans <=1 else minans
                            maxans= qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['plainTextPropertie']['maxNoOfLetter']
                            # print("max chars:",maxans)
                            mytext= faker.text(max_nb_chars=maxans)
                            # print("text is:",mytext)
                            # print("length of text:",len(mytext))
                            if len(mytext) <= minans:
                                mytext= faker.text(max_nb_chars=maxans)
                                # print("length of text in if:",len(mytext))
                                # print("text in if:",mytext)
                        except Exception as e:
                            # coldtdict['plainText']= faker.text()
                            mytext= faker.text()
                        mytext = mytext.replace('\n', '').replace('\r', '')
                        coldtdict['plainText']= mytext
                        dGC_dict['column']= coldtdict
                        dGC_dict['columnId']= colID
                        # print("Data Grid Dictionary for plainText:",dGC_dict)
                        dGC_list.append(dGC_dict)

                    elif colDT == 'list':
                        print("DataGrid - list:")
                        try:
                            labelvals= qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['listPropertie']['values']
                        except KeyError:
                            labelvals= None
                        print("list values:",labelvals)
                        try:
                            minans= qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['listPropertie']['minAnswers']
                            minans = 1 if minans <=1 else minans
                            print("min answers:",minans)
                            maxans= qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['listPropertie']['maxAnswers']
                            rand_maxans = 1 if maxans == 1 else random.randrange(minans, maxans)
                            print("max answers:",rand_maxans)
                            coldtdict['list']= faker.words(nb=rand_maxans, ext_word_list=labelvals)
                        except KeyError:
                            coldtdict['list']= faker.words(ext_word_list=labelvals)
                        dGC_dict['column']=coldtdict
                        dGC_dict['columnId']= colID
                        print("Data Grid Dictionary for list:",dGC_dict)
                        dGC_list.append(dGC_dict)

                    elif colDT == 'number':
                        start=qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['numberPropertie']['start']
                        # print("Data Grid number start:",start)
                        end=qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['numberPropertie']['end']
                        # print("Data Grid Dictionary number end:",end)
                        ran_num= random.randrange(int(start), int(end))
                        # print("Data Grid random number :",ran_num)
                        coldtdict['number']= str(ran_num)
                        dGC_dict['column']= coldtdict
                        # print("Data Grid Dictionary for number:",dGC_dict)
                        dGC_dict['columnId']= colID
                        dGC_list.append(dGC_dict)

                    elif colDT == 'date':
                        start_str=qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['dateProperties']['start']
                        # print("Data Grid date string start:",start_str)
                        start = parser.parse(start_str)
                        # print("Data Grid date start:",start)
                        end_str=qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['dateProperties']['end']
                        # print("Data Grid date string end:",end_str)
                        end = parser.parse(end_str)
                        # print("Data Grid date end:",end)
                        # dGC_dict['date']= faker.date_between_dates(date_start=start, date_end=end).strftime('%Y-%m-%d')
                        coldtdict['date']= faker.date_between_dates(date_start=start, date_end=end).strftime('%Y-%m-%d')
                        dGC_dict['column']= coldtdict
                        # print("Data Grid Dictionary for date:",dGC_dict)
                        dGC_dict['columnId']= colID
                        dGC_list.append(dGC_dict)

                    elif colDT == 'bool':
                        qnsid= qnrdata['questionAnswers'][i]['question']['id']
                        # dGC_dict['bool']= faker.pybool()
                        coldtdict['bool']= faker.pybool()
                        dGC_dict['column']= coldtdict
                        # print("Data Grid Dictionary for bool:",dGC_dict)
                        dGC_dict['columnId']= colID
                        dGC_list.append(dGC_dict)

                    elif colDT == 'fileUpload':
                        filetypes= qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['filePropertie']['fileTypes']
                        fu_len= len(kwargs['dGridfileupload'])
                        allowed_docs= qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['filePropertie']['allowedDocuments']
                        for j in range(fu_len):
                            if any(c in filetypes for c in ('pdf', 'jpeg', 'png', 'jpg', 'docx', 'txt')) and any(c in filetypes for c in ('mp4', 'mov', 'avi', 'flv')) and any(c in filetypes for c in ('mp3', 'wav', 'wma', 'audio')) and "files" in kwargs['dGridfileupload'][j].keys(): 
                                # print ('Data Grid files if condition cleared.')
                                dGC_dict={}
                                coldtlist=[]
                                for k in range(len(kwargs['dGridfileupload'][j]['files'])):
                                    if kwargs['dGridfileupload'][j]['files'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridfileupload'][j]['files'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue
                
                                # dGC_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGC_dict['column']= coldtdict
                                # print("fileupload file answer:",dGC_dict)
                                dGC_dict['columnId']= colID
                                dGC_list.append(dGC_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)  
                                break
                            elif any(c in filetypes for c in ('pdf', 'jpeg', 'png', 'jpg', 'docx', 'txt')) and "files" in kwargs['dGridfileupload'][j].keys(): 
                                # print ('Data Grid files if condition cleared.')
                                dGC_dict={}
                                coldtlist=[]
                                for k in range(len(kwargs['dGridfileupload'][j]['files'])):
                                    if kwargs['dGridfileupload'][j]['files'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridfileupload'][j]['files'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue
                
                                # dGC_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGC_dict['column']= coldtdict
                                # print("fileupload file answer:",dGC_dict)
                                dGC_dict['columnId']= colID
                                dGC_list.append(dGC_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)  
                                break

                            elif any(c in filetypes for c in ('mp4', 'mov', 'avi', 'flv')) and "Videos" in kwargs['dGridfileupload'][j].keys():
                                # print ('Data Grid Videos if condition cleared.')
                                dGC_dict={}
                                coldtlist=[]
                                for k in range(len(kwargs['dGridfileupload'][j]['Videos'])):
                                    if kwargs['dGridfileupload'][j]['Videos'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridfileupload'][j]['Videos'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue
                
                                # dGC_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGC_dict['column']= coldtdict
                                # print("fileupload video answer:",dGC_dict)
                                dGC_dict['columnId']= colID
                                dGC_list.append(dGC_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)  
                                break

                            elif any(c in filetypes for c in ('mp3', 'wav', 'wma', 'audio')) and "Audio" in kwargs['dGridfileupload'][j].keys():
                                # print ('Data Grid Audio if condition cleared.')
                                # colfudict={}
                                coldtlist=[]

                                for k in range(len(kwargs['dGridfileupload'][j]['Audio'])):
                                    if kwargs['dGridfileupload'][j]['Audio'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridfileupload'][j]['Audio'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue
                                    
                                # dGC_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGC_dict['column']= coldtdict
                                # print("fileupload audio answer:",dGC_dict)
                                dGC_dict['columnId']= colID
                                dGC_list.append(dGC_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)
                                break
                        else: 
                            print ('for labelname:', qnrdata['questionAnswers'][i]['question']['labelName'])
                            print ('data grid column labelname:', qnrdata['questionAnswers'][i]['question']['dataGridProperties']['dataGridColumns'][j]['label'])
                            print ("In data grid column, file upload datatype; index, caption and action are required.")

                # dtdict['dataGrid']= dGC_list
                dtdict['dataGrid']= [dict({'dataGridColumn': dGC_list})]
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)
                # print("answerline in datagrid:",answerline)
            
            elif fieldDT == 'dataGridList':
                print("Entered dataGridList")
                qnsid= qnrdata['questionAnswers'][i]['question']['id']
                datagridlist_len= qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns']
                dGL_list=[]
                # dGL_dict={}
                
                for j in range(len(datagridlist_len)):
                    colID= qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['columnId']
                    colDT= qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['dataType']
                    dGL_dict={}
                    coldtdict={}
                    
                    if colDT == 'plainText':
                        try:
                            minans= qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['plainTextPropertie']['minNoOfLetter']
                            # print("min chars:",minans)
                            minans = 1 if minans <=1 else minans
                            maxans= qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['plainTextPropertie']['maxNoOfLetter']
                            # print("max chars:",maxans)
                            mytext= faker.text(max_nb_chars=maxans)
                            # print("text is:",mytext)
                            # print("length of text:",len(mytext))
                            if len(mytext) <= minans:
                                mytext= faker.text(max_nb_chars=maxans)
                                # print("length of text in if:",len(mytext))
                                # print("text in if:",mytext)
                        except Exception as e:
                            # coldtdict['plainText']= faker.text()
                            mytext= faker.text()
                        mytext = mytext.replace('\n', '').replace('\r', '')
                        coldtdict['plainText']= mytext
                        dGL_dict['column']= coldtdict
                        dGL_dict['columnId']= colID
                        # print("Data Grid Dictionary for plainText:",dGL_dict)
                        dGL_list.append(dGL_dict)

                    elif colDT == 'list':
                        print("DataGrid List - list:")
                        try:
                            labelvals= qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['listPropertie']['values']
                        except KeyError:
                            labelvals= None
                        # print("list values:",labelvals)

                        try:
                            baseprice= qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['listPropertie']['basePrice']
                        except KeyError:
                            baseprice=None
                        # print("baseprice:",baseprice)
                        try:
                            minans= qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['listPropertie']['minAnswerable']
                            # minans = 1 if minans <=1 else minans
                            # print("min answers:",minans)
                        except KeyError:
                            minans=None
                        minans = 1 if not minans or minans <=1 else minans
                        # print("min answers:",minans)
                        try:
                            maxans= qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['listPropertie']['maxAnswerable']
                        except KeyError:
                            maxans=None
                        print("max answers:",maxans)
                        if not maxans:
                            rand_maxans = random.randrange(minans, len(labelvals))
                        elif maxans == 1:
                            rand_maxans= maxans
                        else:
                            rand_maxans = random.randrange(minans, maxans)
                        # rand_maxans = random.randrange(minans, len(labelvals)) if not maxans else 1 if maxans == 1 else random.randrange(minans, maxans)
                        print("rand max answers:",rand_maxans)
                        list_value= faker.words(nb=rand_maxans, ext_word_list=labelvals)
                        # print("list value:",list_value)
                        coldtdict['list']= list_value
                        # except KeyError:
                            # coldtdict['list']= faker.words(nb=1, ext_word_list=labelvals)
                        dGL_dict['column']=coldtdict
                        dGL_dict['columnId']= colID
                        dGL_dict['quantity']= 1
                        if baseprice:
                            # print('list_value[0]: ', list_value[0])
                            item= list_value[0]
                            # print('item: ', item)
                            # bprice = json.loads(json.dumps(baseprice))
                            y = baseprice.replace("{",'{"').replace(":",'":"').replace(", ",'", "').replace("}",'"}')
                            bprice = json.loads(y)
                            # print("bprice:",bprice)
                            # print("baseprice type: ", type(bprice))
                            price= bprice[item]
                            # print('price: ', price)
                            dGL_dict['price']= price
                        print("Data Grid Dictionary for list:",dGL_dict)
                        dGL_list.append(dGL_dict)

                    elif colDT == 'number':
                        start=qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['numberPropertie']['start']
                        # print("Data Grid number start:",start)
                        end=qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['numberPropertie']['end']
                        # print("Data Grid Dictionary number end:",end)
                        ran_num= random.randrange(int(start), int(end))
                        # print("Data Grid random number :",ran_num)
                        coldtdict['number']= str(ran_num)
                        dGL_dict['column']= coldtdict
                        # print("Data Grid Dictionary for number:",dGC_dict)
                        dGL_dict['columnId']= colID
                        dGL_list.append(dGL_dict)

                    elif colDT == 'date':
                        start_str=qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['dateProperties']['start']
                        # print("Data Grid date string start:",start_str)
                        start = parser.parse(start_str)
                        # print("Data Grid date start:",start)
                        end_str=qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['dateProperties']['end']
                        # print("Data Grid date string end:",end_str)
                        end = parser.parse(end_str)
                        # print("Data Grid date end:",end)
                        # dGL_dict['date']= faker.date_between_dates(date_start=start, date_end=end).strftime('%Y-%m-%d')
                        coldtdict['date']= faker.date_between_dates(date_start=start, date_end=end).strftime('%Y-%m-%d')
                        dGL_dict['column']= coldtdict
                        # print("Data Grid Dictionary for date:",dGL_dict)
                        dGL_dict['columnId']= colID
                        dGL_list.append(dGL_dict)

                    elif colDT == 'bool':
                        qnsid= qnrdata['questionAnswers'][i]['question']['id']
                        # dGC_dict['bool']= faker.pybool()
                        coldtdict['bool']= faker.pybool()
                        dGL_dict['column']= coldtdict
                        # print("Data Grid Dictionary for bool:",dGC_dict)
                        dGL_dict['columnId']= colID
                        dGL_list.append(dGL_dict)

                    elif colDT == 'fileUpload':
                        print("Entered dataGridList fileUpload")
                        filetypes= qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['filePropertie']['fileTypes']
                        # print("filetypes: ",filetypes )
                        # print("dGridlistfileupload: ",kwargs['dGridlistfileupload'])
                        fu_len= len(kwargs['dGridlistfileupload'])
                        # print("dGridlistfileupload length: ",fu_len)
                        allowed_docs= qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['filePropertie']['allowedDocuments']
                        # print("dGridlistfileupload allowed docs: ",allowed_docs)
                        for j in range(fu_len):
                            if any(c in filetypes for c in ('pdf', 'jpeg', 'png', 'jpg', 'docx', 'txt')) and any(c in filetypes for c in ('mp4', 'mov', 'avi', 'flv')) and any(c in filetypes for c in ('mp3', 'wav', 'wma', 'audio')) and "files" in kwargs['dGridlistfileupload'][j].keys():
                                # print ('dataGridList files if condition cleared.')
                                dGL_dict={}
                                coldtlist=[]
                                for k in range(len(kwargs['dGridlistfileupload'][j]['files'])):
                                    if kwargs['dGridlistfileupload'][j]['files'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridlistfileupload'][j]['files'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue

                
                                # dGL_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGL_dict['column']= coldtdict
                                # print("fileupload file answer:",dGL_dict)
                                dGL_dict['columnId']= colID
                                dGL_list.append(dGL_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)  
                                break

                            elif any(c in filetypes for c in ('pdf', 'jpeg', 'png', 'jpg', 'docx', 'txt')) and "files" in kwargs['dGridlistfileupload'][j].keys(): 
                                # print ('dataGridList files if condition cleared.')
                                dGL_dict={}
                                coldtlist=[]
                                for k in range(len(kwargs['dGridlistfileupload'][j]['files'])):
                                    if kwargs['dGridlistfileupload'][j]['files'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridlistfileupload'][j]['files'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue

                
                                # dGL_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGL_dict['column']= coldtdict
                                # print("fileupload file answer:",dGL_dict)
                                dGL_dict['columnId']= colID
                                dGL_list.append(dGL_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)  
                                break

                            elif any(c in filetypes for c in ('mp4', 'mov', 'avi', 'flv')) and "Videos" in kwargs['dGridlistfileupload'][j].keys():
                                # print ('dataGridList Videos if condition cleared.')
                                dGL_dict={}
                                coldtlist=[]
                                for k in range(len(kwargs['dGridlistfileupload'][j]['Videos'])):
                                    if kwargs['dGridlistfileupload'][j]['Videos'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridlistfileupload'][j]['Videos'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue
                
                                # dGC_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGL_dict['column']= coldtdict
                                # print("fileupload video answer:",dGC_dict)
                                dGL_dict['columnId']= colID
                                dGL_list.append(dGL_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)  
                                break

                            elif any(c in filetypes for c in ('mp3', 'wav', 'wma', 'audio')) and "Audio" in kwargs['dGridlistfileupload'][j].keys():
                                # print ('dataGridList Audio if condition cleared.')
                                # colfudict={}
                                coldtlist=[]

                                for k in range(len(kwargs['dGridlistfileupload'][j]['Audio'])):
                                    if kwargs['dGridlistfileupload'][j]['Audio'][k]['caption'] in allowed_docs:
                                        coldtlist.append(kwargs['dGridlistfileupload'][j]['Audio'][k])
                                        # print ('dtlist:', coldtlist)
                                        break
                                    else:
                                        continue
                                    
                                # dGC_dict['fileUpload']= coldtlist
                                coldtdict['fileUpload']= coldtlist
                                dGL_dict['column']= coldtdict
                                # print("fileupload audio answer:",dGL_dict)
                                dGL_dict['columnId']= colID
                                dGL_list.append(dGL_dict) 
                                # print("answer for fileupload in datagrid:",dGC_list)
                                break
                        else: 
                            print ('Entered Else.')
                            print ('for labelname:', qnrdata['questionAnswers'][i]['question']['labelName'])
                            print ('data grid column labelname:', qnrdata['questionAnswers'][i]['question']['dataGridListProperties']['dataGridListColumns'][j]['label'])
                            print ("In data grid column, file upload datatype; index, caption and action are required.")

                # dtdict['dataGrid']= dGC_list
                dtdict['dataGridList']= [dict({'dataGridListColumn': dGL_list})]
                ansdict['labelName']= lblname
                ansdict['id']= qnsid
                ansdict['answer']= dtdict
                answerline.append(ansdict)
                

        final_data={'questionnaireId': id, 'proConId': proConId, 'answerLine': answerline}
        final_data=json.dumps(final_data)
        # print (final_data)
        return  final_data
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)


def enquiryStatus(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            # date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_status_tbl(account,is_blocked,is_canceled,is_closed,is_default,is_editable,is_verified,is_done,is_rejected,is_pending,name,alias_name,status,type_enum,created_by,created_date,modified_by,updated_date,sort_order)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [
                                 (account, 0, 0, 0, 1, 1, 0, 0, 0, 0, 'Follow Up 1', 'Follow Up 1', 0, 3, '1', datetime.datetime.now(), '0', None,1),
                                 (account, 0, 0, 0, 0, 1, 0, 0, 0, 0, 'Follow Up 2', 'Follow Up 2', 0, 3, '1', datetime.datetime.now(), '0', None,2),
                                 (account, 0, 0, 0, 0, 1, 0, 1, 0, 0, 'KYC', 'KYC', 0, 3, '1', datetime.datetime.now(), '0', None,3),
                                 (account, 0, 0, 1, 0, 0, 0, 0, 0, 0, 'Completed', 'Completed', 0, 3, '1', datetime.datetime.now(), '0', None,4)]
                                 
            cur.executemany(mySql_insert_query, records_to_insert)    

            # cur.execute("update ynw.crm_status_tbl statustbl1, ynw.crm_status_tbl statustbl2 set statustbl1.on_proceed = statustbl2.id where statustbl1.alias_name = 'Follow Up 1' and statustbl2.alias_name = 'Follow Up 2' and statustbl1.type_enum = 3 and statustbl2.type_enum = 3 and statustbl1.account = %s and statustbl2.account = %s;" % (account,account))
            # cur.execute("update ynw.crm_status_tbl statustbl1, ynw.crm_status_tbl statustbl2 set statustbl1.on_proceed = statustbl2.id where statustbl1.alias_name = 'Follow Up 2' and statustbl2.alias_name = 'Completed' and statustbl1.type_enum = 3 and statustbl2.type_enum = 3 and statustbl1.account = %s and statustbl2.account = %s;" % (account,account))        
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def updateEnquiryStatus(account):
    print("In function: ", inspect.stack()[0].function)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            # date= get_date()   

            cur.execute("update ynw.crm_status_tbl statustbl1, ynw.crm_status_tbl statustbl2 set statustbl1.on_proceed = statustbl2.id where statustbl1.alias_name = 'Follow Up 1' and statustbl2.alias_name = 'Follow Up 2' and statustbl1.type_enum = 3 and statustbl2.type_enum = 3 and statustbl1.account = %s and statustbl2.account = %s;" % (account,account))
            cur.execute("update ynw.crm_status_tbl statustbl1, ynw.crm_status_tbl statustbl2 set statustbl1.on_proceed = statustbl2.id where statustbl1.alias_name = 'Follow Up 2' and statustbl2.alias_name = 'KYC' and statustbl1.type_enum = 3 and statustbl2.type_enum = 3 and statustbl1.account = %s and statustbl2.account = %s;" % (account,account)) 
            cur.execute("update ynw.crm_status_tbl statustbl1, ynw.crm_status_tbl statustbl2 set statustbl1.on_proceed = statustbl2.id where statustbl1.alias_name = 'KYC' and statustbl2.alias_name = 'Completed' and statustbl1.type_enum = 3 and statustbl2.type_enum = 3 and statustbl1.account = %s and statustbl2.account = %s;" % (account,account))        
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()


def fileUploadDTProcon(qnrdata, actionval, *files):     
    print("In function: ", inspect.stack()[0].function)
    fileUploadDT.fileslist= list(files)
    supported_filetypes= ['png', 'jpg', 'pdf', 'jpeg', 'bmp', 'flw', 'docx', 'txt']
    supported_videotypes= ['mp4', 'mov', 'flv', 'mkv', 'avi', 'webm']
    supported_audiotypes= ['mp3', 'wav', 'pcm']
    # fileUploadDT.fileindex=0
    # fileUploadDT.fileDGindex=0
    # fileUploadDT.fileDGLindex=0
    fileindex=0
    fileDGindex=0
    fileDGLindex=0
    final_data={}
    nongrid_data=[]
    grid_data=[]
    gridlist_data=[]
    try:
        for i in range(len(qnrdata['labels'])):
            lblname= qnrdata['labels'][i]['questions']['labelName']
            fieldDT= qnrdata['labels'][i]['questions']['fieldDataType']
            if fieldDT == 'fileUpload':
                print(lblname)
                nongrid_data.append(createFUDict(qnrdata['labels'][i]['questions'], fileindex ,actionval))
                fileindex= fileindex + 1
            
            elif fieldDT == 'dataGrid':
                datagrid_len= len(qnrdata['labels'][i]['questions']['dataGridProperties']['dataGridColumns'])
                print(lblname)
                for j in range(datagrid_len):
                    colDT= qnrdata['labels'][i]['questions']['dataGridProperties']['dataGridColumns'][j]['dataType']
                    if colDT == 'fileUpload':
                        grid_data.append(createFUDict(qnrdata['labels'][i]['questions']['dataGridProperties']['dataGridColumns'][j], fileDGindex, actionval))
                        fileDGindex= fileindex + 1
            
            elif fieldDT == 'dataGridList':
                datagrid_len= len(qnrdata['labels'][i]['questions']['dataGridListProperties']['dataGridListColumns'])
                print(lblname)
                for j in range(datagrid_len):
                    colDT= qnrdata['labels'][i]['questions']['dataGridListProperties']['dataGridListColumns'][j]['dataType']
                    if colDT == 'fileUpload':
                        gridlist_data.append(createFUDict(qnrdata['labels'][i]['questions']['dataGridListProperties']['dataGridListColumns'][j], fileDGLindex, actionval))
                        fileDGLindex= fileindex + 1

        final_data['fileupload']= nongrid_data
        final_data['dGridfileupload']= grid_data
        final_data['dGridlistfileupload']= gridlist_data
        return  final_data
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno) 


def leadStatus(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            # date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_status_tbl(account,is_default,is_editable,is_kycupdated,is_creditscoregenerated,is_salesfieldverified,is_documentuploaded,is_documentverified,is_creditrecommended,is_loansaction,is_loandisbursement,is_done,type_enum,is_dashboard_status,sort_order,name,alias_name,status,created_by,created_date,modified_by,updated_date)
                                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [(account, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 1, 'New', 'Leads', 0, '1', datetime.datetime.now(), '0', None),
                                (account, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 2, 'KYC Updated', 'CRIF', 0, '1', datetime.datetime.now(), '0', None),
                                (account, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 2, 1, 3, 'Credit Score Generated', 'Sales Field Verification', 0, '1', datetime.datetime.now(), '0', None),
                                (account, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 2, 1, 4, 'Sales Verified', 'Login', 0, '1', datetime.datetime.now(), '0', None),
                                (account, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 1, 5, 'Login', 'Login Verification', 0, '1', datetime.datetime.now(), '0', None),
                                (account, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2, 1, 6, 'Login Verified', 'Credit Recommendation', 0, '1', datetime.datetime.now(), '0', None),
                                (account, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 2, 1, 7, 'Credit Recommendation', 'Loan Sanction', 0, '1', datetime.datetime.now(), '0', None),
                                (account, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 2, 1, 8, 'Loan Sanction', 'Loan Disbursement', 0, '1', datetime.datetime.now(), '0', None),
                                (account, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 1, 9, 'Loan Disbursement', 'Loan Created', 0, '1', datetime.datetime.now(), '0', None)]
                                 
            cur.executemany(mySql_insert_query, records_to_insert)    

            # cur.execute("update ynw.crm_status_tbl statustbl1, ynw.crm_status_tbl statustbl2 set statustbl1.on_proceed = statustbl2.id where statustbl1.alias_name = 'Follow Up 1' and statustbl2.alias_name = 'Follow Up 2' and statustbl1.type_enum = 3 and statustbl2.type_enum = 3 and statustbl1.account = %s and statustbl2.account = %s;" % (account,account))
            # cur.execute("update ynw.crm_status_tbl statustbl1, ynw.crm_status_tbl statustbl2 set statustbl1.on_proceed = statustbl2.id where statustbl1.alias_name = 'Follow Up 2' and statustbl2.alias_name = 'Completed' and statustbl1.type_enum = 3 and statustbl2.type_enum = 3 and statustbl1.account = %s and statustbl2.account = %s;" % (account,account))        
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def updateLeadStatus(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            # date= get_date()   

            cur.execute("update ynw.crm_status_tbl statustbl1, ynw.crm_status_tbl statustbl2 set statustbl1.on_proceed = statustbl2.id where statustbl1.alias_name = 'CRIF' and statustbl2.alias_name = 'Leads' and statustbl1.type_enum = 2 and statustbl2.type_enum = 2 and statustbl1.account = %s and statustbl2.account = %s;" % (account,account))
            cur.execute("update ynw.crm_status_tbl statustbl1, ynw.crm_status_tbl statustbl2 set statustbl1.on_proceed = statustbl2.id where statustbl1.alias_name = 'Login Verification' and statustbl2.alias_name = 'Login' and statustbl1.type_enum = 2 and statustbl2.type_enum = 2 and statustbl1.account = %s and statustbl2.account = %s;" % (account,account)) 
            cur.execute("update ynw.crm_status_tbl statustbl1, ynw.crm_status_tbl statustbl2 set statustbl1.on_proceed = statustbl2.id where statustbl1.alias_name = 'Loan Sanction' and statustbl2.alias_name = 'Credit Recommendation' and statustbl1.type_enum = 2 and statustbl2.type_enum = 2 and statustbl1.account = %s and statustbl2.account = %s;" % (account,account))        
            dbconn.commit()
                    
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def loanStatus(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            # date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_status_tbl(account,is_blocked,is_canceled,is_closed,is_default,is_editable,is_verified,is_done,is_rejected,is_pending,name,alias_name,status,type_enum,created_by,created_date,modified_by,updated_date,sort_order)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [(account, 0, 0, 0, 1, 1, 0, 0, 0, 0, 'New', 'New', 0, 4, '1', datetime.datetime.now(), '0', None,1)]
                                 
            cur.executemany(mySql_insert_query, records_to_insert)    

            # cur.execute("update ynw.crm_status_tbl statustbl1, ynw.crm_status_tbl statustbl2 set statustbl1.on_proceed = statustbl2.id where statustbl1.alias_name = 'Follow Up 1' and statustbl2.alias_name = 'Follow Up 2' and statustbl1.type_enum = 3 and statustbl2.type_enum = 3 and statustbl1.account = %s and statustbl2.account = %s;" % (account,account))
            # cur.execute("update ynw.crm_status_tbl statustbl1, ynw.crm_status_tbl statustbl2 set statustbl1.on_proceed = statustbl2.id where statustbl1.alias_name = 'Follow Up 2' and statustbl2.alias_name = 'Completed' and statustbl1.type_enum = 3 and statustbl2.type_enum = 3 and statustbl1.account = %s and statustbl2.account = %s;" % (account,account))        
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def loanProduct(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_loanproduct_tbl(account_id,product_name,product_aliasname,status,created_by,created_date,modified_by,updated_date)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [(account,'Mobile', 'Mobile', 0, '1', date, '0', None),
                                 (account,'Laptop', 'Laptop', 0, '1', date, '0', None),
                                 (account,'Television', 'Television', 0, '1', date, '0', None)]
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def loanScheme(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_loanscheme_tbl(account_id,scheme_name,scheme_aliasname,no_of_co_applicat_required,min_amount,max_amount,is_employee_scheme,is_subvention_scheme,subvention_rate,scheme_type,scheme_rate,min_duration,max_duration,loan_to_value,is_multi_item,status,no_of_pdc_required,no_of_spdc_required,overdue_charge_rate,processing_fee_amount,processing_fee_rate,foir_on_assesed_income,foir_on_declared_income,fore_closure_charge,created_by,created_date,modified_by,updated_date)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [(account, 'SCHEME - A', 'SCHEME-A, 6-12 Months'   , '0', '10000.0', '50000.0' , 0, 0, '0', 1, '24.91', '6' ,'12' , '80', 1 , 0, '1', '1', '3.00', '10000.0', '3.0', '45.0', '55.0', '3.0', '1', date, '0', None),
                                 (account, 'SCHEME - B', 'SCHEME-B, 12-36 Months'  , '1', '50001.0', '300000.0', 0, 0, '0', 1, '24.0' , '12','36' , '80', 1 , 0, '1', '2', '3.00', '10000.0', '3.0', '45.0', '55.0', '3.0', '1', date, '0', None),
                                 (account, 'SCHEME - C', 'SCHEME-C, 6-24 Months'   , '1', '10000.0', '50000.0' , 1, 0, '0', 1, '17.50', '6' ,'24' , '80', 1 , 0, '1', '2', '3.00', '10000.0', '3.0', '55.0', '55.0', '3.0', '1', date, '0', None),
                                 (account, 'SUBVENTION', 'No Cost EMI, 6-24 Months', '1', '10000.0', '100000.0', 0, 1, '0', 1, '0'    , '6' ,'24' , '100',1 , 0, '1', '2', '3.00', '10000.0', '3.0', '45.0', '55.0', '3.0', '1', date, '0', None)]
            cur.executemany(mySql_insert_query, records_to_insert)
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def partnercategorytype(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.partner_category_tbl(account,name,alias_name,created_by,created_date,modified_by,updated_date)
            
                           VALUES (%s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [( account, 'Category 1', 'Category 1', '1', date, '0', None),
                                 ( account, 'Category 2', 'Category 2', '1', date, '0', None)]
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def partnertype(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.partner_type_tbl(account,name,alias_name,created_by,created_date,modified_by,updated_date)
                           VALUES (%s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [(account, 'Type 1', 'Type 1', '1', date, '0', None),
                                 (account, 'Type 2', 'Type 2', '1', date, '0', None)]
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def loanProducttype(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_loanproduct_type_tbl(created_by,created_date,modified_by,account,alias_name,name,status)
                                VALUES (%s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [( '1', date, '0', account, 'CDL', 'CDL', '0')]
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def loanProducts(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_loanproduct_tbl(created_by, created_date, modified_by, account_id,product_aliasname,product_name,status,category_name,type_name,category_id,type_id)
                                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [('1',date,'0',account,'Telivision','Telivision','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Washing Mechine','Washing Mechine','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Refrigerator','Refrigerator','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Generator','Generator','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Mobile Devices','Mobile Devices','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Laptop','Laptop','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Computer','Computer','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Tablets','Tablets','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Printer','Printer','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Scanner','Scanner','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Photocopier','Photocopier','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Amplifier set','Amplifier set','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Air Conditioner','Air Conditioner','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Home Appliance','Home Appliance','0','Electronics Goods','CDL','1','1'),
                                 ('1',date,'0',account,'Sofa','Sofa','0','Furniture Goods','CDL','2','1'),
                                 ('1',date,'0',account,'Table','Table','0','Furniture Goods','CDL','2','1'),
                                 ('1',date,'0',account,'Chair','Chair','0','Furniture Goods','CDL','2','1'),
                                 ('1',date,'0',account,'Mattress','Mattress','0','Furniture Goods','CDL','2','1'),
                                 ('1',date,'0',account,'TV Stand','TV Stand','0','Furniture Goods','CDL','2','1'),
                                 ('1',date,'0',account,'Book Case','Book Case','0','Furniture Goods','CDL','2','1'),
                                 ('1',date,'0',account,'Bed','Bed','0','Furniture Goods','CDL','2','1'),
                                 ('1',date,'0',account,'Stool','Stool','0','Furniture Goods','CDL','2','1'),
                                 ('1',date,'0',account,'Almirah - Wooden','Almirah - Wooden','0','Furniture Goods','CDL','2','1'),
                                 ('1',date,'0',account,'Almirah - Steel','Almirah - Steel','0','Furniture Goods','CDL','2','1'),
                                 ('1',date,'0',account,'Divan Coat','Divan Coat','0','Furniture Goods','CDL','2','1'),
                                 ('1',date,'0',account,'Home Appliance','Home Appliance','0','Furniture Goods','CDL','2','1'),
                                 ('1',date,'0',account,'MyG-Combo Pack','MyG-Combo Pack','0','Other Goods','CDL','3','1'),
                                 ('1',date,'0',account,'Solar Pannel','Solar Pannel','0','Other Goods','CDL','3','1'), 
                                 ('1',date,'0',account,'Water Pumpset','Water Pumpset','0','Other Goods','CDL','3','1'),
                                 ('1',date,'0',account,'Cooler Set','Cooler Set','0','Other Goods','CDL','3','1'),
                                 ('1',date,'0',account,'Modular Kitchen','Modular Kitchen','0','Other Goods','CDL','3','1'), 
                                 ('1',date,'0',account,'Gym Equipments','Gym Equipments','0','Other Goods','CDL','3','1')]
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()

def clear_enquiry(number):
    print("In function: ", inspect.stack()[0].function)
    aid=get_acc_id(number)    
   # uid = get_id(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        # cur = dbconn.cursor()
        with dbconn.cursor() as cur:
            delete_entry('crm_enquire_tbl','account_id',aid,cur)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)  
    finally:
        if dbconn is not None:
            dbconn.close()


def LoanProductCategory(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_loanproduct_category_tbl(created_by,created_date,modified_by,account,alias_name,name,status)
            
                           VALUES (%s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [( '1', date, '0', account, 'Electronics Goods', 'Electronics Goods','0' ),
                                 ( '1', date, '0', account, 'Furniture Goods', 'Furniture Goods','0' ),
                                 ( '1', date, '0', account, 'Other Goods', 'Other Goods','0' )]
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()


def LoanProductSubCategory(account, *category_id):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_loanproduct_subcategory_tbl(account,category_id,name,alias_name,created_by,created_date,modified_by,updated_date)
            
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [( account, category_id[0], 'White Goods', 'White Goods', '1', date, '0', None),
                                 ( account, category_id[0], 'Brown Goods', 'Brown Goods', '1', date, '0', None),
                                 ( account, category_id[1], 'Furniture Goods', 'Furniture Goods', '1', date, '0', None),
                                 ( account, category_id[2], 'Other Goods', 'Other Goods', '1', date, '0', None)]
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()



def create_ivr_children(id, name, language, nodevalue, inputvalue):
    ivr = {
        "id": id,
        "name": name,
        "language": language,
        "nodeValue": nodevalue,
        "inputValue": inputvalue
    }
    return ivr



def ivr_acion_dict(id, name, action, language, nodeValue, *chl):
    my_dict = {
        "id": id,
        "name": name,
        "action": action,
        "children": chl,
        "language": language,
        "nodeValue": nodeValue
    }
    return my_dict


def ivr_user_details(account, country_code, myoperator_id, phone, phone_with_countrycode, user_id, user_name):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ivr_user_tbl(account,created_by,created_date,modified_by,updated_date,availability,call_count,country_code,myoperator_id,phone,phone_with_countrycode,user_id,user_name,user_type)
            
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [( account, '1', date , '0' , date , 1 , 0 , country_code , myoperator_id , phone , phone_with_countrycode , user_id , user_name , 1 )]
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()


def after_call_primary_value(ui_vl, is_vl, vt_vl, ic_vl, ia_vl, ib_vl):
    _pm = [
        {"ky": "ui", "vl": ui_vl},
        {"ky": "is", "vl": is_vl},
        {"ky": "vt", "vl": vt_vl},
        {"ky": "ic", "vl": ic_vl},
        {"ky": "ia", "vl": ia_vl},
        {"ky": "ib", "vl": ib_vl}
    ]
    return _pm


def after_call_log_details(ring_start_time, dial_string, last_caller, agent_id, agent_name, agent_email, agent_ex, agent_contact, agent_contact_with_cc, status_call, start_time, end_time, duration, call_status):

    _ld = [
        {
            "_an": False,
            "_rst": ring_start_time,
            "_ds": dial_string,
            "_did": last_caller,
            "_rr": [
                {
                    "_id": agent_id,
                    "_na": agent_name,
                    "_em": agent_email,
                    "_ex": agent_ex,
                    "_ct": agent_contact,
                    "_nr": agent_contact_with_cc
                }
            ],
            "_tt": [],
            "_su": status_call,
            "_st": start_time,
            "_et": end_time,
            "_dr": duration,
            "_ac": call_status
        }
    ]
    return _ld



def time_difference(start_time, end_time):

    """Calculates the difference between two times in the hh:mm:ss format"""

    time_format = "%H:%M:%S"
    start_datetime = datetime.datetime.strptime(start_time, time_format)
    end_datetime = datetime.datetime.strptime(end_time, time_format)
    delta = end_datetime - start_datetime
    hours, remainder = divmod(delta.seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    return f"{hours:02}:{minutes:02}:{seconds:02}"


def get_Timezone_by_lat_long(latitude, longitude):
    # tf = TimezoneFinder()
    # print (type(latitude), float(latitude))
    # print (type(longitude), float(longitude))
    # tz = tf.timezone_at(lng=float(longitude), lat=float(latitude))
    BASE_URL = __import__(os.environ['VARFILE']).BASE_URL
    URL = BASE_URL + '/provider/location/timezone/'+ str(latitude) +'/'+ str(longitude)
    # URL = BASE_URL + '/provider/location/timezone/'+ latitude +'/'+ longitude
    print (URL)
    r = requests.get(url = URL)
    print (r)
    log_request(r)
    log_response(r)
    data = r.json()
    print (data)
    data =  create_tz(data)
    return  data

def get_time_by_timezone(tz):
    BASE_URL = __import__(os.environ['VARFILE']).BASE_URL
    zone, *loc = tz.split('/')
    print("zone: ", zone)
    print("loc: ", loc)
    loc = random.choice(loc)
    print("loc after random choice: ", loc)
    URL = BASE_URL + '/provider/location/date/'+ zone +'/'+ loc
    # URL = BASE_URL + '/provider/location/date/'+ tz
    try:
        r = requests.get(url = URL)
        log_request(r)
        log_response(r)
        print(r.status_code)
        # r.raise_for_status()
        data = r.json()
        date,time= data.split()
        time1= datetime.datetime.strptime(time, '%H:%M:%S').time()
        t= time1.strftime("%I:%M %p")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    

def get_date_by_timezone(tz):
    BASE_URL = __import__(os.environ['VARFILE']).BASE_URL
    zone, *loc = tz.split('/')
    loc = random.choice(loc)
    URL = BASE_URL + '/provider/location/date/'+ zone +'/'+ loc
    # URL = BASE_URL + '/provider/location/date/'+ tz
    r = requests.get(url = URL)
    log_request(r)
    log_response(r)
    data = r.json()
    date,time= data.split()
    try:
        b= datetime.datetime.strptime(date, '%Y-%m-%d').date()
        date = b.strftime("%Y-%m-%d")
        return date
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def get_date_time_by_timezone(tz):
    BASE_URL = __import__(os.environ['VARFILE']).BASE_URL
    zone, *loc = tz.split('/')
    loc = random.choice(loc)
    URL = BASE_URL + '/provider/location/date/'+ zone +'/'+ loc
    # URL = BASE_URL + '/provider/location/date/'+ tz
    r = requests.get(url = URL)
    log_request(r)
    log_response(r)
    data = r.json()
    return data
    # date,time= data.split()
    # try:
    #     b= datetime.datetime.strptime(data, '%Y-%m-%d %H:%M:%S')
    #     date = b.strftime("%Y-%m-%d %I:%M %p")
    #     return date
    # except Exception as e:
    #     print ("Exception:", e)
    #     print ("Exception at line no:", e.__traceback__.tb_lineno)
    #     return 0

def add_timezone_time(tz,h,m):
    try:
        current_dt= get_date_time_by_timezone(tz)
        date_time1= datetime.datetime.strptime(current_dt, '%Y-%m-%d %H:%M:%S')
        b= date_time1 + datetime.timedelta(hours=int(h),minutes=int(m))
        newtime = b.strftime("%I:%M %p")
        return newtime
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def subtract_timezone_time(tz,h,m):
    try:
        current_dt= get_date_time_by_timezone(tz)
        date_time2= datetime.datetime.strptime(current_dt, '%Y-%m-%d %H:%M:%S')
        b= date_time2- datetime.timedelta(hours=int(h),minutes=int(m))
        newtime = b.strftime("%I:%M %p")
        return newtime
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
       
def add_timezone_date(tz, days):
    try:
        current_dt= get_date_time_by_timezone(tz)
        date_time2= datetime.datetime.strptime(current_dt, '%Y-%m-%d %H:%M:%S')
        b= date_time2 + datetime.timedelta(days=int(days))
        newdate = b.strftime("%Y-%m-%d")
        return newdate
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def subtract_timezone_date(tz,days):
    try:
        current_dt= get_date_time_by_timezone(tz)
        date_time2= datetime.datetime.strptime(current_dt, '%Y-%m-%d %H:%M:%S')
        b= date_time2 - datetime.timedelta(days=int(days))
        newdate = b.strftime("%Y-%m-%d")
        return newdate
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0


def get_timezone_weekday(tz):   
    try:
        current_dt= get_date_time_by_timezone(tz)
        d1= datetime.datetime.strptime(current_dt, '%Y-%m-%d %H:%M:%S').isoweekday()
        day=int(d1)
        if day==7:
            return 1
        else:
            return day+1
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

# def get_weekday_by_date(date):
#     try:
#         d= datetime.datetime.strptime(date, '%Y-%m-%d').isoweekday()
#         day=int(d)
#         if day==7:
#             return 1
#         else:
#             return day+1
#     except Exception as e:
#         print ("Exception:", e)
#         print ("Exception at line no:", e.__traceback__.tb_lineno)
#         return 0


def timezone_bill_cycle(tz):
    # date = datetime.date.today()
    current_date= get_date_by_timezone(tz)
    date= datetime.datetime.strptime(current_date, '%Y-%m-%d').date()
    mo= date.month
    ye= date.year
    try:
        if (mo==12):
            d= date.replace(year=ye+1,month=1)
        else :
            d= date.replace(month=mo+1)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        a= calendar.monthrange(ye,mo+1)
        d= date.replace(month=mo+1,day=a[1])
    return str(d)

def timezone_bill_cycle_annual(tz):
    current_date= get_date_by_timezone(tz)
    # date = datetime.date.today()
    date= datetime.datetime.strptime(current_date, '%Y-%m-%d').date()
    mo= date.month
    ye= date.year
    try:
        d= date.replace(year=ye+1)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        a= calendar.monthrange(ye+1,mo)
        d=date.replace(year=ye+1,day=a[1])
    return str(d)


def add_tz_time24(tz,h,m):
    current_dt= get_date_time_by_timezone(tz)
    # print data
    try:
        a= datetime.datetime.strptime(current_dt, '%Y-%m-%d %H:%M:%S')        
        b= a + datetime.timedelta(hours=int(h),minutes=int(m))
        t = b.strftime("%Y-%m-%d %H:%M:%S")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0  
    

def get_tz_time_secs(tz):
    current_dt= get_date_time_by_timezone(tz)
    date,time= current_dt.split()
    try:
        time1= datetime.datetime.strptime(time, '%H:%M:%S').time()
        t= time1.strftime("%I:%M:%S %p")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0


def add_tz_time_sec(tz,h,m,s):
    try:
        current_dt= get_date_time_by_timezone(tz)
        date_time2= datetime.datetime.strptime(current_dt, '%Y-%m-%d %H:%M:%S')
        b= date_time2 + datetime.timedelta(hours=int(h),minutes=int(m),seconds=int(s))
        t = b.strftime("%I:%M:%S %p")
        return t
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def change_date_with_tz(tz,date):
    # date= datetime.datetime.strptime(date, '%Y-%m-%d').date()
    y,m,d=date.split("-")
    # t = datetime.datetime.now()
    current_time= get_time_by_timezone(tz)
    t= datetime.datetime.strptime(current_time, '%I:%M %p').time()
    t = datetime.datetime(year=int(y),month=int(m),day=int(d),hour=t.hour,minute=t.minute)
    str=t.strftime("%m%d%H%M%y.%S")
    user=os.environ['USERNAME']
    hostip=os.environ['IP_ADDRESS']
    userpass=os.environ['SSHPASS']
    # os.system("sudo date '%s'" %str)
    command2="echo "+userpass+" |sshpass  -p "+userpass+" ssh -tt "+user+"@"+hostip+" sudo -S timedatectl set-ntp 0"
    subprocess.call(command2, shell=True)
    command="echo "+userpass+" |sshpass  -p "+userpass+" ssh -tt "+user+"@"+hostip+" sudo -S date "+str
    subprocess.call(command, shell=True)
def getMimetype(*files):
    filetype={}
    for file in files:
        mimetype, encoding = mimetypes.guess_type(file)
        filetype[file]= mimetype
    return  filetype


def load_property(property_key, sep='=', comment_char='#'):
    try:
        with open('/ebs/ynwconf/ynw.properties', 'r') as f:
            for line in f.readlines():
                if property_key in line and not line.startswith(comment_char) and line.strip():
                    print(line)
                    # a = line.replace('\n', '').strip().split("=",1)
                    # print (a)
                    key, value = line.replace('\n', '').strip().split(sep,1)
                    print(key,value)
                    value= value.replace('"', '').strip()
                    print(key,value)
            return value
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

# cbc_key= load_property('aes.cbc.secret')
# iv_key= load_property('aes.cbc.iv')
# ​aes.cbc.secret= "amFsZGVlRW5jcnlwdGlvbkRlY3J5cHRpb24xNDA2MjM="
# aes.cbc.iv= "RW5jRGVjSmFsZGVlMDYyMw=="
cbc_secret_key="amFsZGVlRW5jcnlwdGlvbkRlY3J5cHRpb24xNDA2MjM="
cbc_iv_key="RW5jRGVjSmFsZGVlMDYyMw=="
def ecrypt_data(data):

    try:
        # cbc_key= load_property('aes.cbc.secret')
        # iv_key= load_property('aes.cbc.iv')
        dec_secret = b64decode(cbc_secret_key)
        dec_iv = b64decode(cbc_iv_key)
        data = bytes(data, 'utf-8')
        padder = padding.PKCS7(128).padder()
        padded_data = padder.update(data)
        padded_data += padder.finalize()
        # print("padded data: ",padded_data)
        cipher = Cipher(algorithms.AES(dec_secret), modes.CBC(dec_iv))
        encryptor = cipher.encryptor()
        ciphertext = encryptor.update(padded_data) + encryptor.finalize()
        # print("ciphertext: ",ciphertext)
        b64_encoded_data= b64encode(ciphertext)
        # print("b64 encoded data: ",b64_encoded_data)
        string_data = b64_encoded_data.decode()
        print(string_data)
        # json_object = json.loads(string_data)
        # return  b64_encoded_data
        return  string_data
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

    
def decrypt_data(data):
    try:
        # cbc_key= load_property('aes.cbc.secret')
        # iv_key= load_property('aes.cbc.iv')
        dec_secret = b64decode(cbc_secret_key)
        dec_iv = b64decode(cbc_iv_key)
        b64_decoded_data=  b64decode(data)
        # print(b64_decoded_data)
        cipher = Cipher(algorithms.AES(dec_secret), modes.CBC(dec_iv))
        decryptor = cipher.decryptor()
        dect = decryptor.update(b64_decoded_data) + decryptor.finalize()
        unpadder = padding.PKCS7(128).unpadder()
        data = unpadder.update(dect)
        # print(data)
        final_data=  data + unpadder.finalize()
        string_data = final_data.decode()
        print(type(string_data))
        json_object = json.loads(string_data)
        print(type(json_object))
        return  json_object
    except Exception as e:
            print ("Exception:", e)
            print ("Exception at line no:", e.__traceback__.tb_lineno)


def Set_TZ_Header(**kwargs):
    tzheaders= {} 
    locparam= {}
    rem_list= []
    print("kwargs: ",kwargs)
    print("kwargs key: ",kwargs.get("timeZone"))
    print("location key: ",kwargs.get("location"))
    if kwargs=={} or (kwargs.get("timeZone")== None and kwargs.get("location") == None) :
        tzheaders.update({'timeZone':'Asia/Kolkata'})
        print("default time zone set: ",tzheaders)
    else:
        for key, value in kwargs.items():
            if key == 'timeZone':
                tzheaders.update({'timeZone':value})
                rem_list.append(key)
                # removed_value = kwargs.pop(key, 'No Key found')
                # print(key," Removed from kwargs -", removed_value)
                # print(tzheaders)
                print("user provided time zone set: ",tzheaders)
            elif key == 'location':
                locparam.update({key:value})
                # removed_value = kwargs.pop(key, 'No Key found')
                rem_list.append(key)
                # print(key," Removed from kwargs -", removed_value)
                # print(locparam)
                print("user provided location param set: ",locparam)
    [kwargs.pop(key) for key in rem_list]
    print("Final kwargs: ",kwargs)
    return  tzheaders, kwargs, locparam


def CDLcategorytype(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_category_tbl(account,type_enum,name,alias_name,conversion_value,status,created_by,created_date,modified_by)
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [(account,4,'CDL','CDL','1.0',0,1,date,0)]
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()


def CDLtype(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_type_tbl(account,type_enum,name,status,created_by,created_date,modified_by)
                           VALUES (%s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [(account,4,'Direct walkin',0,1,date,0),
                                 (account,4,'Referral',0,1,date,0),
                                 (account,4,'Social Media',0,1,date,0),
                                 (account,4,'Dealer Point',0,1,date,0),
                                 (account,4,'Business Associate',0,1,date,0),
                                 (account,4,'MAFIL Branch',0,1,date,0)]
            cur.executemany(mySql_insert_query, records_to_insert)            
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()


def CDLEnqStatus(account):
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try:
        with dbconn.cursor() as cur:
            date= get_date()
            mySql_insert_query = """INSERT INTO ynw.crm_status_tbl(account,type_enum,name,alias_name,status,created_by,created_date,modified_by,is_blocked,is_canceled,is_closed,is_default,is_editable,is_verified,is_done,is_rejected,is_pending)
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) """

            records_to_insert = [(account,3,'Follow Up','Follow Up',0,1,date,0, 0, 0, 0, 1, 1, 0, 0, 0, 0),
                 (account,3,'Completed','Completed',0,1,date,0, 0, 0, 1, 0, 0, 0, 0, 0, 0)]
                                 
            cur.executemany(mySql_insert_query, records_to_insert)  
            dbconn.commit()
         
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        pass
    finally:
        if dbconn is not None:
            dbconn.close()


def timestamp_conversion(timestamp):
    try:
        date_time1= datetime.datetime.fromtimestamp(int(timestamp)/1000)
        return date_time1
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0

def clear_multilocation (usrid):
    print("In function: ", inspect.stack()[0].function)
    aid=get_acc_id(usrid)
    clear_queue(usrid)
    clear_Rating(usrid)
    clear_appt_schedule(usrid)
    dbconn = connect_db(db_host, db_user, db_passwd, db)
    try :
        with dbconn.cursor() as cursor:
            print('fetching base location id')
            cursor.execute("SELECT base_location FROM account_info_tbl WHERE id='%s'" % aid)
            row = cursor.fetchone()
            baseloc_id = row[0]
            delete_search(aid)
            delete_schedule_service(aid)
            delete_entry('transaction_payment_tbl','account',aid,cursor)
            delete_entry('donation_tbl','account',aid,cursor)
            cursor.execute("SELECT id FROM location_tbl WHERE account='%s'" % aid)
            row = cursor.fetchall()
            print (row) 
            for index in range(len(row)):
                if row[index][0]!= baseloc_id:
                    delete_entry_2Fields('location_tbl','id',int(row[index][0]),'account',aid,cursor)
            dbconn.commit()
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)
        return 0
    finally:
        if dbconn is not None:
            dbconn.close()


def endtime_conversion(time1,time2):     
    if time2[-2:] == "AM" and time1[-2:] == "PM": 
        time2 = "11:59 PM" + time2[2:2] 
        return str(time1), str(time2)
    else:
        return str(time1), str(time2)