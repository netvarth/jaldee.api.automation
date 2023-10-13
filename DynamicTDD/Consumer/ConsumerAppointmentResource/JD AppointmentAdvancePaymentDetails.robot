*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           random
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}     manicure 
${SERVICE2}     pedicure
${SERVICE3}  pensil101
${SERVICE4}  Book12101
${SERVICE5}  watch13101
${self}         0
${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}

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
    [Return]  ${subdomain}  ${resp.json()['serviceBillable']}


*** Test Cases ***

JD-TC- AppointmentAdvancePaymentdetails-1

    [Documentation]  Get appointment payment details without prepayment and coupon

    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+100100212
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_B}${\n}
    Set Suite Variable   ${PUSERNAME_B}
    ${resp}=   Run Keywords  clear_queue  ${PUSERNAME_B}  AND  clear_service  ${PUSERNAME_B}  AND  clear_location  ${PUSERNAME_B}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=   Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
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
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERNAME_B}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERNAME_B}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  "${resp.json()}"    "true"
    
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_B}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_B}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_B}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ${d1} 
    Set Suite Variable   ${domains} 
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  
    Set Suite Variable   ${sub_domains}
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
    ${Jamount}=    Random Int   min=10  max=50
    ${Jamount}=  Convert To Number  ${Jamount}  1
    Set Suite Variable   ${Jamount}
    ${cupn_name}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    clear_jaldeecoupon  ${cupn_code2018}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  ${Jamount}  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  15  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pid}=  get_acc_id  ${PUSERNAME_B}
    Set Suite Variable  ${pid}

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${businessStatus}    Random Element   ${businessStatus}  
    ${accounttype}  Random Element   ${accounttype} 
    ${fname}=   FakerLibrary.name
    ${panCardNumber}=  Generate_pan_number
    ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
    ${bankName}=  FakerLibrary.company
    ${ifsc}=  Generate_ifsc_code
    ${panname}=  FakerLibrary.name
    ${city}=   get_place
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME_B}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}  
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  payuVerify  ${pid}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME_B}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${pan_name}  ${fname}  ${city}  ${businessStatus}  ${accounttype}   
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  ${merchantid}
    
    ${resp}=  Enable Appointment
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    clear_service   ${PUSERNAME_B}
    clear_location  ${PUSERNAME_B}    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME_B}
    Set Suite Variable   ${pid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_time  0  15  
    # ${delta}=  FakerLibrary.Random Int  min=10  max=60
    # ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${lid}=  Create Sample Location
    # Set Suite Variable   ${lid}
    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    clear_appt_schedule   ${PUSERNAME_B}

    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=200   max=500
    ${ser_amount}=  Convert To Number  ${ser_amount}  1
    Set Suite Variable    ${ser_amount} 
    ${min_pre}=   Random Int   min=10   max=50
    ${min_pre}=  Convert To Number  ${min_pre}  1
    Set Suite Variable    ${min_pre} 
    ${notify}    Random Element     ['True','False']
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${SERVICE1}=   FakerLibrary.name
    ${description}=  FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${min_pre}  ${ser_amount}  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id1}  ${resp.json()}

    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id2}  ${resp.json()}

    ${SERVICE2}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE3}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id3}  ${resp.json()}

    ${SERVICE5}=   FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE5}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${EMPTY}  ${ser_amount}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id5}  ${resp.json()}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id1}  ${s_id2}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}   

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id2}  ${resp.json()} 

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${totalTaxAmount}=  Evaluate  ${ser_amount} * ${gstpercentage[2]} / 100
    Set Suite Variable  ${totalTaxAmount}

    ${cid}=  get_id  ${CUSERNAME7}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${EMPTY_List}=  Create List
    Set Suite Variable   ${EMPTY_List}
    ${resp}=   Appointment AdvancePayment Details   ${pid}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     0.0
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
  
    
JD-TC-AppointmentAdvancePaymentdetails-2
    [Documentation]   Get appointment payment details with prepayment 

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cid}=  get_id  ${CUSERNAME1}   
    ${cnote}=   FakerLibrary.name
    ${EMPTY_List}=  Create List
    ${resp}=   Appointment AdvancePayment Details   ${pid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
  
JD-TC-AppointmentAdvancePaymentdetails-3
    [Documentation]   Get appointment payment details with prepayment and jaldeecoupon

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${SystemNote}=  Create List  ${SystemNote[2]}  
    Set Suite Variable  ${SystemNote} 

    ${cid}=  get_id  ${CUSERNAME1}   
    ${cnote}=   FakerLibrary.name
    ${coupons}=  Create List   ${cupn_code2018}
    ${resp}=   Appointment AdvancePayment Details   ${pid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${coupons}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        ${Jamount}
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         ${Jamount}
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    Should Be Equal As Strings  ${resp.json()['jCouponList']['${cupn_code2018}']['value']}        ${Jamount}
    Should Be Equal As Strings  ${resp.json()['jCouponList']['${cupn_code2018}']['systemNote']}   ${SystemNote}
    
JD-TC-AppointmentAdvancePaymentdetails-4
    [Documentation]    Get appointment payment details when appoointment needs Advance amount (Advance amount same as service total price).

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${description}=  FakerLibrary.sentence
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${notify}    Random Element     ['True','False'] 
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount1}=   Random Int   min=100   max=150
    ${ser_amount1}=  Convert To Number  ${ser_amount1}  1
    Set Suite Variable    ${ser_amount1}  
    ${resp}=  Create Service  ${SERVICE4}  ${description}   ${ser_durtn}  ${status[0]}  ${btype}  ${notify}   ${notifytype}  ${ser_amount1}  ${ser_amount1}  ${bool[1]}  ${bool[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable    ${s_id4}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id3}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id3}   name=${schedule_name}  apptState=${Qstate[0]}

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${pc_amount}=  Convert To Number  ${pc_amount}  1
    Set Suite Variable  ${pc_amount}
    ${cupn_code}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code}
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
    ${services}=   Create list   ${sid4}    ${sid1}    
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id3}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id3}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${amt}=  Evaluate   ${ser_amount1} - ${pc_amount}
    ${totalTaxAmount}=  Evaluate  ${amt} * ${gstpercentage[2]} / 100
    ${amt}=  Evaluate   ${amt} + ${totalTaxAmount}
    ${amount}=    Set Variable If  ${ser_amount1} > ${amt}   ${amt}   ${ser_amount1}

    ${cid}=  get_id  ${CUSERNAME3}   
    ${cnote}=   FakerLibrary.name
    ${coupons}=  Create List   ${cupn_code}
    ${resp}=   Appointment AdvancePayment Details   ${pid}  ${s_id4}  ${sch_id3}  ${DAY1}  ${cnote}   ${apptfor}  ${coupons}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount1}
    Should Be Equal As Numbers  ${resp.json()['amountRequiredNow']}                     ${amount}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         ${pc_amount}
    Should Be Equal As Numbers  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    Should Be Equal As Strings  ${resp.json()['proCouponList']['${cupn_code}']['value']}               ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['proCouponList']['${cupn_code}']['systemNote']}          ${SystemNote}
    

