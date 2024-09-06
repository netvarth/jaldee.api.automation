*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Coupon
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


***Keywords***

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Suite Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[1]}'
    END
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}

*** Variables ***

${SERVICE1}  Note Book101
${SERVICE2}  boots101
${SERVICE3}  walk12
@{gender}    Female    Male
${service_duration}   2
${digits}       0123456789
${self}         0
${CUSERPH}      ${CUSERNAME}
@{empty_list} 

*** Test Cases ***


JD-TC-ProviderCouponBill-1
    
    [Documentation]  Taking waitlist from consumer side for a prepayment service and consumer apply provider coupon 
             

    clear_location   ${PUSERNAME185}
    clear_service    ${PUSERNAME185}
    clear_queue      ${PUSERNAME185}
    clear_customer   ${PUSERNAME185}

    ${pid}=  get_acc_id  ${PUSERNAME185}
    Set Suite Variable  ${pid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}

    ${resp}=   Change License Package  ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
 
    ${list}=  Create List  1  2  3  4  5  6  7
   
    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p1_lid}=  Create Sample Location

    # ${resp}=  Get Locations
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=   Get Location ById  ${p1_lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_lid}  ${resp.json()['id']} 
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    
    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable  ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    ${Tot1}=  Convert To Number  ${Tot}  1
    Set Suite Variable  ${Tot1} 

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid1}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${Tot1}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_sid2}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${parallel}=   Random Int  min=1   max=1
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${p1_lid}  ${p1_sid1}  ${p1_sid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_qid1}  ${resp.json()}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    # ${pc_amount}=   FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${p1_sid1}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId1}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid1}=  get_id  ${CUSERNAME15}
    Set Suite Variable   ${cid1}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}  
    ${resp}=  Add To Waitlist Consumers   ${pid}  ${p1_qid1}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    # ${json}=  evaluate    json.loads('''${resp.content()}''')    json
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]}
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${balamount}=  Evaluate  ${Tot1}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount}  1

    ${balamount2}=  Evaluate  ${balamount1}-${pc_amount}
    ${balamount2}=  Convert To Number  ${balamount2}  1

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME185}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${p1_sid1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${Tot1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${cwid}  ${cupn_code}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${balamount3}=  Evaluate  ${Tot1}-${pc_amount}
    ${balamount3}=  Convert To Number  ${balamount3}  1
    
    ${SysNote}=  Create List  ${SystemNote[2]}  
    Set Suite Variable  ${SysNote} 
    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['value']}  50.0
    # Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}         ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['systemNote']}        ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${p1_sid1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount2}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['systemNote']}        ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${p1_sid1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount2}
  

JD-TC-ProviderCouponBill-2

    [Documentation]  Taking waitlist from consumer side with provider coupon
              
    ${resp}=  Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${SysNote}=  Create List  ${SystemNote[2]}  
    Set Suite Variable  ${SysNote} 

    ${coupon1}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${p1_sid1}   
    ${resp}=  Create Provider Coupon   ${coupon1}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId2}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid2}=  get_id  ${CUSERNAME16}
    Set Suite Variable   ${cid2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${coupons}=  Create List  ${cupn_code}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${p1_qid1}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${balamount}=  Evaluate  ${Tot1}-${pc_amount}
    ${balamount1}=  Evaluate  ${balamount}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount1}  2

   
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    # ${resp}=  ConsumerLogout
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Encrypted Provider Login   ${PUSERNAME185}  ${PASSWORD} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['value']}  50.0
    # Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}         ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['systemNote']}        ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${p1_sid1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}


JD-TC-ProviderCouponBill-UH1

    [Documentation]  Consumer apply a coupon at Checkin time.but maxProviderUseLimit is over

    clear_Coupon     ${PUSERNAME185}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${coupon3}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    Set Suite Variable  ${pc_amount} 
    ${cupn_code3}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=1   max=1
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${p1_sid1}   
    ${resp}=  Create Provider Coupon   ${coupon3}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code3}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId3}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME18}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${coupons}=  Create List  ${cupn_code3}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${p1_qid1}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${balamount}=  Evaluate  ${Tot1}-${pc_amount}
    ${balamount1}=  Evaluate  ${balamount}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount1}  1
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Encrypted Provider Login   ${PUSERNAME185}  ${PASSWORD} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Bill By UUId  ${cwid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  ProviderLogout
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code3}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['systemNote']}        ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${p1_sid1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}

    ${resp}=  Consumer Login  ${CUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${coupons}=  Create List  ${cupn_code3}  
    # ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${p1_qid1}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    # Log  ${resp.json()}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid1}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()['proCouponList']['${cupn_code3}']['systemNote']}   EXCEEDS_PRO_COUP_APPLY_LIMIT


JD-TC-ProviderCouponBill-UH2
    [Documentation]  Consumer apply a coupon at Checkin time.but coupon not in online
     
    ${resp}=  Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${coupon4}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${cupn_code4}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=15
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${p1_sid2}   
    ${resp}=  Create Provider Coupon   ${coupon4}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code4}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId4}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${coupons}=  Create List  ${cupn_code4}  
    # ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${p1_qid1}  ${DAY}  ${p1_sid2}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    # Log  ${resp.json()}
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid1}  ${DAY}  ${p1_sid2}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain   ${resp.json()['proCouponList']['${cupn_code4}']['systemNote']}   PROVIDER_COUPON_NOT_APPLICABLE_BOOKING_MODE
    # Should Be Equal As Strings  ${resp.json()}  "Provider use Limit Reached"

 
