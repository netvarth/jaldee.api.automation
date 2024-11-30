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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Test Cases ***


JD-TC-Get_Membership_Service-1

    [Documentation]  Get Membership Service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME57}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=    get_acc_id       ${PUSERNAME57}
    Set Suite Variable      ${accountId}

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}

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
    ${description2}=    FakerLibrary.bs
    ${name2}=           generate_firstname
    ${displayname2}=    generate_firstname
    ${effectiveFrom2}=  db.get_date_by_timezone  ${tz}
    ${effectiveTo2}=    db.add_timezone_date  ${tz}  12
    Set Suite Variable    ${description}
    Set Suite Variable    ${name}
    Set Suite Variable    ${displayname}
    Set Suite Variable    ${effectiveFrom}
    Set Suite Variable    ${effectiveTo}
    Set Suite Variable    ${description2}
    Set Suite Variable    ${name2}
    Set Suite Variable    ${displayname2}
    Set Suite Variable    ${effectiveFrom2}
    Set Suite Variable    ${effectiveTo2}

    ${resp}=    Create Membership Service     ${description}    ${name}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${memberid}    ${resp.json()}

    ${resp}=    Create Membership Service     ${description2}    ${name2}    ${displayname2}    ${effectiveFrom2}    ${effectiveTo2}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${memberid2}    ${resp.json()}

    ${resp}=    Get Membership Service 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Should Be Equal As Strings    ${resp.json()[0]['id']}    ${memberid2}
    Should Be Equal As Strings    ${resp.json()[0]['name']}    ${name2}
    Should Be Equal As Strings    ${resp.json()[0]['displayName']}    ${displayname2}
    Should Be Equal As Strings    ${resp.json()[0]['description']}    ${description2}
    Should Be Equal As Strings    ${resp.json()[0]['effectiveFrom']}    ${effectiveFrom2}
    Should Be Equal As Strings    ${resp.json()[0]['effectiveTo']}    ${effectiveTo2}
    Should Be Equal As Strings    ${resp.json()[0]['approvalType']}    ${MembershipApprovalType[0]}
    Should Be Equal As Strings    ${resp.json()[0]['allowLogin']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[0]['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()[0]['provider']}    ${user_id}

    Should Be Equal As Strings    ${resp.json()[1]['id']}    ${memberid}
    Should Be Equal As Strings    ${resp.json()[1]['name']}    ${name}
    Should Be Equal As Strings    ${resp.json()[1]['displayName']}    ${displayname}
    Should Be Equal As Strings    ${resp.json()[1]['description']}    ${description}
    Should Be Equal As Strings    ${resp.json()[1]['effectiveFrom']}    ${effectiveFrom}
    Should Be Equal As Strings    ${resp.json()[1]['effectiveTo']}    ${effectiveTo}
    Should Be Equal As Strings    ${resp.json()[1]['approvalType']}    ${MembershipApprovalType[0]}
    Should Be Equal As Strings    ${resp.json()[1]['allowLogin']}    ${bool[1]}
    Should Be Equal As Strings    ${resp.json()[1]['serviceStatus']}    ${MembershipServiceStatus[0]}
    Should Be Equal As Strings    ${resp.json()[1]['provider']}    ${user_id}


JD-TC-Get_Membership_Service-UH1

    [Documentation]  Get Membership Service with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME58}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Membership Service 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-Get_Member_Service-UH2

    [Documentation]  Get Member Service with consumer login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME57}  ${PASSWORD}
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

    ${resp}=  Provider Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['id']}

    ${resp}=    Get Membership Service 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

JD-TC-Get_Member_Service-UH3

    [Documentation]  Get Member Service By Id without login

    ${resp}=    Get Membership Service 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED} 