JD-TC-AppointmentAdvancePaymentdetails-5
    [Documentation]  Get appointment payment details with prepayment and  both jaldee coupon and provider coupon 

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${totalTaxAmount}=  Evaluate  ${ser_amount} * ${gstpercentage[2]} / 100
    ${totalDiscount}=   Evaluate  ${pc_amount} + ${Jamount} 
    ${amt}=  Evaluate   ${min_pre} - ${totalDiscount}
    ${amt}=  Evaluate   ${amt} + ${totalTaxAmount}

    ${cid}=  get_id  ${CUSERNAME4}   
    ${cnote}=   FakerLibrary.name
    ${coupons}=  Create List   ${cupn_code2018}   ${cupn_code}
    ${resp}=  Appointment AdvancePayment Details   ${pid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  ${coupons}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        ${Jamount}
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         ${totalDiscount}
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    Should Be Equal As Strings  ${resp.json()['jCouponList']['${cupn_code2018}']['value']}        ${Jamount}
    Should Be Equal As Strings  ${resp.json()['jCouponList']['${cupn_code2018}']['systemNote']}   ${SystemNote}
    Should Be Equal As Strings  ${resp.json()['proCouponList']['${cupn_code}']['value']}          ${pc_amount}
    Should Be Equal As Strings  ${resp.json()['proCouponList']['${cupn_code}']['systemNote']}     ${SystemNote}
    
JD-TC-AppointmentAdvancePaymentdetails-6
    [Documentation]    Get appointment advance payment details with Enable JDN  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${disc_max}=   Random Int   min=100   max=300
    ${disc_max}=  Convert To Number   ${disc_max}
    ${d_note}=   FakerLibrary.word
    ${resp}=   Enable JDN for Percent    ${d_note}  ${jdn_disc_percentage[0]}   ${disc_max}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}


    ${jdnDiscount}=  Evaluate  ${ser_amount} * ${jdn_disc_percentage[0]} / 100
    ${taxableamt}=  Evaluate  ${ser_amount} - ${jdnDiscount} 
    ${totalTaxAmount}=  Evaluate  ${taxableamt} * ${gstpercentage[2]} / 100
    # ${totalTaxAmount}=  twodigitfloat  ${totalTaxAmount}
    ${totalTaxAmount}=  roundoff  ${totalTaxAmount}  
    ${totalTaxAmount}=  roundoff  ${totalTaxAmount}  

    
    ${cid}=  get_id  ${CUSERNAME5}   
    ${cnote}=   FakerLibrary.name
    ${resp}=  Appointment AdvancePayment Details   ${pid}   ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  ${EMPTY_List} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           ${jdnDiscount}
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         ${jdnDiscount}
    Should Be Equal As Numbers  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    
