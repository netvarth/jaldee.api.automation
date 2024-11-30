*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Membership Service
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           RequestsLibrary
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/excelfuncs.py
Library		      /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Test Cases ***


JD-TC-Get_Member_Service_By_Id-1

    [Documentation]  Get Member Service By Id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=    get_acc_id       ${PUSERNAME55}
    Set Suite Variable      ${accountId}

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    
    ${description}=    FakerLibrary.bs
    ${name}=           generate_firstname
    ${displayname}=    generate_firstname
    ${effectiveFrom}=  db.get_date_by_timezone  ${tz}
    ${effectiveTo}=      db.add_timezone_date  ${tz}  10   
    Set Suite Variable    ${description}
    Set Suite Variable    ${name}
    Set Suite Variable    ${displayname}
    Set Suite Variable    ${effectiveFrom}
    Set Suite Variable    ${effectiveTo}

    ${resp}=    Create Membership Service     ${description}    ${name}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${memberid}    ${resp.json()}

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['id']}    ${memberid}
    Should Be Equal As Strings    ${resp.json()['name']}    ${name}
    Should Be Equal As Strings    ${resp.json()['displayName']}    ${displayname}
    Should Be Equal As Strings    ${resp.json()['description']}    ${description}
    Should Be Equal As Strings    ${resp.json()['effectiveFrom']}    ${effectiveFrom}
    Should Be Equal As Strings    ${resp.json()['effectiveTo']}    ${effectiveTo}
    Should Be Equal As Strings    ${resp.json()['approvalType']}    ${MembershipApprovalType[0]}
    Should Be Equal As Strings    ${resp.json()['allowLogin']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()['provider']}    ${user_id}

JD-TC-Get_Member_Service_By_Id-UH1

    [Documentation]  Get Member Service By Id with invalid member id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${invmem}=    Generate random string    4    ${digits} 

    ${resp}=    Get Membership Service by id    ${invmem}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MEMBER_SERVICE_ID_INVALID}

JD-TC-Get_Member_Service_By_Id-UH2

    [Documentation]  Get Member Service By Id with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}

JD-TC-Get_Member_Service_By_Id-UH3

    [Documentation]  Get Member Service By Id with consumer login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${consumerPhone}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
    ${fname}=   generate_firstname
    ${lname}=    FakerLibrary.last_name
    Set Test Variable      ${fname}
    Set Test Variable      ${lname}  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${fname}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${fname}   lastName=${lname}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${consumerId}  ${resp.json()[0]['id']}
    ${fullName}   Set Variable    ${fname} ${lname}
    Set Test Variable  ${fullName}

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Consumer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['id']}

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

JD-TC-Get_Member_Service_By_Id-UH4

    [Documentation]  Get Member Service By Id without login

    ${resp}=    Get Membership Service by id    ${memberid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}