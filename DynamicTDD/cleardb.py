import os, shutil, re, pymysql, json


filename="numbers.txt"
panfile="pan.txt"
timefile="time.txt"
dir="varfiles"
dirpath=os.path.realpath('../Docker/')
envfile = "env*.list"
db_host = "127.0.0.1"
db_user = "root"
db_passwd = "netvarth"
dbname = "ynw"

# def delete_entry(table,field,value):
# 	try:
# 		dbconn = db.connect_db(db.host, db.user, db.passwd, db.db)
# 		cur = dbconn.cursor()
# 		cur.execute("DELETE FROM %s WHERE %s ='%s'" % (table,field,value))
		
# 		dbconn.commit()
# 		dbconn.close()
# 	except:
#         	return 0

def connect_db(host, user, passwd, db):
    try:
        return pymysql.connect(host=host,
                               user=user,
                               passwd=passwd,
                               db=db)
    except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

def delete_entry(table,field,value,cur):
	try:
		print(table)
		cur.execute("delete from %s where %s ='%s';" % (table,field,value))
		print(table, 'cleared')
	except Exception as e:
		print ("Exception:", e)
		print ("Exception at line no:", e.__traceback__.tb_lineno)


def delete_search(aid,cur):
	try:
		cur.execute("SELECT id FROM location_tbl WHERE account='%s'" % aid)
		print(cur.fetchall())
		row = [str(item[0]) for item in cur.fetchall()]
		for i in range(len(row)) :
			cur.execute("INSERT INTO search_data_tbl(intent,id,account) VALUES (2,%s,%s) ON DUPLICATE KEY UPDATE intent=2" % (row[i],aid, cur))
	except Exception as e:
		print ("Exception:", e)
		print ("Exception at line no:", e.__traceback__.tb_lineno)


# def delete_sequence_generator(aid,cur):
# 	try:
# 		cur.execute("SELECT id FROM queue_tbl WHERE account='%s'" % aid)
# 		row = [str(item[0]) for item in cur.fetchall()]
# 		for i in range(len(row)) :
# 			cur.execute("DELETE FROM sequence_generator_tbl WHERE queue ='%s'" % (row[i]))
# 	except Exception as e:
# 		print ("Exception:", e)
# 		print ("Exception at line no:", e.__traceback__.tb_lineno)
# 		return 0


def clear_queue(aid,cur):
	try:
		cur.execute("SELECT id FROM queue_tbl WHERE account='%s'" % aid)
		row = [str(item[0]) for item in cur.fetchall()]
		for i in range(len(row)) :
			# cur.execute("DELETE FROM ml_tbl WHERE queue ='%s'" % (row[i]))
			# cur.execute("DELETE FROM sequence_generator_tbl WHERE queue ='%s'" % (row[i]))
			# cur.execute("DELETE FROM acct_queue_stats_tbl WHERE queue ='%s'" % (row[i]))
			# cur.execute("DELETE FROM queue_service_tbl WHERE queue_id ='%s'" % (row[i]))
			delete_entry('ml_tbl','queue',(row[i]),cur)
			delete_entry('sequence_generator_tbl','queue',(row[i]),cur)
			delete_entry('acct_queue_stats_tbl','queue',(row[i]),(row[i]))
			delete_entry('queue_service_tbl','queue_id',aid,cur)
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
		delete_entry('wl_sb_tbl','account_id',aid,cur)
		# delete_queue_service(aid)
		# delete_queue_stats_table(aid)
		# delete_ML_table(aid)
		delete_entry('queue_tbl','account',aid,cur)
		delete_entry('holidays_tbl','account',aid,cur)
	except Exception as e:
		print ("Exception:", e)
		print ("Exception at line no:", e.__traceback__.tb_lineno)
		return 0


# def delete_queue_service(aid, cur):
# 	try:
# 		cur.execute("SELECT id FROM queue_tbl WHERE account='%s'" % aid)
# 		row = [str(item[0]) for item in cur.fetchall()]
# 		for i in range(len(row)) :
# 			cur.execute("DELETE FROM queue_service_tbl WHERE queue_id ='%s'" % (row[i]))
# 	except Exception as e:
# 		print ("Exception:", e)
# 		print ("Exception at line no:", e.__traceback__.tb_lineno)
# 		return 0

