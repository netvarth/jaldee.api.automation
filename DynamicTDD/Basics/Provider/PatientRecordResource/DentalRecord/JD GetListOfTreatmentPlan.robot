*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Patient Record
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{emptylist}
${order}    0


*** Test Cases ***
JD-TC-Get List of Treatment Plan against a Case and Tooth-1

    [Documentation]    Get list of Treatment Plan against case and Tooth .

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}
    Set Suite Variable    ${accountName}      ${resp.json()['businessName']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['timezone']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${name}=  FakerLibrary.name
    ${aliasName}=  FakerLibrary.name

    ${resp}=    Create Case Category    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${category_id}    ${resp.json()['id']} 

    ${resp}=    Create Case Type    ${name}  ${aliasName}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${type_id}    ${resp.json()['id']}  
 
    ${title}=  FakerLibrary.name
    Set Suite Variable    ${title}
    ${description}=  FakerLibrary.last_name
    Set Suite Variable    ${description}

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    Set Suite Variable  ${email}  ${lastName}${primaryMobileNo}.${test_mail}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout 
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${cid}            ${resp.json()['providerConsumer']}
    Set Suite Variable    ${jconid}         ${resp.json()['id']}
    Set Suite Variable    ${proconfname}    ${resp.json()['firstName']}    
    Set Suite Variable    ${proconlname}    ${resp.json()['lastName']} 
    Set Suite Variable    ${fullname}       ${proconfname}${space}${proconlname}

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${consumer}=  Create Dictionary  id=${cid} 
    ${category}=  Create Dictionary  id=${category_id}  
    ${type}=  Create Dictionary  id=${type_id}  
    ${doctor}=  Create Dictionary  id=${pid}

    ${resp}=    Create Case     ${title}  ${doctor}  ${consumer}    
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${caseId}        ${resp.json()['id']}
    Set Suite Variable    ${caseUId}    ${resp.json()['uid']}

    ${resp}=    Get MR Case By UID   ${caseUId}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${toothNo}=   Random Int  min=10   max=47
    Set Suite Variable      ${toothNo}
    ${note1}=  FakerLibrary.word
    Set Suite Variable      ${note1}
    ${investigation}=    Create List   ${note1}
    Set Suite Variable      ${investigation}
    ${toothSurfaces}=    Create List   ${toothSurfaces[0]}
    # Set Suite Variable      ${toothSurfaces}

    ${resp}=    Create DentalRecord    ${toothNo}  ${toothType[0]}  ${caseUId}    investigation=${investigation}    toothSurfaces=${toothSurfaces}
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable      ${id}           ${resp.json()}

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}

    ${resp}=    Create Treatment Plan    ${caseUId}   ${id}   ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Suite Variable    ${treatmentId}        ${resp.json()}

    ${resp}=    Get Treatment Plan List        ${caseUId}      ${toothNo}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()[0]['caseDto']['uid']}     ${caseUId} 
    Should Be Equal As Strings    ${resp.json()[0]['caseDto']['consumer']['firstName']}     ${proconfname} 
    Should Be Equal As Strings    ${resp.json()[0]['caseDto']['consumer']['lastName']}     ${proconlname} 
    Should Be Equal As Strings    ${resp.json()[0]['caseDto']['doctor']['id']}     ${pid} 
    Should Be Equal As Strings    ${resp.json()[0]['caseDto']['doctor']['firstName']}     ${pdrfname} 
    Should Be Equal As Strings    ${resp.json()[0]['caseDto']['doctor']['lastName']}     ${pdrlname}
    Should Be Equal As Strings    ${resp.json()[0]['caseDto']['type']['id']}     ${type_id} 
    Should Be Equal As Strings    ${resp.json()[0]['caseDto']['category']['id']}     ${category_id} 
    Should Be Equal As Strings    ${resp.json()[0]['treatment']}     ${treatment}
    Should Be Equal As Strings    ${resp.json()[0]['works'][0]['status']}     ${PRStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['works'][0]['work']}     ${work}
    Should Be Equal As Strings    ${resp.json()[0]['dentalRecord']['id']}     ${id}
    Should Be Equal As Strings    ${resp.json()[0]['dentalRecord']['toothNo']}     ${toothNo}

JD-TC-Get List of Treatment Plan against a Case and Tooth-UH1

    [Documentation]    Get List of Treatment Plan against with invalid case.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${invalid}=   Random Int  min=123   max=400

    ${resp}=    Get Treatment Plan List        ${invalid}      ${toothNo}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings              ${resp.json()}   ${INVALID_CASE_ID}

JD-TC-Get List of Treatment Plan against a Case and Tooth-UH2

    [Documentation]    Get List of Treatment Plan against with invalid Tooth.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${invalid}=   Random Int  min=123   max=400

    ${resp}=    Get Treatment Plan List        ${caseUId}      ${invalid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings              ${resp.json()}   []

JD-TC-Get List of Treatment Plan against a Case and Tooth-UH3

    [Documentation]    Get List of Treatment Plan against with another provider login.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${resp}=    Get Treatment Plan List        ${caseUId}      ${toothNo}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-Get List of Treatment Plan against a Case and Tooth-UH4

    [Documentation]    Get List of Treatment Plan against with providerConsumer login.

    ${resp}=  Encrypted Provider Login    ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}         
    Should Be Equal As Strings            ${resp.status_code}    200

    ${firstName}=  FakerLibrary.name
    ${lastName}=  FakerLibrary.last_name
    ${primaryMobileNo}    Generate random string    10    123456789
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    ${email}=    FakerLibrary.Email

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}
  
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}    ${OtpPurpose['Authentication']}     JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    # ${resp}=  Consumer Logout   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200  
   
    ${resp}=    ProviderConsumer Login with token    ${primaryMobileNo}    ${accountId}    ${token}    ${countryCodes[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Treatment Plan List        ${caseUId}      ${toothNo}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings              ${resp.json()}   ${NoAccess}