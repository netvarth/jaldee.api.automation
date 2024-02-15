*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Reimbursement
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
${self}  0


*** Test Cases ***
JD-TC-GetReimburseReports-1
    [Documentation]  coupon settl jccoupon applied bill and generate invoice report
      
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length    ${len}    
    FOR   ${a}  IN RANGE   ${start}    ${length}    

        clear_service       ${PUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable   ${domain}    ${decrypted_data['sector']}
        Set Test Variable   ${subdomain}    ${decrypted_data['subSector']}
        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=  View Waitlist Settings
        Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
        Set Suite Variable   ${a}    
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Run Keyword If   '${resp2.json()['serviceBillable']}' == '${bool[1]}'   Exit For Loop        

    END
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable   ${d1}    ${decrypted_data['sector']}
    Set Suite Variable   ${sd1}    ${decrypted_data['subSector']}
    # Set Suite Variable   ${d1}    ${resp.json()['sector']}
    # Set Suite Variable   ${sd1}    ${resp.json()['subSector']}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${pid}=  get_acc_id  ${PUSERNAME${a}}     
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains   ${d1}    
    ${sub_domains}=  Jaldee Coupon Target SubDomains   ${d1}_${sd1}
    ProviderLogout

    # ${loc1}=  Jaldee Coupon Target Locations  ${longi}  ${latti}  5
    # ${loc2}=  Jaldee Coupon Target Locations  ${longi1}  ${latti1}  2
    # ${locations}=  Create List  ${loc1}  ${loc2}

    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code20181}=   FakerLibrary.word
    Set Suite Variable    ${cupn_code20181}
    ${cupn_name}=    FakerLibrary.name
    Set Suite Variable   ${cupn_name}
    ${cupn_des}=   FakerLibrary.sentence
    Set Suite Variable     ${cupn_des}
    ${c_des}=   FakerLibrary.sentence
    Set Suite Variable     ${c_des}
    ${p_des}=    FakerLibrary.sentence
    Set Suite Variable     ${p_des}
    clear_jaldeecoupon  ${cupn_code20181}
    ${resp}=  Create Jaldee Coupon  ${cupn_code20181}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code20181}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}

    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME${a}} 
    LOg   ${resp.json()}
    Set Suite Variable   ${pid}
    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    clear_location   ${PUSERNAME${a}} 
    clear_service   ${PUSERNAME${a}}
    clear_queue   ${PUSERNAME${a}}
    clear_waitlist  ${PUSERNAME${a}}
    clear_payment_invoice  ${PUSERNAME${a}}
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
    # ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  1000  ${bool[0]}  ${bool[1]}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${s_id2}  ${resp.json()}  
    # ${resp}=   Create Service  ${SERVICE3}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[0]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${s_id3}  ${resp.json()}  
    # ${resp}=   Create Service  ${SERVICE4}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${s_id4}  ${resp.json()}
    
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   db.subtract_timezone_time  ${tz}  2  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}       0  20 
    Set Suite Variable    ${end_time} 
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    Set Suite Variable   ${parallel}
    Set Suite Variable   ${capacity}  
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${lid}  ${s_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${cnote}=   FakerLibrary.word
    Set Suite Variable  ${cnote}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=1180.0  billPaymentStatus=${paymentStatus[0]}  amountDue=1180.0
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code20181}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code20181}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code20181}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code20181}  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${amount}  ${resp.json()['amountDue']}
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=1130.0  billPaymentStatus=${paymentStatus[0]}  amountDue=1130.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code20181}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code20181}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_code20181}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
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
    
    sleep   03s
    ${end}=  db.add_tz_time24  ${tz}   0  0
    ${start}=  db.add_tz_time24  ${tz}   0  -5
    ${resp}=  Create Reimburse Reports By Provider  ${start}  ${end}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code20181}
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
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_code20181}":50.0}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}      
    
*** comments ***
JD-TC-GetReimburseReports-2
    [Documentation]  two provider create bill with jcoupon and  settl then after generete invoice report

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+100100143
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}  AND  clear_waitlist  ${PUSERPH0}    AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
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
    Should Be Equal As Strings  "${resp.json()}"    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}101.${test_mail}  ${views}
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
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile With Shcedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep   01s

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  18  ${GST_num}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${lic1} 
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cupn_code2018}=    FakerLibrary.word
    Set Suite Variable  ${cupn_code2018}
    clear_jaldeecoupon  ${cupn_code2018}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    
    
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fname}=  FakerLibrary.name
    Set suite Variable   ${fname}
    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}
    ${city}=   get_place
    Set Suite Variable   ${city}
    ${IFSC}=  Generate_ifsc_code
    Set Suite Variable   ${IFSC}
    ${ph}=   evaluate    ${PUSERNAME152}+1234
    Set Suite Variable   ${ph}
    ${acc}=    Generate_random_value  11   ${numbers}
    Set Suite Variable   ${acc}

    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${ph}   ${pan_num}  ${acc}  ${name1}  ${IFSC}  ${fname}  ${fname}  ${city}   ${businessStatus[1]}  ${accounttype[1]}  
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${pid}
    #${merchantid}=   Random Int  min=1111111  max=5555555
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  payuVerify  ${pid}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${ph}   ${pan_num}  ${acc}  ${name1}  ${IFSC}  ${fname}  ${fname}  ${city}   ${businessStatus[1]}  ${accounttype[1]}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${cid}
    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid} 
    
    ${ser_desc}=   FakerLibrary.word
    Set Suite Variable   ${ser_desc}
    ${total_amount}=    Random Int  min=100  max=500
    Set Suite Variable  ${total_amount}
    ${min_prepayment}=  Random Int   min=1   max=50
    Set Suite Variable   ${min_prepayment}
    ${ser_duratn}=      Random Int   min=10   max=30
    Set Suite Variable   ${ser_duratn}
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  1000  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  1000  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE3}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id3}  ${resp.json()}  
    # ${resp}=   Create Service  ${SERVICE4}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${s_id4}  ${resp.json()}
    ${strt_time}=   db.subtract_timezone_time  ${tz}  2  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}       0  20 
    Set Suite Variable    ${end_time} 
    
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  1  100  ${lid}  ${s_id1}  ${s_id2}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  1000.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  1180.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  1180.0
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
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
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=1130.0  billPaymentStatus=${paymentStatus[0]}  amountDue=1130.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  1130.0  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  1130.0

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
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_code2018}": 50}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}

