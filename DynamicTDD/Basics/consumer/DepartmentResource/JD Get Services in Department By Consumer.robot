*** Settings ***
Suite Teardown    Delete All Sessions  
Test Teardown     Delete All Sessions
Force Tags        Department
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${service_duration}     30

*** Test Cases ***
JD-TC-Create Services and Enable Department
    [Documentation]  Provider Get Services in Department By Consumer

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_K}=  Evaluate  ${PUSERNAME}+423826
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_K}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_K}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_K}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_K}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_K}${\n}
    Set Suite Variable  ${PUSERNAME_K}

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    
    ${acc_id}=  get_acc_id  ${PUSERNAME_K}
    Set Suite Variable  ${acc_id}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${PUSERNAME_K}+1000000000
    ${ph2}=  Evaluate  ${PUSERNAME_K}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_K}.${test_mail}  ${views}
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
    ${sTime}=  db.subtract_timezone_time  ${tz}  3  00
    Set Suite Variable  ${BsTime30}  ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  2  30  
    Set Suite Variable  ${BeTime30}  ${eTime}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # sleep   02s

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    Set Test Variable  ${email_id}  ${P_Email}${PUSERNAME_K}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname_A}  ${lastname_A}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}
        ${resp}=  Enable Waitlist
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    # sleep   01s

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
    

    ${SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}

    ${SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}

    ${SERVICE3}=    FakerLibrary.word
    Set Suite Variable  ${SERVICE3}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()}

    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-Get Services in Department By Consumer-UH1
    [Documentation]  Get Services in Department By Consumer without login
    ${resp}=  Get Services in Department By Consumer  ${acc_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"

JD-TC-Get Services in Department By Consumer-UH2
    [Documentation]  Get Services in Department By Consumer using invalid acc_id
    
    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Services in Department By Consumer  000
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${ACCOUNT_NOT_EXIST}"

JD-TC-Get Services in Department By Consumer-1
    [Documentation]  Provider Get Services in Department By Consumer
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}   ${sid1}  ${sid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}
    ${resp}=  Get Departments 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depname0}  ${resp.json()['departments'][0]['departmentName']}
    Set Suite Variable  ${depid0}    ${resp.json()['departments'][0]['departmentId']}
    Set Suite Variable  ${depcode0}  ${resp.json()['departments'][0]['departmentCode']}
    Set Suite Variable  ${depdesc0}  ${resp.json()['departments'][0]['departmentDescription']}
    Set Suite Variable  ${sid0}      ${resp.json()['departments'][0]['serviceIds'][0]}

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # sleep   2s
    ${resp}=  Get Services in Department By Consumer  ${acc_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Suite Variable   ${len}

    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()['departments'][${i}]['departmentId']}' == '${depid1}'  
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentName']}          ${dep_name1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentCode']}          ${dep_code1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentDescription']}   ${dep_desc1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentStatus']}        ${status[0]}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][0]}           ${sid1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][1]}           ${sid2}

        ELSE 

            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentName']}          ${depname0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentId']}            ${depid0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentCode']}          ${depcode0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentDescription']}   ${depdesc0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentStatus']}        ${status[0]}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][0]}           ${sid0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][1]}           ${sid3}

        END    
    END

JD-TC-Get Services in Department By Consumer-2

    [Documentation]  Provider Create department using Service names then Get Services in Department By Consumer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code2}
    ${dep_desc2}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc2}

    ${SERVICE1}=	   FakerLibrary.Word
    ${SERVICE2}=	   FakerLibrary.Word
    ${SERVICE3}=	   FakerLibrary.Word
    
    ${resp}=  Create Department With ServiceName  ${dep_name2}  ${dep_code2}  ${dep_desc2}   ${SERVICE1}  ${SERVICE2}  ${SERVICE3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid2}  ${resp.json()}
    ${resp}=  Get Department ById  ${depid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Service
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid4}  ${resp.json()[2]['id']}
    Set Suite Variable  ${sid5}  ${resp.json()[1]['id']}
    Set Suite Variable  ${sid6}  ${resp.json()[0]['id']}

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # sleep  4s
    ${resp}=  Get Services in Department By Consumer  ${acc_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Suite Variable   ${len}

    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()['departments'][${i}]['departmentId']}' == '${depid0}' 

            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentName']}          ${depname0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentId']}            ${depid0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentCode']}          ${depcode0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentDescription']}   ${depdesc0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentStatus']}        ${status[0]}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][0]}           ${sid0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][1]}           ${sid3}

        ELSE IF   '${resp.json()['departments'][${i}]['departmentId']}' == '${depid1}' 

            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentName']}          ${dep_name1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentId']}            ${depid1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentCode']}          ${dep_code1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentDescription']}   ${dep_desc1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentStatus']}        ${status[0]}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][0]}           ${sid1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][1]}           ${sid2}

        ELSE IF   '${resp.json()['departments'][${i}]['departmentId']}' == '${depid2}' 

            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentName']}          ${dep_name2}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentId']}            ${depid2}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentCode']}          ${dep_code2}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentDescription']}   ${dep_desc2}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentStatus']}        ${status[0]}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][0]}           ${sid4}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][1]}           ${sid5}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][2]}           ${sid6}
            ${count}=  Get Length  ${resp.json()['departments'][${i}]['serviceIds']} 
            Should Be Equal As Integers  ${count}  3

        END
    END


JD-TC-Get Services in Department By Consumer-3

    [Documentation]  Provider Create department without Service names then Get Services in Department By Consumer

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${dep_name3}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name3}
    ${dep_code3}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code3}
    ${dep_desc3}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc3}
    ${resp}=  Create Department With ServiceName  ${dep_name3}  ${dep_code3}  ${dep_desc3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid3}  ${resp.json()}
    ${resp}=  Get Department ById  ${depid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # sleep  4s
    ${resp}=  Get Services in Department By Consumer  ${acc_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Set Suite Variable   ${len}

    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()['departments'][${i}]['departmentId']}' == '${depid0}' 

            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentName']}          ${depname0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentId']}            ${depid0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentCode']}          ${depcode0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentDescription']}   ${depdesc0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentStatus']}        ${status[0]}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][0]}           ${sid0}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][1]}           ${sid3}

        ELSE IF   '${resp.json()['departments'][${i}]['departmentId']}' == '${depid1}' 

            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentName']}          ${dep_name1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentId']}            ${depid1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentCode']}          ${dep_code1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentDescription']}   ${dep_desc1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentStatus']}        ${status[0]}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][0]}           ${sid1}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][1]}           ${sid2}

        ELSE IF   '${resp.json()['departments'][${i}]['departmentId']}' == '${depid2}' 

            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentName']}          ${dep_name2}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentId']}            ${depid2}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentCode']}          ${dep_code2}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentDescription']}   ${dep_desc2}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['departmentStatus']}        ${status[0]}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][0]}           ${sid4}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][1]}           ${sid5}
            Should Be Equal As Strings  ${resp.json()['departments'][${i}]['serviceIds'][2]}           ${sid6}
            ${count}=  Get Length  ${resp.json()['departments'][${i}]['serviceIds']} 
            Should Be Equal As Integers  ${count}  3
        END
    END

    Should Not Contain          ${resp.json()}      ${dep_name3}