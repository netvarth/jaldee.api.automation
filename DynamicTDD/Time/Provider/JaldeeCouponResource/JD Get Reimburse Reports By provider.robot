*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Reports
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

***Variables***

${start}  200
${start1}  220

${SERVICE1}  QWERTY1
${SERVICE2}  QWERTY2
${SERVICE3}  QWERTY3
${SERVICE4}  QWERTY4
${SERVICE1P}  QWERTY5
${SERVICE2P}  QWERTY6
${queue1}  morning
${LsTime}   08:00 AM
${LeTime}   09:00 AM

${sTime}    10:00 AM
${eTime}    11:55 PM
${sTime1}    11:00 AM
${eTime1}    12:55 PM

${longi}        89.524764
${latti}        86.524764
${numbers}  0123456789

${self}   0

*** Test Cases ***

JD-TC-GetReimburseReports-1

    [Documentation]  coupon settl jccoupon applied bill and generate invoice report

    # clear_reimburseReport  
    # ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    # ${len}=   Split to lines  ${resp}
    # ${length}=  Get Length    ${len}    
    # FOR   ${a}  IN RANGE   ${start}    ${length}    

    #     clear_service       ${PUSERNAME134}
    #     ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    #     Log   ${resp.json()}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     ${domain}=   Set Variable    ${resp.json()['sector']}
    #     ${subdomain}=    Set Variable      ${resp.json()['subSector']}
    #     ${resp}=  View Waitlist Settings
    #     Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
    #      ${resp}=   Get jaldeeIntegration Settings
    #     Log   ${resp.json()}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    #     ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    #     Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    #     Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    #     ${resp}=   Get jaldeeIntegration Settings
    #     Log   ${resp.json()}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Set Suite Variable   ${a}    
    #     ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
    #     Should Be Equal As Strings    ${resp.status_code}    200
    #     Run Keyword If   '${resp2.json()['serviceBillable']}' == '${bool[1]}'   Exit For Loop        

    # END
    # clear_reimburseReport
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_location   ${PUSERNAME134}
    clear_service    ${PUSERNAME134}
    clear_queue     ${PUSERNAME134}
    clear_customer   ${PUSERNAME134}
    clear_payment_invoice  ${PUSERNAME134}

    Set Suite Variable   ${d1}    ${resp.json()['sector']}
    Set Suite Variable   ${sd1}    ${resp.json()['subSector']}

    ${pid}=  get_acc_id  ${PUSERNAME134}
    Set Suite Variable   ${pid}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains   ALL 
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ALL

    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code2018}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code2018}
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}

    clear_jaldeecoupon  ${cupn_code2018}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${cid}=  get_id  ${CUSERNAME5}
    # Set Suite Variable  ${cid}

    ${lid}=   Create Sample Location
    Log   ${lid}
    Set Suite Variable    ${lid} 
    
    ${ser_desc}=   FakerLibrary.word
    Set Suite Variable   ${ser_desc}
    
    ${ser_duratn}=      Random Int   min=10   max=30
    Set Suite Variable   ${ser_duratn}
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  1000  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  1000  ${bool[0]}  ${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE3}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  1000  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id3}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE4}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  1000  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id4}  ${resp.json()}
    
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   db.subtract_timezone_time  ${tz}  2  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}       1  45 
    Set Suite Variable    ${end_time} 
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    Set Suite Variable   ${parallel}
    Set Suite Variable   ${capacity}  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${s_id1}  ${s_id2}   ${s_id3}  ${s_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${cnote}=   FakerLibrary.word
    Set Suite Variable  ${cnote}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=1180.0  billPaymentStatus=${paymentStatus[0]}  amountDue=1180.0
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code2018}  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${amount}  ${resp.json()['amountDue']}
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=1130.0  billPaymentStatus=${paymentStatus[0]}  amountDue=1130.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  ${amount}  
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${amount}  

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0  
    ${resp}=  Get Reimburse Reports By Provider
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_code2018}":50.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}      