JD-TC-GetReimburseReports-3
    [Documentation]  Consumer apply a coupon at self payment and GetReimburseReports

    clear_reimburseReport
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}   
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  1000.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  1180.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  1180.0
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[7]}  1180  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon At Selfpay  ${wid}  ${cupn_code2018}  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By Consumer  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['value']}  50.0
    
    Verify Response  ${resp}  uuid=${wid}   netTotal=1000.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[0]}  netRate=1130.0  billPaymentStatus=${paymentStatus[0]}  amountDue=1130.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0

    ${resp}=  Make payment Consumer  1130.0  ${payment_modes[2]}  ${wid}  ${pid}  ${purpose[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain  ${resp.json()['response']}  \"merchantId\":\"${merchantid}\
    Should Contain  ${resp.json()['response']}  <td><input name=\"amount\" value=1130.00 /></td>
    Should Contain  ${resp.json()['response']}  <td><input name=\"email\" id=\"email\" value=${CUSEREMAIL5} /></td>
    Should Contain  ${resp.json()['response']}  <td>Phone: </td>\n   <td><input name=\"phone\" value=${CUSERNAME5} ></td>
    ${resp}=  Make payment Consumer Mock  1130.0  ${bool[1]}  ${wid}   ${pid}  ${purpose[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist By Id  ${wid}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[2]} 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  1000.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  1130.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  0.0
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}  ${paymentStatus[2]}
    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0 

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
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['providerId']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportFromDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['reportEndDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeBank']}  0.0    
    Should Be Equal As Strings  ${resp.json()[0]['subTotalJaldeeCoupons']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['grantTotal']}  50.0
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[3]}
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_code2018}": 50}


JD-TC-GetReimburseReports -UH5
    [Documentation]   Get jaldee coupons by without login  
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetReimburseReports -UH6
    [Documentation]   Consumer get jaldee coupons
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Reimburse Reports By Provider
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"


*** Comments ***
JD-TC-GetReimburseReports-13

       
    clear_reimburseReport
    Run Keywords   clear_queue  ${PUSERNAME${a}}  AND  clear_payment_invoice  ${PUSERNAME${a}}  AND  clear_waitlist  ${PUSERNAME${a}}  AND  clear_payment_invoice  ${PUSERNAME${a}}    
    clear_service  ${PUSERNAME${a}}    
    clear_location  ${PUSERNAME${a}}
    


    ${pid}=  get_acc_id  ${PUSERNAME${a}}            
    ${resp}=   Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}     
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
    ${cupn_codeAADI1}=   FakerLibrary.word
    Set Suite Variable   ${cupn_codeAADI1}
    ${cupn_name1}=   FakerLibrary.name
    Set Suite Variable   ${cupn_name1}
    clear_jaldeecoupon  ${cupn_codeAADI1}
    ${resp}=  Create Jaldee Coupon  ${cupn_codeAADI1}  ${cupn_name1}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  100  100  ${bool[0]}  ${bool[0]}  100  1000  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_codeAADI1}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME${a}} 
    
    Set Suite Variable  ${cid}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid} 
    ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  1000  ${bool[0]}  ${bool[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id13}  ${resp.json()}  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_id13}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id13}  ${qid1}  ${DAY1}  ${cnote}  ${bool[1]}  ${self}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Consumer Login   ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${cid}=  get_id  ${CUSERNAME1} 
    clear_waitlist   ${CUSERNAME1}
    ${resp}=  Add To Waitlist Consumers  ${pid}   ${qid1}   ${DAY1}   ${s_id13}   ${cnote}   ${bool[0]}   ${self}
    Log   ${resp.json()}
    
    ${wid13}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid13}  ${wid13[0]}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=   Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${wid13}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid13}  ${wid13[0]}  
    ${resp}=  Get Bill By UUId  ${wid13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid13}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id13}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  1000.0

    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeAADI1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  NEW
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_codeAADI1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_codeAADI1}
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_codeAADI1}  ${wid13}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid13}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id13}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  1000.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  1000.0
   # Should Be Equal As Strings  ${resp.json()['netRate']}  0.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeAADI1}']['value']}  100.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeAADI1}']['systemNote']}  [u'COUPON_APPLIED', u'NO_OTHER_COUPONS_ALLOWED']
    #Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_codeAADI1}']['systemNote']}  [SystemNote[2]]
    Should Be Equal As Strings  ${resp.json()['billPaymentStatus']}   ${paymentStatus[2]} 
    Should Be Equal As Strings  ${resp.json()['totalAmountPaid']}  0.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  0.0   

   ${resp}=  Settl Bill  ${wid13}
   Log   ${resp.json()}
   Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid13}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid13}    
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
    Should Be Equal As Strings  ${resp.json()[0]['listOfJaldeeCoupons']}  {"${cupn_codeAADI1}": 100}
    