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
Library           /ebs/TDD/excelfuncs.py
Library		      /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

${xlFile}      ${EXECDIR}/TDD/Member Registration.xlsx   
${self}      0
@{emptylist}
${jpg}     /ebs/TDD/small.jpg

*** Test Cases ***


JD-TC-Submit_Member_QNR-1

    [Documentation]  Submit Member QNR

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Log List  ${QnrChannel}
    Log List  ${QnrTransactionType}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${servicenames}
    Set Suite Variable   ${servicenames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${user_id}  ${decrypted_data['id']}
    # Set Suite Variable    ${user_id}    ${resp.json()['id']}
    ${accountId}=    get_acc_id       ${PUSERNAME62}
    Set Suite Variable    ${accountId}

    ${lid}=  Create Sample Location
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    
    ${description}=    FakerLibrary.bs
    ${name}=           FakerLibrary.firstName
    ${displayname}=    FakerLibrary.firstName
    ${effectiveFrom}=  db.get_date_by_timezone  ${tz}
    ${effectiveTo}=      db.add_timezone_date  ${tz}  10   
    Set Suite Variable    ${description}
    Set Suite Variable    ${name}
    Set Suite Variable    ${displayname}
    Set Suite Variable    ${effectiveFrom}
    Set Suite Variable    ${effectiveTo}

    ${resp}=    Create Membership Service     ${description}    ${servicenames[0]}    ${displayname}    ${effectiveFrom}    ${effectiveTo}    ${MembershipApprovalType[0]}    ${boolean[1]}    ${MembershipServiceStatus[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${membershipid}    ${resp.json()}

    ${resp}=    Get Membership Service 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${accountId}    ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List   ${accountId}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${j}=  Evaluate  ${len}+1

   FOR  ${i}  IN RANGE   1  ${j}
        Set Suite Variable    ${qid11}    ${resp.json()[${i}-1]['id']}
        ${qns}   Get Questionnaire By Id  ${accountId}  ${qid11}  
        Log  ${qns.json()}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}
    END

    FOR  ${i}  IN RANGE   1  ${j}

        ${qns}   Get Questionnaire By Id  ${accountId}  ${qid11}  
        Log  ${qns.json()}
        Should Be Equal As Strings  ${qns.status_code}  200
        Set Suite Variable   ${Qnr_Status}   ${qns.json()['status']}

        IF   '${Qnr_Status}' == '${status[1]}'
            ${resp}=  Change Status of Questionnaire   ${accountId}  ${status[0]}  ${qid11}
            Log  ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
        END
        ${qns}   Get Questionnaire By Id  ${accountId}  ${qid11}  
        Log  ${qns.json()}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    END  
    
    ${resp}=  Get Questionnaire List   ${accountId}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[12]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[12]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings  ${qns.status_code}  200

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${number1}    Generate random string    10    123456789
    ${number1}    Convert To Integer  ${number1}
    Set Suite Variable    ${number1}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${number1}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${number1}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${number1}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Customer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${number1}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200 

    ${resp}=    Create Membership     ${firstName}    ${lastName}    ${number1}    ${membershipid}    ${countryCodes[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable     ${memberid1}    ${resp.json()}

    ${respo}=    Get Before Questionnaire Membership    ${accountId}    ${membershipid}    ${QnrChannel[1]}
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Set Suite Variable    ${qid}     ${respo.json()['questionnaireId']}
    Set Suite Variable    ${Quid}     ${respo.json()['id']}
    
    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME62}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${caption}     FakerLibrary.firstName
    ${file_size}    Get File Size    ${jpg}
    ${labelName}    FakerLibrary.firstName
    ${resp}=    db.getMimetype   ${jpg}
    ${mimetype}    Get From Dictionary    ${resp}    ${jpg}
    ${keyName}    FakerLibrary.firstName  
    ${file_name}    Evaluate    __import__('os').path.basename('${jpg}')

    ${resp}=    Imageupload.UploadQNRfiletoTempLocation    ${cookie}  ${user_id}  ${Quid}  ${caption}  ${mimetype}  ${file_name}  ${file_name}  ${file_size}  ${labelName}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200
    Set Suite Variable    ${driveid}     ${resp.json()['urls'][0]['driveId']}

    ${fudata}=  db.fileUploadDT   ${respo.json()}  ${FileAction[0]}  ${memberid1}  ${jpg} 
    Log  ${fudata}

    ${len}=  Get Length  ${fudata['fileupload'][0]['files']}
    FOR  ${i}  IN RANGE  0    ${len}
        Set To Dictionary    ${fudata['fileupload'][0]['files'][${i}]}    driveid    ${driveid}
    END

    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${respo.json()}   ${Quid}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}

    ${resp}=  Consumer Validate Questionnaire    ${accountId}    ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Submit Member Qnr    ${accountId}    ${memberid1}    ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    get all Member questionnaire    ${accountId}    ${memberid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Submit_Member_QNR-UH1

    [Documentation]  Submit Member QNR which is already submited

    ${resp}=  Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Generate random string    4    0123456789

    ${resp}=    Submit Member Qnr    ${accountId}    ${memberid1}    ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${QUESTIONNAIRE_NOT_EXIST}

JD-TC-Submit_Member_QNR-UH2

    [Documentation]  Submit Member QNR where memberid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME62}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${fake}=    Generate random string    4    0123456789

    ${resp}=    Submit Member Qnr    ${accountId}    ${fake}    ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_UID}

JD-TC-Submit_Member_QNR-UH3

    [Documentation]  Submit Member QNR with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME63}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Submit Member Qnr    ${accountId}    ${memberid1}    ${data}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}

JD-TC-Submit_Member_QNR-UH4

    [Documentation]  Submit Member QNR with consumer login

    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Submit Member Qnr    ${accountId}    ${memberid1}    ${data}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Submit_Member_QNR-UH5

    [Documentation]  Submit Member QNR without login

    ${resp}=    Submit Member Qnr    ${accountId}    ${memberid1}    ${data}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}