JD-TC-GetReimburseReports-2

    [Documentation]  Consumer apply a coupon at Checkin time  and GetReimburseReports

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    clear_customer   ${PUSERNAME134}
    clear_payment_invoice  ${PUSERNAME134} 
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Suite Variable   ${d1}    ${resp.json()['sector']}
    Set Suite Variable   ${sd1}    ${resp.json()['subSector']}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ALL 
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL

    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2} 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code01}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code01}
    ${cupn_name1}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name1}

    clear_jaldeecoupon  ${cupn_code01}
    ${resp}=  Create Jaldee Coupon  ${cupn_code01}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  100  100  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code02}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code02}
    ${cupn_name2}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name2}
    
    clear_jaldeecoupon   ${cupn_code02}
    ${resp}=  Create Jaldee Coupon  ${cupn_code02}  ${cupn_name2}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  100  100  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Push Jaldee Coupon  ${cupn_code01}  ${cupn_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code02}  ${cupn_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code01}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code01}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code02}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code02}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${pid4}=  get_acc_id  ${PUSERNAME134}
    Log   ${pid4}
    Set Suite Variable  ${pid4}
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${cupn_code01}  ${cupn_code02}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid4}  ${qid1}  ${DAY1}  ${s_id3}  ${cupn_des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid_4}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid_4}  ${wid_4[0]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid_4}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid_4}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=900.0  billPaymentStatus=${paymentStatus[0]}  amountDue=900.0
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code01}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code01}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code02}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code02}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
  
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${cid1}=  get_id  ${CUSERNAME5}

    ${resp}=  Make payment Consumer Mock  ${pid4}  900  ${purpose[1]}  ${wid_4}  ${s_id3}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    ${resp}=  Get consumer Waitlist By Id  ${wid_4}  ${pid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=  Get Bill By Consumer  ${wid_4}  ${pid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code01}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code01}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code02}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code02}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid_4}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  1000.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  900.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Settl Bill  ${wid_4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid_4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid_4}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 

    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid4}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  100.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  100.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}

    Variable Should Exist   ${resp.json()}    "${cupn_code01}":50.0
    Variable Should Exist   ${resp.json()}    "${cupn_code02}":50.0
  

JD-TC-GetReimburseReports-3

    [Documentation]  Consumer apply a coupon at Checkin time when that coupon has the rule of Combine With OtherCoupons is ${bool[0]} and GetReimburseReports
    
   
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Suite Variable   ${d1}    ${resp.json()['sector']}
    Set Suite Variable   ${sd1}    ${resp.json()['subSector']}

    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL

    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code03}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code03}
    clear_jaldeecoupon  ${cupn_code03}
    ${resp}=  Create Jaldee Coupon  ${cupn_code03}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  20  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code03}  ${cupn_des}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code03}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code03}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME6} 

    ${pid5}=  get_acc_id  ${PUSERNAME134}
    Log   ${pid5}   
    ${coupons}=  Create List  ${cupn_code2018}  ${cupn_code01}  ${cupn_code03}
    Log   ${coupons}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid5}  ${qid1}  ${DAY1}  ${s_id3}  ${cnote}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${cupn_code03} Cannot be combined with any other coupons"

    # ${coupons}=  Create List  ${cupn_code2018}  ${cupn_code2018}
    # ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid5}  ${qid1}  ${DAY1}  ${s_id3}  ${cnote}  ${bool[0]}  ${coupons}  ${self}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Log  ${resp.json()} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote'][1]}  NO_OTHER_COUPONS_ALLOWED
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code01}']['value']}  0.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code01}']['systemNote'][0]}  CANT_COMBINE_WITH_OTHER_COUPONES

    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=950.0  billPaymentStatus=${paymentStatus[0]}  amountDue=950.0
    Should Be Equal As Strings    ${resp.json()['service'][0]['serviceId']}  ${s_id3} 
    Should Be Equal As Strings    ${resp.json()['service'][0]['price']}   1000.0 
    Should Be Equal As Strings    ${resp.json()['service'][0]['serviceName']}   ${SERVICE3} 
    Should Be Equal As Strings    ${resp.json()['service'][0]['quantity']}   1.0   

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0
   
     
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code01}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0
   
    
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0
    
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code03}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  400  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Make payment Consumer Mock  400  ${bool[0]}  ${wid}  ${pid5}  ${purpose[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Make payment Consumer Mock  ${pid5}  950  ${purpose[1]}  ${wid}  ${s_id3}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=  Get Bill By Consumer  ${wid}  ${pid5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  ${SystemNote[2]} 
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  1000.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  950.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 

    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid5}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    # Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_code2018}":50.0} 
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}

    Variable Should Exist   ${resp.json()}    "${cupn_code2018}":50.0


JD-TC-GetReimburseReports-4

    [Documentation]  Consumer apply a coupon at Checkin time when that coupon has discount type as PERCENTAGE and GetReimburseReports
    
    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL

    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code04}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code04}
    clear_jaldeecoupon   ${cupn_code04}
    ${resp}=  Create Jaldee Coupon  ${cupn_code04}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code04}  ${cupn_des}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code04}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code04}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${cid}=  get_id  ${CUSERNAME7}    
    ${coupons}=  Create List  ${cupn_code04}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id4}  ${cnote}  ${bool[0]}  ${coupons}  ${self}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=1130.0  billPaymentStatus=${paymentStatus[0]}  amountDue=1130.0  billPaymentStatus=${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code04}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code04}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code04}']['systemNote'][1]}  ${SystemNote[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  1130  
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

     
    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Make payment Consumer Mock  ${pid}  1130  ${purpose[1]}  ${wid}  ${s_id4}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s

    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=1130.0  billPaymentStatus=${paymentStatus[0]}  amountDue=0.0  billPaymentStatus=${paymentStatus[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code04}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code04}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code04}']['systemNote'][1]}  ${SystemNote[1]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    
    sleep  2s
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_code04}":50.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}

