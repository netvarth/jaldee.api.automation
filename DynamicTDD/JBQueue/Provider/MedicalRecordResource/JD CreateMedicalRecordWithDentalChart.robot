*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        MR
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}               SERVICE1
${SERVICE2}               SERVICE2
${SERVICE3}               SERVICE3
${SERVICE4}               SERVICE4
${SERVICE5}               SERVICE3
${SERVICE6}               SERVICE4
${self}                   0

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

*** Keywords ***

dental surface 
    [Arguments]    ${toothId}    ${dentalState}     ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${boolean}    ${notes}    ${chiefIssue}   @{vargs}   

    ${len}=  Get Length  ${vargs}
    ${attachments}=  Create List

    FOR    ${index}    IN RANGE    ${len}   
        Exit For Loop If  ${len}==0
        Append To List  ${attachments}  ${vargs[${index}]}
    END
    ${occlusal}=  Create Dictionary  description=${occlusal_des}  symptoms=${occlusal_symptoms}    observations=${occlusal_observations}    diagnosis=${occlusal_diagnosis}  procedure=${occlusal_proc} 
    ${mesial}=  Create Dictionary  description=${mesial_des}    symptoms=${mesial_symptoms}    observations=${mesial_observations}    diagnosis=${mesial_diagnosis}  procedure=${mesial_proc}    
    ${distal}=  Create Dictionary  description=${distal_des}    symptoms=${distal_symptoms}    observations=${distal_observations}    diagnosis=${distal_diagnosis}  procedure=${distal_proc}   
    ${buccal}=  Create Dictionary  description=${buccal_des}    symptoms=${buccal_symptoms}    observations=${buccal_observations}    diagnosis=${buccal_diagnosis}  procedure=${buccal_proc}    
    ${lingual}=  Create Dictionary  description=${lingual_des}    symptoms=${lingual_symptoms}    observations=${lingual_observations}    diagnosis=${lingual_diagnosis}  procedure=${lingual_proc}    
    ${incisal}=  Create Dictionary  description=${incisal_des}    symptoms=${incisal_symptoms}    observations=${incisal_observations}    diagnosis=${incisal_diagnosis}  procedure=${incisal_proc}    
    # ${status}=  Create Dictionary  status=${status}  chiefComplaint=${boolean}    notes=${notes}    attachments=${attachments}
    ${surface}=    Create Dictionary    occlusal=${occlusal}    mesial=${mesial}    distal=${distal}    buccal=${buccal}    lingual=${lingual}    incisal=${incisal}    
    ${teeth}=    Create Dictionary  toothId=${toothId}    dentalState=${dentalState}    surface=${surface}    status=${status}  chiefComplaint=${boolean}    notes=${notes}    chiefIssue=${chiefIssue}    attachments=${attachments}
    [Return]  ${teeth}

