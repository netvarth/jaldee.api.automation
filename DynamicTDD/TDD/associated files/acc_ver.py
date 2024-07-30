
import  db

def  db_verify(id,invoice_id,q_id,up1,log_id,usr_id):
    
    try:
       
        dbconn = db.connect_db(db.host, db.user, db.passwd, db.db)
        cur = dbconn.cursor()
                
        cur.execute("SELECT count(*) FROM location_tbl WHERE account='%s'" % id)
        row = cur.fetchone()
        tbl = "location_tbl"
       
        if (row[0] > 0):
           return [False,tbl]

        cur.execute("SELECT count(*) from acc_discount_tbl WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "acc_discount_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from acc_coupon_tbl WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "acc_coupon_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from item_tbl WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "item_tbl"   
        if (row[0] > 0):
            return [False,tbl]
        
        cur.execute("SELECT count(*) from invoice_details_tbl WHERE invoice_id='%s' or invoice_id='%s' "%(invoice_id[0],invoice_id[1]))
        row = cur.fetchone()
        tbl = "invoice_details_tbl"   
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from invoice_tbl WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "invoice_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from adword_tbl WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "adword_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from acc_credit_debit_tbl WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "acc_credit_debit_tbl"
        if (row[0] > 0):
            return [False,tbl]
            
        cur.execute("SELECT count(*) from payment_tbl WHERE account_id='%s'"%id)
        row = cur.fetchone()
        tbl = "payment_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from refund_tbl WHERE account_id='%s'"%id)
        row = cur.fetchone()
        tbl = "refund_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from account_payment_settings_tbl WHERE id='%s'"%id)
        row = cur.fetchone()
        tbl = "account_payment_settings_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from license_comp_info_tbl WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "license_comp_info_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from account_license_tbl WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "account_license_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from acc_lic_subscription_tbl WHERE id='%s'"%id)
        row = cur.fetchone()
        tbl = "acc_lic_subscription_tbl"
        if (row[0] > 0):
            return [False,tbl]
        
        cur.execute("SELECT count(*) from  account_transient_metrics_tbl WHERE id='%s'"%id)
        row = cur.fetchone()
        tbl = "account_transient_metrics_tbl"
        if (row[0] > 0):
            return [False,tbl]
        
        cur.execute("SELECT count(*) from  account_matrix_usage_tbl WHERE id='%s'"%id)
        row = cur.fetchone()
        tbl = "account_matrix_usage_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  wl_settings_tbl WHERE id='%s'"%id)
        row = cur.fetchone()
        tbl = "wl_settings_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  wl_state_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "wl_state_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  wl_history_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "wl_history_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  wl_rating_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "wl_rating_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  wl_cache_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "wl_cache_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from schedule_service_tbl  where schedule_service_tbl.schedule.account='%s'"%id)
        row = cur.fetchone()
        tbl = "schedule_service_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  bill_tbl  WHERE account_id='%s'"%id)
        row = cur.fetchone()
        tbl = "bill_tbl"
        if (row[0] > 0):
            return [False,tbl]
            
        cur.execute("SELECT count(*) from  family_member_tbl inner join provider_consumer_tbl ON  family_member_tbl.pro_con_parent_id= provider_consumer_tbl.id where provider_consumer_tbl.account='%s'"%id)
        row = cur.fetchone()
        tbl = "family_member_tbl"
        if (row[0] > 0):
            return [False,tbl]
        
        cur.execute("SELECT count(*) from  appmnt_archive_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "appmnt_archive_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  appt_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "appt_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  appt_sb_tbl  WHERE account_id='%s'"%id)
        row = cur.fetchone()
        tbl = "appt_sb_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  appt_state_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "appt_state_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  appt_daily_schedule_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "appt_daily_schedule_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  provider_consumer_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "provider_consumer_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  jdn_disc_tbl  WHERE id='%s'"%id)
        row = cur.fetchone()
        tbl = "jdn_disc_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  label_tbl  WHERE account_id='%s'"%id)
        row = cur.fetchone()
        tbl = "label_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  wl_sb_tbl  WHERE account_id='%s'"%id)
        row = cur.fetchone()
        tbl = "wl_sb_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  sb_dimension_tbl  WHERE id='%s'"%id)
        row = cur.fetchone()
        tbl = "sb_dimension_tbl"
        if (row[0] > 0):
            return [False,tbl]
            
        cur.execute("SELECT count(*) from  provider_sales_channel_tbl  WHERE  id='%s'"%id)
        row = cur.fetchone()
        tbl = "provider_sales_channel_tbl"
        if (row[0] > 0):
            return [False,tbl]
        
       
        cur.execute("SELECT count(*) from queue_service_tbl where queue_id='%s' or queue_id='%s' or queue_id='%s' or queue_id='%s' or queue_id='%s' or queue_id='%s' "%(q_id[0],q_id[1],q_id[2],q_id[3],q_id[4],q_id[5]))
        row = cur.fetchone()
        tbl = "queue_service_tbl"
        if (row[0] > 0):
            return [False,tbl]

       
        cur.execute("SELECT count(*) from  acct_queue_stats_tbl  WHERE queue='%s' or queue='%s' or queue='%s' or queue='%s' or queue='%s' or queue='%s' "%(q_id[0],q_id[1],q_id[2],q_id[3],q_id[4],q_id[5]))
        row = cur.fetchone()
        tbl = "acct_queue_stats_tbl"
        if (row[0] > 0):
            return [False,tbl]
            
        cur.execute("SELECT count(*) from  ml_tbl  WHERE queue='%s'or queue='%s' or queue='%s' or queue='%s' or queue='%s' or queue='%s' "%(q_id[0],q_id[1],q_id[2],q_id[3],q_id[4],q_id[5]))
        row = cur.fetchone()
        tbl = "ml_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  queue_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "queue_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  appt_rating_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "appt_rating_tbl"
        if (row[0] > 0):
            return [False,tbl]
            
        cur.execute("SELECT count(*) from  donation_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "donation_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  donation_service_tbl  WHERE id='%s'"%id)
        row = cur.fetchone()
        tbl = "donation_service_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  virtual_service_tbl  WHERE id='%s'"%id)
        row = cur.fetchone()
        tbl = "virtual_service_tbl"

        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  department_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "department_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  audit_log_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "audit_log_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  alert_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "alert_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  provider_msg_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "provider_msg_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  favorite_provider_tbl  WHERE account_id='%s'"%id)
        row = cur.fetchone()
        tbl = "favorite_provider_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  account_verify_tbl  WHERE account_id='%s'"%id)
        row = cur.fetchone()
        tbl = "account_verify_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  jc_live_stat_tbl  WHERE provider_id='%s'"%id)
        row = cur.fetchone()
        tbl = "jc_live_stat_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  reimburse_payment_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "reimburse_payment_tbl"
        if (row[0] > 0):
            return [False,tbl]
            
        cur.execute("SELECT count(*) from  reimburse_invoice_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "reimburse_invoice_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  provider_jc_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "provider_jc_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  subscription_lic_disc_tbl  WHERE account_id='%s'"%id)
        row = cur.fetchone()
        tbl = "subscription_lic_disc_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  pos_settings_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "pos_settings_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  tax_tbl  WHERE id='%s'"%id)
        row = cur.fetchone()
        tbl = "tax_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  notification_settings_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "notification_settings_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  provider_note_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "provider_note_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  favorite_provider_tbl  WHERE account_id='%s'"%id)
        row = cur.fetchone()
        tbl = "favorite_provider_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT id  from  local_user_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        cur.execute("SELECT count(*) from  consumer_msg_tbl where consumer_msg_tbl.id='%s'"%(row[0]))
        row = cur.fetchone()
        tbl = "consumer_msg_tbl"

        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  local_user_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "local_user_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  login_history_tbl  WHERE account_id='%s'"%id)
        row = cur.fetchone()
        tbl = "login_history_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  login_tbl  WHERE login_id_phone='%s'"%log_id)
        row = cur.fetchone()
        tbl = "login_tbl"
        if (row[0] > 0):
            return [False,tbl]

        
        cur.execute("SELECT count(*) from  user_tbl  WHERE id='%s'"%usr_id)
        row = cur.fetchone()
        tbl = "user_tbl"
        if (row[0] > 0):
            return [False,tbl]

        
        cur.execute("SELECT count(*) from  user_profile_tbl  WHERE id='%s'"%up1)
        row = cur.fetchone()
        tbl = "user_profile_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  account_info_tbl  WHERE id='%s'"%id)
        row = cur.fetchone()
        tbl = "account_info_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  appt_schedule_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "appt_schedule_tbl"
        if (row[0] > 0):
            return [False,tbl]
            
        cur.execute("SELECT count(*) from  search_data_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "search_data_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  sc_invoice_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "sc_invoice_tbl"
        if (row[0] > 0):
            return [False,tbl]
            
        cur.execute("SELECT count(*) from  custom_view_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "custom_view_tbl"
        if (row[0] > 0):
            return [False,tbl]
            
        cur.execute("SELECT count(*) from  jaldee_integration_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "jaldee_integration_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  account_settings_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "account_settings_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  consumer_notification_settings_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "consumer_notification_settings_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  notification_settings_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "notification_settings_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  appt_settings_tbl  WHERE account='%s'"%id)
        row = cur.fetchone()
        tbl = "appt_settings_tbl"
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from  appt_queueset_tbl  WHERE account_id='%s'"%id)
        row = cur.fetchone()
        tbl = "appt_queueset_tbl"
        if (row[0] > 0):
            return [False,tbl]
            
        cur.execute("SELECT count(*) from  account_tbl  WHERE  id='%s'"%id)
        row = cur.fetchone()
        tbl = "account_tbl"
        if (row[0] > 0):
            return [False,tbl]
                  
        return True
        dbconn.commit()
        
    except:
        return [False,tbl]
    finally:
     if dbconn is not None:
        dbconn.close()


def  consmr_db_verify(id):
    
    try:
       
        dbconn = db.connect_db(db.host, db.user, db.passwd, db.db)
        cur = dbconn.cursor()
        
        cur.execute("SELECT count(*) FROM favorite_provider_tbl WHERE cust_id='%s'" % id)
        row = cur.fetchone()
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from login_history_tbl WHERE user_id='%s'"%id)
        row = cur.fetchone()
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from consumer_msg_tbl WHERE id='%s'"%id)
        row = cur.fetchone()
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from family_member_tbl WHERE pro_con_parent_id='%s'"%id)
        row = cur.fetchone()
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from provider_consumer_tbl WHERE jaldee_consumer='%s'"%id)
        row = cur.fetchone()
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from consumer_tbl WHERE id='%s'"%id)
        row = cur.fetchone()
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from login_tbl WHERE id='%s'"%id)
        row = cur.fetchone()
        if (row[0] > 0):
            return [False,tbl]

        cur.execute("SELECT count(*) from user_tbl WHERE id='%s'"%id)
        row = cur.fetchone()
        if (row[0] > 0):
            return [False,tbl]

        return True
                  
    except:
        return [False,tbl]
    finally:
     if dbconn is not None:
        dbconn.close()