JD-TC-AppointmentAdvancePaymentdetails-7
    [Documentation]     Get appointment advance payment details with disabled JDN

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Disable JDN
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get JDN 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${totalTaxAmount}=  Evaluate  ${ser_amount} * ${gstpercentage[2]} / 100

    ${cnote}=   FakerLibrary.name
    ${resp}=  Appointment AdvancePayment Details   ${pid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  ${EMPTY_List}  
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${min_pre}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    
  
JD-TC-AppointmentAdvancePaymentdetails-UH1
    [Documentation]    Get appointment advance payment details using Invalid account id.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.name
    ${resp}=  Appointment AdvancePayment Details   0  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    404
    Should Be Equal As Strings  "${resp.json()}"  "${ACCOUNT_NOT_EXIST}"

JD-TC-AppointmentAdvancePaymentdetails-UH2
    [Documentation]    Get appointment advance payment details using service not present in any available queue.

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor} 

    ${cnote}=   FakerLibrary.name
    ${resp}=  Appointment AdvancePayment Details   ${pid}  ${s_id5}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${SCHEDULE_SERVICE_NOT_EXIST}"

JD-TC-AppointmentAdvancePaymentdetails-UH3
    [Documentation]    Get appointment advance payment details by using provider login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.name
    ${resp}=  Appointment AdvancePayment Details   ${pid}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ACCESS_TO_URL}"

JD-TC-AppointmentAdvancePaymentdetails-UH4
    [Documentation]    Get appointment advance payment details without login.

    ${cnote}=   FakerLibrary.name
    ${resp}=  Appointment AdvancePayment Details   ${pid}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}  ${EMPTY_List} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-AppointmentAdvancePaymentdetails-UH5
    [Documentation]    Get appointment advance payment details using Invalid coupon code.

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.name
    ${INVALID_Coupon}=  Create List   0
    ${resp}=  Appointment AdvancePayment Details   ${pid}   ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  ${INVALID_Coupon} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"  "${COUPON_INVALID}"

JD-TC-AppointmentAdvancePaymentdetails-UH6
    [Documentation]    Get appointment advance payment details by applying a coupon.(If Coupon start date is a future date)
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${pc_amount}=   Random Int   min=10  max=50
    ${cupn_code1}=   FakerLibrary.word
    Set Suite Variable  ${cupn_code1}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.add_timezone_date  ${tz}  1
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=90   max=100
    ${max_disc_val}=   Random Int   min=90  max=100
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[1]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid4}   
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${pc_amount}  ${calctype[1]}  ${cupn_code1}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[0]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId1}  ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id3}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id3}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${totalTaxAmount}=  Evaluate  ${ser_amount1} * ${gstpercentage[2]} / 100
    ${SystemNote1}=  Create List   PROVIDER_COUPON_NOT_APPLICABLE

    ${desc}=   FakerLibrary.word
    ${coupons}=  Create List   ${cupn_code1}
    ${resp}=  Appointment AdvancePayment Details   ${pid}  ${s_id4}  ${sch_id3}  ${DAY1}  ${desc}  ${apptfor}  ${coupons} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['netTotal']}                              ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['amountRequiredNow']}                     ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['jdnDiscount']}                           0.0
    Should Be Equal As Strings  ${resp.json()['couponDiscount']}                        0.0
    Should Be Equal As Strings  ${resp.json()['providerCouponDiscount']}                0.0
    Should Be Equal As Strings  ${resp.json()['totalDiscount']}                         0.0
    Should Be Equal As Strings  ${resp.json()['netTaxAmount']}                          ${totalTaxAmount}
    Should Be Equal As Strings  ${resp.json()['proCouponList']['${cupn_code1}']['value']}               0.0
    Should Be Equal As Strings  ${resp.json()['proCouponList']['${cupn_code1}']['systemNote']}          ${SystemNote1}

*** comment ***   
   
JD-TC-AppointmentAdvancePaymentdetails-UH7
    [Documentation]  Consumer apply a coupon at Checkin time.but coupon rule contain  maxConsumerUseLimitPerProvider is one

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cupn_code2021}=    FakerLibrary.word
    ${Jamount1}=    Random Int   min=10  max=50
    ${Jamount1}=  Convert To Number  ${Jamount1}  1
    ${cupn_name}=   FakerLibrary.name
    ${cupn_des}=   FakerLibrary.sentence
    ${c_des}=   FakerLibrary.sentence
    ${p_des}=   FakerLibrary.sentence
    clear_jaldeecoupon  ${cupn_code2021}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2021}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  ${Jamount1}  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  1  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2021}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2021}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2021}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2021}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id3}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id3}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}


    ${desc}=   FakerLibrary.word
    ${coupons}=  Create List   ${cupn_code2021}
    ${resp}=  Appointment AdvancePayment Details   ${pid}  ${s_id4}  ${sch_id3}  ${DAY1}  ${desc}  ${apptfor}  ${coupons} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${qid2}  ${DAY1}  ${s_id4}  ${desc}  ${bool[0]}  ${coupons}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${cwid}  ${wid[0]}  
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${cwid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Appointment AdvancePayment Details   ${pid}  ${s_id4}  ${sch_id3}  ${DAY1}  ${desc}  ${apptfor}  ${coupons} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

   













    