JD-TC-ProviderCouponBill-UH3
    [Documentation]  Consumer apply a coupon at Checkin time but Coupon created on future date
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${coupon5}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${cupn_code5}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.add_timezone_date  ${tz}  1
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=15
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${p1_sid2}   
    ${resp}=  Create Provider Coupon   ${coupon5}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code5}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId5}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId5} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME3}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${p1_qid1}  ${DAY}  ${p1_sid2}  ${msg}  ${bool[0]}   ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    # Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code5}
    # Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
    # Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['systemNote']}        [${SystemNote[2]}]
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${p1_sid2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${Tot1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${Tot1}


    ${resp}=  Apply Jaldee Coupon At Selfpay  ${cwid}  ${cupn_code5}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${COUPON_NOT_APPLICABLE}"
    
    
JD-TC-ProviderCouponBill-3

    [Documentation]  Consumer apply  provider coupon and jaldee coupon at checkin time for a taxable service 

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+1002101
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    #${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=  Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    Log  ${d1}
    Log  ${sd1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    "${resp.json()}"    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}200.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  

    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200    
    sleep   1s
 
    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ${d1}  
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    Set Suite Variable   ${licenses}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code2018}=    FakerLibrary.word
    Set Suite Variable   ${cupn_code2018}
    ${cupn_name}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable   ${c_des}
    ${p_des}=   FakerLibrary.sentence
    Set Suite Variable   ${p_des}
    ${dis_amt}=   Random Int   min=10   max=50
    ${dis_amt}=  Convert To Number  ${dis_amt}  1
    
    clear_jaldeecoupon  ${cupn_code2018}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  ${dis_amt}  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.word
    Set Test Variable  ${email2}  ${email}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${resp}=  Enable Waitlist

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pid1}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable   ${pid1}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${24hours}    Random Element    ['True','False']
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parkingType[0]}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${loc_id1}    ${resp.json()}  
    ${description}=  FakerLibrary.sentence
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${notify}    Random Element     ['True','False'] 
    ${resp}=  Create Service  ${SERVICE1}  ${description}   2  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id1}  ${resp.json()}
    
    ${resp}=  Create Service  ${SERVICE2}  ${description}   2  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${Tot1}  ${bool[0]}  ${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id2}  ${resp.json()}

    ${resp}=  Create Service  ${SERVICE3}  ${description}   2  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${Tot1}  ${bool[0]}  ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id3}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${strt_time}=   db.subtract_timezone_time  ${tz}  1  00
    ${end_time}=    add_timezone_time  ${tz}  1  00   
    ${parallel}=   Random Int  min=1   max=2
    ${capacity}=  Random Int   min=10   max=100
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${s_id1}  ${s_id2}  ${s_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}


    ${coupon1}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount1}=   Random Int   min=10  max=50
    ${pc_amount1}=  Convert To Number  ${pc_amount1}  1
    Set Suite Variable  ${pc_amount1}
    ${cupn_code02}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code02}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id2}  ${s_id3}  
    ${resp}=  Create Provider Coupon   ${coupon1}  ${desc}  ${pc_amount1}  ${calctype[1]}  ${cupn_code02}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId02}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId02} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid2}=  get_id  ${CUSERNAME6}
    
    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${coupons}=  Create List  ${cupn_code02}  ${cupn_code2018}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid1}  ${qid1}  ${DAY}  ${s_id2}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${taxabletotal}=  Evaluate  ${Tot1}-${pc_amount1}
    ${taxabletotal}=  Convert To Number  ${taxabletotal}  2
    ${tax}=  Evaluate  ${taxabletotal}*${gstpercentage[2]}/100
    ${tax}=  Convert To Number  ${tax}  2
    ${balamount}=  Evaluate  ${taxabletotal}+${tax}
    ${amountdue}=  Evaluate  ${balamount}-${dis_amt}
    ${amountdue}=  Convert To Number  ${amountdue}  2
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['value']}        ${dis_amt}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}   ${SysNote}
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code02}']['value']}          ${pc_amount1}
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code02}']['systemNote']}     ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${amountdue}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${amountdue}
    Should Be Equal As Strings  ${resp.json()['taxableTotal']}                          ${taxabletotal}
    Should Be Equal As Strings  ${resp.json()['totalTaxAmount']}                        ${tax}

    # ${resp}=  Make payment Consumer Mock  ${min_pre1}  ${bool[1]}  ${cwid}  ${pid}  ${purpose[0]}  ${cid2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By consumer  ${cwid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}    
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code02}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount1}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['systemNote']}        ${SysNote}
    Should Be Equal As Strings  ${resp.json()['jCouponList'][0]['couponCode']}        ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()['jCouponList'][0]['value']}             ${dis_amt}
    Should Be Equal As Strings  ${resp.json()['jCouponList'][0]['systemNote']}        ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${amountdue}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${amountdue}
    Should Be Equal As Strings  ${resp.json()['taxableTotal']}                          ${taxabletotal}
    Should Be Equal As Strings  ${resp.json()['totalTaxAmount']}                        ${tax}


