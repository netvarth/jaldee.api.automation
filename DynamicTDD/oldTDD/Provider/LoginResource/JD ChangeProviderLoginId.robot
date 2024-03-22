*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Login
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${PUSERPH}      ${PUSERNAME}

*** Test Cases ***

JD-TC-ChangeProviderLoginId-1
    [Documentation]    Change provider's email login id 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${mail}=   FakerLibrary.word
    ${PUSEREMAIL18}=  Set Variable  ${P_Email}${mail}.${test_mail}
    Set Suite Variable  ${PUSEREMAIL18}
    ${resp}=  Send Verify Login   ${PUSEREMAIL18}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200
    ${resp}=  Verify Login        ${PUSEREMAIL18}   4
    Should Be Equal As Strings    ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSEREMAIL18}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-ChangeProviderLoginId-2
    [Documentation]    Change provider's mobile number login id 

    ${resp}=   Encrypted Provider Login  ${PUSEREMAIL18}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERPH18}=  Evaluate  ${PUSERPH}+456782
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH18}${\n}
    Set Suite Variable   ${PUSERPH18}
    ${resp}=  Send Verify Login   ${PUSERPH18}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Verify Login   ${PUSERPH18}  4
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERPH18}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}     ${NOT_REGISTERED_PROVIDER}

JD-TC-ChangeProviderLoginId-ChangeToOld
    [Documentation]    Change to old state

    ${resp}=   Encrypted Provider Login  ${PUSEREMAIL18}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Send Verify Login   ${PUSERNAME18}
    Should Be Equal As Strings    ${resp.status_code}  200
    ${resp}=  Verify Login        ${PUSERNAME18}  4
    Should Be Equal As Strings    ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-ChangeProviderLoginId-UH1
    [Documentation]    use the url in consumer session

    ${resp}=   Consumer Login     ${CUSERNAME7}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Send Verify Login   ${PUSEREMAIL18}
    Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.content}      ${LOGIN_NO_ACCESS_FOR_URL}  

JD-TC-ChangeProviderLoginId-UH2
    [Documentation]    use the url without login

    ${resp}=  Send Verify Login    ${PUSEREMAIL18}
    Should Be Equal As Strings     ${resp.status_code}  419    
    Should Be Equal As Strings     ${resp.content}     ${SESSION_EXPIRED}
    
JD-TC-ChangeProviderLoginId-UH3
    [Documentation]    Change provider's mobile num to an already existing provider's number 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Send Verify Login   ${PUSERNAME18}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${MOBILE_NO_USED}

JD-TC-ChangeProviderLoginId-UH4	
    [Documentation]  Change provider's mobile num to an already existing consumer's number 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Send Verify Login   ${CUSERNAME7}
    # Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${PRIMARY_MOB_NO_ALREADY_USED}
    # ${resp}=   Encrypted Provider Login  ${CUSERNAME7}  ${PASSWORD} 
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  ProviderLogout
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=   Consumer Login     ${CUSERNAME7}  ${PASSWORD} 
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Logout
    # Should Be Equal As Strings    ${resp.status_code}    200
  
JD-TC-ChangeProviderLoginId-UH5
    [Documentation]  Change provider's email login id to an already existing another provider's email

    ${resp}=   Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Send Verify Login   ${PUSEREMAIL18}
    Should Be Equal As Strings    ${resp.status_code}  422
    # Should Be Equal As Strings    ${resp.json()}     	${EMAIL_EXISTS}
    Should Be Equal As Strings    ${resp.content}     	${PRIMARY_MOB_NO_ALREADY_USED}
    
    
JD-TC-ChangeProviderLoginId-UH6
    [Documentation]  Change provider's email login id to an already existing provider's own email

    ${resp}=   Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Send Verify Login   ${PUSEREMAIL18}
    Should Be Equal As Strings    ${resp.status_code}  422
    # Should Be Equal As Strings    ${resp.json()}   ${EMAIL_VERIFIED} 
    Should Be Equal As Strings    ${resp.content}     	${PRIMARY_MOB_NO_ALREADY_USED}
  
JD-TC-ChangeProviderLoginId-UH7
    [Documentation]    Change provider's email login id  to an already existing consumer's email

    ${resp}=   Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Send Verify Login   ${CUSEREMAIL5}
    Should Be Equal As Strings    ${resp.status_code}  422
    # Should Be Equal As Strings    ${resp.json()}     	${EMAIL_EXISTS}
    Should Be Equal As Strings    ${resp.content}     	${PRIMARY_MOB_NO_ALREADY_USED}

JD-TC-ChangeProviderLoginId-H
    [Documentation]    Change provider's mobile number login id and country code

    ${resp}=   Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${country_code}    Generate random string    2    0123456789
    ${country_code}    Convert To Integer  ${country_code}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH18}${\n}
    # Set Suite Variable   ${PUSERPH18}
    ${resp}=  Send Verify Login   ${PUSERPH0}  countryCode=${country_code}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     

JD-TC-ChangeProviderLoginId-CLEAR
    [Documentation]    Change provider's email login id 

    ${resp}=   Encrypted Provider Login  ${PUSERNAME18}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${mail}=   FakerLibrary.word
    ${PUSEREMAIL17}=  Set Variable  ${P_Email}${mail}.${test_mail}
    Set Suite Variable            ${PUSEREMAIL17}
    ${resp}=  Send Verify Login   ${PUSEREMAIL17} 
    Should Be Equal As Strings    ${resp.status_code}  200
    ${resp}=  Verify Login        ${PUSEREMAIL17}  4
    Should Be Equal As Strings    ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSEREMAIL17}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200  
 
    
