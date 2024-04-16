*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Signup  Appointment  Waitlist
Library           Collections
Library           OperatingSystem
Library           String
Library           json
Library           random
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot

*** Variables ***
# ${sTime}  05:00 AM
# ${eTime}  11:00 PM
# ${licpkgid}    1
# ${licpkgname}   basic
@{Views}  self  all  customersOnly


*** Test Cases ***

JD-TC-Provider_Signup-1
    [Documentation]   Provider Signup in Random Domain 

    Create Directory   ${EXECDIR}/TDD/${ENVIRONMENT}data/
    Create Directory   ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/
    # Create File   ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/providers.py
    
    # ${PO_Number}=  FakerLibrary.Numerify  %#####
    # ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Log  ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/providers.py
    ${num}=  find_last  ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/providers.py
    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PUSERPH0}  555${PH_Number}
    FOR  ${index}  IN RANGE   5
        ${num}=  Evaluate   ${num}+1
        ${ph}=  Evaluate   ${PUSERPH0}+${index}
        Log   ${ph}
        # Set Suite Variable  ${ph}
        ${ph1}=  Evaluate  ${ph}+1000000000
        ${ph2}=  Evaluate  ${ph}+2000000000
        # ${licresp}=   Get Licensable Packages
        # Should Be Equal As Strings  ${licresp.status_code}  200
        # # Log   ${licresp.content}
        # ${liclen}=  Get Length  ${licresp.json()}
        # Set Test Variable  ${licpkgid}  ${licresp.json()[0]['pkgId']}
        # Set Test Variable  ${licpkgname}  ${licresp.json()[0]['displayName']}
        ${licpkgid}  ${licpkgname}=  get_highest_license_pkg
        ${corp_resp}=   get_iscorp_subdomains  1
        ${resp}=  Get BusinessDomainsConf
        # Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${dom_len}=  Get Length  ${resp.json()}
        ${dom}=  random.randint  ${0}  ${dom_len-1}
        ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
        Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
        Log   ${domain}
        
        FOR  ${subindex}  IN RANGE  ${sdom_len}
            ${sdom}=  random.randint  ${0}  ${sdom_len-1}
            Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
            ${is_corp}=  check_is_corp  ${subdomain}
            Exit For Loop If  '${is_corp}' == 'False'
        END
        Log   ${subdomain}
        ${fname}=  FakerLibrary.name
        ${lname}=  FakerLibrary.lastname
        ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${domain}  ${subdomain}  ${ph}  ${licpkgid}
        # Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Activation  ${ph}  0
        # Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
        # Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  03s
        ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        Append To File  ${EXECDIR}/TDD/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt  ${ph} - ${PASSWORD}${\n}
        Append To File  ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/providers.py  PUSERNAME${num}=${ph}${\n}
        
        ${list}=  Create List  1  2  3  4  5  6  7
        ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
        ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
        ${views}=  Evaluate  random.choice($Views)  random
        ${name1}=  FakerLibrary.name
        ${name2}=  FakerLibrary.name
        ${name3}=  FakerLibrary.name
        ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
        ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
        ${emails1}=  Emails  ${name3}  Email  ${P_Email}${ph}.${test_mail}  ${views}
        ${bs}=  FakerLibrary.bs
        ${companySuffix}=  FakerLibrary.companySuffix
        ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
        ${parking}   Random Element   ${parkingType}
        ${24hours}    Random Element    ['True','False']
        ${desc}=   FakerLibrary.sentence
        ${url}=   FakerLibrary.url
        ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
        Set Suite Variable  ${tz}
        ${DAY1}=  db.get_date_by_timezone  ${tz}
        ${Time}=  db.get_time_by_timezone  ${tz}
        ${sTime}=  db.add_timezone_time  ${tz}  0  15  
        ${eTime}=  db.add_timezone_time  ${tz}  0  45  
        ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
        # Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${account_id}  ${resp.json()['id']}

        ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
        Log  ${fields.content}
        Should Be Equal As Strings    ${fields.status_code}   200

        ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

        ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${spec}=  get_Specializations  ${resp.json()}
        
        ${resp}=  Update Specialization  ${spec}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Get Features  ${subdomain}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${service_name}  ${resp.json()['features']['defaultServices'][0]['service']}
        Set Test Variable  ${service_duration}  ${resp.json()['features']['defaultServices'][0]['duration']}
        Set Test Variable  ${service_status}  ${resp.json()['features']['defaultServices'][0]['status']}    

        ${resp}=  Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response List   ${resp}  0  name=${service_name}  status=${service_status}  serviceDuration=${service_duration}

        ${resp}=  Get Order Settings by account id
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}
        # Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
        # Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${fname}
        # Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${lname}
        # Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${ph}
    
    END

    #     ############For Appointment##############3

    #     ${resp}=   Get License UsageInfo 
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    #     ${resp}=  Get Business Profile
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Set Test Variable  ${bname}  ${resp.json()['businessName']}
    #     Set Test Variable  ${pid}  ${resp.json()['id']}
    #     Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

    #     ${resp}=   Get jaldeeIntegration Settings
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
    #         ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    #         Should Be Equal As Strings  ${resp1.status_code}  200
    #     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
    #         ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    #         Should Be Equal As Strings  ${resp1.status_code}  200
    #     END

    #     ${resp}=   Get jaldeeIntegration Settings
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    #     # ${resp}=  Get Account Payment Settings
    #     # Log  ${resp.content}
    #     # Should Be Equal As Strings  ${resp.status_code}  200
    
    #     # IF  ${resp.json()['onlinePayment']}==${bool[0]}
    #     #     ${resp1}=    Enable Disable Online Payment   ${toggle[0]}
    #     #     Log  ${resp1.content}
    #     #     Should Be Equal As Strings  ${resp1.status_code}  200
    #     # END

    #     # ${resp}=  Get Account Payment Settings
    #     # Log  ${resp.content}
    #     # Should Be Equal As Strings  ${resp.status_code}  200

    #     ${resp}=  Get jp finance settings
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    #     IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
    #         ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
    #         Log  ${resp1.content}
    #         Should Be Equal As Strings  ${resp1.status_code}  200
    #     END

    #     ${resp}=  Get jp finance settings    
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    #     ${resp}=   Get Appointment Settings
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     IF  ${resp.json()['enableAppt']}==${bool[0]}   
    #         ${resp}=   Enable Appointment 
    #         Should Be Equal As Strings  ${resp.status_code}  200
    #     END

    #     ${resp}=   Get Appointment Settings
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    #     Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 

    #     ${resp}=   Get Service
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    #     ${resp}=    Get Locations
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    #     ${lid}=  Create Sample Location  
    #     ${resp}=   Get Location ById  ${lid}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    #     ${resp}=    Get Locations
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
        
    #     comment  Services for check-ins
        
    #     ${SERVICE1}=    FakerLibrary.job
    #     ${min_pre}=   Random Int   min=10   max=50
    #     ${servicecharge}=   Random Int  min=100  max=200
    #     ${s_id}=  Create Sample Service with Prepayment   ${SERVICE1}  ${min_pre}  ${servicecharge}

    #     ${SERVICE1}=    FakerLibrary.job
    #     ${s_id1}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=10
    #     Set Suite Variable  ${s_id1}

    #     ${resp}=  Get Appointment Schedules
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    #     ${DAY1}=  db.get_date_by_timezone  ${tz}
    #     ${DAY2}=  db.add_timezone_date  ${tz}  10        
    #     ${DAY3}=  db.add_timezone_date  ${tz}  4  
    #     ${list}=  Create List  1  2  3  4  5  6  7
    #     ${sTime1}=  db.get_time_by_timezone  ${tz}
    #     ${delta}=  FakerLibrary.Random Int  min=10  max=60
    #     ${eTime1}=  add_two   ${sTime1}  ${delta}
    #     ${schedule_name}=  FakerLibrary.bs
    #     ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    #     ${maxval}=  Convert To Integer   ${delta/4}
    #     ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    #     ${bool1}=  Random Element  ${bool}
    #     ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  ${s_id1}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Set Test Variable  ${sch_id}  ${resp.json()}

    #     ${resp}=  Get Appointment Schedule ById  ${sch_id}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}  
    #     ...   parallelServing=${parallel}  batchEnable=${bool1}

    #     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200
    #     Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}

    #     ${resp}=  Provider Logout
    #     Log  ${resp.content}
    #     Should Be Equal As Strings    ${resp.status_code}    200
        
    # END