JD-TC-ProviderCouponBill-4
    [Documentation]  Consumer apply  provider coupon at checkin time and disable coupon

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid2}=  get_id  ${CUSERNAME1}
    
    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${coupons}=  Create List  ${cupn_code02}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid1}  ${qid1}  ${DAY}  ${s_id3}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${balamount}=  Evaluate  ${Tot1}-${pc_amount1}
    ${balamount}=  Convert To Number  ${balamount}  2

   
    ${resp}=  Get Bill By UUId  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code02}']['value']}        ${pc_amount1}
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code02}']['systemNote']}   ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${s_id3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount}
    Should Be Equal As Strings  ${resp.json()['taxableTotal']}                          0.0
    Should Be Equal As Strings  ${resp.json()['totalTaxAmount']}                        0.0

    ${resp}=  Disable Coupon  ${couponId02}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By consumer  ${cwid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${cwid}    
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code02}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount1}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['systemNote']}        ${SysNote}
    # Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${s_id3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount}
    Should Be Equal As Strings  ${resp.json()['taxableTotal']}                          0.0
    Should Be Equal As Strings  ${resp.json()['totalTaxAmount']}                        0.0

JD-TC-ProviderCouponBill-5
    [Documentation]  Consumer apply a coupon at Checkin time and provider also apply another coupon on bill
    
    clear_Coupon     ${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${coupon3}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount1}=   Random Int   min=10  max=50
    ${pc_amount1}=  Convert To Number  ${pc_amount1}  1
    ${cupn_code3}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10  max=15
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id3}   
    ${resp}=  Create Provider Coupon   ${coupon3}  ${desc}  ${pc_amount1}  ${calctype[1]}  ${cupn_code3}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId03}  ${resp.json()}

    ${coupon4}=    FakerLibrary.firstName
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount4}=   Random Int   min=10  max=50
    ${pc_amount4}=  Convert To Number  ${pc_amount4}  1
    Set Suite Variable  ${pc_amount4}
    ${cupn_code4}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code4}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10  max=15
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id3}   
    ${resp}=  Create Provider Coupon   ${coupon4}  ${desc}  ${pc_amount4}  ${calctype[1]}  ${cupn_code4}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId04}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId03} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME2}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${coupons}=  Create List  ${cupn_code3}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid1}  ${qid1}  ${DAY}  ${s_id3}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

   
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${balamount}=  Evaluate  ${Tot1}-${pc_amount1}
    ${balamount}=  Convert To Number  ${balamount}  2

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code3}']['value']}        ${pc_amount1}
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code3}']['systemNote']}   ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${s_id3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount}
    Should Be Equal As Strings  ${resp.json()['taxableTotal']}                          0.0
    Should Be Equal As Strings  ${resp.json()['totalTaxAmount']}                        0.0

    ${resp}=  Update Bill   ${cwid}  ${action[12]}    ${cupn_code4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${totaldisc}=  Evaluate  ${pc_amount1} + ${pc_amount4}
    ${balamount}=  Evaluate  ${Tot1}-${totaldisc}
    ${balamount}=  Convert To Number  ${balamount}  2

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code3}']['value']}        ${pc_amount1}
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code3}']['systemNote']}   ${SysNote}
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code4}']['value']}        ${pc_amount4}
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code4}']['systemNote']}   ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${s_id3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount}
    Should Be Equal As Strings  ${resp.json()['taxableTotal']}                          0.0
    Should Be Equal As Strings  ${resp.json()['totalTaxAmount']}                        0.0


    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