JD-TC-GetReimburseReports-5

    [Documentation]  Consumer apply a coupon at Checkin time when that coupon as defaultly ${couponState[1]} and GetReimburseReports
    
    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2} 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code05}=   FakerLibrary.first_name
    Set Suite Variable   ${cupn_code05}
    clear_jaldeecoupon  ${cupn_code05}
    ${resp}=  Create Jaldee Coupon  ${cupn_code05}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[1]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code05}  ${cupn_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code05}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    

    ${coupons}=  Create List  ${cupn_code05}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id4}  ${cnote}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=1130.0  billPaymentStatus=${paymentStatus[0]}  amountDue=1130.0  billPaymentStatus=${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code05}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code05}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code05}']['systemNote'][1]}  ${SystemNote[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0   

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code05}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  1130 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Make payment Consumer Mock  540  ${bool[0]}  ${wid}  ${pid}  ${purpose[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  1130  ${purpose[1]}  ${wid}  ${s_id4}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=1130.0  billPaymentStatus=${paymentStatus[2]}  amountDue=0.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code05}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code05}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code05}']['systemNote'][1]}  ${SystemNote[1]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 

    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_code05}":50.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}

JD-TC-GetReimburseReports-6
    [Documentation]  Consumer apply a coupon at Checkin time when that coupon as always enabled and GetReimburseReports
    
    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ${licenses}=  Jaldee Coupon Target License  ${lic1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code07}=   FakerLibrary.last_name
    Set Suite Variable   ${cupn_code07}
    clear_jaldeecoupon  ${cupn_code07}
    ${resp}=  Create Jaldee Coupon  ${cupn_code07}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[1]}  ${bool[1]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_code07}  ${cupn_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code07}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME8}    

    ${coupons}=  Create List  ${cupn_code07}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id4}  ${cnote}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=1130.0  billPaymentStatus=${paymentStatus[0]}  amountDue=1130.0  billPaymentStatus=${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code07}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code07}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code07}']['systemNote'][1]}  ${SystemNote[1]}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
  
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code07}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  1130 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Make payment Consumer Mock  540  ${bool[0]}  ${wid}  ${pid}  ${purpose[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Make payment Consumer Mock  ${pid}  1130  ${purpose[1]}  ${wid}  ${s_id4}  ${bool[0]}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code07}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code07}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code07}']['systemNote'][1]}  ${SystemNote[1]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  1000.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  1130.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]}
    
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    sleep  2s
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_code07}":50.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}

