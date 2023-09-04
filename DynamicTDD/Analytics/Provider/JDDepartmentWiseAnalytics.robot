*** Settings ***
# Suite Teardown    Run Keywords  Delete All Sessions  resetsystem_time
# Test Teardown     Run Keywords  Delete All Sessions  resetsystem_time
Suite Teardown    Run Keywords  Delete All Sessions  
Test Teardown     Run Keywords  Delete All Sessions  
Force Tags        Analytics
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
# &{tokenAnalyticsMetrics}   PHONE_TOKEN=1  WALK_IN_TOKEN=2  ONLINE_TOKEN=3  TELE_SERVICE_TOKEN=4
# ...  TOTAL_FOR_TOKEN=6  CHECKED_IN_TOKEN=7  ARRIVED_TOKEN=8  STARTED_TOKEN=9  CANCELLED_TOKEN=10  DONE_TOKEN=11
# ...  RESCHEDULED_TOKEN=12  TOTAL_ON_TOKEN=13  WEB_TOKENS=14  TOKENS_FOR_LICENSE_BILLING=20

# &{appointmentAnalyticsMetrics}  PHONE_APPMT=21  WALK_IN_APPMT=22  ONLINE_APPMT=23  TELE_SERVICE_APPMT=24
# ...  CONFIRMED_APPMT=26  ARRIVED_APPMT=27  STARTED_APPMT=28  CANCELLED_APPMT=29  COMPLETETED_APPMT=30  
# ...  RESCHEDULED_APPMT=31  TOTAL_APPMT=32	TOTAL_ON_APPMT=33  WEB_APPMTS=34

# &{paymentAnalyticsMetrics}  PRE_PAYMENT_COUNT=44  PRE_PAYMENT_TOTAL=45  BILL_PAYMENT_COUNT=46  BILL_PAYMENT_TOTAL=47

${digits}      0123456789
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${self}        0
@{empty_list}  
${count}       ${9}
${def_amt}     0.0

${SERVICE1}  Makeup  
${SERVICE2}  Hairmakeup 
${SERVICE3}  Facialmakeup 
${SERVICE4}  Bridal makeup 
${SERVICE5}  Hair remove
${SERVICE6}  Bleach
${SERVICE7}  Hair cut

${service_duration}     30


*** Test Cases ***
JD-TC-DepartmentWiseAnalytics-1
    [Documentation]   take walkin checkins for a provider and check Department wise analytics for TOTAL_FOR_TOKEN and TOTAL_ON_TOKEN

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
        Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


    # ------------ Sign up a provider with highest licence package and random domain and subdomain.
    ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+884550
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}

     ${DAY1}=  get_date
     Set Suite Variable  ${DAY1}  ${DAY1}
     ${list}=  Create List  1  2  3  4  5  6  7
     Set Suite Variable  ${list}  ${list}
     ${ph1}=  Evaluate  ${MUSERNAME_E}+1000000000
     ${ph2}=  Evaluate  ${MUSERNAME_E}+2000000000
     ${views}=  Random Element    ${Views}
     ${name1}=  FakerLibrary.name
     ${name2}=  FakerLibrary.name
     ${name3}=  FakerLibrary.name
     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
     ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
     ${bs}=  FakerLibrary.bs
     ${city}=   get_place
     ${latti}=  get_latitude
     ${longi}=  get_longitude
     ${companySuffix}=  FakerLibrary.companySuffix
     ${postcode}=  FakerLibrary.postcode
     ${address}=  get_address
     ${parking}   Random Element   ${parkingType}
     ${24hours}    Random Element    ${bool}
     ${desc}=   FakerLibrary.sentence
     ${url}=   FakerLibrary.url
     ${sTime}=  add_time  0  15
     Set Suite Variable   ${sTime}
     ${eTime}=  add_time   0  45
     Set Suite Variable   ${eTime}
     ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
     Log  ${fields.json()}
     Should Be Equal As Strings    ${fields.status_code}   200

     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
     Should Be Equal As Strings    ${resp.status_code}   200

     ${spec}=  get_Specializations  ${resp.json()}
     ${resp}=  Update Specialization  ${spec}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}   200


     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=  Enable Waitlist
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep   01s
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

     ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

    ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}
    ${acc_id}=  get_acc_id  ${MUSERNAME_E}
    
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