# *** Comments ***
# JD-TC-Consumer_Signup-1
#     [Documentation]   Consumer Signup

#     ${PH_Number}    Random Number 	digits=5 
#     ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
#     Log  ${PH_Number}
#     Set Suite Variable  ${CUSERPH0}  555${PH_Number}
#     ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${address}=  FakerLibrary.address
#     ${dob}=  FakerLibrary.Date
#     ${gender}    Random Element    ${Genderlist}
#     ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Activation  ${CUSERPH0}  ${OtpPurpose['ConsumerSignUp']}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200



# *** Comments ***
JD-TC-AddToWL-1
    [Documentation]   Add To waitlist
    ${cust_pro}=  Evaluate  random.choice(list(open('${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/providers.py')))  random
    Log  ${cust_pro}
    # ${cust_pro}=    Remove String    ${cust_pro}    ${SPACE}
    # ${cust_pro}=    Remove String    ${cust_pro}    ${\n}
    ${cust_pro}=   Set Variable  ${cust_pro.strip()}
    ${var} 	${ph}=   Split String    ${cust_pro}  =  
    Set Suite Variable  ${ph}

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    # Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ser_durtn}=   Random Int   min=2   max=2
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_durtn}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${Empty}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}
        ${resp}=  Enable Waitlist
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${SERVICE1}=    FakerLibrary.job
        ${s_id}=  Create Sample Service  ${SERVICE1}
    ELSE
        Set Test Variable   ${s_id}   ${resp.json()[0]['id']}
    END

    ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${prepay_appt_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${prepay_appt_len}

        ${resp1}=  Waitlist Action  ${waitlist_actions[4]}   ${resp.json()[${i}]['uid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        
    END
    
    ${resp}=  Get Waitlist Today   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${today_appt_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${today_appt_len}

        ${resp1}=  Waitlist Action  ${waitlist_actions[4]}   ${resp.json()[${i}]['uid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200      

    END

    ${resp}=  Get Waitlist Future
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${future_appt_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${future_appt_len}

        ${resp1}=  Waitlist Action  ${waitlist_actions[4]}   ${resp.json()[${i}]['uid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        
    END

    ${resp}=  Get Queues
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${queues_count}=  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${queues_count}

        ${resp1}=  Disable Queue  ${resp.json()[${i}]['id']}
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200

    END

    ${DAY}=  get_date_by_timezone  ${tz}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${p1queue1}=    FakerLibrary.job
    ${capacity}=  FakerLibrary.Numerify  %%
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERPH0}  firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${q_id1}  ${DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wlresp}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wlresp[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-TakeAppointment-1
    [Documentation]   Take appointment
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    # Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

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
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp1}=  Enable Appointment
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 
    
    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${SERVICE1}=    FakerLibrary.Word
        ${s_id}=  Create Sample Service  ${SERVICE1}
    ELSE
        Set Test Variable   ${s_id}   ${resp.json()[0]['id']}
    END

    ${resp}=  Get Appointments Today  apptStatus-eq=${apptStatus[1]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${prepay_appt_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${prepay_appt_len}

        ${resp1}=  Appointment Action   ${apptStatus[6]}   ${resp.json()[${i}]['uid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        
    END
    
    ${resp}=  Get Appointments Today
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${today_appt_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${today_appt_len}

        ${resp1}=  Appointment Action   ${apptStatus[6]}   ${resp.json()[${i}]['uid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        
    END

    ${resp}=  Get Future Appointments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${future_appt_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${future_appt_len}

        ${resp1}=  Appointment Action   ${apptStatus[6]}   ${resp.json()[${i}]['uid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        
    END

    ${resp}=  Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${schedules_count}=  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${schedules_count}

        ${resp1}=  Disable Appointment Schedule  ${resp.json()[${i}]['id']}
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200

    END

    ${DAY1}=  get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10
    ${sTime1}=  get_time_by_timezone  ${tz}   
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${schedule_name}=  FakerLibrary.bs
    ${parallelServing}=  FakerLibrary.Random Int  min=5  max=10
    ${consumerparallelserving}=  FakerLibrary.Random Int  min=1  max=${parallelServing}
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallelServing}  ${consumerparallelserving}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${PO_Number}    Generate random string    5    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERPH0}  firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