JD-TC-ProviderCouponBill-6
    [Documentation]  Provider apply a coupon after waitlist and consumer also apply a coupon at Selfpay
   
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${coupon5}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount1}=   Random Int   min=10  max=50
    ${pc_amount1}=  Convert To Number  ${pc_amount1}  1
    ${cupn_code5}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=15
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id3}   
    ${resp}=  Create Provider Coupon   ${coupon5}  ${desc}  ${pc_amount1}  ${calctype[1]}  ${cupn_code5}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${couponId05}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId05} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${coupon6}=    FakerLibrary.firstName
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount4}=   Random Int   min=10  max=50
    ${pc_amount4}=  Convert To Number  ${pc_amount4}  1
    Set Suite Variable  ${pc_amount4}
    ${cupn_code6}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code6}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10  max=15
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id3}   
    ${resp}=  Create Provider Coupon   ${coupon6}  ${desc}  ${pc_amount4}  ${calctype[1]}  ${cupn_code6}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId04}  ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME3}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${qid1}  ${DAY}  ${s_id3}  ${msg}  ${bool[0]}   ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${balamount}=  Evaluate  ${Tot1}-${pc_amount1}
    ${balamount}=  Convert To Number  ${balamount}  2

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${s_id3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${Tot1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${Tot1}
    Should Be Equal As Strings  ${resp.json()['taxableTotal']}                          0.0
    Should Be Equal As Strings  ${resp.json()['totalTaxAmount']}                        0.0


    ${resp}=  Update Bill   ${cwid}  ${action[12]}    ${cupn_code5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code5}']['value']}        ${pc_amount1}
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code5}']['systemNote']}   ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${s_id3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount}
    Should Be Equal As Strings  ${resp.json()['taxableTotal']}                          0.0
    Should Be Equal As Strings  ${resp.json()['totalTaxAmount']}                        0.0
   

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code5}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount1}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['systemNote']}        ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Eq ual As Strings  ${resp.json()['service'][0]['serviceId']}              ${s_id3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount}

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${cwid}  ${cupn_code6}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${totaldisc}=  Evaluate  ${pc_amount1} + ${pc_amount4}
    ${balamount}=  Evaluate  ${Tot1}-${totaldisc}
    ${balamount}=  Convert To Number  ${balamount}  2

    sleep  3s
    ${resp}=  Get Bill By consumer  ${cwid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code6}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount4}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['systemNote']}        ${SysNote}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][1]['couponCode']}        ${cupn_code5}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][1]['value']}             ${pc_amount1}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][1]['systemNote']}        ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Eq ual As Strings  ${resp.json()['service'][0]['serviceId']}              ${s_id3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount}


JD-TC-ProviderCouponBill-UH4

    [Documentation]  Provider apply a coupon after waitlist and consumer also apply same coupon at Selfpay
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=15
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id3}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${couponId}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME5}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${qid1}  ${DAY}  ${s_id3}  ${msg}  ${bool[0]}   ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Bill   ${cwid}  ${action[12]}    ${cupn_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${netRate}=  Evaluate  ${Tot1} - ${pc_amount}
    ${netRate}=  Convert To Number  ${netRate}  2

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['systemNote']}        ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${s_id3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${netRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${netRate}

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${cwid}  ${cupn_code}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${COUPON_ALREADY_USED}"
    
    
JD-TC-ProviderCouponBill-UH5

    [Documentation]  Consumer apply a coupon at self payment and provider also apply same  coupon to same bill

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=15
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id3}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${couponId}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME15}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=  Add To Waitlist Consumers  ${pid1}  ${qid1}  ${DAY}  ${s_id3}  ${msg}  ${bool[0]}   ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${cwid}  ${cupn_code}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${netRate}=  Evaluate  ${Tot1} - ${pc_amount}
    ${netRate}=  Convert To Number  ${netRate}  2

    ${resp}=  Get Bill By consumer  ${cwid}  ${pid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['systemNote']}        ${SysNote}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${s_id3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${netRate}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${netRate}
 
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Bill   ${cwid}  ${action[12]}    ${cupn_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${COUPON_ALREADY_USED}"

JD-TC-ProviderCouponBill-UH6

    [Documentation]  Consumer apply a coupon at Checkin time.but the coupon is for first checkin only

    clear_Coupon     ${PUSERNAME185}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${coupon3}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    Set Suite Variable  ${pc_amount} 
    ${cupn_code3}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=1   max=1
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${p1_sid1}   ${p1_sid2} 
    ${resp}=  Create Provider Coupon   ${coupon3}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code3}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${couponId3}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME19}

    ${desc}=   FakerLibrary.word
    ${coupons}=  Create List  ${cupn_code3}  
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid1}  ${DAY}  ${p1_sid1}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    # ${coupons}=  Create List  ${cupn_code3}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${p1_qid1}  ${DAY}  ${p1_sid1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${balamount}=  Evaluate  ${Tot1}-${pc_amount}
    ${balamount1}=  Evaluate  ${balamount}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount1}  1
    
    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}
    
    ${resp}=  Make payment Consumer Mock  ${pid}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${p1_sid1}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME185}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['systemNote'][0]}    COUPON_APPLIED

    ${resp}=  ProviderLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Bill By consumer  ${cwid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${DAY2}=  db.add_timezone_date  ${tz}  1

    ${desc}=   FakerLibrary.word
    ${resp}=  Waitlist AdvancePayment Details   ${pid}  ${p1_qid1}  ${DAY2}  ${p1_sid2}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Contain   ${resp.json()['proCouponList']['${cupn_code3}']['systemNote']}   ONLY_WHEN_FITST_CHECKIN

    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${p1_qid1}  ${DAY2}  ${p1_sid2}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid1}  ${wid[0]} 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${cwid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain  ${resp.json()['providerCoupon']['${cupn_code3}']['systemNote']}    ONLY_WHEN_FITST_CHECKIN


JD-TC-ProviderCouponBill-UH7

    [Documentation]   Provider Consumer apply a coupon at Checkin time.but the coupon is for first checkin only

    ${resp}=  Encrypted Provider Login  ${PUSERNAME185}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

# .....cases for provider coupon based on consumer group........

JD-TC-ProviderCouponBill-7
    
    [Documentation]  Taking waitlist from consumer side for a prepayment service and consumer apply provider coupon
    ...   where consumer belongs to the consumer group in which the coupon based on. 
             

    clear_location   ${PUSERNAME140}
    clear_service    ${PUSERNAME140}
    clear_queue      ${PUSERNAME140}
    clear_customer   ${PUSERNAME140}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp1}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        Set Test Variable  ${locId1}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
    END

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    ${Tot1}=  Convert To Number  ${Tot}  1
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${parallel}=   Random Int  min=1   max=1
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${locId1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}  ${resp.json()}

    clear_customer_groups  ${PUSERNAME140}
    
    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${cust ids}=  Create List

    FOR   ${a}  IN RANGE   5

        ${resp}=  AddCustomer  ${CUSERNAME${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Append To List   ${cust ids}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${customers}=  get_customers_from_group  ${groupid}
    Log  ${customers}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${ser_id1}
    ${groups}=   Create list   ${groupid}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}   consumerGroups=${groups}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId1}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  GetCustomer  groups-eq=${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len}  5

    ${i}=  Set Variable  ${0}
    FOR   ${a}  IN RANGE   ${len-1}  0  -1
        
        ${resp1}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Should Be Equal As Strings  ${resp1.json()[0]['id']}  ${cid${i}}

        ${resp}=  Consumer Login  ${CUSERNAME${i}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${consid}=  get_id  ${CUSERNAME${i}}

        ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}  
        ${resp}=  Add To Waitlist Consumers   ${account_id1}  ${que_id1}  ${DAY}  ${ser_id1}  ${msg}  ${bool[0]}  ${self}
        Log  ${resp.json()}
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${account_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

        ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${cwid${a}}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        sleep   2s

        ${balamount}=  Evaluate  ${Tot1}-${min_pre1}
        ${balamount1}=  Convert To Number  ${balamount}  1

        ${resp}=  Get Bill By consumer  ${cwid${a}}  ${account_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid${a}}
        Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
        Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
        Should Be Equal As Strings  ${resp.json()['netRate']}                               ${Tot1}
        Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}

        ${resp}=  Apply Jaldee Coupon At Selfpay  ${cwid${a}}  ${cupn_code}  ${account_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${balamount2}=  Evaluate  ${balamount1}-${pc_amount}
        ${balamount2}=  Convert To Number  ${balamount2}  1
        
        ${balamount3}=  Evaluate  ${Tot1}-${pc_amount}
        ${balamount3}=  Convert To Number  ${balamount3}  1

        ${resp}=  Get Bill By consumer  ${cwid${a}}  ${account_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
        Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
        Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid${a}}
        Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
        Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
        Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
        Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount2}

        ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Bill By UUId  ${cwid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
        Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
        Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid${a}}
        Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
        Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
        Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
        Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount2}
    
        ${i}=  Evaluate  ${i}+1

    END


