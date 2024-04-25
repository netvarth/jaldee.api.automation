***Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        DeActivate
Library           Collections
Library           String
Library           json
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Library           /ebs/TDD/db.py

*** Variables ***

${parallel}           1
${self}               0
@{emptylist}

*** Keywords ***
DeActivate Service Provider  
    
    Check And Create YNW Session
    ${resp}=  DELETE On Session  ynw   provider/login/deActivate   expected_status=any
    RETURN  ${resp}

*** Test Cases ***

JD-TC-DeActivate Service Provider -1
    [Documentation]   Login a Provider and deActivate that provider.

    # ${domresp}=  Get BusinessDomainsConf
    # Log   ${domresp.content}
    # Should Be Equal As Strings  ${domresp.status_code}  200
    # ${dlen}=  Get Length  ${domresp.json()}
    # ${d1}=  Random Int   min=0  max=${dlen-1}
    # Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    # ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    # ${sdom}=  Random Int   min=0  max=${sdlen-1}
    # Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${domresp}=  get_iscorp_subdomains  0
    Log  ${domresp}
    ${dlen}=  Get Length  ${domresp}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp[${d1}]['domain']}
    Set Test Variable  ${sub_dom}  ${domresp[${d1}]['subdomains']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Suite Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
        Set Suite Variable  ${pkg_name}  ${licresp.json()[${pos}]['displayName']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    # ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    DeActivate Service Provider 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${ACCOUNT_DEACTIVATED}


JD-TC-DeActivate Service Provider -2
    [Documentation]   Login a Provider and create a service then deActivate that provider.

    # ${domresp}=  Get BusinessDomainsConf
    # Log   ${domresp.content}
    # Should Be Equal As Strings  ${domresp.status_code}  200
    # ${dlen}=  Get Length  ${domresp.json()}
    # ${d1}=  Random Int   min=0  max=${dlen-1}
    # Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    # ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    # ${sdom}=  Random Int   min=0  max=${sdlen-1}
    # Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${domresp}=  get_iscorp_subdomains  0
    Log  ${domresp}
    ${dlen}=  Get Length  ${domresp}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp[${d1}]['domain']}
    Set Test Variable  ${sub_dom}  ${domresp[${d1}]['subdomains']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=    DeActivate Service Provider 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings    ${resp.json()}   ${ACCOUNT_DEACTIVATED}

JD-TC-DeActivate Service Provider -3
    [Documentation]   Login a Provider and create a waitlist then deActivate that provider.

    # ${domresp}=  Get BusinessDomainsConf
    # Log   ${domresp.content}
    # Should Be Equal As Strings  ${domresp.status_code}  200
    # ${dlen}=  Get Length  ${domresp.json()}
    # ${d1}=  Random Int   min=0  max=${dlen-1}
    # Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    # ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    # ${sdom}=  Random Int   min=0  max=${sdlen-1}
    # Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${domresp}=  get_iscorp_subdomains  1
    Log  ${domresp}
    ${dlen}=  Get Length  ${domresp}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp[${d1}]['domain']}
    Set Test Variable  ${sub_dom}  ${domresp[${d1}]['subdomains']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
      
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}

    # ${resp}=   Get jaldeeIntegration Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
    #     ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    # ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
    #     ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    #     Should Be Equal As Strings  ${resp1.status_code}  200
    # END

    # ${resp}=   Get jaldeeIntegration Settings
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END
    

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${min_pre1}=   Random Int   min=50   max=100
    ${Tot}=   Random Int   min=150   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    Set Suite Variable   ${min_pre1}
    ${pre_float1}=  twodigitfloat  ${min_pre1}
    Set Suite Variable   ${pre_float1}   
    ${Tot1}=  Convert To Number  ${Tot}  1 
    Set Suite Variable   ${Tot1}   
    ${ser_duratn}=   Random Int   min=10   max=30

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF  '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME18}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${pcid18}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${pcid18}  ${resp.json()[0]['id']}
    END

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}  department=${dep_id}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  -10
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=15  max=60
    ${eTime}=  add_two   ${sTime}  ${delta}
    ${capacity}=  Random Int  min=20   max=40
    ${parallel}=  Random Int   min=1   max=2
    ${queue1}=    FakerLibrary.Word
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${pcid18}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${pcid18}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-DeActivate Service Provider -4
    [Documentation]   consumer login - DeActivate provider.

    ${resp}=   Consumer Login  ${CUSERNAME3}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    DeActivate Service Provider 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}   ${NoAccess}

JD-TC-DeActivate Service Provider -5
    [Documentation]   without login - DeActivate provider.


    ${resp}=    DeActivate Service Provider 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}