# def delete_queue_stats_table(aid, cur):
#     try:
#             cur.execute("SELECT id FROM queue_tbl WHERE account='%s'" % aid)
#             row = [str(item[0]) for item in cur.fetchall()]
#             for i in range(len(row)) :
#                 cur.execute("DELETE FROM acct_queue_stats_tbl WHERE queue ='%s'" % (row[i]))
#     except Exception as e:
#         print ("Exception:", e)
#         print ("Exception at line no:", e.__traceback__.tb_lineno)
#         return 0 

def delete_service(aid, cur):
	try:
		cur.execute("SELECT id FROM service_tbl WHERE account='%s'" % aid)
		row = [str(item[0]) for item in cur.fetchall()]
		for i in range(len(row)) :
			# cur.execute("DELETE FROM donation_service_tbl WHERE id ='%s'" % (row[i]))
			# cur.execute("DELETE FROM schedule_service_tbl WHERE service_id ='%s'" % (row[i]))
			delete_entry('donation_service_tbl','id',(row[i]),cur)
			delete_entry('schedule_service_tbl','service_id',(row[i]),cur)
			delete_entry('virtual_service_tbl','id',(row[i]),cur)
			delete_entry('queue_service_tbl','service_id',(row[i]),cur)
			delete_entry('transaction_payment_tbl','service_id',int((row[i])),cur)
			delete_entry('wl_cache_tbl','service_id',int((row[i])),cur)
			delete_entry('donation_tbl','service_id',int((row[i])),cur)
			delete_entry('questionnaire_tbl','transaction_id',int((row[i])),cur)
		delete_entry('service_tbl','account',aid,cur)
	except Exception as e:
		print ("Exception:", e)
		print ("Exception at line no:", e.__traceback__.tb_lineno)
		return 0

# def delete_schedule_service(aid, cur):
#     try:
#             cur.execute("SELECT id FROM service_tbl WHERE account='%s'" % aid)
#             row = [str(item[0]) for item in cur.fetchall()]
#             for i in range(len(row)) :
#                 cur.execute("DELETE FROM schedule_service_tbl WHERE service_id ='%s'" % (row[i]))
#     except Exception as e:
#         print ("Exception:", e)
#         print ("Exception at line no:", e.__traceback__.tb_lineno)
#         return 0

def clear_appt_schedule(aid, cur):
    
	try :
		cur.execute("SELECT uid FROM appt_tbl WHERE account='%s'" % aid)
		apptid = cur.fetchall()
		print (apptid)
		cur.execute("SELECT id FROM appt_schedule_tbl WHERE account='%s'" % aid)
		apptschid = cur.fetchall()
		print (apptschid)
		
		for index in range(len(apptid)):
			delete_entry('appt_livetrack_tbl','uuid',apptid[index][0],cur) 
			# print('appt_livetrack_tbl cleared')
			delete_entry('appt_tbl','uid',apptid[index][0],cur)
			# print('appt_tbl cleared')
		for index in range(len(apptschid)):
			delete_entry('schedule_service_tbl','schedule_id',int(apptschid[index][0]),cur)
			# print('schedule_service_tbl cleared')
			delete_entry('transaction_payment_tbl','schedule_id',int(apptschid[index][0]),cur)
			# print('transaction_payment_tbl cleared')
		delete_entry('appmnt_archive_tbl','account',aid,cur)
		# print('appmnt_archive_tbl cleared')
		delete_entry('appt_daily_schedule_tbl','account',aid,cur)
		# print('appt_daily_schedule_tbl cleared')
		delete_entry('appt_queueset_tbl','account_id',aid,cur)
		# print('appt_queueset_tbl cleared')
		delete_entry('appt_tbl','account',aid,cur)
		# print('appt_tbl cleared')
		delete_entry('appt_schedule_tbl','account',aid,cur)
		# print('appt_schedule_tbl cleared')
		delete_entry('appt_state_tbl','account',aid,cur)
		# print('appt_state_tbl cleared')
		delete_entry('holidays_tbl','account',aid,cur)
		# print('holidays_tbl cleared')
	except Exception as e:
		print ("Exception:", e)
		print ("Exception at line no:", e.__traceback__.tb_lineno)
		return 0

