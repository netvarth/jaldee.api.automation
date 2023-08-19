*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
##Library           ExcellentLibrary
Library           OperatingSystem
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${xlFile1}    ${EXECDIR}/TDD/sampleqnr.xlsx     # DataSheet
${xlFile}   ${EXECDIR}/TDD/Dr.Aparna -Facial.xlsx   # DataSheet 2
${self}      0
@{emptylist}
${mp4file}   /ebs/TDD/MP4file.mp4
${mp4mime}   video/mp4
${mp3file}   /ebs/TDD/MP3file.mp3
${mp3mime}   audio/mpeg
${pdffile}   /ebs/TDD/sample.pdf
${jpgfile}   /ebs/TDD/uploadimage.jpg
${pngfile}   /ebs/TDD/upload.png


*** Test Cases ***


JD-TC-OneTimeInfoSave-1
  [Documentation]  One time Info Save

  ${wb}=  readWorkbook  ${xlFile}
  ${sheet1}  GetCurrentSheet   ${wb}
  Set Suite Variable   ${sheet1}
  ${colnames}=  getColumnHeaders  ${sheet1}
  Log List  ${colnames}
  Log List  ${QnrChannel}
  Log List  ${QnrTransactionType}
  Set Suite Variable   ${colnames}

  ${resp}=  Provider Login  ${PUSERNAME27}  ${PASSWORD}
  Log  ${resp.content}
  Should Be Equal As Strings    ${resp.status_code}    200
  Set Suite Variable    ${proid}    ${resp.json()['id']}

  ${resp}=  Get Business Profile
  Should Be Equal As Strings  ${resp.status_code}  200
  Set Suite Variable  ${account_id}  ${resp.json()['id']}

  ${resp}=   Get Service
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200

  ${lid}=  Create Sample Location
  Set Suite Variable   ${lid}

  ${min_pre1}=   Random Int   min=50   max=100
  ${Tot}=   Random Int   min=150   max=500
  ${min_pre1}=  Convert To Number  ${min_pre1}  1
  Set Suite Variable   ${min_pre1}
  ${pre_float1}=  twodigitfloat  ${min_pre1}
  Set Suite Variable   ${pre_float1}   
  ${Tot1}=  Convert To Number  ${Tot}  1 
  Set Suite Variable   ${Tot1}   
  ${ser_duratn}=   Random Int   min=10   max=12

  ${SERVICE1}=    FakerLibrary.word
  ${desc}=   FakerLibrary.sentence
  ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${ser_duratn}  ${status[0]}   ${btype}    ${bool[1]}  ${notifytype[2]}  ${min_pre1}  ${Tot1}  ${bool[1]}  ${bool[0]}
  Log   ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200
  Set Suite Variable  ${s_id}  ${resp.json()}

  ${resp}=  Provider Logout
  Log  ${resp.content}
  Should Be Equal As Strings    ${resp.status_code}    200
    
  ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200

  ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200

  ${resp}=  Provider Login  ${PUSERNAME27}  ${PASSWORD}
  Log  ${resp.content}
  Should Be Equal As Strings    ${resp.status_code}    200

  ${resp}=   Get jaldeeIntegration Settings
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200
  Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

  ${resp}=    Get Locations
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200
  Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 

  ${resp}=   Get Service
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200

  clear_queue   ${PUSERNAME27}

  ${DAY1}=  get_date
    
  ${resp}=  Sample Queue   ${lid}   ${s_id}
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200
  Set Test Variable  ${q_id}  ${resp.json()}

  ${resp}=  Get Queue ById  ${q_id}
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200
  Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

  ${resp}=  Get Questionnaire List By Provider   
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200
  ${len}=  Get Length  ${resp.json()}
  FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[4]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[3]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
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

  ${resp}=   Get Service
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200
  Set Suite Variable   ${s_id}

  ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
  Log  ${resp.content}
  Should Be Equal As Strings      ${resp.status_code}  200
  IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME7}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid1}  ${resp1.json()}
  ELSE
        Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}
  END
    
  ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
  Log  ${resp.content}
  Should Be Equal As Strings      ${resp.status_code}  200
  Set Test Variable  ${jdid}  ${resp.json()[0]['id']}

  ${resp}=    Get Locations
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200
  Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 

  ${DAY1}=  get_date
  ${list}=  Create List  1  2  3  4  5  6  7
  ${DAY1}=  get_date
  ${DAY2}=  add_date  15 
  ${sTime}=  db.get_time
  ${eTime}=  add_time  0  15
  ${capacity}=  Random Int  min=20   max=40
  ${parallel}=  Random Int   min=1   max=2
  ${queue1}=    FakerLibrary.Word
  ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY2}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id}
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200
  Set Test Variable  ${q_id}  ${resp.json()}

  ${resp}=  Get Queue ById  ${q_id}
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200
  Verify Response  ${resp}  id=${q_id}   queueState=${Qstate[0]}

  ${desc}=   FakerLibrary.word
  ${resp}=  Add To Waitlist  ${cid1}  ${s_id}  ${q_id}  ${DAY2}  ${desc}  ${bool[1]}  ${cid1}
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200
  ${wid}=  Get Dictionary Values  ${resp.json()}
  Set Suite Variable  ${wid}  ${wid[0]}

  ${resp}=  Get Waitlist By Id  ${wid} 
  Log  ${resp.content}
  Should Be Equal As Strings  ${resp.status_code}  200

  ${resp}=  Provider Login  ${PUSERNAME27}  ${PASSWORD}
  Log  ${resp.content}
  Should Be Equal As Strings    ${resp.status_code}    200

  ${resp}=    ProviderConsumer View Questionnaire   # ${jdid}    ${proid}
  Log    ${resp.content}
  Should Be Equal As Strings   ${resp.status_code}  200

  # ${resp}=  Get Questionnaire By uuid For Waitlist    ${wid}
  # Log  ${resp.content}
  # Should Be Equal As Strings  ${resp.status_code}  200
  # Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
  # Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
  ${fudata}=  db.fileUploadDTProcon   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile} 
  Log  ${fudata}

  ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${cid1}   &{fudata}
  Log  ${data}
  Set Suite Variable   ${data}

  ${firstName}=  FakerLibrary.name
  Set Suite Variable    ${firstName}
  ${lastName}=  FakerLibrary.last_name
  Set Suite Variable    ${lastName}
  ${email}=    FakerLibrary.Email
  Set Suite Variable    ${email}

  ${resp}=    Send Otp For Login    ${CUSERNAME7}    ${accountId}
  Log   ${resp.content}
  Should Be Equal As Strings    ${resp.status_code}   200

  ${resp}=    Verify Otp For Login   ${CUSERNAME7}   12
  Log   ${resp.content}
  Should Be Equal As Strings    ${resp.status_code}   200
  Set Suite Variable  ${token}  ${resp.json()['token']}

  ${resp}=    Customer Logout 
  Log   ${resp.content}
  Should Be Equal As Strings    ${resp.status_code}   200

  ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${CUSERNAME7}     ${accountId}
  Log  ${resp.json()}
  Should Be Equal As Strings    ${resp.status_code}   200    
   
  ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${accountId}  ${token} 
  Log   ${resp.content}
  Should Be Equal As Strings    ${resp.status_code}   200
  