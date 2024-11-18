*** Settings ***
# Suite Teardown    Delete All Sessions
# Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Deprecation
Library           Collections
Library           String
Library           json
Library           FakerLibrary
#Library           ExcellentLibrary
Library           OperatingSystem
# Library           /ebs/TDD/excelfuncs.py
# Library           /ebs/TDD/CustomKeywords.py
# Library           /ebs/TDD/KeywordNameLogger.py
# Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
# Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
# Variables       /ebs/TDD/varfiles/consumerlist.py 
# Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

${var_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${data_file}              ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt


*** Keywords ***
# Check Deprication
#     [Arguments]    ${response}  ${keyword_name}
#     IF  'Deprecated-Url' in &{response.headers}
#         Log  ${response.headers['Deprecated-Url']}
#         Log  *${keyword_name} DEPRECATED in REST.*  level=WARN
#     END

# Get BusinessDomainsConf
#     Check And Create YNW Session
#     ${resp}=   GET On Session  ynw  /ynwConf/businessDomains   expected_status=any
#     # IF  'Deprecated-Url' in &{resp.headers}
#     #     Log  ${resp.headers['Deprecated-Url']}
#     #     Log  *Get BusinessDomainsConf DEPRECATED in REST.*  level=WARN
#     # END
#     Check Deprication  ${resp}  Get BusinessDomainsConf
#     RETURN  ${resp}

# *** Keywords ***
# My Keyword
#     ${keyword_name}=    Get Current Keyword Name
#     Log    Keyword inside My Keyword is ${keyword_name}



# Select Domain Subdomain
#     [Arguments]   ${Domain}=${EMPTY}  ${SubDomain}=${EMPTY}
#     IF  ${Domain} == ${EMPTY} 
#         ${domresp}=  Get BusinessDomainsConf
#         Log   ${domresp.content}
#         Should Be Equal As Strings  ${domresp.status_code}  200
#         ${dlen}=  Get Length  ${domresp.json()}
#         IF  ${SubDomain} == ${EMPTY}
#             ${dlen}=  Get Length  ${domresp.json()}
#             ${d1}=  Random Int   min=0  max=${dlen-1}
#             Set Test Variable  ${Domain}  ${domresp.json()[${d1}]['domain']}
#             ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
#             ${sdom}=  Random Int   min=0  max=${sdlen-1}
#             Set Test Variable  ${SubDomain}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}
#         ELSE
#             FOR  ${domindex}  IN RANGE  ${dlen}
#                 ${sdom_len}=  Get Length  ${resp.json()[${domindex}]['subDomains']}
#                 FOR  ${subindex}  IN RANGE  ${sdom_len}
#                     Set Test Variable  ${subdom}  ${resp.json()[${domindex}]['subDomains'][${subindex}]['subDomain']}
#                     Exit For Loop If  '${subdom}' == '${SubDomain}'
#                 END
#                 IF  '${subdom}' == '${SubDomain}'
#                     Set Test Variable  ${Domain}  ${domresp.json()[${domindex}]['domain']}
#                     Exit For Loop
#                 END
#             END
#         END
#     ELSE
#         IF  ${SubDomain} == ${EMPTY}
#             FOR  ${domindex}  IN RANGE  ${dlen}
#                 Set Test Variable  ${dom}  ${resp.json()[${dom}]['domain']}
#                 IF  '${dom}' == '${Domain}'
#                     ${sdom_len}=  Get Length  ${resp.json()[${domindex}]['subDomains']}
#                     ${sdom}=  random.randint  ${0}  ${sdom_len-1}
#                     Set Test Variable  ${SubDomain}  ${resp.json()[${dom}]['subDomains'][${sdom}]['subDomain']}
#                     Exit For Loop
#                 END
#             END
#         END
#     END
#     RETURN  ${Domain}  ${SubDomain}





*** Test Cases ***
Testing signup in test server

    ${firstname}  ${lastname}  ${PhoneNumber}  ${LoginId}=  Provider Signup
    ${num}=  find_last  ${var_file}
    ${num}=  Evaluate   ${num}+1
    Append To File  ${data_file}  ${LoginId} - ${PASSWORD}${\n}
    Append To File  ${var_file}  PUSERNAME${num}=${LoginId}${\n}
    Log    PUSERNAME${num}

    ${resp}=  Encrypted Provider Login  ${LoginId}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

# Example Test Case

    # @{fruits}	apple	banana	orange

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME376}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Check Server Availibility
    
    # ${Domain}  ${SubDomain}=  Select Domain Subdomain

    # ${Domain}  ${SubDomain}=  Select Random Domain and Subdomain
    # ${Domain}  ${SubDomain}=  Select Domain Subdomain  Domain=${Domain}

    # ${Domain}  ${SubDomain}=  Select Random Domain and Subdomain
    # ${Domain}  ${SubDomain}=  Select Domain Subdomain  SubDomain=${SubDomain}

    
    # ${provider1}=    Provider Signup

    # ${PO_Number}=  FakerLibrary.Numerify  %#####
    # ${PhoneNumber}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # ${provider2}=    Provider Signup  PhoneNumber=${PhoneNumber}

    # ${Domain}  ${SubDomain}=  Select Random Domain and Subdomain
    # ${provider3}=    Provider Signup  Domain=${Domain}  SubDomain=${SubDomain}  

    # ${licid}  ${licname}=  Select Random License
    # ${provider4}=    Provider Signup  LicenseId=${licid}

    # # FakerLibrary.user_name
    # ${LoginID}=    FakerLibrary.user_name
    # ${provider4}=    Provider Signup  LoginId=${LoginID}

    # ${PO_Number}=  FakerLibrary.Numerify  %#####
    # ${PhoneNumber}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # ${Domain}  ${SubDomain}=  Select Random Domain and Subdomain
    # ${licid}  ${licname}=  Select Random License
    # ${LoginID}=    FakerLibrary.user_name
    # ${provider5}=    Provider Signup  PhoneNumber=${PhoneNumber}  LicenseId=${licid}  Domain=${Domain}  SubDomain=${SubDomain}  LoginId=${LoginID}
    

    

*** COMMENTS ***
Testing Deprecation
    
    # example_keyword
    # ${resp}=  Get BusinessDomainsConf
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Log  ${resp.headers}
    # Log  ${resp.headers['Deprecated-Url']}
    # IF  'Deprecated-Url' in &{resp.headers}
    #     Log  ${resp.headers['Deprecated-Url']}
    # END
    ${resp}=  get_business_domains_conf  


JD-TC-55num-1
    ${PUSERPH0}=    Generate Random 555 Number
    Log To Console  ${PUSERPH0}

    ${resp}=  Get BusinessDomainsConf
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${dom_len}=  Get Length  ${resp.json()}
    ${dom}=  Random Int  min=${0}   max=${dom_len-1}    
    Set Suite Variable  ${domain}  ${resp.json()[${dom}]['domain']}
    Log   ${domain}

    ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
    ${sdom}=  Random Int  min=${0}  max=${sdom_len-1}
    Set Suite Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${sdom}]['subDomain']}
    Log   ${subdomain}