JD-TC-ProviderCouponBill-8
    
    [Documentation]  Taking waitlist from consumer side for a prepayment service and consumer apply provider coupon
    ...   where consumer who is not belongs to the consumer group in which the coupon based on. 
             

    clear_location   ${PUSERNAME141}
    clear_service    ${PUSERNAME141}
    clear_queue      ${PUSERNAME141}
    clear_customer   ${PUSERNAME141}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp1}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        Set Test Variable  ${locId1}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
    END

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    ${Tot1}=  Convert To Number  ${Tot}  1
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${parallel}=   Random Int  min=1   max=1
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${locId1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}  ${resp.json()}

    clear_customer_groups  ${PUSERNAME141}
    
    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${cust ids}=  Create List

    FOR   ${a}  IN RANGE   5

        ${resp}=  AddCustomer  ${CUSERNAME${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Append To List   ${cust ids}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${customers}=  get_customers_from_group  ${groupid}
    Log  ${customers}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=  Create List  
    ${groups}=   Create list   ${groupid}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}   services=${services}   consumerGroups=${groups}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId1}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  GetCustomer  groups-eq=${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len}  5

    ${i}=  Set Variable  ${0}
    FOR   ${a}  IN RANGE   ${len-1}  0  -1
        
        ${resp1}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Should Be Equal As Strings  ${resp1.json()[0]['id']}  ${cid${i}}

        ${resp}=  Consumer Login  ${CUSERNAME${i}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${consid}=  get_id  ${CUSERNAME${i}}

        ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}  
        ${resp}=  Add To Waitlist Consumers   ${account_id1}  ${que_id1}  ${DAY}  ${ser_id1}  ${msg}  ${bool[0]}  ${self}
        Log  ${resp.json()}
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${cwid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id  ${cwid${a}}  ${account_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

        ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${cwid${a}}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        sleep   2s

        ${balamount}=  Evaluate  ${Tot1}-${min_pre1}
        ${balamount1}=  Convert To Number  ${balamount}  1

        ${resp}=  Get Bill By consumer  ${cwid${a}}  ${account_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid${a}}
        Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
        Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
        Should Be Equal As Strings  ${resp.json()['netRate']}                               ${Tot1}
        Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}

        ${resp}=  Apply Jaldee Coupon At Selfpay  ${cwid${a}}  ${cupn_code}  ${account_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${balamount2}=  Evaluate  ${balamount1}-${pc_amount}
        ${balamount2}=  Convert To Number  ${balamount2}  1
        
        ${balamount3}=  Evaluate  ${Tot1}-${pc_amount}
        ${balamount3}=  Convert To Number  ${balamount3}  1

        ${resp}=  Get Bill By consumer  ${cwid${a}}  ${account_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
        Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
        Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid${a}}
        Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
        Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
        Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
        Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount2}

        ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Bill By UUId  ${cwid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
        Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
        Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid${a}}
        Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
        Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
        Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
        Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount2}
    
        ${i}=  Evaluate  ${i}+1

    END

    ${resp}=  Consumer Login  ${CUSERNAME35}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consid}=  get_id  ${CUSERNAME35}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}  
    ${resp}=  Add To Waitlist Consumers   ${account_id1}  ${que_id1}  ${DAY}  ${ser_id1}  ${msg}  ${bool[0]}  ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${balamount}=  Evaluate  ${Tot1}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount}  1

    ${resp}=  Get Bill By consumer  ${cwid}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${Tot1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${cwid}  ${cupn_code}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-ProviderCouponBill-9
    
    [Documentation]  Taking Appointment from consumer side for a prepayment service and consumer apply provider coupon
    ...   where consumer belongs to the consumer group in which the coupon based on. 
             

    clear_location   ${PUSERNAME142}
    clear_service    ${PUSERNAME142}
    clear_queue      ${PUSERNAME142}
    clear_customer   ${PUSERNAME142}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME142}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp1}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[0]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        Set Test Variable  ${locId1}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    Set Suite variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    Set Suite Variable  ${min_pre1}
    ${Tot1}=  Convert To Number  ${Tot}  1
    Set Suite Variable  ${Tot1}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id1}  ${resp.json()}

    ${min_pre2}=   Random Int   min=50   max=100
    ${service_amount}=   Random Int   min=100   max=500
    ${min_pre2}=  Convert To Number  ${min_pre2}  1
    ${pre_float1}=  twodigitfloat  ${min_pre2}  
    Set Suite Variable  ${min_pre2}
    ${service_amount1}=  Convert To Number  ${service_amount}  1
    Set Suite Variable  ${service_amount1}
    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre2}  ${service_amount}  ${bool[1]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id2}  ${resp.json()}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    Set Suite Variable  ${min_pre1}
    ${Tot1}=  Convert To Number  ${Tot}  1
    Set Suite Variable  ${Tot1}
    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ser_id1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${parallel}=   Random Int  min=1   max=1
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${locId1}  ${ser_id1}   ${ser_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}  ${resp.json()}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${duration}=  FakerLibrary.Random Int  min=1  max=5
    ${bool1}=  Random Element  ${bool}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  15  

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${locId1}  ${duration}  ${bool1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    clear_customer_groups  ${PUSERNAME142}
    
    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${cust ids}=  Create List

    FOR   ${a}  IN RANGE   5

        ${resp}=  AddCustomer  ${CUSERNAME${a}}   
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Append To List   ${cust ids}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${customers}=  get_customers_from_group  ${groupid}
    Log  ${customers}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    Set suite Variable   ${pc_amount}
    ${cupn_code}=   FakerLibrary.word
    Set suite Variable   ${cupn_code}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=  Create List  
    ${groups}=   Create list   ${groupid}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}   services=${services}   consumerGroups=${groups}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId1}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  GetCustomer  groups-eq=${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len}  5

    ${i}=  Set Variable  ${0}
    FOR   ${a}  IN RANGE   ${len-1}  0  -1
        
        ${resp1}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Should Be Equal As Strings  ${resp1.json()[0]['id']}  ${cid${i}}

        ${resp}=  Consumer Login  ${CUSERNAME${i}}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${consid}=  get_id  ${CUSERNAME${i}}

        ${resp}=  Get Appointment Schedules Consumer  ${account_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${account_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${account_id1}
        Log   ${resp.json()} 
        Should Be Equal As Strings    ${resp.status_code}    200
        ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
        @{slots}=  Create List
        FOR   ${x}  IN RANGE   0   ${no_of_slots}
            Run Keyword If  ${resp.json()['availableSlots'][${x}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${x}]['time']}
        END
        ${num_slots}=  Get Length  ${slots}
        ${j}=  Random Int  max=${num_slots-1}
        Set Test Variable   ${slot1}   ${slots[${j}]}

        ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.name
        ${resp}=   Take Appointment For Provider   ${account_id1}  ${ser_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${apptid${a}}  ${apptid[0]}

        ${resp}=  Get consumer Appointment By Id   ${account_id1}   ${apptid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   

        ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${apptid${a}}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        sleep   2s

        ${balamount}=  Evaluate  ${Tot1}-${min_pre1}
        ${balamount1}=  Convert To Number  ${balamount}  1

        ${resp}=  Get Bill By consumer  ${apptid${a}}  ${account_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid${a}}
        Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
        Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
        Should Be Equal As Strings  ${resp.json()['netRate']}                               ${Tot1}
        Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}

        ${resp}=  Apply Jaldee Coupon At Selfpay  ${apptid${a}}  ${cupn_code}  ${account_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${balamount2}=  Evaluate  ${balamount1}-${pc_amount}
        ${balamount2}=  Convert To Number  ${balamount2}  1
        
        ${balamount3}=  Evaluate  ${Tot1}-${pc_amount}
        ${balamount3}=  Convert To Number  ${balamount3}  1

        ${resp}=  Get Bill By consumer  ${apptid${a}}  ${account_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
        Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
        Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid${a}}
        Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
        Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
        Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
        Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount2}

        ${resp}=  Encrypted Provider Login  ${PUSERNAME142}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Bill By UUId  ${apptid${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
        Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
        Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid${a}}
        Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
        Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
        Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
        Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
        Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
        Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount2}
    
        ${i}=  Evaluate  ${i}+1

    END


JD-TC-ProviderCouponBill-10
    
    [Documentation]  Taking Appointment from consumer side for a prepayment service and consumer apply provider coupon
    ...   where consumer who is not belongs to the consumer group in which the coupon based on. 

    ${resp}=  Consumer Login  ${CUSERNAME35}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consid}=  get_id  ${CUSERNAME35}

    ${resp}=  Get Appointment Schedules Consumer  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${account_id1}
    Log   ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${account_id1}  ${ser_id1}  ${sch_id1}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get consumer Appointment By Id   ${account_id1}   ${apptid1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${apptid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${balamount}=  Evaluate  ${Tot1}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount}  1

    ${resp}=  Get Bill By consumer  ${apptid1}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${apptid1}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${Tot1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${apptid1}  ${cupn_code}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-ProviderCouponBill-11
    
    [Documentation]  Taking online check in for a prepayment service (with coupon)
    ...   where consumer belongs to the consumer group in which the coupon based on. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME142}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${groupid1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME39}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}  ${resp.json()}
    
    ${cust_ids1}=   Create List   ${cid4}

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=1

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount1}=   Random Int   min=10  max=50
    ${pc_amount1}=  Convert To Number  ${pc_amount1}  1
    Set suite Variable   ${pc_amount1}
    ${cupn_code1}=   FakerLibrary.word
    Set suite Variable   ${cupn_code1}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=  Create List   ${ser_id1}
    ${groups}=   Create list   ${groupid1}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount1}  ${calctype[1]}  ${cupn_code1}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}   services=${services}   consumerGroups=${groups}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId2}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
  
    ${resp}=  Consumer Login  ${CUSERNAME39}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consid}=  get_id  ${CUSERNAME39}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${coupons}=  Create List  ${cupn_code1}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${account_id1}  ${que_id1}  ${DAY1}  ${ser_id1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid1}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id  ${cwid1}  ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${desc}=   FakerLibrary.word 
    ${resp}=  Waitlist AdvancePayment Details   ${account_id1}  ${que_id1}  ${DAY1}  ${ser_id1}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${cwid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${balamount}=  Evaluate  ${Tot1}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount}  1
    ${balamount3}=  Evaluate  ${Tot1}-${pc_amount1}
    ${balamount3}=  Convert To Number  ${balamount3}  1
    ${balamount2}=  Evaluate  ${balamount1}-${pc_amount1}
    ${balamount2}=  Convert To Number  ${balamount2}  1

    # ${resp}=  Get Bill By consumer  ${cwid1}  ${account_id1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid1}
    # Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    # Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    # Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    # Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    # Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    # Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
    # Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount2}

    ${resp}=  Get Bill By consumer  ${cwid1}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code1}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount1}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid1}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount2}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME142}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${cwid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code1}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount1}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid1}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount2}


    ${resp}=  Consumer Login  ${CUSERNAME35}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consid}=  get_id  ${CUSERNAME35}

    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${coupons}=  Create List  ${cupn_code1}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${account_id1}  ${que_id1}  ${DAY1}  ${ser_id1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${balamount}=  Evaluate  ${Tot1}-${min_pre1}-${pc_amount1}
    ${balamount1}=  Convert To Number  ${balamount}  1

    ${resp}=  Get Bill By consumer  ${cwid}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount1}


