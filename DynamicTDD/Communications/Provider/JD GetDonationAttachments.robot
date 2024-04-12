*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Order
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***

@{multiples}  10  20  30   40   50
${SERVICE1}   MakeUp
${SERVICE2}   Coloring
${SERVICE3}   Painting

${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458
*** Test Cases ***

JD-TC-GetDonationAttachments-1

    [Documentation]    Get Donation Attachments

    ${resp}=  Encrypted Provider Login  ${PUSERNAME253}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pdrname}  ${decrypted_data['userName']}
        
    clear_queue      ${PUSERNAME253}
    clear_location   ${PUSERNAME253}
    clear_service    ${PUSERNAME253}
    clear_customer   ${PUSERNAME253}

    ${pid}=  get_acc_id  ${PUSERNAME253}
    Set Suite Variable  ${pid}
        
    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp} 

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${min_don_amt1}=   Random Int   min=100   max=500
    ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
    ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
    ${max_don_amt1}=   Random Int   min=5000   max=10000
    ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
    ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
    ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
    Set Suite Variable  ${min_don_amt}
    ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
    Set Suite Variable  ${max_don_amt}
    ${service_duration}=   Random Int   min=10   max=50
    Set Suite Variable  ${service_duration}
    ${total_amnt}=   Random Int   min=100   max=500
    ${total_amnt}=  Convert To Number  ${total_amnt}   1

    ${SERVICE1}=  FakerLibrary.word
    ${SERVICE2}=  FakerLibrary.first_name
    ${SERVICE3}=  FakerLibrary.last_name
    ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid1}  ${resp.json()}

    ${total_amnt}=   Random Int   min=100   max=500
    ${total_amnt}=  Convert To Number  ${total_amnt}   1

    ${resp}=  Create Donation Service  ${SERVICE2}   ${description}   ${service_duration}   ${btype}    ${bool[1]}    ${notifytype[2]}   ${total_amnt}   ${bool[0]}   ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid2}  ${resp.json()}

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${consumerPhone}  555${PH_Number}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
    ${consumerFirstName}=   FakerLibrary.first_name
    Set Suite Variable  ${consumerFirstName}
    ${consumerLastName}=    FakerLibrary.last_name  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${consumerFirstName}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${consumerFirstName}   lastName=${consumerLastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Provider Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token     ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Suite Variable    ${PCid}   ${resp.json()['id']}

    ${con_id}=  get_id  ${CUSERNAME5}
    Set Suite Variable  ${con_id}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}

    ${don_amt1}=   Random Int   min=1000   max=4000
    ${mod}=  Evaluate  ${don_amt1}%${multiples[0]}
    ${don_amt1}=  Evaluate  ${don_amt1}-${mod}
    ${don_amt1}=  Convert To Number  ${don_amt1}  1
    Set Suite Variable  ${don_amt1}
    ${don_amt_float1}=  twodigitfloat  ${don_amt1}

    ${resp}=  Donation By Consumer  ${con_id}  ${sid1}  ${loc_id1}  ${don_amt1}  ${consumerFirstName}  ${consumerLastName}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    ${don_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${don_id1}  ${don_id[0]}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME253}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    FakerLibrary.firstname
    Set Suite variable    ${fileName}

    ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${attachments}=  Create Dictionary  owner=${pid}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}
    Set Suite Variable   ${attachment}

    ${uuid}=    Create List  ${don_id1}
    Set Suite Variable  ${uuid}

    ${resp}=    Send Message With Donation   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Donation Attachments     ${don_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']}          ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['fileName']}       ${fileName}
    Should Be Equal As Strings  ${resp.json()[0]['fileSize']}       ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['fileType']}       ${fileType1}
    Should Be Equal As Strings  ${resp.json()[0]['action']}         ${file_action[0]}
    Should Be Equal As Strings  ${resp.json()[0]['ownerName']}      ${pdrname}

JD-TC-GetDonationAttachments-UH1

    [Documentation]    Get Donation Attachments  - where order id is inalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME253}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${inv}=     FakerLibrary.Random Int

    ${resp}=    Get Donation Attachments   ${inv}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    404
    Should Be Equal As Strings  ${resp.json()}  ${DONATION_NOT_EXIST}

JD-TC-GetDonationAttachments-UH2

    [Documentation]    Get Donation Attachments  - with consumer login

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Donation Attachments   ${don_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    400
    Should Be Equal As Strings  ${resp.json()}  ${LOGIN_INVALID_URL}

JD-TC-GetDonationAttachments-UH3

    [Documentation]    Get Donation Attachments  - without login  

    ${resp}=    Get Donation Attachments   ${don_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    419
    Should Be Equal As Strings  ${resp.json()}  ${SESSION_EXPIRED}