JD-TC-GetReimburseReports-UH1
    [Documentation]  Consumer apply a coupon at Checkin time.but minBillAmount is not satisfied and GetReimburseReports
    
    ${domains}=  Jaldee Coupon Target Domains  ALL
    
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
   
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code2018}=   FakerLibrary.first_name
    Set Suite Variable    ${cupn_code2018}
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}
    clear_jaldeecoupon  ${cupn_code2018}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}   
  
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id4}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code2018}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  409
    Should Be Equal As Strings  "${resp.json()}"  "${JALDEE_COUPON_MINIMUM_BILL_AMT_REQUIRED}"   
    
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  0.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

JD-TC-GetReimburseReports-UH2
    [Documentation]  Consumer apply a coupon at Checkin time.but maxConsumerUseLimit is over and GetReimburseReports
    
    # clear_waitlist  ${PUSERNAME134}
    
    # ${resp}=  Get BusinessDomainsConf
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    # Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    # Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    # Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    # Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    # Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    
    ${domains}=  Jaldee Coupon Target Domains  ALL
    
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${coupon10}=   FakerLibrary.word
    Set Suite Variable    ${coupon10}
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}
    clear_jaldeecoupon  ${coupon10}
    
    ${resp}=  Create Jaldee Coupon  ${coupon10}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Push Jaldee Coupon  ${coupon10}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${coupon10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cid}=  get_id  ${CUSERNAME5}    
    ${coupons}=  Create List  ${coupon10}
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id4}  ${cupn_des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=540.0  billPaymentStatus=${paymentStatus[0]}  amountDue=540.0  billPaymentStatus=${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${coupon10}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${coupon10}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${coupon10}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 
  
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id2}  ${cupn_des}  ${bool[0]}  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${coupon10} ${JALDEE_COUPON_EXCEEDS_APPLY_LIMIT}"

JD-TC-GetReimburseReports-UH3
    [Documentation]  GetReimburseReports of not settiled bill
    
    # clear_waitlist  ${PUSERNAME134}
    
    # ${resp}=  Get BusinessDomainsConf
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    # Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    # Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    # Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    # Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    # Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    
    ${domains}=  Jaldee Coupon Target Domains  ALL
    
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${coupon13}=   FakerLibrary.word
    Set Suite Variable    ${coupon13}
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}
    clear_jaldeecoupon  ${coupon13}
    
    ${resp}=  Create Jaldee Coupon  ${coupon13}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Push Jaldee Coupon  ${coupon13}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${coupon13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    
    ${cid}=  get_id  ${CUSERNAME1}    
    ${coupons}=  Create List  ${coupon13}
    
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid1}  ${DAY1}  ${s_id4}  ${cupn_des}  ${bool[0]}  ${coupons}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=540.0  billPaymentStatus=${paymentStatus[0]}  amountDue=540.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${coupon13}']['value']}  50.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${coupon13}']['systemNote'][0]}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
   
    
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    
JD-TC-GetReimburseReports-7
    [Documentation]  1st wl using jc , create and settle bill 
    ...  2nd wl  using jc and pay online 
    ...  generate invoice 
    
    Run Keywords  clear_queue  ${PUSERNAME}  AND  clear_payment_invoice  ${PUSERNAME}    AND  clear_waitlist  ${PUSERNAME}   AND  clear_payment_invoice  ${PUSERNAME}   AND  clear_service  ${PUSERNAME}   AND  clear_location  ${PUSERNAME}      
    Run Keywords  clear_queue  ${PUSERNAME134}  AND  clear_payment_invoice  ${PUSERNAME134}   AND  clear_waitlist  ${PUSERNAME134}   AND  clear_payment_invoice  ${PUSERNAME134}   AND  clear_service  ${PUSERNAME134}   AND  clear_location  ${PUSERNAME134}              
    

    
    ${resp}=  Get BusinessDomainsConf 
    Set Suite Variable  ${SERVICE1}   ABCDEFGH1
    Set Suite Variable  ${SERVICE2}   ABCDEFGH2
    
    # clear_jaldeecoupon  ${cupn_codeLMTONI108}    
    # ${resp}=  Get BusinessDomainsConf
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    # Set Test Variable  ${sd2}  ${resp.json()[1]['subDomains'][0]['subDomain']}  
    # Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    # Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ALL
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ALL
    ProviderLogout
    ${licenses}=  Jaldee Coupon Target License  1  2  3  4  5  6 
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_jaldeecoupon  ${cupn_codeVINIESTA68} 
    ${cupn_codeVINIESTA68}=    FakerLibrary.sentence
    Set Suite Variable     ${cupn_codeVINIESTA68}
    clear_jaldeecoupon  ${cupn_codeVINIESTA68} 
    ${resp}=  Create Jaldee Coupon  ${cupn_codeVINIESTA68}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_codeVINIESTA68}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_codeLMTONI108}=    FakerLibrary.sentence
    Set Suite Variable   ${cupn_codeLMTONI108}
    clear_jaldeecoupon  ${cupn_codeLMTONI108}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeLMTONI108}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Push Jaldee Coupon  ${cupn_codeLMTONI108}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME}
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid} 
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}   
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${sId1_P}  ${sId2_P}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1_P}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sId1_P}  ${qid1_P}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId1_P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  560.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  560.0

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeVINIESTA68}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['couponState']}  ${billStatus[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeVINIESTA68}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeVINIESTA68}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeVINIESTA68}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=485.0  billPaymentStatus=${paymentStatus[0]}  amountDue=485.0  billPaymentStatus=${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeVINIESTA68}']['value']}  75.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeVINIESTA68}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeVINIESTA68}']['systemNote']}  ${SystemNote[2]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId1_P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  485.0 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  485.0

    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]}
    ProviderLogout



    Comment  second provider using jc and payment online 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${gstper}=  Random Element  ${gstpercentage}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME134}
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid} 
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_id1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  560.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  560.0
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeLMTONI108}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeLMTONI108}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeLMTONI108}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeLMTONI108}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=495.0  billPaymentStatus=${paymentStatus[0]}  amountDue=495.0  
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['value']}  65.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  495.0   
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Make payment Consumer Mock  495.0  ${bool[0]}  ${wid}  ${pid}  ${purpose[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['value']}  65.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  495.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]}    

    Comment  check Reimburse Reports
    sleep  2s
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_codeLMTONI108}":65.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  65.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  65.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME}
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}   {"${cupn_codeVINIESTA68}":75.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  75.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  75.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}

