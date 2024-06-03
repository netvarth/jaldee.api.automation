*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Department
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}	   Bridal Makeup_001
${SERVICE2}	   Groom MakeupW_002
${SERVICE3}	   Groom MakeupW_003
${SERVICE4}	   Groom MakeupW_004
${start}           140
${description}  Service
${default_ser_durtn}   10

*** Test Cases ***
JD-TC-Get Services in Department-1
    [Documentation]  Provider Get Services in Department

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_K}=  Evaluate  ${PUSERNAME}+423824
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_K}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_K}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_K}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_K}${\n}
    Set Suite Variable  ${PUSERNAME_K}
    ${id}=  get_id  ${PUSERNAME_K}
    Set Suite Variable  ${id}
    
    ${ser_desc}=   FakerLibrary.word
    Set Suite Variable   ${ser_desc}
    ${total_amount}=    Random Int  min=100  max=500
    Set Suite Variable  ${total_amount}
    ${min_prepayment}=  Random Int   min=1   max=50
    Set Suite Variable   ${min_prepayment}
    ${ser_duratn}=      Random Int   min=10   max=30
    Set Suite Variable   ${ser_duratn}
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE3}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()}  
    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc}   ${sid1}  ${sid2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}
    ${resp}=  Get Services in Department  ${depid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}                         ${sid1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['description']}                ${ser_desc}
    Should Be Equal As Strings  ${resp.json()['services'][0]['serviceDuration']}            ${ser_duratn}
    Should Be Equal As Strings  ${resp.json()['services'][0]['notificationType']}           ${notifytype[2]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['notification']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['isPrePayment']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['minPrePaymentAmount']}        ${min_prepayment}.0
    Should Be Equal As Strings  ${resp.json()['services'][0]['totalAmount']}                ${total_amount}.0
    Should Be Equal As Strings  ${resp.json()['services'][0]['bType']}                      ${bType}
    Should Be Equal As Strings  ${resp.json()['services'][0]['status']}                     ${status[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['taxable']}                    ${bool[0]}
    
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}                         ${sid2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['name']}                       ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['description']}                ${ser_desc}
    Should Be Equal As Strings  ${resp.json()['services'][1]['serviceDuration']}            ${ser_duratn}
    Should Be Equal As Strings  ${resp.json()['services'][1]['notificationType']}           ${notifytype[2]}
    Should Be Equal As Strings  ${resp.json()['services'][1]['notification']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['services'][1]['isPrePayment']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['services'][1]['minPrePaymentAmount']}        ${min_prepayment}.0
    Should Be Equal As Strings  ${resp.json()['services'][1]['totalAmount']}                ${total_amount}.0
    Should Be Equal As Strings  ${resp.json()['services'][1]['bType']}                      ${bType}
    Should Be Equal As Strings  ${resp.json()['services'][1]['status']}                     ${status[0]}
    Should Be Equal As Strings  ${resp.json()['services'][1]['taxable']}                    ${bool[0]}

JD-TC-Get Services in Department-2
    [Documentation]  Provider Create department using Service names then Get Services in Department
    
    ${resp}=  Encrypted Provider Login   ${PUSERNAME39}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Enable service   ${sid1} 
    ${resp}=  Enable service   ${sid2}
    ${resp}=  Enable service   ${sid3}
    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code2}
    ${resp}=  Toggle Department Enable
    ${resp}=  Create Department With ServiceName  ${dep_name2}  ${dep_code2}  ${dep_desc}    ${SERVICE1}  ${SERVICE2}  ${SERVICE3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid2}  ${resp.json()}
    ${resp}=  Get Services in Department  ${depid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['services'][0]['name']}                       ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['description']}                ${SERVICE1} ${description}
    Should Be Equal As Strings  ${resp.json()['services'][0]['serviceDuration']}            ${default_ser_durtn}
    Should Be Equal As Strings  ${resp.json()['services'][0]['notificationType']}           ${notifytype[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['isPrePayment']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['bType']}                      ${bType}
    Should Be Equal As Strings  ${resp.json()['services'][0]['status']}                     ${status[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['taxable']}                    ${bool[0]}
    
    Should Be Equal As Strings  ${resp.json()['services'][1]['name']}                       ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['description']}                ${SERVICE2} ${description}
    Should Be Equal As Strings  ${resp.json()['services'][1]['serviceDuration']}            ${default_ser_durtn}
    Should Be Equal As Strings  ${resp.json()['services'][1]['notificationType']}           ${notifytype[0]}
    Should Be Equal As Strings  ${resp.json()['services'][1]['isPrePayment']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['services'][1]['bType']}                      ${bType}
    Should Be Equal As Strings  ${resp.json()['services'][1]['status']}                     ${status[0]}
    Should Be Equal As Strings  ${resp.json()['services'][1]['taxable']}                    ${bool[0]}

    Should Be Equal As Strings  ${resp.json()['services'][2]['name']}                       ${SERVICE3}
    Should Be Equal As Strings  ${resp.json()['services'][2]['description']}                ${SERVICE3} ${description}
    Should Be Equal As Strings  ${resp.json()['services'][2]['serviceDuration']}            ${default_ser_durtn}
    Should Be Equal As Strings  ${resp.json()['services'][2]['notificationType']}           ${notifytype[0]}
    Should Be Equal As Strings  ${resp.json()['services'][2]['isPrePayment']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['services'][2]['bType']}                      ${bType}
    Should Be Equal As Strings  ${resp.json()['services'][2]['status']}                     ${status[0]}
    Should Be Equal As Strings  ${resp.json()['services'][2]['taxable']}                    ${bool[0]}

JD-TC-Get Services in Department-UH1
     [Documentation]  Get Services in Department without login

     ${resp}=  Get Services in Department  ${depid2}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"    "${SESSION_EXPIRED}"
     
JD-TC-Get Services in Department-UH2
     [Documentation]  Get Services in Department using consumer login

     ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get Services in Department  ${depid2}
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Get Services in Department-UH3
    [Documentation]  Get Services in Department using invalid department id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_K}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Services in Department  000
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DETP_NOT_BELONGS_TO_THIS_ACCOUNT}"

JD-TC-Get Services in Department-UH4
    [Documentation]  Get Services in Department using another provider department id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME40}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Services in Department  ${depid2}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"