def clear_corporate (uid,cur):
	try:
		cur.execute("select corporate_id from corporate_tbl where corporate_uid ='%s'" %(uid))
		row = cur.fetchone()
		print (int(row[0]))
		cur.execute("select branch_id from account_tbl where corporate_id ='%s'" %(int(row[0])))
		row1 = cur.fetchone()
		print (row1)
		for i in len(row1):
			# cur.execute("DELETE FROM branch_tbl WHERE branch_id ='%s'" %(int(row1[i])))
			delete_entry('branch_tbl','branch_id',(int(row1[i])),cur)

		delete_entry('corporate_license_tbl','corp_id',(int(row[0])),cur)
		delete_entry('corporate_license_subscription_tbl','id',(int(row[0])),cur)
		delete_entry('corporate_tbl','corporate_id',(int(row[0])),cur)
		delete_entry('corporate_verification_tbl','corp_id',(int(row[0])),cur)
		# cur.execute("DELETE FROM corporate_license_tbl WHERE corporate_id ='%s'" % (int(row[0])))
		# cur.execute("DELETE FROM corporate_license_subscription_tbl WHERE corporate_id ='%s'" % (int(row[0])))
		# cur.execute("DELETE FROM corporate_tbl WHERE corporate_id ='%s'" % (int(row[0])))
	except Exception as e:
		print ("Exception:", e)
		print ("Exception at line no:", e.__traceback__.tb_lineno)
		return 0  

def clear_customer(aid, cur):
	try:
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
			delete_entry('provider_consumer_msg_tbl','providerconsumer',conid[index][0], cur)
			# select_entry('provider_consumer_tbl','parent_id',conid[index][0],cur)
			# print('provider_consumer_tbl')
			delete_entry('provider_consumer_tbl','id',conid[index][0],cur)
			# print('provider_consumer_tbl')
			delete_entry('provider_consumer_tbl','account',aid,cur)

	except Exception as e:
		print ("Exception:", e)
		print ("Exception at line no:", e.__traceback__.tb_lineno) 

def clear_users(aid, cur):
	try:
		cur.execute("SELECT id FROM service_tbl WHERE account='%s'" % aid)
		row = [str(item[0]) for item in cur.fetchall()]
		for i in range(len(row)) :
			# cur.execute("DELETE FROM donation_service_tbl WHERE id ='%s'" % (row[i]))
			# cur.execute("DELETE FROM schedule_service_tbl WHERE service_id ='%s'" % (row[i]))
			delete_entry('donation_service_tbl','id',(row[i]),cur)
			delete_entry('schedule_service_tbl','service_id',(row[i]),cur)
			delete_entry('virtual_service_tbl','id',(row[i]),cur)
			delete_entry('queue_service_tbl','service_id',(row[i]),cur)
			delete_entry('transaction_payment_tbl','service_id',int((row[i])),cur)
			delete_entry('wl_cache_tbl','service_id',int((row[i])),cur)
			delete_entry('donation_tbl','service_id',int((row[i])),cur)
			delete_entry('questionnaire_tbl','transaction_id',int((row[i])),cur)
		delete_entry('service_tbl','account',aid,cur)
	except Exception as e:
		print ("Exception:", e)
		print ("Exception at line no:", e.__traceback__.tb_lineno)
		return 0

