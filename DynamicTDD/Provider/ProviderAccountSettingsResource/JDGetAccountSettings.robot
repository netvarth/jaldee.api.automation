*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Familymemeber
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***
JD-TC-GetAccountSettings-1
    [Documentation]   Get Account settings by provider login

    ${resp}=  ProviderLogin  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response   ${resp}    enableSms=${bool[1]}  jaldeeIntegration=${bool[1]}  customerSeriesEnum=PATTERN
    # Set Test Variable  ${j_id}  ${resp.json()['jaldeeId']}
    # Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
    Should Be Equal As Strings  ${resp.json()['enableSms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['jaldeeIntegration']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['waitlist']}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${j_id}


JD-TC-GetAccountSettings-UH1
    [Documentation]   Get Customers without provider login

    ${resp}=  Get Accountsettings 
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetAccountSettings-UH2
    [Documentation]   Get Customers using consumer login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"  
    
JD-TC-GetorderAccountSettings-3
    [Documentation]   Get Order Account settings by provider login here enable order

    ${resp}=  ProviderLogin  ${PUSERNAME101}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId1}=  get_acc_id  ${PUSERNAME106}
    Set Suite Variable  ${accId1} 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME106}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableSms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['jaldeeIntegration']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['waitlist']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['sendNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['order']}  ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${j_id}

JD-TC-GetorderAccountSettings-4
    [Documentation]   Get Order Account settings by provider login disable order

    ${resp}=  ProviderLogin  ${PUSERNAME101}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Disable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableSms']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['jaldeeIntegration']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['appointment']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['waitlist']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['sendNotification']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['order']}  ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${j_id}

