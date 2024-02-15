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
    RETURN  ${teeth}

    
Create Medical Record With Dental Chart

    [Arguments]  ${uid}  ${bookingType}  ${consultationMode}    &{kwargs}

   ${data}=  Create Dictionary    bookingType=${bookingType}  consultationMode=${consultationMode}      
   FOR  ${key}  ${value}  IN  &{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
   END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/mr/${uid}  data=${data}  expected_status=any
   RETURN  ${resp}

Create Dental Chart With patientId


    [Arguments]  ${id}  ${bookingType}  ${consultationMode}    &{kwargs}

   ${data}=  Create Dictionary    bookingType=${bookingType}  consultationMode=${consultationMode}       
   FOR  ${key}  ${value}  IN  &{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
   END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/mr/patient/${id}  data=${data}  expected_status=any
   RETURN  ${resp}

Create Dental Chart with MR id

    [Arguments]  ${mrid}  &{kwargs}

   ${data}=  Create Dictionary          
   FOR  ${key}  ${value}  IN  &{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
   END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  POST On Session  ynw  /provider/mr/dentalchart/${mrid}  data=${data}  expected_status=any
   RETURN  ${resp}

Update Dental Chart with MR id

    [Arguments]  ${mrid}  &{kwargs}

   ${data}=  Create Dictionary          
   FOR  ${key}  ${value}  IN  &{kwargs}
            Set To Dictionary  ${data}   ${key}=${value}
   END
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  PUT On Session  ynw  /provider/mr/dentalchart/${mrid}  data=${data}  expected_status=any
   RETURN  ${resp}

Get dental chart with mr id
    [Arguments]     ${mrId}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/mr/dentalchart/${mrId}  expected_status=any
    RETURN  ${resp}

Remove tooth details with MR id

    [Arguments]  ${mrId}  ${toothId} 

   ${data}=    Create Dictionary  toothId=${toothId}
   ${data}=  json.dumps  ${data}
   Check And Create YNW Session
   ${resp}=  DELETE On Session  ynw  /provider/mr/dentalchart/${mrId}  data=${data}  expected_status=any
   RETURN  ${resp}

*** Test Cases ***

JD-TC-Createdentalchart-1
    [Documentation]    create a dental chart with mrid And update the mr with empty remarks.

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+7855041
    Set Suite Variable    ${PUSERNAME_C} 
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id}  ${decrypted_data['id']}
    Set Suite Variable  ${userName}  ${decrypted_data['userName']}
    # Set Suite Variable    ${id}    ${resp.json()['id']} 
    # Set Suite Variable    ${userName}    ${resp.json()['userName']}         
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}

    ${pid}=  get_acc_id  ${PUSERNAME_C}
    Set Suite Variable  ${pid}

    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   get_place
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  db.add_timezone_time  ${tz}  0  15
    ${eTime}=  db.add_timezone_time  ${tz}   0  45
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

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  0  30
    ${end_time}=    db.add_timezone_time  ${tz}  5  00  
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${Pres_notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence
    ${type}=     FakerLibrary.word
    ${clinicalNote}=     FakerLibrary.word
    ${clinicalNote1}=        FakerLibrary.sentence
    ${type1}=        FakerLibrary.sentence

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}

    ${aadhaarAttachments}=    Create Dictionary   action=${FileAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${aadhaarAttachments1}=    Create Dictionary   action=${FileAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments1}

    ${Notes}=    clinical Notes Attachments    ${type}  ${clinicalNote}    ${aadhaarAttachments}    ${aadhaarAttachments}

    ${Notes1}=    clinical Notes Attachments    ${type1}  ${clinicalNote1}    ${aadhaarAttachments}    ${aadhaarAttachments1}

    ${clinicalNotes}=  Create List   ${Notes}    ${Notes1}
   
    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}

    ${prescriptionsList}=  Create List   ${pre_list}

    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}
    
    ${resp}=  Create MR With uuid  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    # ${apptfor}=   Create List  ${apptfor1}
    
    # ${cnote}=   FakerLibrary.word
    # ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
          
    # ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    # Set Suite Variable  ${apptid1}  ${apptid[0]}

    # ${resp}=  Get Appointment EncodedID   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${encId}=  Set Variable   ${resp.json()}

    # ${resp}=  Get Appointment By Id   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

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


    ${dental_status}=  FakerLibrary.sentence
    Set Suite Variable  ${dental_status}
    ${notes}=  FakerLibrary.sentence
    Set Suite Variable  ${notes}
    ${remarks}=  FakerLibrary.sentence
    Set Suite Variable  ${remarks}
    ${attachments}=    Create List
    Set Suite Variable  ${attachments}
    ${procedure}=      FakerLibrary.sentence
    Set Suite Variable  ${procedure}
    ${chiefIssue}=      FakerLibrary.sentence
    Set Suite Variable  ${chiefIssue}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    ${name}=    Fakerlibrary.name

    ${attachment}=    Create Dictionary   action=${FileAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment}
    Set Suite Variable    ${attachment}

    ${attachment1}=    Create Dictionary   action=${FileAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment1}
    Set Suite Variable    ${attachment1}

    ${attachmentList}=    Create List    ${attachment}    ${attachment1}
    Set Suite Variable    ${attachmentList}

    ${dental_Chart}=  dental surface   1    ${dentalState[0]}     ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${dental_status}    ${bool[1]}    ${notes}    ${chiefIssue}    ${attachment}    ${attachment1}
    Log   ${dental_Chart}

    ${teeth}=    Create List    ${dental_Chart}
    # ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}


    ${resp}=  Create Dental Chart with MR id    ${mr_id1}  teeth=${teeth}    remarks=${remarks}     
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${teeth}=    Create List    ${dental_Chart}
    # ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${EMPTY}     attachments=${attachmentList}

    ${resp}=  Update Dental Chart with MR id    ${mr_id1}    remarks=${EMPTY}     
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get dental chart with mr id    ${mr_id1}  
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Updatedentalchart-2
    [Documentation]    create a dental chart with mrid And update the mr with empty notes.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface   1    ${dentalState[0]}     ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${dental_status}    ${bool[1]}    ${EMPTY}    ${chiefIssue}    
    Log   ${dental_Chart}

    ${teeth}=    Create List    ${dental_Chart}

    ${resp}=  Update Dental Chart with MR id    ${mr_id1}  teeth=${teeth}        
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get dental chart with mr id    ${mr_id1}  
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['teeth'][0]['notes']}    ${EMPTY}