JD-TC-ProviderCouponBill-12
    
    [Documentation]  Taking online check in for a prepayment service (with coupon) and tax
    ...   where consumer belongs to the consumer group in which the coupon based on. 

    ${resp}=  Consumer Login  ${CUSERNAME39}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consid}=  get_id  ${CUSERNAME39}
    ${DAY3}=   db.add_timezone_date  ${tz}  1  
    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${coupons}=  Create List  ${cupn_code1}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${account_id1}  ${que_id1}  ${DAY3}  ${ser_id1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid1}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id  ${cwid1}  ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${desc}=   FakerLibrary.word 
    ${resp}=  Waitlist AdvancePayment Details   ${account_id1}  ${que_id1}  ${DAY3}  ${ser_id2}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${taxabletotal}=  Evaluate  ${Tot1}-${pc_amount1}
    ${taxabletotal}=  Convert To Number  ${taxabletotal}  2
    ${tax}=  Evaluate  ${taxabletotal}*${gstpercentage[0]}/100
    ${tax}=  Convert To Number  ${tax}  2
    ${balamount}=  Evaluate  ${taxabletotal}+${tax}
    ${amountdue}=  Evaluate  ${balamount}-${min_pre1}
    ${amountdue}=  Convert To Number  ${amountdue}  2

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${cwid1}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${balamount}=  Evaluate  ${Tot1}-${min_pre1}
    ${balamount1}=  Convert To Number  ${balamount}  1
    ${balamount3}=  Evaluate  ${Tot1}-${pc_amount1}
    ${balamount3}=  Convert To Number  ${balamount3}  1
    ${balamount2}=  Evaluate  ${balamount1}-${pc_amount1}
    ${balamount2}=  Convert To Number  ${balamount2}  1

    ${resp}=  Get Bill By consumer  ${cwid1}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code1}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount1}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid1}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount3}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             ${balamount2}


