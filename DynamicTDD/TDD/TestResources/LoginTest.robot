*** Settings ***

Suite Teardown    Delete All Sessions
Force Tags        Provider Signup
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           random
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py


*** Test Cases ***




Provider_Signup

    ${domresp}=  Get BusinessDomainsConf
    Log  ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${domain_list}=  Create List
    ${subdomain_list}=  Create List
    FOR  ${domindex}  IN RANGE  ${len}
        Set Test Variable  ${d}  ${domresp.json()[${domindex}]['domain']}    
        Append To List  ${domain_list}    ${d} 
        Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']}
        Append To List  ${subdomain_list}    ${sd} 
    END
    Log  ${domain_list}
    Log  ${subdomain_list}
    Set Suite Variable  ${domain_list}
    Set Suite Variable  ${subdomain_list}
    Set Test Variable  ${d1}  ${domain_list[0]}
    Set Test Variable  ${sd1}  ${subdomain_list[0]}
    ${ph}=  Evaluate  ${PUSERNAME}+5666554
    Set Suite Variable  ${ph}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ph}   1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

*** Comments ***

Consumer_Signup

    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+100100201
    Set Suite Variable   ${CUSERPH0}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH0}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    # ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}    ${dob}  ${EMPTY}  ${gender}   ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH0}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  ${OtpPurpose['ConsumerSignUp']}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Send Verify Login Consumer   ${C_Email}${CUSERPH0}.${test_mail}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Verify Login Consumer  ${C_Email}${CUSERPH0}.${test_mail}  5
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Consumer Profile  ${firstname}  ${lastname}  ${address}  ${EMPTY}  ${gender}   email=${C_Email}${CUSERPH0}.${test_mail}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

Multiuser_Signup

    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  

    ${ph}=  Evaluate  ${PUSERNAME}+5666258
    Log   ${ph}

    

    ${licresp}=   Get Licensable Packages
    # Log to Console   ${licresp.content}
    Log  ${licresp.content}
    Should Be Equal As Strings  ${licresp.status_code}  200
    ${liclen}=  Get Length  ${licresp.json()}
    # Log to Console   ${liclen}
    Log  ${liclen}
    ${lic_index}=  random.randint  ${0}  ${liclen-1}
    Set Test Variable  ${licid}  ${licresp.json()[${lic_index}]['pkgId']}
    # Log to Console   ${licid}
    Log  ${licid}
    Set Test Variable  ${licname}  ${licresp.json()[${lic_index}]['displayName']}
    # Log to Console   ${licname}
    Log  ${licname}
    
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${dom_index}=  random.randint  ${0}  ${len-1}
    Set Test Variable  ${dom}  ${resp.json()[${dom_index}]['domain']}
    # Log to Console   ${dom}
    Log   ${dom}
    ${sublen}=  Get Length  ${resp.json()[${dom_index}]['subDomains']}
    FOR  ${subindex}  IN RANGE  ${sublen}
        ${sdom_index}=  random.randint  ${0}  ${sublen-1}
        Set Test Variable  ${sdom}  ${resp.json()[${dom_index}]['subDomains'][${sdom_index}]['subDomain']}
        ${is_corp}=  check_is_corp  ${sdom}
        Log  ${is_corp}
        Exit For Loop If  '${is_corp}' == 'True'
    END
    # Log to Console   ${sdom}
    Log   ${sdom}
    
    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${dom}  ${sdom}  ${ph}  ${licid}
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200