JD-TC-GetReimburseReports-8
    [Documentation]  3provider 2wl for each diffrent coupon for ech provider     
    
    Run Keywords  clear_queue  ${PUSERNAME}  AND  clear_payment_invoice  ${PUSERNAME}    AND  clear_waitlist  ${PUSERNAME}   AND  clear_payment_invoice  ${PUSERNAME}   AND  clear_location  ${PUSERNAME}     
    Run Keywords  clear_queue  ${PUSERNAME134}  AND  clear_payment_invoice  ${PUSERNAME134}   AND  clear_waitlist  ${PUSERNAME134}   AND  clear_payment_invoice  ${PUSERNAME134}   AND  clear_location  ${PUSERNAME134}
    Run Keywords  clear_queue  ${PUSERNAME134}  AND  clear_payment_invoice  ${PUSERNAME134}   AND  clear_waitlist  ${PUSERNAME134}   AND  clear_payment_invoice  ${PUSERNAME134}   AND  clear_location  ${PUSERNAME134}    AND  clear_jaldeecoupon  MALDININESTA510              
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd2}  ${resp.json()[1]['subDomains'][0]['subDomain']}  
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${d3}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Suite Variable  ${SERVICE1}   ABCDE
    Set Suite Variable  ${SERVICE2}   ABCDE1
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}  ${d3}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d2}_${sd2}  ${d3}_${sd3}
    ProviderLogout
    ${licenses}=  Jaldee Coupon Target License  1  2  3  4  5  6 
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_codeLMTONI108}=    FakerLibrary.sentence
    Set Suite Variable   ${cupn_codeLMTONI108}

    ${cupn_codeVINIESTA68}=    FakerLibrary.sentence
    Set Suite Variable     ${cupn_codeVINIESTA68}

    ${cupn_codeMALDININESTA510}=    FakerLibrary.sentence
    Set Suite Variable   ${cupn_codeMALDININESTA510}

    ${resp}=  Get BusinessDomainsConf 
    Set Suite Variable  ${SERVICE1}   ABCDEFGH1
    Set Suite Variable  ${SERVICE2}   ABCDEFGH2
    clear_jaldeecoupon  ${cupn_codeVINIESTA68} 
    clear_jaldeecoupon  ${cupn_codeLMTONI108}
    clear_jaldeecoupon  ${cupn_codeMALDININESTA510}


    ${resp}=  Create Jaldee Coupon  ${cupn_codeVINIESTA68}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeVINIESTA68}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Jaldee Coupon  ${cupn_codeLMTONI108}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeLMTONI108}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Jaldee Coupon  ${cupn_codeMALDININESTA510}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeMALDININESTA510}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME}
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    # ${city}=   get_place
    # Set Suite Variable  ${city}
    # ${latti}=  get_latitude
    # Set Suite Variable  ${latti}
    # ${longi}=  get_longitude
    # Set Suite Variable  ${longi}
    # ${postcode}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode}
    # ${address}=  get_address
    # Set Suite Variable  ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    Set Suite Variable   ${eTime}

    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid}   
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  free  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid}  ${resp.json()}   
    ${description}=  FakerLibrary.sentence
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${notify}    Random Element     ['True','False'] 
    ${resp}=  Create Service  ${SERVICE1}  ${description}   2  ACTIVE  Waitlist  ${bool[1]}  email  50  500  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}     
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${sId1_P}  ${sId2_P}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1_P}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sId1_P}  ${qid1_P}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId1_P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  560.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  560.0

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeVINIESTA68}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${billStatus[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeVINIESTA68}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeVINIESTA68}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeVINIESTA68}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=485.0  billPaymentStatus=${paymentStatus[0]}  amountDue=485.0  billPaymentStatus=${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeVINIESTA68}']['value']}  75.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeVINIESTA68}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeVINIESTA68}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId1_P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  485.0  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  485.0
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]}

    comment  second waitlist 
    ${resp}=  Add To Waitlist  ${cid}  ${sId2_P}  ${qid1_P}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId2_P} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  560.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  560.0

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeLMTONI108}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${billStatus[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeLMTONI108}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeLMTONI108}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeLMTONI108}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=495.0  billPaymentStatus=${paymentStatus[0]}  amountDue=495.0  billPaymentStatus=${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['value']}  65.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId2_P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  495.0   
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  495.0
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]}
    ProviderLogout

    Comment  second provider using jc and payment online 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${pid}=  get_acc_id  ${PUSERNAME134}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid} 
    ${gstper}=  Random Element  ${gstpercentage}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}     
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_id1}  ${s_id2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}

   

    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  560.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  560.0
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeLMTONI108}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeLMTONI108}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeLMTONI108}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeLMTONI108}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=495.0  billPaymentStatus=${paymentStatus[0]}  amountDue=495.0  billPaymentStatus=${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['value']}  65.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  495.0  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    # ${resp}=  Make payment Consumer Mock  495  ${bool[0]}  ${wid}  ${pid}  ${purpose[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['value']}  65.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeLMTONI108}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  495.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 

    Comment  second waitlist  provider2


    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  560.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  560.0

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeMALDININESTA510}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeMALDININESTA510}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeMALDININESTA510}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeMALDININESTA510}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=505.0  billPaymentStatus=${paymentStatus[0]}  amountDue=505.0  billPaymentStatus=${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeMALDININESTA510}']['value']}  55.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeMALDININESTA510}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeMALDININESTA510}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  505 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${pid}=  get_acc_id  ${PUSERNAME134}
   
    # ${resp}=  Make payment Consumer Mock  505  ${bool[0]}  ${wid}  ${pid}  ${purpose[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=505.0  billPaymentStatus=${paymentStatus[2]}  amountDue=0.0  
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeMALDININESTA510}']['value']}  55.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeMALDININESTA510}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 
    ${resp}=  ProviderLogout


    Comment  3rd provider


    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${gstper}=  Random Element  ${gstpercentage}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME134}
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid} 

    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}  
    
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${sId1_P}  ${sId2_P}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1_P}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sId1_P}  ${qid1_P}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId1_P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  560.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  560.0

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeVINIESTA68}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${billStatus[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeVINIESTA68}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeVINIESTA68}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeVINIESTA68}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=485.0  billPaymentStatus=${paymentStatus[0]}  amountDue=485.0  billPaymentStatus=${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeVINIESTA68}']['value']}  75.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeVINIESTA68}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeVINIESTA68}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId1_P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  485  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  485.0
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]}


    Comment  2nd waitlist provider 3


    ${resp}=  Add To Waitlist  ${cid}  ${sId2_P}  ${qid1_P}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId2_P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  560.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  560.0

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeMALDININESTA510}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${billStatus[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeMALDININESTA510}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeMALDININESTA510}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeMALDININESTA510}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=505.0  billPaymentStatus=${paymentStatus[0]}  amountDue=505.0  billPaymentStatus=${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeMALDININESTA510}']['value']}  55.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeMALDININESTA510}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_codeMALDININESTA510}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId2_P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  505  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  505.0
    

    comment  check Reimburse Reports
    sleep  2s
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_codeVINIESTA68}":75.0}  
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  75.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  75.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=   Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME}
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_codeLMTONI108}":65.0,"${cupn_codeVINIESTA68}":75.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  140.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  140.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME134}
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_codeLMTONI108}":65.0,"${cupn_codeMALDININESTA510}":55.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  120.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  120.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}
    