Create Medical Record With Dental Chart


    [Arguments]  ${uid}  ${bookingType}  ${consultationMode}    &{kwargs}

   ${data}=  Create Dictionary    bookingType=${bookingType}  consultationMode=${consultationMode}      
   FOR  ${key}  ${value}  IN  &{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
   END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/mr/${uid}  data=${data}  expected_status=any
   [Return]  ${resp}

*** Test Cases ***

JD-TC-Createdentalchart
    [Documentation]    create a medical record with a dental chart for a Appointment(Walk-in).
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+7850065
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}    ${resp.json()['id']} 
    Set Suite Variable    ${userName}    ${resp.json()['userName']}         
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}

    ${pid}=  get_acc_id  ${PUSERNAME_C}
    Set Suite Variable  ${pid}

    ${DAY1}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_time  0  15
    ${eTime}=  add_time   0  45
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
 
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id1}    ${resp} 
    
    ${DAY1}=  get_date
    ${DAY2}=  add_date  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME11}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${occlusal_des}=      FakerLibrary.sentence
    Set Suite Variable  ${occlusal_des}
    ${occlusal_proc}=     FakerLibrary.sentence
    Set Suite Variable  ${occlusal_proc}
    ${occlusal_symptoms}=      FakerLibrary.sentence
    Set Suite Variable  ${occlusal_symptoms}
    ${occlusal_observations}=     FakerLibrary.sentence
    Set Suite Variable  ${occlusal_observations}
    ${occlusal_diagnosis}=     FakerLibrary.sentence
    Set Suite Variable  ${occlusal_diagnosis}

    ${mesial_des}=      FakerLibrary.sentence
    Set Suite Variable  ${mesial_des}
    ${mesial_proc}=     FakerLibrary.sentence
    Set Suite Variable  ${mesial_proc}
    ${mesial_symptoms}=      FakerLibrary.sentence
    Set Suite Variable  ${mesial_symptoms}
    ${mesial_observations}=     FakerLibrary.sentence
    Set Suite Variable  ${mesial_observations}
    ${mesial_diagnosis}=     FakerLibrary.sentence
    Set Suite Variable  ${mesial_diagnosis}

    ${distal_des}=      FakerLibrary.sentence
    Set Suite Variable  ${distal_des}
    ${distal_proc}=     FakerLibrary.sentence
    Set Suite Variable  ${distal_proc}
    ${distal_symptoms}=      FakerLibrary.sentence
    Set Suite Variable  ${distal_symptoms}
    ${distal_observations}=     FakerLibrary.sentence
    Set Suite Variable  ${distal_observations}
    ${distal_diagnosis}=     FakerLibrary.sentence
    Set Suite Variable  ${distal_diagnosis}

    ${buccal_des}=      FakerLibrary.sentence
    Set Suite Variable  ${buccal_des}
    ${buccal_proc}=     FakerLibrary.sentence
    Set Suite Variable  ${buccal_proc}
    ${buccal_symptoms}=      FakerLibrary.sentence
    Set Suite Variable  ${buccal_symptoms}
    ${buccal_observations}=     FakerLibrary.sentence
    Set Suite Variable  ${buccal_observations}
    ${buccal_diagnosis}=     FakerLibrary.sentence
    Set Suite Variable  ${buccal_diagnosis}

    ${lingual_des}=      FakerLibrary.sentence
    Set Suite Variable  ${lingual_des}
    ${lingual_proc}=     FakerLibrary.sentence
    Set Suite Variable  ${lingual_proc}
    ${lingual_symptoms}=      FakerLibrary.sentence
    Set Suite Variable  ${lingual_symptoms}
    ${lingual_observations}=     FakerLibrary.sentence
    Set Suite Variable  ${lingual_observations}
    ${lingual_diagnosis}=     FakerLibrary.sentence
    Set Suite Variable  ${lingual_diagnosis}

    ${incisal_des}=      FakerLibrary.sentence
    Set Suite Variable  ${incisal_des}
    ${incisal_proc}=     FakerLibrary.sentence
    Set Suite Variable  ${incisal_proc}
    ${incisal_symptoms}=      FakerLibrary.sentence
    Set Suite Variable  ${incisal_symptoms}
    ${incisal_observations}=     FakerLibrary.sentence
    Set Suite Variable  ${incisal_observations}
    ${incisal_diagnosis}=     FakerLibrary.sentence
    Set Suite Variable  ${incisal_diagnosis}
    ${chiefIssue}=      FakerLibrary.sentence
    Set Suite Variable  ${chiefIssue}

    ${status}=  FakerLibrary.sentence
    Set Suite Variable  ${status}
    ${notes}=  FakerLibrary.sentence
    Set Suite Variable  ${notes}
    ${remarks}=  FakerLibrary.sentence
    Set Suite Variable  ${remarks}
    ${attachments}=    Create List
    Set Suite Variable  ${attachments}
    ${procedure}=      FakerLibrary.sentence
    Set Suite Variable  ${procedure}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    ${name}=    Fakerlibrary.name

    # ${resp}    upload file to temporary location    ${file_action[0]}    ${pid}    ${ownerType[0]}    ${name}    ${pdffile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200 
    # Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

    # ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200

    ${attachment}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment}
    Set Suite Variable    ${attachment}

    ${attachment1}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment1}
    Set Suite Variable    ${attachment1}

    ${attachmentList}=    Create List    ${attachment}    ${attachment1}

    ${dental_Chart}=  dental surface   1    ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}    ${attachment1}
        # occlusal=${attachmentList}     mesial=${attachmentList}    distal=${attachmentList}    buccal=${attachmentList}    lingual=${attachmentList}    incisal=${attachmentList}    
    Log   ${dental_Chart}

    # ${dental_Chart}=  Create dental Chart    1    ${description}    ${procedure}    ${status}    ${bool[1]}    ${notes} 
    # Log   ${dental_Chart}

    ${teeth}=    Create List    ${dental_Chart}
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}


    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}      dentalChart=${teeth}     
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Createdentalchart-1
    [Documentation]    create dental chart for 2 teeth.

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart1}=  dental surface   1    ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}    ${attachment1}
    Log   ${dental_Chart1}

    ${dental_Chart2}=  dental surface   2    ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}    ${attachment1}
    Log   ${dental_Chart2}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart1}    ${dental_Chart2}
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}    dentalChart=${teeth}     
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Createdentalchart-2
    [Documentation]    create dental chart for 2 teeth.

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart1}=  dental surface   25    ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}    ${attachment1}
    Log   ${dental_Chart1}

    ${dental_Chart2}=  dental surface   50    ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}    ${attachment1}
    Log   ${dental_Chart2}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart1}    ${dental_Chart2}
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}    dentalChart=${teeth}     
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MedicalRecords  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Createdentalchart-3
    [Documentation]    create medical record with a dental chart for a Appointment(Walk-in).

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  get_date

    ${resp}=  AddCustomer  ${CUSERNAME14}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${dental_Chart1}=  dental surface   6    ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}    ${attachment1}
    Log   ${dental_Chart1}

    ${dental_Chart2}=  dental surface   10    ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}    ${attachment1}
    Log   ${dental_Chart2}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart1}    ${dental_Chart2}
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}    dentalChart=${teeth}     
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MedicalRecords  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-Createdentalchart-4
    [Documentation]    create medical record with a dental chart with Empty toothId.

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface    ${EMPTY}    ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart}    
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${TOOTH_ID_CANNOT_BE_NULL}