try:
	with open(filename,'r') as file:
		dbconn = connect_db(db_host, db_user, db_passwd, dbname)
		for num in file:
			num = num.rstrip('\n')
			print (num)
			with dbconn.cursor() as cur:
				cur.execute("SELECT id FROM account_info_tbl WHERE acct_linked_ph_no='%s'" % num)
				row1 = cur.fetchone()
				print (row1)
				if row1==None:
					continue
				aid = row1[0]
				print ("aid:", aid)

				cur.execute("SELECT id FROM user_tbl WHERE primary_mobile_no='%s'" % num)
				row2 = cur.fetchone()
				print (row2)
				uid = row2[0]
				print ("uid:", uid)

				# cur.execute("SELECT account FROM local_user_tbl WHERE id='%s'" % uid)
				# row1 = cur.fetchone()
				# print (row1)
				# aid = row1[0]
				# print("aid:", aid)

				# uid = db.get_id(str(num))
				# aid = db.get_acc_id(str(num))
				# print (uid, cur) 
				# print (aid, cur)
				delete_search(aid, cur)
				# delete_sequence_generator(aid, cur)
				# delete_ML_table(aid, cur)
				clear_queue(aid, cur)
				delete_entry('favorite_provider_tbl','account_id',aid, cur)
				delete_entry('favorite_provider_tbl','cust_id',uid, cur)
				# delete_entry('wl_state_tbl','account',aid, cur)
				# delete_entry('wl_state_tbl','created_by',uid, cur)
				# delete_entry('wl_provider_note_tbl','account',aid, cur)
				# delete_entry('wl_rating_tbl','account',aid, cur)
				# delete_entry('wl_history_tbl','account',aid, cur)
				# delete_entry('wl_history_tbl','created_by',uid, cur)
				# delete_entry('wl_history_tbl','consumer_id',uid, cur)
				# delete_entry('wl_cache_tbl','account',aid, cur)
				# delete_entry('wl_cache_tbl','created_by',uid, cur)
				# delete_entry('wl_cache_tbl','consumer_id',uid, cur)
				# delete_queue_service(aid, cur)
				# delete_queue_stats_table(aid, cur)
				# delete_donation_service(aid, cur)
				# delete_schedule_service(aid, cur)
				delete_service(aid, cur)
				delete_entry('queue_tbl','account',aid, cur)
				delete_entry('service_tbl','account',aid, cur)  
				# delete_entry('acc_contact_info_tbl','acc_info_id',aid, cur) --- table does not exist
				delete_entry('account_info_tbl','id',aid, cur) 
				delete_entry('account_license_tbl','account',aid, cur)
				delete_entry('account_matrix_usage_tbl','id',aid, cur)
				delete_entry('account_transient_metrics_tbl','id',aid, cur)
				delete_entry('account_settings_tbl','account',aid, cur)
				delete_entry('account_payment_settings_tbl','id',aid, cur)
				delete_entry('wl_settings_tbl','id',aid, cur)
				delete_entry('acc_lic_subscription_tbl','id',aid, cur)
				delete_entry('acc_report_tbl','account',aid, cur)
				delete_entry('access_key_tbl','login_id',num, cur)
				delete_entry('account_verify_tbl','account',aid, cur)
				clear_appt_schedule(aid, cur)
				delete_entry('appt_rating_tbl','account',aid, cur)
				delete_entry('appt_sb_tbl','account_id',aid, cur)
				delete_entry('appt_settings_tbl','id',aid, cur)
				delete_entry('local_user_tbl','account',aid, cur)
				delete_entry('login_history_tbl','user_id',aid, cur)
				delete_entry('audit_log_tbl','account',aid, cur)
				delete_entry('consumer_msg_tbl','created_by',uid, cur)
				delete_entry('consumer_msg_tbl','modified_by',uid, cur)
				delete_entry('consumer_msg_tbl','id',uid, cur)
				delete_entry('provider_msg_tbl','account',aid, cur)	
				# delete_entry('bill_tbl','account_id',aid, cur)
				# delete_entry('bill_tbl','consumer_id',uid, cur)
				delete_entry('consumer_tbl','prod_acc',aid, cur)
				delete_entry('consumer_tbl','id',uid, cur)
				delete_entry('user_profile_tbl','created_by',aid, cur)
				delete_entry('login_tbl','id',uid, cur)
				# delete_entry('login_history_tbl','user_id',uid, cur)
				delete_entry('item_tbl','account',aid, cur)
				delete_entry('acc_discount_tbl','account',aid, cur)
				delete_entry('alert_tbl','account',aid, cur)
				delete_entry('image_info_tbl','id',aid, cur)	
				delete_entry('acc_coupon_tbl','account',aid, cur)
				delete_entry('adword_tbl','account',aid, cur)
				delete_entry('invoice_details_tbl','created_by',uid, cur)
				delete_entry('invoice_tbl','account',aid, cur)
				delete_entry('tax_tbl','id',aid, cur)
				delete_entry('account_tbl','id',aid, cur)
				delete_entry('acc_credit_debit_tbl','account',aid, cur)
				delete_entry('label_tbl','account_id',aid, cur)
				delete_entry('account_rating_tbl','id',aid, cur)
				delete_entry('holidays_tbl','account',aid, cur)
				delete_entry('branch_tbl','id',aid, cur)
				delete_entry('item_unit_tbl','created_by',uid, cur)
				delete_entry('bill_tbl','account_id',aid, cur)
				# delete_entry('ynw_txn_tbl','created_by',uid, cur)
				delete_entry('service_tbl','account',aid, cur)
				delete_entry('payment_tbl','account_id',aid, cur)   
				delete_entry('reimburse_payment_tbl','account',aid, cur)  
				delete_entry('reimburse_invoice_tbl','account',aid, cur) 
				# delete_entry('bill_tbl','account_id',aid, cur)
				delete_entry('jc_provider_stats_tbl','provider_id',aid, cur)
				delete_entry('jc_live_stat_tbl','provider_id',aid, cur)
				delete_entry('provider_jc_tbl','account_id',aid, cur)
				delete_entry('pos_settings_tbl','account',aid, cur)
				delete_entry('notification_settings_tbl','account',aid, cur)
				delete_entry('jdn_disc_tbl','id',aid, cur)
				delete_entry('corporate_tbl','corporate_uid',uid, cur)
				delete_entry('ynw.label_tbl','account_id',aid, cur)
				delete_entry('consumer_notification_settings_tbl','account',aid, cur)
				delete_entry('analytics_tbl','account',aid, cur)
				delete_entry('authn_tbl','primary_account',aid, cur)
				delete_entry('bank_accounts_tbl','account',aid, cur)
				delete_entry('booking_log_tbl','account',aid, cur)
				delete_entry('catalog_item_tbl','account',aid, cur)
				delete_entry('catalog_tbl','account',aid, cur)
				delete_entry('chat_bot_stat_tbl','provider',aid, cur)
				delete_entry('chat_bot_stat_tbl','consumer',uid, cur)
				delete_entry('consumer_family_member_tbl','parent_id',uid, cur)
				delete_entry('consumer_group_tbl','account',aid, cur)
				clear_corporate(uid, cur)
				delete_entry('crif_inquiry_tbl','account_id',aid, cur)
				delete_entry('crm_lead_master_tbl','account_id',aid, cur)
				delete_entry('crm_enquire_tbl','account_id',aid, cur)
				delete_entry('crm_category_tbl','account',aid, cur)
				delete_entry('crm_consumer_task_audit_log_tbl','account_id',aid, cur)
				delete_entry('crm_consumer_task_tbl','account',aid, cur)
				delete_entry('crm_enquire_master_tbl','account_id',aid, cur)
				delete_entry('crm_lead_audit_log_tbl','account_id',aid, cur)
				delete_entry('lead_kyc_tbl','account',aid, cur)
				delete_entry('crm_lead_tbl','account_id',aid, cur)
				delete_entry('crm_priority_tbl','account',aid, cur)
				delete_entry('crm_provider_task_audit_log_tbl','account_id',aid, cur)
				delete_entry('crm_provider_task_tbl','account',aid, cur)
				delete_entry('crm_status_tbl','account',aid, cur)
				delete_entry('crm_task_master_tbl','account',aid, cur)
				delete_entry('crm_type_tbl','account',aid, cur)
				delete_entry('location_tbl','account',aid, cur)
				delete_entry('user_tbl','id',uid, cur)
				# delete_entry('custom_app_activation_tbl','account_id',aid, cur)
				delete_entry('custom_app_tbl','account',aid, cur)
				delete_entry('custom_field_tbl','account',aid, cur)
				delete_entry('custom_view_tbl','account',aid, cur)
				delete_entry('department_tbl','account',aid, cur)
				delete_entry('donation_tbl','account',aid, cur)
				delete_entry('drive_tbl','account',aid, cur)
				delete_entry('family_member_tbl','pro_con_parent_id',uid, cur)
				delete_entry('file_share_tbl','account',aid, cur)
				delete_entry('jaldee_cash_offer_tbl','created_by',aid, cur)
				delete_entry('jaldee_cash_tbl','acc_id',aid, cur)
				delete_entry('jaldee_integration_tbl','account',aid, cur)
				delete_entry('jaldee_share_tbl','owner',aid, cur)
				delete_entry('jaldee_share_tbl','owner',uid, cur)
				delete_entry('jc_live_tbl','created_by',aid, cur)
				delete_entry('jc_tbl','created_by',aid, cur)
				delete_entry('jcash_offer_issue_stat_tbl','consumer_id',uid, cur)
				delete_entry('jcash_txn_log_tbl','acc_id',aid, cur)
				delete_entry('jcash_txn_log_tbl','consumer_id',uid, cur)
				# delete_entry('jd_location_tbl','account',aid, cur)
				# delete_entry('lic_dis_code_tbl','account',aid, cur)
				# delete_entry('license_analysis_tbl','account',aid, cur)
				delete_entry('license_comp_info_tbl','account',aid, cur)
				delete_entry('livetrack_waitlist_tbl','created_by',aid, cur)
				# delete_entry('maintenance_tbl','account',aid, cur)
				delete_entry('medical_record_tbl','account',aid, cur)
				delete_entry('meeting_tbl','acc_id',aid, cur)
				delete_entry('order_archive_tbl','account',aid, cur)
				delete_entry('order_rating_tbl','account',aid, cur)
				delete_entry('order_settings_tbl','account_id',aid, cur)
				delete_entry('order_state_tbl','account',aid, cur)
				delete_entry('order_tbl','account',aid, cur)
				delete_entry('payment_link_tbl','acc_id',aid, cur)
				delete_entry('payment_request_tbl','account_id',aid, cur)
				delete_entry('pro_coupon_stat_tbl','provider_id',aid, cur)
				# delete_entry('provider_consumer_msg_tbl','parent_id',aid, cur)
				# delete_entry('provider_consumer_tbl','parent_id',aid, cur)
				clear_customer(aid, cur)
				delete_entry('provider_drive_tbl','account',aid, cur)
				# delete_entry('provider_sales_channel_tbl','account',aid, cur)
				delete_entry('provider_telegram_notification_settings_tbl','account',aid, cur)
				delete_entry('qnr_request_tbl','account',aid, cur)
				delete_entry('question_answer_tbl','account',aid, cur)
				# delete_entry('questionnaire_map_tbl','account',aid, cur)
				delete_entry('questionnaire_tbl','account',aid, cur)
				delete_entry('refund_tbl','account_id',aid, cur)
				delete_entry('reimburse_balance_tbl','account',aid, cur)
				delete_entry('report_criteria_tbl','account',aid, cur)
				delete_entry('report_data_tbl','account',aid, cur)
				delete_entry('sb_dimension_tbl','account_id',aid, cur)
				# delete_entry('sc_com_model_tbl','account',aid, cur)
				# delete_entry('sc_comm_report_tbl','account',aid, cur)
				# delete_entry('sc_invoice_tbl','account',aid, cur)
				# delete_entry('sc_rep_tbl','account',aid, cur)
				# delete_entry('sc_tbl','account',aid, cur)
				# delete_entry('service_request_tbl','account',aid, cur)
				delete_entry('store_credit_tbl','account',aid, cur)
				delete_entry('subscription_lic_disc_tbl','account_id',aid, cur)
				delete_entry('support_tbl','account_id',aid, cur)
				delete_entry('team_tbl','account',aid, cur)
				delete_entry('thirdparty_setting_tbl','account_id',aid, cur)
				delete_entry('user_stat_tbl','account',aid, cur)
				# delete_entry('user_team_tbl','account',aid, cur)
				delete_entry('video_tbl','acc_id',aid, cur)
				delete_entry('voice_tbl','acc_id',aid, cur)
				# delete_entry('wallet_tbl','account',aid, cur)
				
				

except IOError:
	print ('File',filename,'not accessible')

except Exception as e:
        print ("Exception:", e)
        print ("Exception at line no:", e.__traceback__.tb_lineno)

finally:
        if dbconn is not None:
            dbconn.close()

# open(filename, "w").close()

# try:
# 	open(panfile, "w").close()
# except IOError:
# 	print ('File',panfile,'not accessible')

# try:
# 	open(timefile, "w").close()
# except IOError:
# 	print ('File',timefile,'not accessible')

# try:
# 	shutil.rmtree(dir)
# except:
# 	print ('Error Deleting Directory',dir,'. Check if it exists')

# for f in os.listdir(dirpath):
# 		if re.search(envfile, f):
# 			os.remove(os.path.join(dirpath, f))