JD-TC-GetReimburseReports-9
    [Documentation]  payment without coupon
    Run Keywords  clear_queue  ${PUSERNAME134}  AND  clear_payment_invoice  ${PUSERNAME134}   AND  clear_waitlist  ${PUSERNAME134}   AND  clear_payment_invoice  ${PUSERNAME134}   AND  clear_location  ${PUSERNAME134}    AND  clear_jaldeecoupon  ${cupn_codeLMTONI108}    AND  clear_service  ${PUSERNAME134}          
    # clear_reimburseReport
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${pid}=  get_acc_id  ${PUSERNAME134}
    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${list}=  Create List   1  2  3  4  5  6  7
    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid} 
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${sId1_P}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Add To Waitlist  ${cid}  ${sId1_P}  ${qid1}  ${DAY1}  ${cnote}  ${bool[0]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=590.0  billPaymentStatus=${paymentStatus[0]}  amountDue=590.0  billPaymentStatus=${paymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId1_P}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  590.0  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Make payment Consumer  590.0  ${payment_modes[2]}  ${wid}  ${pid}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Make payment Consumer Mock  590.0  ${bool[0]}  ${wid}  ${pid}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=590.0  billPaymentStatus=${paymentStatus[2]}  amountDue=0.0  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId1_P} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1P}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]}    

    Comment  check Reimburse Reports

    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}   

    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME134}
    ${resp}=  Get Reimburse Reports By Provider
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
  
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  560.5
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  560.5
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}  
    
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jBankTotal']}  590.0
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['gatewayCommission']}  11.8 
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['jaldeeCommission']}  17.7
    Should Be Equal As Strings  ${resp.json()[0]['jPaymentDetails']['settlementAmount']}  560.5
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    

