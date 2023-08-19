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
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***
${SERVICE1}     manicure 
${SERVICE2}     pedicure
${self}         0
${digits}       0123456789
@{provider_list}
@{dom_list}
@{multiloc_providers}
${countryCode}   +91

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

Get coupon list by service and location id for appointment
    [Arguments]   ${serviceId}    ${locationId}
    Check And Create YNW Session
    ${resp}=    GET On Session     ynw   /consumer/appointment/service/${serviceId}/location/${locationId}/coupons  expected_status=any
    [Return]  ${resp}

*** Test Cases ***

JD-TC-Get coupon list by service and location id for appointment-1

    [Documentation]  Consumer get coupon for appointment 

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+5566014
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_B}    ${highest_package[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_B}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.content}
# *** comment ***
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_B}${\n}
    Set Suite Variable  ${PUSERNAME_B}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}

    # Set Test Variable  ${pid}  ${resp.json()['id']}

    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_B}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_B}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
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
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_B}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Appointment
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

    ${domains}=  Jaldee Coupon Target Domains  ${dom}  
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${dom}_${sub_dom}  
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    Set Suite Variable   ${licenses}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
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
    clear_jaldeecoupon  ${cupn_code2018}

    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  10  10  ${bool[0]}  ${bool[0]}  10  10  10  10  10  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_des}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupon By CouponCode  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponStatus']}  ${status[0]}
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[1]}

    clear_service   ${PUSERNAME_B}
    clear_location  ${PUSERNAME_B}

    ${resp}=  Get Coupons 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME_B}
    Set Suite Variable   ${pid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  add_timezone_time  ${tz}  0  15  
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
    ${SERVICE1}=   FakerLibrary.name
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
    # ${SERVICE2}=   FakerLibrary.name
    # ${s_id2}=  Create Sample Service  ${SERVICE2}
    # Set Suite Variable   ${s_id2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}   

    # ${schedule_name}=  FakerLibrary.bs
    # ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    # ${maxval}=  Convert To Integer   ${delta/2}
    # ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    # ${bool1}=  Random Element  ${bool}
    # ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sch_id2}  ${resp.json()} 

    # ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get coupon list by service and location id for appointment  ${s_id}    ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log  ${resp.content}
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

    ${cid}=  get_id  ${CUSERNAME7}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    # ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200 
    # Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    # Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
    # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    # Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${s_id}
    # Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    # Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    # Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    # Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    # Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${lid}

    ${resp}=  Get coupon list by service and location id for appointment  ${s_id}    ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
*** comment ***
JD-TC-ApplyJaldeeCoupon-1
    [Documentation]  Provider apply a coupon after waitlist
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+100110103
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}  AND  clear_customer  ${PUSERPH0}
     
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
    ${resp}=  Enable Waitlist
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}101.ynwtest@netvarth.com  ${views}
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
    # ${resp}=  Create Business Profile  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Update Business Profile with schedule  ${bs}  ${bs} Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${companySuffix}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   01s

    # ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    # ${resp}=  Update Tax Percentage  18  ${GST_num}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  Enable Tax
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${licid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
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
    
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${time}=  Create Dictionary  sTime=${sTime1}  eTime=${eTime1}
    ${timeslot}=  Create List  ${time}
    ${terminator}=  Create Dictionary  endDate=${DAY2}  noOfOccurance=0
    ${targetDate}=  Create Dictionary  startDate=${DAY1}   timeSlots=${timeslot}  terminator=${terminator}  recurringType=${recurringtype[1]}   repeatIntervals=${list}
    ${targetDate}=  Create List   ${targetDate}

    clear_jaldeecoupon  ${cupn_code2018}
    ${resp}=  Create Jaldee Coupon  ${cupn_code2018}  ${cupn_name}  ${cupn_des}  ${age_group[0]}  ${DAY1}  ${DAY2}  ${discountType[0]}  50  100  ${bool[0]}  ${bool[0]}  0  100  1000  5  2  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${c_des}  ${p_des}  ${domains}  ${sub_domains}  ALL  ${licenses}  targetDate=${targetDate}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${cupn_code2018}  ${cupn_name}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    # ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    # Log    ${resp.json()}

    ${firstname}=  FakerLibrary.name
    ${name1}=  FakerLibrary.name
    ${city}=   get_place
    ${IFSC}=  Generate_ifsc_code
    ${ph}=   evaluate    ${PUSERNAME152}+1234
    ${acc}=    Generate_random_value  11   ${numbers}

    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${ph}   ${pan_num}  ${acc}  ${name1}  ${IFSC}  ${firstname}  ${firstname}  ${city}  ${businessStatus[1]}  ${accounttype[1]}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid1}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${pid1}
    ${resp}=  payuVerify  ${pid1}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${ph}   ${pan_num}  ${acc}  ${name1}  ${IFSC}  ${firstname}  ${firstname}  ${city}  ${businessStatus[1]}  ${accounttype[1]}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid1}  ${merchantid}
   
    ${resp}=  AddCustomer  ${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()}

    # ${cid}=  get_id  ${CUSERNAME5}
    # Set Suite Variable  ${cid}
    ${companySuffix}=  FakerLibrary.companySuffix
    Set Suite Variable    ${companySuffix}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable    ${postcode}
    ${description}=  FakerLibrary.sentence
    Set Suite Variable    ${description}
    ${address}=  get_address
    Set Suite Variable    ${address}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Location  ABCDE  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}  ${address}  ${parkingType[3]}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${lid}  ${resp.json()}

    ${resp}=  Create Service  ${SERVICE1}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  50  500  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE3}  ${description}   2  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  0  500  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id3}  ${resp.json()}

    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_id1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${des}=   FakerLibrary.sentence
    Set Suite Variable   ${des}
    
    ${resp}=  Add To Waitlist  ${id}  ${s_id2}  ${qid1}  ${DAY1}  ${des}  ${bool[1]}  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid1[0]}
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[0]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  590.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  590.0
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ${couponState[0]}
    ${resp}=  Enable Jaldee Coupon By Provider  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Apply Jaldee Coupon By Provider  ${cupn_code2018}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${cupn_code2018}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  ${SystemNote[1]}
    Should Contain  ${resp.json()['jCoupon']['${cupn_code2018}']['systemNote']}  ${SystemNote[2]}
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    Should Be Equal As Strings  ${resp.json()['netRate']}  531.0
    Should Be Equal As Strings  ${resp.json()['amountDue']}  531.0
    ${resp}=  Accept Payment  ${wid1}  ${acceptPaymentBy[0]}  531.0
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${acceptPaymentBy[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  531.0

    ${resp}=  Get Jaldee Coupon Stats By Coupon_code  ${cupn_code2018}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageAmt']}  50.0
    Should Be Equal As Strings  ${resp.json()['providerUsage']['usageCount']}  1
    Should Be Equal As Strings  ${resp.json()['providerUsage']['reimbursed']}  0.0