#     ${resp}=  Create Department For Branch  ${acc_id}  Bridal Department  Dep001  Bridal Makeups  ACTIVE  
#     Log To Console  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${depid1}  ${resp.content}

      ${dep_name1}=  FakerLibrary.bs
      ${dep_code1}=   Random Int  min=100   max=999
      ${dep_desc1}=   FakerLibrary.word  
      ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
      Log  ${resp1.content}
      Should Be Equal As Strings  ${resp1.status_code}  200
      Set Suite Variable  ${depid1}  ${resp1.json()}


     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+226445
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${address}=  get_address
     Set Suite Variable  ${address}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL} 
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+226446
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
     ${firstname1}=  FakerLibrary.name
     Set Suite Variable  ${firstname1}
     ${lastname1}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname1}
     ${address1}=  get_address
     Set Suite Variable  ${address1}
     ${dob1}=  FakerLibrary.Date
     Set Suite Variable  ${dob1}
     # ${pin1}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin1}
     FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Test Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${depid1}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}
     
     sleep  4s
    ${resp}=  Get Users By Department  ${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  1  id=${u_id}  firstName=${firstname}  lastName=${lastname}   primaryMobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U1}.${test_mail}    state=${state}
    # Should Be Equal As Strings  ${resp.json()[1]['city']}      ${city}    ignore_case=True
    # Verify Response List  ${resp}  2  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}   primaryMobileNo=${PUSERNAME_U2}  dob=${dob1}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U2}.${test_mail}   state=${state1}
    # Should Be Equal As Strings  ${resp.json()[2]['city']}      ${city1}    ignore_case=True

    FOR  ${i}  IN RANGE   5
        ${ser_names}=  FakerLibrary.Words  	nb=30
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
        Exit For Loop If  '${kw_status}'=='True'
    END

    Set Suite Variable  ${ser_names}

    # ${SERVICE2}=    Set Variable  ${ser_names[5]}
    # ${min_pre}=   Random Int   min=10   max=50
    # ${servicecharge}=   Random Int  min=100  max=200
    # ${s_id1}=  Create Sample Service with Prepayment   ${SERVICE2}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    # Set Suite Variable  ${s_id1}

    ${SERVICE3}=    Set Variable  ${ser_names[0]}
    # ${SERVICE3}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}    department=${depid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()}

    ${SERVICE4}=    Set Variable  ${ser_names[1]}
    # ${SERVICE3}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE4}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=52
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}    department=${dep_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid4}  ${resp.json()}

    ${resp}=  Sample Queue   ${lid}   ${sid3}   ${sid4} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}
    ${DAY2}=  add_date  10      
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_time  0  15
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_time   2  30
    Set Suite Variable   ${eTime1}

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}

    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dur1}=  FakerLibrary.Random Int  min=10  max=20
    Set Suite Variable  ${dur1}

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${depid1}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${resp}=   Get Service By Id  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  20  20  ${lid}  ${u_id1}    ${s_id2}   
    # ${sid3}   ${sid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Queues
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200


    ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${queue_name1}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue For User  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  20  20  ${lid}  ${u_id}    ${s_id}   
    # ${sid3}   ${sid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    

    # ------------------- Add customers and take checkin  -------------------
    # comment  Add customers and take check-ins

     FOR   ${a}  IN RANGE   ${count}
            
        ${PO_Number}    Generate random string    7    0123456789
        ${cons_num}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${cons_num}
        ${firstname}=  FakerLibrary.name    
        ${lastname}=  FakerLibrary.last_name
        Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
        ${resp}=  AddCustomer  ${CUSERPH${a}}   firstName=${firstname}   lastName=${lastname}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END

    ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${walkin_waitlist_ids}=  Create List
    Set Suite Variable   ${walkin_waitlist_ids}

    ${service_count}=  Create List
    Set Suite Variable   ${service_count}
    
    FOR   ${a}  IN RANGE   ${count}
            
        ${desc}=   FakerLibrary.word

        ${resp}=  Add To Waitlist By User  ${cid${a}}  ${s_id2}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id1}  ${cid${a}} 
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        ${resp}=  Get Waitlist By Id  ${wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${walkin_waitlist_ids}  ${wid${a}}
        Append To List   ${service_count}  ${wid${a}}

    END

    ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
            
        ${desc}=   FakerLibrary.word

        ${resp}=  Add To Waitlist By User  ${cid${a}}  ${s_id}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid${a}} 
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        ${resp}=  Get Waitlist By Id  ${wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${walkin_waitlist_ids}  ${wid${a}}
        Append To List   ${service_count}  ${wid${a}}

    END

    ${resp}=  GetCustomer
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_cust}=  Get Length  ${resp.json()}

    Log List   ${walkin_waitlist_ids}

    ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids)
    Set Suite Variable   ${walkin_token_len}

    ${service_count_len}=   Evaluate  len($service_count)
    Set Suite Variable   ${service_count_len}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # sleep  05s

    ${resp}=  Get Account Level Analytics   ${DeptWiseMetric['TOTAL_FOR_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}  deptId=${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${DeptWiseMetric['TOTAL_FOR_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${service_count_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${DeptWiseMetric['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}  deptId=${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${DeptWiseMetric['TOTAL_ON_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${service_count_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues']}   ${empty_list}

JD-TC-DepartmentWiseAnalytics-2
    [Documentation]   take prepayment checkin for a provider and check Department wise analytics for TOTAL_FOR_TOKEN and TOTAL_ON_TOKEN

    ${resp}=   Provider Login  ${PUSERNAME_U2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${SERVICE2}=    Set Variable  ${ser_names[5]}
    ${min_pre}=   Random Int   min=10   max=50
    ${servicecharge}=   Random Int  min=100  max=200
    ${s_id1}=  Create Sample Service with Prepayment   ${SERVICE2}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10    department=${depid1}
    Set Suite Variable  ${s_id1}

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${time_now}=  db.get_time
    ${etime}=  Set Variable  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}
    ${eTime1}=  add_two   ${etime}  120
    ${resp}=  Update Queue  ${q_id1}  ${resp.json()['name']}  ${resp.json()['queueSchedule']['recurringType']}  ${resp.json()['queueSchedule']['repeatIntervals']}
    ...  ${resp.json()['queueSchedule']['startDate']}  ${EMPTY}  ${EMPTY}  ${resp.json()['queueStartTime']}  ${resp.json()['queueEndTime']}
    ...  ${resp.json()['parallelServing']}   ${resp.json()['capacity']}  ${lid}  ${s_id1}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${prepay_walkin_waitlist_ids}=  Create List
    Set Suite Variable   ${prepay_walkin_waitlist_ids}
    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()[0]['id']}
        
        ${desc}=   FakerLibrary.word
        ${resp}=  Add To Waitlist  ${cid${a}}  ${s_id1}  ${q_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        Append To List   ${prepay_walkin_waitlist_ids}  ${wid${a}}

    END

    Log List   ${prepay_walkin_waitlist_ids}

    ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids) + len($prepay_walkin_waitlist_ids)
    Set Suite Variable   ${walkin_token_len}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END



JD-TC-DepartmentWiseAnalytics-1
    [Documentation]   take walkin checkins for a provider and check Department wise analytics for TOTAL_FOR_TOKEN and TOTAL_ON_TOKEN

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
        Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}

        ${resp}=  Consumer Logout
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

    END


    # ------------ Sign up a provider with highest licence package and random domain and subdomain.
    ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+884555
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}

     ${DAY1}=  get_date
     Set Suite Variable  ${DAY1}  ${DAY1}
     ${list}=  Create List  1  2  3  4  5  6  7
     Set Suite Variable  ${list}  ${list}
     ${ph1}=  Evaluate  ${MUSERNAME_E}+1000000000
     ${ph2}=  Evaluate  ${MUSERNAME_E}+2000000000
     ${views}=  Random Element    ${Views}
     ${name1}=  FakerLibrary.name
     ${name2}=  FakerLibrary.name
     ${name3}=  FakerLibrary.name
     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
     ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
     ${bs}=  FakerLibrary.bs
     ${city}=   get_place
     ${latti}=  get_latitude
     ${longi}=  get_longitude
     ${companySuffix}=  FakerLibrary.companySuffix
     ${postcode}=  FakerLibrary.postcode
     ${address}=  get_address
     ${parking}   Random Element   ${parkingType}
     ${24hours}    Random Element    ${bool}
     ${desc}=   FakerLibrary.sentence
     ${url}=   FakerLibrary.url
     ${sTime}=  add_time  0  15
     Set Suite Variable   ${sTime}
     ${eTime}=  add_time   0  45
     Set Suite Variable   ${eTime}
     ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
     Log  ${fields.json()}
     Should Be Equal As Strings    ${fields.status_code}   200

     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
     Should Be Equal As Strings    ${resp.status_code}   200

     ${spec}=  get_Specializations  ${resp.json()}
     ${resp}=  Update Specialization  ${spec}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}   200


     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=  Enable Waitlist
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep   01s
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

     ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

    ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}
    ${acc_id}=  get_acc_id  ${MUSERNAME_E}
    
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp}' != '${None}'   Log   ${resp.json()}
    Run Keyword If  '${resp}' != '${None}'   Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

