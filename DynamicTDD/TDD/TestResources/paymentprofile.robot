*** Settings ***
Test Teardown     Delete All Sessions
Force Tags        Bill
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Keywords ***

Get Service payment modes
    [Arguments]  ${accountId}   ${serviceId}   ${paymentPurpose}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/payment/modes/service/${accountId}/${serviceId}/${paymentPurpose}    expected_status=any
    [Return]  ${resp}
    
Get payment modes
    [Arguments]  ${accountId}   ${serviceId}   ${paymentPurpose}
    Check And Create YNW Session
    ${resp}=   GET On Session  ynw  /consumer/payment/modes/service/${accountId}/${serviceId}/${paymentPurpose}    expected_status=any
    [Return]  ${resp}

# Get convenienceFee Details 
#     [Arguments]  ${accountId}     ${profileId}    ${amount}
#     ${data}=    Create Dictionary    profileId=${profileId}  amount=${amount}
#     ${data}=  json.dumps  ${data}
#     Check And Create YNW Session
#     ${resp}=  PUT On Session  ynw   /consumer/payment/modes/convenienceFee/${accountId}   data=${data}   expected_status=any

# Get convenienceFee Details 
#     [Arguments]  ${accountId}     ${profileId}    ${amount}
#     ${data}=    Create Dictionary    profileId=${profileId}  amount=${amount}
#     ${data}=  json.dumps  ${data}
#     Check And Create YNW Session
#     ${resp}=   PUT On Session  ynw  /consumer/payment/modes/convenienceFee/${accountId}   data=${data}   expected_status=any
#     [Return]  ${resp}

Get convenienceFee Details 
    [Arguments]  ${accountId}     ${profileId}    ${amount}
    ${data}=    Create Dictionary    profileId=${profileId}  amount=${amount}
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=   PUT On Session  ynw  /consumer/payment/modes/MockConvenienceFee/${accountId}   data=${data}   expected_status=any
    [Return]  ${resp}

# Get Billable Subdomain
#     [Arguments]   ${domain}  ${jsondata}  ${posval}  
#     ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
#     FOR  ${pos}  IN RANGE  ${length}
#             Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
#             ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
#             Should Be Equal As Strings    ${resp.status_code}    200
#             Exit For Loop IF  '${resp.json()['serviceBillable']}' == 'True'
#     END
#     [Return]  ${subdomain}  ${resp.json()['serviceBillable']}

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Suite Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Log  ${resp.json()}
            Should Be Equal As Strings    ${resp.status_code}    200
            ${Status}=   Run Keyword And Return Status   Run Keywords   Should Be ${bool[1]}   '${resp.json()['maxPartySize']}' > '${1}'  AND   Should Be ${bool[1]}  '${resp.json()['serviceBillable']}' == '${bool[1]}'
            Exit For Loop IF  ${Status}
    END
    [Return]  ${subdomain}  ${Status}

*** Variables ***

${digits}       0123456789
${service_duration}   2
${parallel}           1
${self}               0
@{provider_list}
${start}              140
${jcoupon1}   CouponMul00
${chargeConsumer}    GatewayAPi

${id}            spDefaultProfile
${displayName}   SP Default Payment Profile
${id1}            spDefaultProfile1
${displayName1}   Default Payment Profile2


${SERVICE1}     manicure 
${SERVICE2}     pedicure
@{dom_list}
@{multiloc_providers}
${countryCode}   +91

${item1}   ITEM1
${item2}   ITEM2
${item3}   ITEM3
${item4}   ITEM4
${item5}   ITEM5
${CUSERPH}      ${CUSERNAME}

@{multiples}  10  20  30   40   50
${SERVICE1}   MakeUp
${SERVICE2}   Coloring




*** Test Cases ***

