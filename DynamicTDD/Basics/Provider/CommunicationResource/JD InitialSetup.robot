*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Communication
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           random
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Keywords ***

Cancel Appointment By Provider
    [Arguments]  ${appmntId}  ${cancelReason}  ${message}  
    ${data}=  Create Dictionary  cancelReason=${cancelReason}  communicationMessage=${message}  
    ${data}=    json.dumps    ${data}
    Check And Create YNW Session
    ${resp}=  PUT On Session   ynw  /provider/appointment/statuschange/Cancelled/${appmntId}    data=${data}  expected_status=any 
    RETURN  ${resp}

*** Variables ***

${PSUSERNAME}          5550004756
${PASSWORD}            Jaldee12
${test_mail}           test@jaldee.com
${count}               ${5}
@{Views}               self  all  customersOnly

*** Test Cases ***

JD-TC-Initial Setup-1

    [Documentation]   sign up

#...........signup a provider.......

    Create Directory   ${EXECDIR}/TDD/${ENVIRONMENT}data/
    Create Directory   ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/
    Log  ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/providers.py
    ${num}=  find_last  ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/providers.py

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PUSERPH0}  555${PH_Number}

    FOR  ${index}  IN RANGE   5
        ${num}=  Evaluate   ${num}+1
        ${ph}=  Evaluate   ${PUSERPH0}+${index}
        Log   ${ph}
        ${ph1}=  Evaluate  ${ph}+1000000000
        ${ph2}=  Evaluate  ${ph}+2000000000
        ${licpkgid}  ${licpkgname}=  get_highest_license_pkg
        ${corp_resp}=   get_iscorp_subdomains  1

        ${resp}=  Get BusinessDomainsConf
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
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Account Activation  ${ph}  0
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
        Log   ${resp.content}
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
        Log  ${resp.content}
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
        
        ${resp}=  Get Order Settings by account id
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
      
    END

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${resp}=  Get Account Settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  Get jp finance settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    ${resp}=  View Waitlist Settings
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=    Get Locations
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Test Variable   ${locId}

        ${resp}=   Get Location ById  ${locId}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ELSE
        Set Test Variable  ${locId}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${resp}=  Get Departments
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            Set Test Variable   ${u_id1}        ${resp.json()[${i}]['id']}
            IF   not '${user_phone}' == '${PUSERPH0}'

                ${resp}=  EnableDisable User   ${u_id1}  ${toggle[1]}
                Log   ${resp.content}
                Should Be Equal As Strings  ${resp.status_code}  200

            END
        END
    END

    ${u_id1}=  Create Sample User
    Set Test Variable   ${u_id1}
   
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}
    Set Test Variable  ${userf_name}  ${resp.json()['firstName']}
    Set Test Variable  ${userl_name}  ${resp.json()['lastName']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${empty_list}=   Create List

    ${SERVICE1}=    FakerLibrary.word
    ${s_id}=  Create Sample Service  ${SERVICE1}   department=${dep_id}   maxBookingsAllowed=10
   
    ${resp}=   Get Service By Id  ${s_id}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${ser_dur}      ${resp.json()['serviceDuration']}
    Set Test Variable   ${ser_amount}   ${resp.json()['totalAmount']}
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}

    ##....subservice creation..........

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname
   
    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}

    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${locId}  ${duration}  ${bool1}  ${s_id}
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
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    ${slots}=  Create List
    FOR   ${i}  IN RANGE   ${no_of_slots}
        ${available_slots_cnt}=  Set Variable  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']}
        FOR   ${j}  IN RANGE   ${available_slots_cnt}
            Append To List  ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${slots_len}=  Get Length  ${slots}

    ${prov_cons_list}=  Create List

    FOR   ${a}  IN RANGE   ${count}
    
        ${PH_Number}=  FakerLibrary.Numerify  %#####
        ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
        Log  ${PH_Number}
        Set Test Variable  ${CUSERPH}  555${PH_Number}
        Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${firstname}=  FakerLibrary.name
            ${lastname}=  FakerLibrary.last_name
            ${resp1}=  AddCustomer  ${CUSERPH${a}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Append To List  ${prov_cons_list}  ${resp.json()}
        ELSE
            Append To List  ${prov_cons_list}  ${resp.json()[${a}]['id']}
            Append To List  ${prov_cons_list}  ${resp.json()[${a}]['firstName']}
        END
    END

    ${resp}=  GetCustomer  phoneNo-eq=${prov_cons_list[0]}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()[0]['id']}

    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slots[0]}
    ${apptfor}=   Create List  ${apptfor1}

#...........take walkin Appointment..................

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get From Dictionary  ${resp.json()}  ${firstname}
    Set Suite Variable  ${walkin_appt1}  ${apptid}

    ${resp}=  Get Appointment EncodedID   ${walkin_appt1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${encId1}  ${resp.json()}

    ${resp}=  Get Appointment By Id   ${walkin_appt1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}                ${walkin_appt1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId1}

#.........cancel appointment by provider...........

    ${resp}=    Get Default Messages 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${reason}=  Random Element  ${cancelReason}
    ${msg}=   FakerLibrary.word
    Append To File  ${EXECDIR}/data/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
    ${resp}=    Cancel Appointment By Provider  ${walkin_appt1}  ${reason}  ${msg}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    