#     ${resp}=  Create Department For Branch  ${acc_id}  Bridal Department  Dep001  Bridal Makeups  ACTIVE  
#     Log To Console  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${depid1}  ${resp.content}

      ${dep_name1}=  FakerLibrary.bs
      ${dep_code1}=   Random Int  min=100   max=999
      ${dep_desc1}=   FakerLibrary.word  
      ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
      Log  ${resp1.content}
      Should Be Equal As Strings  ${resp1.status_code}  200
      Set Suite Variable  ${depid1}  ${resp1.json()}

      ${dep_name2}=  FakerLibrary.bs
      ${dep_code2}=   Random Int  min=100   max=999
      ${dep_desc2}=   FakerLibrary.word  
      ${resp1}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc2} 
      Log  ${resp1.content}
      Should Be Equal As Strings  ${resp1.status_code}  200
      Set Suite Variable  ${depid2}  ${resp1.json()}

      ${dep_name3}=  FakerLibrary.bs
      ${dep_code3}=   Random Int  min=100   max=999
      ${dep_desc3}=   FakerLibrary.word  
      ${resp1}=  Create Department  ${dep_name3}  ${dep_code3}  ${dep_desc3} 
      Log  ${resp1.content}
      Should Be Equal As Strings  ${resp1.status_code}  200
      Set Suite Variable  ${depid3}  ${resp1.json()}

      ${dep_name4}=  FakerLibrary.bs
      ${dep_code4}=   Random Int  min=100   max=999
      ${dep_desc4}=   FakerLibrary.word  
      ${resp1}=  Create Department  ${dep_name4}  ${dep_code4}  ${dep_desc4} 
      Log  ${resp1.content}
      Should Be Equal As Strings  ${resp1.status_code}  200
      Set Suite Variable  ${depid4}  ${resp1.json()}


     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+2746445
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${address}=  get_address
     Set Suite Variable  ${address}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL} 
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+228846
     clear_users  ${PUSERNAME_U2}
     Set Suite Variable  ${PUSERNAME_U2}
     ${firstname1}=  FakerLibrary.name
     Set Suite Variable  ${firstname1}
     ${lastname1}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname1}
     ${address1}=  get_address
     Set Suite Variable  ${address1}
     ${dob1}=  FakerLibrary.Date
     Set Suite Variable  ${dob1}
     # ${pin1}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin1}
     FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Test Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${depid1}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id1}  ${resp.json()}

    ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+2278444
     clear_users  ${PUSERNAME_U3}
     Set Suite Variable  ${PUSERNAME_U3}
     ${firstname1}=  FakerLibrary.name
     Set Suite Variable  ${firstname1}
     ${lastname1}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname1}
     ${address1}=  get_address
     Set Suite Variable  ${address1}
     ${dob1}=  FakerLibrary.Date
     Set Suite Variable  ${dob1}
     # ${pin1}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin1}
     FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Test Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${depid2}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id2}  ${resp.json()}

    ${PUSERNAME_U4}=  Evaluate  ${PUSERNAME}+228445
     clear_users  ${PUSERNAME_U4}
     Set Suite Variable  ${PUSERNAME_U4}
     ${firstname1}=  FakerLibrary.name
     Set Suite Variable  ${firstname1}
     ${lastname1}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname1}
     ${address1}=  get_address
     Set Suite Variable  ${address1}
     ${dob1}=  FakerLibrary.Date
     Set Suite Variable  ${dob1}
     # ${pin1}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin1}
     FOR    ${i}    IN RANGE    3
        ${pin1}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin1}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${city1}   ${resp.json()[0]['PostOffice'][0]['District']}   
     Set Test Variable  ${state1}  ${resp.json()[0]['PostOffice'][0]['State']}      
     Set Test Variable  ${pin1}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U4}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U4}  ${depid3}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id3}  ${resp.json()}
     
    sleep  01s
    ${resp}=  Get Users By Department  ${dep_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List  ${resp}  1  id=${u_id}  firstName=${firstname}  lastName=${lastname}   primaryMobileNo=${PUSERNAME_U1}  dob=${dob}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U1}.${test_mail}    state=${state}
    # Should Be Equal As Strings  ${resp.json()[1]['city']}      ${city}    ignore_case=True
    # Verify Response List  ${resp}  2  id=${u_id1}  firstName=${firstname1}  lastName=${lastname1}   primaryMobileNo=${PUSERNAME_U2}  dob=${dob1}  gender=${Genderlist[0]}  email=${P_Email}${PUSERNAME_U2}.${test_mail}   state=${state1}
    # Should Be Equal As Strings  ${resp.json()[2]['city']}      ${city1}    ignore_case=True

    FOR  ${i}  IN RANGE   5
        ${ser_names}=  FakerLibrary.Words  	nb=30
        ${kw_status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${ser_names}
        Exit For Loop If  '${kw_status}'=='True'
    END

    Set Suite Variable  ${ser_names}

    # ${SERVICE2}=    Set Variable  ${ser_names[5]}
    # ${min_pre}=   Random Int   min=10   max=50
    # ${servicecharge}=   Random Int  min=100  max=200
    # ${s_id1}=  Create Sample Service with Prepayment   ${SERVICE2}  ${min_pre}  ${servicecharge}  maxBookingsAllowed=10
    # Set Suite Variable  ${s_id1}

    ${SERVICE3}=    Set Variable  ${ser_names[0]}
    # ${SERVICE3}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}    department=${depid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()}

    ${SERVICE4}=    Set Variable  ${ser_names[1]}
    # ${SERVICE3}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE4}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=52
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE4}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}   department=${dep_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid4}  ${resp.json()}

    ${resp}=  Sample Queue   ${lid}   ${sid3}   ${sid4} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}
    ${DAY2}=  add_date  10      
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_time  0  15
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_time   2  30
    Set Suite Variable   ${eTime1}

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}

    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dur1}=  FakerLibrary.Random Int  min=10  max=20
    Set Suite Variable  ${dur1}

    # ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${depid1}  ${u_id1}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${s_id2}  ${resp.json()}
    # ${resp}=   Get Service By Id  ${s_id2}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  20  20  ${lid}  ${u_id}    ${s_id}   
    # ${sid3}   ${sid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Queues
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200


    # ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${queue_name1}=  FakerLibrary.bs
    # Set Suite Variable  ${queue_name}
    # ${resp}=  Create Queue For User  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  20  20  ${lid}  ${u_id}    ${s_id}   
    # # ${sid3}   ${sid4}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
    

    # ------------------- Add customers and take checkin  -------------------
    # comment  Add customers and take check-ins

     FOR   ${a}  IN RANGE   ${count}
            
        ${PO_Number}    Generate random string    7    0123456789
        ${cons_num}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${cons_num}
        ${firstname}=  FakerLibrary.name    
        ${lastname}=  FakerLibrary.last_name
        Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
        ${resp}=  AddCustomer  ${CUSERPH${a}}   firstName=${firstname}   lastName=${lastname}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END

    # ${resp}=  ProviderLogin  ${PUSERNAME_U2}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${walkin_waitlist_ids}=  Create List
    Set Suite Variable   ${walkin_waitlist_ids}

    ${service_count}=  Create List
    Set Suite Variable   ${service_count}
    
    # FOR   ${a}  IN RANGE   ${count}
            
    #     ${desc}=   FakerLibrary.word

    #     ${resp}=  Add To Waitlist By User  ${cid${a}}  ${s_id2}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id1}  ${cid${a}} 
    #     Log   ${resp.json()}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     ${wid}=  Get Dictionary Values  ${resp.json()}
    #     Set Test Variable  ${wid${a}}  ${wid[0]}

    #     ${resp}=  Get Waitlist By Id  ${wid${a}}
    #     Log  ${resp.json()} 
    #     Should Be Equal As Strings  ${resp.status_code}  200

    #     Append To List   ${walkin_waitlist_ids}  ${wid${a}}
    #     Append To List   ${service_count}  ${wid${a}}

    # END

    ${resp}=  ProviderLogin  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    FOR   ${a}  IN RANGE   ${count}
            
        ${desc}=   FakerLibrary.word

        ${resp}=  Add To Waitlist By User  ${cid${a}}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid${a}} 
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        ${resp}=  Get Waitlist By Id  ${wid${a}}
        Log  ${resp.json()} 
        Should Be Equal As Strings  ${resp.status_code}  200

        Append To List   ${walkin_waitlist_ids}  ${wid${a}}
        Append To List   ${service_count}  ${wid${a}}

    END

    ${resp}=  GetCustomer
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_cust}=  Get Length  ${resp.json()}

    Log List   ${walkin_waitlist_ids}

    ${walkin_token_len}=   Evaluate  len($walkin_waitlist_ids)
    Set Suite Variable   ${walkin_token_len}

    ${service_count_len}=   Evaluate  len($service_count)
    Set Suite Variable   ${service_count_len}

    sleep  01s
    # sleep  05m

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    # sleep  05s

    ${resp}=  Get Account Level Analytics   ${DeptWiseMetric['TOTAL_FOR_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}  deptId=${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${DeptWiseMetric['TOTAL_FOR_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${service_count_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${DeptWiseMetric['TOTAL_ON_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}  deptId=${dep_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${DeptWiseMetric['TOTAL_ON_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${service_count_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['WALK_IN_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${tokenAnalyticsMetrics['ARRIVED_TOKEN']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${walkin_token_len}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

    ${resp}=  Get Account Level Analytics  ${tokenAnalyticsMetrics['CHECKED_IN_TOKEN']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues']}   ${empty_list}