JD-TC-ProviderCouponBill-13
    
    [Documentation]  Taking online check in with prepayment and provider coupon amount as the service amount
    ...   then verify the bill.

    clear_location   ${PUSERNAME150}
    clear_service    ${PUSERNAME150}
    clear_queue      ${PUSERNAME150}
    clear_customer   ${PUSERNAME150}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp1}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        Set Test Variable  ${locId1}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
    END

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Tot}=   Random Int   min=100   max=500
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    ${Tot1}=  Convert To Number  ${Tot}  1
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${parallel}=   Random Int  min=1   max=1
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${locId1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}  ${resp.json()}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Evaluate   ${Tot1}-${min_pre1}
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${ser_id1}
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId1}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consid}=  get_id  ${CUSERNAME10}
    
    ${DAY3}=   db.add_timezone_date  ${tz}  1  
    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${coupons}=  Create List  ${cupn_code}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${account_id1}  ${que_id1}  ${DAY3}  ${ser_id1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${balamount}=  Evaluate  ${Tot1}-${pc_amount}
    ${balamount1}=  Convert To Number  ${balamount}  1

    ${resp}=  Get Bill By consumer  ${cwid}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount1}
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                       ${balamount1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}                     ${paymentStatus[2]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             0.0
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                       ${balamount1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}                     ${paymentStatus[2]}


JD-TC-ProviderCouponBill-14
    
    [Documentation]  Taking online check in with prepayment and coupon amount as the service amount
    ...  then cancel the waitlist by consumer and check refund.

    clear_location   ${PUSERNAME151}
    clear_service    ${PUSERNAME151}
    clear_queue      ${PUSERNAME151}
    clear_customer   ${PUSERNAME151}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['onlinePayment']}==${bool[0]}
        ${resp1}=    Enable Disable Online Payment   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        Set Test Variable  ${locId1}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
    END

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    
    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Tot}=   Random Int   min=100   max=500
    ${pre_float1}=  twodigitfloat  ${min_pre1}  
    ${Tot1}=  Convert To Number  ${Tot}  1
    ${P1SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence

    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${parallel}=   Random Int  min=1   max=1
    ${sTime}=  add_timezone_time  ${tz}  2  00  
    ${eTime}=  add_timezone_time  ${tz}  2  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${locId1}  ${ser_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}  ${resp.json()}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Evaluate   ${Tot1}-${min_pre1}
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${ser_id1}
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId1}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${couponId1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${consid}=  get_id  ${CUSERNAME10}
    
    ${DAY3}=   db.add_timezone_date  ${tz}  1  
    ${msg}=  Fakerlibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${coupons}=  Create List  ${cupn_code}  
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${account_id1}  ${que_id1}  ${DAY3}  ${ser_id1}  ${msg}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]} 

    ${resp}=  Get consumer Waitlist By Id  ${cwid}  ${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${account_id1}  ${min_pre1}  ${purpose[0]}  ${cwid}  ${ser_id1}  ${bool[0]}   ${bool[1]}  ${consid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s

    ${balamount}=  Evaluate  ${Tot1}-${pc_amount}
    ${balamount1}=  Convert To Number  ${balamount}  1

    ${resp}=  Get Bill By consumer  ${cwid}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['couponCode']}        ${cupn_code}
    Should Be Equal As Strings  ${resp.json()['proCouponList'][0]['value']}             ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                  ${cwid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}                            ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}               ${ser_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}                   ${Tot1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}             ${P1SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}                1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${Tot1}
    Should Be Equal As Strings  ${resp.json()['netRate']}                               ${balamount1}
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}                       ${balamount1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}                             0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}                     ${paymentStatus[2]}

    sleep   2s
    ${resp}=   Cancel Waitlist  ${cwid}  ${account_id1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Bill By consumer  ${cwid}  ${account_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