JD-TC-Add To WaitlistByConsumer-25
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_location  ${PUSERPH0}   AND   clear_service   ${PUSERPH0}  AND  clear waitlist   ${PUSERPH0}

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=   Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    # ${max_party}=  get_maxpartysize_subdomain
    # Log    ${max_party}
    # Set Suite Variable  ${d1}  ${max_party['domain']}
    # Set Suite Variable  ${sd1}  ${max_party['subdomain']}

    # ${resp}=   Get Sub Domain Settings    ${d1}    ${sd1}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    '${resp.json()['serviceBillable']}'  'True'
    
    ${pkg_id}=   get_highest_license_pkg

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}    ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    # Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+100100302
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH1}${\n}
    
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+100100303
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}
    
    ${PUSERMAIL0}=   Set Variable  ${P_Email}ph301.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    Log   ${views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY}=  get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    sleep   01s

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid0}  ${resp.json()['id']}
    # Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH0}.${test_mail}

    ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${loc1}  ${resp.json()[0]['id']} 
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${DAY}=  db.add_timezone_date  ${tz}  3

    ${resp}=   Get payment profiles  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable   ${P1SERVICE1}
    ${service_duration}=   Random Int   min=2   max=10
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ps1}  ${resp.json()}

    ${P2SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P2SERVICE2}
    ${service_duration1}=   Random Int   min=2   max=10
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    Set Suite Variable  ${min_pre}
    ${servicecharge}=   Random Int  min=100  max=500
    ${Total1}=  Convert To Number  ${servicecharge}  1 
    Set Suite Variable   ${Total}   ${Total1}
    ${amt_float}=  twodigitfloat  ${Total}
    Set Suite Variable  ${amt_float}  ${amt_float}  

    ${resp}=  Create Service  ${P2SERVICE2}  ${desc}   ${service_duration1}  ${status[0]}    ${btype}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${ps2}  ${resp.json()}

    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel[0]}  ${capacity}  ${loc1}  ${ps1}  ${ps2}  
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p_q1}  ${resp.json()}

    ${resp}=    Enable Search Data
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${consid1}  ${resp.json()['id']}
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable  ${f1}   ${resp.json()}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${p_q1}  ${DAY}  ${ps2}  ${cnote}  ${bool[0]}  ${f1}  ${self}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 
    Set Suite Variable  ${cwidfam}  ${wid[1]} 

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcons_id0}  ${resp.json()[1]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Get consumer Waitlist By Id   ${cwid}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  appxWaitingTime=0  waitlistedBy=CONSUMER
    # Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P2SERVICE2}
    # Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ps2}
    # Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${consid1}
    # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id0}
    # Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p_q1}

    ${resp}=  Get consumer Waitlist By Id   ${cwidfam}  ${pid0}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[3]}  appxWaitingTime=${service_duration1}  waitlistedBy=CONSUMER
    # Should Be Equal As Strings  ${resp.json()['service']['name']}  ${P2SERVICE2}
    # Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ps2}
    # Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${consid1}
    # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${f1}
    # Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${p_q1}

    ${min_pre2}=  Evaluate  $min_pre * 2
    ${resp}=    Get convenienceFee Details     ${pid0}    customizedJBProfile   ${min_pre2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # ${min_pre2}=  Evaluate  $min_pre * 2
    ${resp}=  Make payment Consumer Mock  ${pid0}  ${min_pre2}  ${purpose[0]}  ${cwid}  ${ps2}  ${bool[0]}   ${bool[1]}  ${consid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   02s

    ${resp}=  Get consumer Waitlist By Id  ${cwidfam}  ${pid0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[1]}

    sleep   2s
    ${resp}=   Cancel Waitlist  ${cwidfam}  ${pid0}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

***Comment***
JD-TC-NBFC Account Creation-1
    [Documentation]   Create NBFC account for cdl load testing
 
        
    ${licid}  ${licname}=  get_highest_license_pkg

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${domain}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${subdomain}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    Log Many  ${domain}  ${subdomain}
    ${is_corp}=  check_is_corp  ${subdomain}

    ${PH_Number}    Random Number 	digits=7  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PUSER}  555${PH_Number}

    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.lastname
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSER}    ${licid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSER}  0
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${PUSER}  ${PASSWORD}  0
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSER}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/phnumbers.txt  ${PUSER}${\n}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME190}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME190}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME190}.${test_mail}  ${views}
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
    ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fields}=   Get subDomain level Fields  ${domain}   ${subdomain}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['enabledWaitlist']}'=='${bool[0]}'
        ${resp}=  Enable Waitlist
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  enabledWaitlist=True
    

    ${desc}=  FakerLibrary.word
    ${type}=  Create List   onlinePay   bank2bank 
    ${txnTypes}=   Create List   any
    
    ${paymode}=  Create List   any
    ${gateway}=  Create List   RAZORPAY
    ${chargeConsumer}=  Create List   ${chargeConsumer}
    # ${gatewayFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedPctValue=0   fixedAmountValue=0  fixedPctValueMax=0  fixedPctValueMin=0
 
    ${splitPayment}   Create List   no  2-way   3-way
    ${destBanks}=   Create Dictionary   bankID=${EMPTY}   payPct=50   fixedPctValueMin=3   fixedPctValueMax=5   fixed=${EMPTY}     
    ${destBanks}=  Create List   ${destBanks}
    ${fee}=   Create List   incl  excl
    ${fromBank}=   Create Dictionary   bankID=${EMPTY}   maxLimit=100000   fee=${fee}  


    ${chargeConsumer}=  Create List   fixedAmount
    ${convenienceFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedAmountValue=50   fixedPctValue=0  

    ${destBank}=  Create List   JALDEE
    ${chargeConsumer}=  Create List   fixedAmount
    ${convenienceFee}=   Create Dictionary   chargeConsumer=${chargeConsumer}   fixedAmountValue=50   fixedPctValue=0  

    ${chargeConsumer}=  Create List   NO
    ${gatewayFee}=   Create Dictionary    fixedPctValue=0    chargeConsumer=${chargeConsumer}    fixedAmountValue=0  fixedPctValueMax=0  fixedPctValueMin=0

    ${indianPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gatewayFee=${gatewayFee}   mode=${payment_modes[2]}   gatewayFee=${gatewayFee}  
    ${indianPaymodes1}=  Create List   ${indianPaymodes1}
    ${internationalPaymodes1}=   Create Dictionary   mode=${payment_modes[5]}   gatewayFee=${gatewayFee}    mode=${payment_modes[1]}   gatewayFee=${gatewayFee} 
    ${internationalPaymodes}=  Create List    ${internationalPaymodes1}
    ${resp}=   Create Dictionary    id=customizedJBProfile    destBank=${destBank}    indiaPay=${boolean[1]}    displayName=Jaldee Bank Payment Profile   convenienceFee=${convenienceFee}   indianPaymodes=${indianPaymodes1}    internationalPay=${boolean[1]}    internationalPaymodes=${internationalPaymodes}
    Log  ${resp}
    
    ${resp1}=   Create Dictionary    id=secondJBProfile    destBank=${destBank}    indiaPay=${boolean[1]}    displayName=Second Jaldee Bank Payment Profile      indianPaymodes=${indianPaymodes1}    internationalPay=${boolean[1]}    internationalPaymodes=${internationalPaymodes}
    Log  ${resp1}
    ${profiles}=  Setting Payment Profile  ${resp}   ${resp1}
    
    ${combined_json}=  Payment Profile Json  ${profiles}   
    
    ${payment_profile}=  payment_profiles   ${combined_json}  ${account_id}

    ${resp}=   Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSER}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Update Destination Bank  customizedJBProfile  ${bool[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get payment profiles  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Bank Details  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
    ${Total1}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${ser_duratn}=   Random Int   min=10   max=30

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}  ${bool[0]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  1  15  
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    # ${resp}=  ProviderLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid1}   ${resp.json()['id']}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${account_id}  ${qid}  ${DAY}  ${s_id}  ${msg}  ${bool[0]}  ${self}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${cwid}  ${wid[0]} 

    # ${resp}=  ConsumerLogout
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get convenienceFee Details     ${account_id}    customizedJBProfile   ${min_pre1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        Run Keyword And Continue On Failure  Dictionary Should Contain Value  ${resp.json()[${i}]}  CC
        Run Keyword And Continue On Failure  Dictionary Should Contain Value  ${resp.json()[${i}]}  DC
        Run Keyword And Continue On Failure  Dictionary Should Contain Value  ${resp.json()[${i}]}  MOCK
    END