JD-TC-GetReimburseReports-10
    [Documentation]  payment without coupon
    # clear_reimburseReport
    Run Keywords  clear_queue  ${PUSERNAME134}  AND  clear_payment_invoice  ${PUSERNAME134}   AND  clear_waitlist  ${PUSERNAME134}   AND  clear_payment_invoice  ${PUSERNAME134}   AND  clear_location  ${PUSERNAME134}    AND  clear_jaldeecoupon  ${cupn_codeLMTONI108}              
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid}=  get_id  ${CUSERNAME5} 
    Set Suite Variable  ${cid}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid}  
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]} 

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=590.0  billPaymentStatus=${paymentStatus[0]}  amountDue=590.0  billPaymentStatus=${paymentStatus[0]}  
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Make payment Consumer  590  ${payment_modes[2]}  ${wid}  ${pid}  ${purpose[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Contain  ${resp.json()['response']}  me\":\"name\",\"description\":\"description\",\"value\":590.0,\"merchantId\":\"${merchantid}\",\"commission\":0.0}]} 
    Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL5} /></td>
    Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME5} ></td>
    ${resp}=  Make payment Consumer Mock  590  ${bool[0]}  ${wid}  ${pid}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 

    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=590.0  billPaymentStatus=${paymentStatus[0]}  amountDue=0.0  billPaymentStatus=${paymentStatus[2]}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['amountDue']}  0.0  

    ${service}=  Service Bill  service forme  ${s_id2}  1 
    ${resp}=  Update Bill   ${wid}  addService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0 

    Comment  check Reimburse Reports
    sleep  2s
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []

