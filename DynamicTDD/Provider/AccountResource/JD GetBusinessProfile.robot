** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        BusinessProfile
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***
@{Views}  self  all  customersOnly

*** Test Cases ***

# JD-TC-GetBusinessProf-1
#     [Documentation]  Create  business profile with no details of provider
#     ${domresp}=  Get BusinessDomainsConf
#     Should Be Equal As Strings  ${domresp.status_code}  200
#     ${len}=  Get Length  ${domresp.json()}
#     ${len}=  Evaluate  ${len}-1
#     Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
#     Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
#     ${firstname}=  FakerLibrary.first_name
#     ${lastname}=  FakerLibrary.last_name
#     ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+560023
#     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_B}    1
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Activation  ${PUSERNAME_B}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=  Provider Login  ${PUSERNAME_B}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_B}${\n}
#     Set Suite Variable  ${PUSERNAME_B}
#     ${DAY1}=  get_date
#     Set Suite Variable  ${DAY1}  ${DAY1}
#     ${list}=  Create List  1  2  3  4  5  6  7
#     Set Suite Variable  ${list}  ${list}
#     ${resp}=  Update Business Profile without details  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
YNW-TC-GetBusinessProf-UH1
    Comment  Get business profile without login
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}
    

YNW-TC-GetBusinessProf-UH2
    Comment   Get business profile by  login as consumer
    ${resp}=    ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetBusinessProf-1
	[Documentation]  Get business profile of Provider
    ${resp}=  ProviderLogin  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${domain}=   Set Variable    ${resp.json()['sector']}
    ${subdomain}=    Set Variable      ${resp.json()['subSector']}
    sleep   02s
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  businessName=${EMPTY}  businessDesc=${EMPTY}  shortName=${EMPTY}  status=INACTIVE  createdDate=${DAY1}
    Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${domain}
    Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${subdomain}
    # Should Be Equal As Strings  ${resp.json()['emails'][0]}  ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]}  ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]}  ${EMPTY}
    Should Not Be Equal As Strings  ${resp.json()['businessName']}   ${EMPTY}
    Should Not Be Equal As Strings  ${resp.json()['businessDesc']}   ${EMPTY}
    Should Not Be Equal As Strings  ${resp.json()['shortName']}   ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['status']}   ACTIVE
    Should Not Be Equal As Strings  ${resp.json()['emails'][0]}   ${EMPTY}
    Should Not Be Equal As Strings  ${resp.json()['phoneNumbers'][0]}   ${EMPTY}
    Should Not Be Equal As Strings  ${resp.json()['phoneNumbers'][1]}   ${EMPTY}

JD-TC-GetBusinessProf-2
	[Documentation]  Get business profile of Branch
    ${resp}=  ProviderLogin  ${MUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${domain}=   Set Variable    ${resp.json()['sector']}
    ${subdomain}=    Set Variable      ${resp.json()['subSector']}
    sleep   02s
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  businessName=${EMPTY}  businessDesc=${EMPTY}  shortName=${EMPTY}  status=INACTIVE  createdDate=${DAY1}
    Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${domain}
    Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${subdomain}
    # Should Be Equal As Strings  ${resp.json()['emails'][0]}  ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]}  ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]}  ${EMPTY}
    Should Not Be Equal As Strings  ${resp.json()['businessName']}   ${EMPTY}
    Should Not Be Equal As Strings  ${resp.json()['businessDesc']}   ${EMPTY}
    Should Not Be Equal As Strings  ${resp.json()['shortName']}   ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['status']}   ACTIVE
    Should Not Be Equal As Strings  ${resp.json()['emails'][0]}   ${EMPTY}
    Should Not Be Equal As Strings  ${resp.json()['phoneNumbers'][0]}   ${EMPTY}
    Should Not Be Equal As Strings  ${resp.json()['phoneNumbers'][1]}   ${EMPTY}