JD-TC-Createdentalchart-5
    [Documentation]    create medical record with a dental chart with diffrent bookingType (TOKEN).

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface    80   ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart}    
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[0]}  ${consultationMode[3]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_BOOKING_TYPE}

JD-TC-Createdentalchart-6
    [Documentation]    create medical record with a dental chart with diffrent bookingType (FOLLOWUP).

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface    88   ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart}    
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[2]}  ${consultationMode[3]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_BOOKING_TYPE}

JD-TC-Createdentalchart-7
    [Documentation]    create medical record with a dental chart with diffrent consultationMode (EMAIL).

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface    82   ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart}    
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[0]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Createdentalchart-8
    [Documentation]    create medical record with a dental chart with diffrent consultationMode (PHONE).

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface    82   ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart}    
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[1]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Createdentalchart-9
    [Documentation]    create medical record with a dental chart with diffrent consultationMode (VIDEO).

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface    82   ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart}    
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[2]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Createdentalchart-10
    [Documentation]    Add same dental chart details to teeth list.

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface    82   ${dentalState[0]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart}    ${dental_Chart}    ${dental_Chart}
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Createdentalchart-11
    [Documentation]    create dental chart With dentalState-PERMANENT.

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface    82   ${dentalState[1]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart}    
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Createdentalchart-12
    [Documentation]    create dental chart With dentalState-MIXED.

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface    82   ${dentalState[2]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart}    
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Createdentalchart-13
    [Documentation]    create dental chart With EMPTY remarks.

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface    82   ${dentalState[2]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    ${attachment}   

    ${teeth}=    Create List    ${dental_Chart}    
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${EMPTY}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Createdentalchart-14
    [Documentation]    create dental chart With EMPTY attachments.

    ${resp}=  Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface    82   ${dentalState[2]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    

    ${teeth}=    Create List    ${dental_Chart}    
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${EMPTY}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Createdentalchart-15
    [Documentation]    create dental chart With Consumer Login.

    ${resp}=  Consumer Login  ${CUSERNAME27}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${dental_Chart}=  dental surface    82   ${dentalState[2]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    ${attachment}

    ${teeth}=    Create List    ${dental_Chart}    
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Createdentalchart-16
    [Documentation]    create dental chart WithOut Login.


    ${dental_Chart}=  dental surface    8   ${dentalState[2]}       ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}  
    Log   ${dental_Chart}

    ${attachmentList}=    Create List    ${attachment}

    ${teeth}=    Create List    ${dental_Chart}    
    ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}

    ${resp}=  Create Medical Record With Dental Chart    ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}          dentalChart=${teeth}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"