JD-TC-GetReimburseReports-11

    clear_service  ${PUSERNAME134}
   
    # clear_reimburseReport
    Run Keywords   clear_queue  ${PUSERNAME134}  AND  clear_payment_invoice  ${PUSERNAME134}  AND  clear_waitlist  ${PUSERNAME134}  AND  clear_payment_invoice  ${PUSERNAME134}    
    clear_service  ${PUSERNAME134}    
    clear_location  ${PUSERNAME134}     
    clear_jaldeecoupon  ${cupn_codeAADI1}



    ${pid}=  get_acc_id  ${PUSERNAME134} 
  
           
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    
    Should Be Equal As Strings    ${resp.status_code}   200


  
    Set Suite Variable   @{licenses}   ${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
 
 
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
   
    Set Suite Variable   ${domain}   ${resp.json()['serviceSector']['domain']}
    Set Suite Variable   ${subdomain}   ${resp.json()['serviceSubSector']['subDomain']}
   
  
    ${domains}=  Jaldee Coupon Target Domains  ${domain}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${domain}_${sub_domain}
 
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
   
    Set Suite Variable  ${DAY2}  ${DAY2}
    ProviderLogout

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_codeAADI1}=   FakerLibrary.sentence
    Set Suite Variable   ${cupn_codeAADI1}
    
    clear_jaldeecoupon  ${cupn_codeAADI1}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeAADI1}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeAADI1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200


    ${pid}=  get_acc_id  ${PUSERNAME134} 
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid} 


    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  100  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}  


    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_idd}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${qid1}  ${resp.json()}




    ${resp}=  Add To Waitlist  ${cid}  ${s_idd}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    


    

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Consumer Login   ${CUSERNAME}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${cid}=  get_id  ${CUSERNAME} 

    ${resp}=  Add To Waitlist Consumers  ${pid}   ${qid1}   ${DAY1}   ${s_idd}   ${cnote}   ${bool[0]}   ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    
    

    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}  
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200


    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_idd}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  100.0


    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeAADI1}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_idd}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  100.0
   # Should Be Equal As Strings  ${resp.json()['netRate']}  0.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeAADI1}']['value']}  100.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeAADI1}']['systemNote']}  [u'COUPON_APPLIED']
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}   ${paymentStatus[0]} 
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}  0.0
   # Should Be Equal As Strings  ${resp.json()['amountDue']}  0.0

   

   ${resp}=  Settl Bill  ${wid} 
   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]}

    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Reimburse Reports By Provider
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  100.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  100.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_codeAADI1}":100.0}
    