JD-TC-Updatedentalchart-3
    [Documentation]    create a dental chart with mrid And update the mr chiefComplaint.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dental_Chart}=  dental surface   1    ${dentalState[0]}     ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${dental_status}    ${bool[0]}    ${notes}    ${chiefIssue}
    Log   ${dental_Chart}

    ${teeth}=    Create List    ${dental_Chart}

    ${resp}=  Update Dental Chart with MR id    ${mr_id1}  teeth=${teeth}        
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get dental chart with mr id    ${mr_id1}  
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['teeth'][0]['chiefComplaint']}    ${bool[0]}

JD-TC-Updatedentalchart-4
    [Documentation]    create a dental chart with mrid And update the mr Attachment (Remove).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${attachment}=    Create Dictionary   action=${FileAction[2]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment}
    # Set Suite Variable    ${attachment}

    ${attachment1}=    Create Dictionary   action=${FileAction[2]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment1}
    # Set Suite Variable    ${attachment1}

    ${dental_Chart}=  dental surface   1    ${dentalState[0]}     ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${dental_status}    ${bool[0]}    ${notes}    ${chiefIssue}   ${attachment}    ${attachment1}   
    Log   ${dental_Chart}

    ${teeth}=    Create List    ${dental_Chart}

    ${resp}=  Update Dental Chart with MR id    ${mr_id1}  teeth=${teeth}        
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get dental chart with mr id    ${mr_id1}  
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['teeth'][0]['chiefComplaint']}    ${bool[0]}
# *** comment ***
JD-TC-Updatedentalchart-5
    [Documentation]    create a dental chart with mrid And update the tooth ecclusal to empty.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${attachment}=    Create Dictionary   action=${FileAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment}
    # Set Suite Variable    ${attachment}

    ${attachment1}=    Create Dictionary   action=${FileAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment1}
    # Set Suite Variable    ${attachment1}

    ${dental_Chart}=  dental surface   1    ${dentalState[0]}     ${EMPTY}    ${EMPTY}    ${EMPTY}   ${EMPTY}   ${EMPTY}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${dental_status}    ${bool[0]}    ${notes}    ${chiefIssue}   ${attachment}    ${attachment1}   
    Log   ${dental_Chart}

    ${teeth}=    Create List    ${dental_Chart}

    ${resp}=  Update Dental Chart with MR id    ${mr_id1}  teeth=${teeth}        
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get dental chart with mr id    ${mr_id1}  
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Updatedentalchart-6
    [Documentation]   Create two teeth dentalChart and update to both same value.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${Pres_notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence
    ${type}=     FakerLibrary.word
    ${clinicalNote}=     FakerLibrary.sentence
    ${clinicalNote1}=        FakerLibrary.sentence
    ${type1}=        FakerLibrary.sentence

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}


    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}

    ${aadhaarAttachments}=    Create Dictionary   action=${FileAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${aadhaarAttachments1}=    Create Dictionary   action=${FileAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments1}

    ${Notes}=    clinical Notes Attachments    ${type}  ${clinicalNote}    ${aadhaarAttachments}    ${aadhaarAttachments}

    ${Notes1}=    clinical Notes Attachments    ${type1}  ${clinicalNote1}    ${aadhaarAttachments}    ${aadhaarAttachments1}

    ${clinicalNotes}=  Create List   ${Notes}    ${Notes1}
   
    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}

    ${prescriptionsList}=  Create List   ${pre_list}

    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}
    
    ${resp}=  Create MR With uuid  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id2}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    # ${apptfor}=   Create List  ${apptfor1}
    
    # ${cnote}=   FakerLibrary.word
    # ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
          
    # ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    # Set Suite Variable  ${apptid1}  ${apptid[0]}

    # ${resp}=  Get Appointment EncodedID   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${encId}=  Set Variable   ${resp.json()}

    # ${resp}=  Get Appointment By Id   ${apptid1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${occlusal_des1}=      FakerLibrary.sentence
    Set Suite Variable  ${occlusal_des1}
    ${occlusal_proc1}=     FakerLibrary.sentence
    Set Suite Variable  ${occlusal_proc1}
    ${occlusal_symptoms1}=      FakerLibrary.sentence
    Set Suite Variable  ${occlusal_symptoms1}
    ${occlusal_observations1}=     FakerLibrary.sentence
    Set Suite Variable  ${occlusal_observations1}
    ${occlusal_diagnosis1}=     FakerLibrary.sentence
    Set Suite Variable  ${occlusal_diagnosis1}

    ${mesial_des1}=      FakerLibrary.sentence
    Set Suite Variable  ${mesial_des1}
    ${mesial_proc1}=     FakerLibrary.sentence
    Set Suite Variable  ${mesial_proc1}
    ${mesial_symptoms1}=      FakerLibrary.sentence
    Set Suite Variable  ${mesial_symptoms1}
    ${mesial_observations1}=     FakerLibrary.sentence
    Set Suite Variable  ${mesial_observations1}
    ${mesial_diagnosis1}=     FakerLibrary.sentence
    Set Suite Variable  ${mesial_diagnosis1}

    ${distal_des1}=      FakerLibrary.sentence
    Set Suite Variable  ${distal_des1}
    ${distal_proc1}=     FakerLibrary.sentence
    Set Suite Variable  ${distal_proc1}
    ${distal_symptoms1}=      FakerLibrary.sentence
    Set Suite Variable  ${distal_symptoms1}
    ${distal_observations1}=     FakerLibrary.sentence
    Set Suite Variable  ${distal_observations1}
    ${distal_diagnosis1}=     FakerLibrary.sentence
    Set Suite Variable  ${distal_diagnosis1}

    ${buccal_des1}=      FakerLibrary.sentence
    Set Suite Variable  ${buccal_des1}
    ${buccal_proc1}=     FakerLibrary.sentence
    Set Suite Variable  ${buccal_proc1}
    ${buccal_symptoms1}=      FakerLibrary.sentence
    Set Suite Variable  ${buccal_symptoms1}
    ${buccal_observations1}=     FakerLibrary.sentence
    Set Suite Variable  ${buccal_observations1}
    ${buccal_diagnosis1}=     FakerLibrary.sentence
    Set Suite Variable  ${buccal_diagnosis1}

    ${lingual_des1}=      FakerLibrary.sentence
    Set Suite Variable  ${lingual_des1}
    ${lingual_proc1}=     FakerLibrary.sentence
    Set Suite Variable  ${lingual_proc1}
    ${lingual_symptoms1}=      FakerLibrary.sentence
    Set Suite Variable  ${lingual_symptoms1}
    ${lingual_observations1}=     FakerLibrary.sentence
    Set Suite Variable  ${lingual_observations1}
    ${lingual_diagnosis1}=     FakerLibrary.sentence
    Set Suite Variable  ${lingual_diagnosis1}

    ${incisal_des1}=      FakerLibrary.sentence
    Set Suite Variable  ${incisal_des1}
    ${incisal_proc1}=     FakerLibrary.sentence
    Set Suite Variable  ${incisal_proc1}
    ${incisal_symptoms1}=      FakerLibrary.sentence
    Set Suite Variable  ${incisal_symptoms1}
    ${incisal_observations1}=     FakerLibrary.sentence
    Set Suite Variable  ${incisal_observations1}
    ${incisal_diagnosis1}=     FakerLibrary.sentence
    Set Suite Variable  ${incisal_diagnosis1}


    ${dental_status1}=  FakerLibrary.sentence
    Set Suite Variable  ${dental_status1}
    ${notes1}=  FakerLibrary.sentence
    Set Suite Variable  ${notes1}
    ${remarks1}=  FakerLibrary.sentence
    Set Suite Variable  ${remarks1}
    ${attachments1}=    Create List
    Set Suite Variable  ${attachments1}
    ${procedure}=      FakerLibrary.sentence
    Set Suite Variable  ${procedure}
    ${dental_notes}=  FakerLibrary.sentence
    Set Suite Variable  ${dental_notes}

    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    ${name}=    Fakerlibrary.name

    ${attachment}=    Create Dictionary   action=${FileAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment}
    Set Suite Variable    ${attachment}

    ${attachment1}=    Create Dictionary   action=${FileAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment1}
    Set Suite Variable    ${attachment1}

    ${attachmentList}=    Create List    ${attachment}    ${attachment1}
    Set Suite Variable    ${attachmentList}

    ${dental_Chart}=  dental surface   1    ${dentalState[0]}     ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${dental_status}    ${bool[1]}     ${dental_notes}    ${chiefIssue}    ${attachment}    
    Log   ${dental_Chart}

    ${dental_Chart1}=  dental surface   2   ${dentalState[1]}     ${occlusal_des1}    ${occlusal_proc1}    ${occlusal_symptoms1}   ${occlusal_observations1}   ${occlusal_diagnosis1}    ${mesial_des1}    ${mesial_proc1}    ${mesial_symptoms1}    ${mesial_observations1}    ${mesial_diagnosis1}  ${distal_des1}    ${distal_proc1}    ${distal_symptoms1}    ${distal_observations1}    ${distal_diagnosis1}  ${buccal_des1}    ${buccal_proc1}    ${buccal_symptoms1}    ${buccal_observations1}    ${buccal_diagnosis1}  ${lingual_des1}    ${lingual_proc1}    ${lingual_symptoms1}    ${lingual_observations1}    ${lingual_diagnosis1}  ${incisal_des1}    ${incisal_proc1}    ${incisal_symptoms1}    ${incisal_observations1}    ${incisal_diagnosis1}    ${dental_status1}    ${bool[1]}    ${notes1}    ${chiefIssue}    ${attachment}    ${attachment1}
    Log   ${dental_Chart1}

    ${teeth}=    Create List    ${dental_Chart}    ${dental_Chart1}
    # ${teeth}=    Create Dictionary    teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}


    ${resp}=  Create Dental Chart with MR id    ${mr_id2}  teeth=${teeth}    remarks=${remarks}     attachments=${attachmentList}
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get dental chart with mr id    ${mr_id2}  
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attachment}=    Create Dictionary   action=${FileAction[2]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment}
    # Set Suite Variable    ${attachment}

    ${attachment1}=    Create Dictionary   action=${FileAction[2]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment1}
    # Set Suite Variable    ${attachment1}

    ${dental_Chart}=  dental surface   2    ${dentalState[0]}     ${occlusal_des}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${dental_status}    ${bool[0]}    ${dental_notes}    ${chiefIssue}   ${attachment}    ${attachment1}   
    Log   ${dental_Chart}

    ${teeth}=    Create List    ${dental_Chart}

    ${resp}=  Update Dental Chart with MR id    ${mr_id2}  teeth=${teeth}        
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get dental chart with mr id    ${mr_id2}  
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Updatedentalchart-7
    [Documentation]   Update The Same MR with different tooth id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${occlusal_des2}=  FakerLibrary.sentence

    ${dental_Chart}=  dental surface   3    ${dentalState[0]}     ${occlusal_des2}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${dental_status}    ${bool[0]}    ${dental_notes}    ${chiefIssue}   ${attachment}    ${attachment1}   
    Log   ${dental_Chart}

    ${teeth}=    Create List    ${dental_Chart}

    ${resp}=  Update Dental Chart with MR id    ${mr_id2}  teeth=${teeth}        
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get dental chart with mr id    ${mr_id2}  
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Updatedentalchart-8
    [Documentation]   Remove Latest toothId and again add.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Remove tooth details with MR id    ${mr_id2}  3 
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get dental chart with mr id    ${mr_id2}  
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${occlusal_des2}=  FakerLibrary.sentence

    ${dental_Chart}=  dental surface   3    ${dentalState[0]}     ${occlusal_des2}    ${occlusal_proc}    ${occlusal_symptoms}   ${occlusal_observations}   ${occlusal_diagnosis}    ${mesial_des}    ${mesial_proc}    ${mesial_symptoms}    ${mesial_observations}    ${mesial_diagnosis}  ${distal_des}    ${distal_proc}    ${distal_symptoms}    ${distal_observations}    ${distal_diagnosis}  ${buccal_des}    ${buccal_proc}    ${buccal_symptoms}    ${buccal_observations}    ${buccal_diagnosis}  ${lingual_des}    ${lingual_proc}    ${lingual_symptoms}    ${lingual_observations}    ${lingual_diagnosis}  ${incisal_des}    ${incisal_proc}    ${incisal_symptoms}    ${incisal_observations}    ${incisal_diagnosis}    ${dental_status}    ${bool[0]}    ${dental_notes}    ${chiefIssue}   ${attachment}    ${attachment1}   
    Log   ${dental_Chart}

    ${teeth}=    Create List    ${dental_Chart}

    ${resp}=  Update Dental Chart with MR id    ${mr_id2}  teeth=${teeth}        
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get dental chart with mr id    ${mr_id2}  
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200




