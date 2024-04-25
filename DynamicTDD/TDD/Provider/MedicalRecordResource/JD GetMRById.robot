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

*** Test Cases ***

JD-TC-GetMRById-1
    [Documentation]   Get Medical Record By Id for a waitlist(Walk-in).
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+780233
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    # # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id}  ${decrypted_data['id']}
    Set Suite Variable  ${userName}  ${decrypted_data['userName']}
    # Set Suite Variable    ${id}    ${resp.json()['id']} 
    # Set Suite Variable    ${userName}    ${resp.json()['userName']}    
    # ${pid}=  get_acc_id  ${PUSERNAME_C}
    # Set Suite Variable  ${pid}

    
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
    Set Suite Variable  ${pid}  ${resp.json()['id']}

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

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

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
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${C_date}=  Convert Date  ${CUR_DAY}  result_format=%d-%m-%Y
    Set Suite Variable   ${C_date}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    ${end_time}=    db.add_timezone_time  ${tz}  3  00  
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
    
    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${Pres_notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    Set Suite Variable    ${med_name}

    ${frequency}=     FakerLibrary.word
    Set Suite Variable    ${frequency}

    ${duration}=      FakerLibrary.sentence
    Set Suite Variable    ${duration}

    ${duration1}=      FakerLibrary.sentence
    Set Suite Variable    ${duration1}

    ${instrn}=        FakerLibrary.sentence
    Set Suite Variable    ${instrn}

    ${dosage}=        FakerLibrary.sentence
    Set Suite Variable    ${dosage}


    ${type}=     FakerLibrary.word
    Set Suite Variable    ${type}

    ${clinicalNote}=     FakerLibrary.word
    Set Suite Variable    ${clinicalNote}

    ${clinicalNote1}=        FakerLibrary.sentence
    Set Suite Variable    ${clinicalNote1}

    ${type1}=        FakerLibrary.sentence
    Set Suite Variable    ${type1}


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

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments1}

    ${Notes}=    clinical Notes Attachments    ${type}  ${clinicalNote}    ${aadhaarAttachments}    ${aadhaarAttachments}

    ${Notes1}=    clinical Notes Attachments    ${type1}  ${clinicalNote1}    ${aadhaarAttachments}    ${aadhaarAttachments1}

    ${clinicalNotes}=  Create List   ${Notes}    ${Notes1}
    Set Suite Variable  ${clinicalNotes}
   
    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}

    ${prescriptionsList}=  Create List   ${pre_list}
    
    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}
    Set Suite Variable  ${prescriptions}

    ${resp}=  Create MR With uuid  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileName']}              ${pdffile}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileType']}             ${fileType}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['caption']}             ${caption}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['duration']}              ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['frequency']}             ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['instructions']}          ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['medicine_name']}         ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['dosage']}                ${dosage}

    # ${MR_Description}=  Format String   ${MR_Description}    ${cid1}
    # ${PRE_Description}=  Format String   ${PRE_Description}    ${cid1}
    # ${CLINI_Description}=  Format String   ${CLINI_Description}  ${cid1}

    # Should Contain   ${resp.json()}   [{\"Action\":\"Prescription created\",\"Description\":\"Prescription created for patient id 1\",\"DateTime\":\"30-11-2020 10:37 AM\",\"User\":\"Christine Malone\"}]  

    # Should Be Equal As Strings  ${resp.json()['auditLogs']['prescription']'[0]['Action']'}            "${mraction[1]}"
    # Should Be Equal As Strings  ${resp.json()['auditLogs']['prescription'][0]['Description']}       ${MR_Description}
    # Should Be Equal As Strings  ${resp.json()['auditLogs']['prescription'][0]['User']}              ${userName}
    # Should Be Equal As Strings  ${resp.json()['auditLogs']['prescription'][0]['DateTime']}          ${C_date} ${ctime}

    # Should Be Equal As Strings  ${resp.json()['auditLogs']['clinicalNotes'][1]['Action']}            ${mraction[1]}
    # Should Be Equal As Strings  ${resp.json()['auditLogs']['clinicalNotes'][1]['Description']}       ${PRE_Description}
    # Should Be Equal As Strings  ${resp.json()['auditLogs']['clinicalNotes'][1]['User']}              ${userName}
    # Should Be Equal As Strings  ${resp.json()['auditLogs']['clinicalNotes'][1]['DateTime']}          ${C_date} ${ctime}

    # Should Be Equal As Strings  ${resp.json()['auditLogs']['medicalRecord'][2]['Action']}            ${mraction[2]}
    # Should Be Equal As Strings  ${resp.json()['auditLogs']['medicalRecord'][2]['Description']}       ${CLINI_Description}
    # Should Be Equal As Strings  ${resp.json()['auditLogs']['medicalRecord'][2]['User']}              ${userName}
    # Should Be Equal As Strings  ${resp.json()['auditLogs']['medicalRecord'][2]['DateTime']}          ${C_date} ${ctime}
   

JD-TC-GetMRById-2
    [Documentation]   Get Medical Record for multiple waitlist(walk-in).

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+7854782
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_D}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_D}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    # Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_D}${\n}
    Set Suite Variable  ${PUSERNAME_D}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id1}  ${decrypted_data['id']}
    # Set Suite Variable    ${id1}    ${resp.json()['id']} 
    
    
    # ${pid0}=  get_acc_id  ${PUSERNAME_D}
    # Set Suite Variable  ${pid0}

    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_D}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_D}+25566122
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
    Set Suite Variable    ${DAY1}
    ${sTime}=  db.add_timezone_time  ${tz}  0  15
    ${eTime}=  db.add_timezone_time  ${tz}   0  45
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid0}  ${resp.json()['id']}

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

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   

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
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id2}    ${resp} 
    ${resp}=   Get Location ById  ${loc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}   
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${resp}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable    ${ser_id3}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    Set Suite Variable  ${strt_time}
    ${end_time}=    db.add_timezone_time  ${tz}  3  00  
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id2}  ${ser_id2}   ${ser_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${FUT_DAY}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id2}  ${que_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id3}  ${que_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${ctime}=         db.get_time_by_timezone   ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${wid2}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id2}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid2}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileName']}              ${pdffile}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileType']}             ${fileType}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['caption']}             ${caption}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['duration']}              ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['frequency']}             ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['instructions']}          ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['medicine_name']}         ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['dosage']}                ${dosage}

    # ${ctime}=          db.get_time_by_timezone   ${tz}
    # ${complaint1}=     FakerLibrary.word
    # ${symptoms1}=      FakerLibrary.sentence
    # ${allergies1}=     FakerLibrary.sentence
    # ${vacc_history1}=  FakerLibrary.sentence
    # ${observations1}=  FakerLibrary.sentence
    # ${diagnosis1}=     FakerLibrary.sentence
    # ${misc_notes1}=    FakerLibrary.sentence
    # ${notes1}=         FakerLibrary.sentence
    # ${med_name1}=      FakerLibrary.name
    # ${frequency1}=     FakerLibrary.word
    # ${duration1}=      FakerLibrary.sentence
    # ${instrn1}=        FakerLibrary.sentence
    # ${dosage1}=        FakerLibrary.sentence

    # ${pre_list1}=  Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  duration=${duration1}  instructions=${instrn1}  dosage=${dosage1}
    
    ${resp}=  Create MR With uuid  ${wid3}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id3}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid3}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id3}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileName']}              ${pdffile}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileType']}             ${fileType}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['caption']}             ${caption}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['duration']}              ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['frequency']}             ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['instructions']}          ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['medicine_name']}         ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['dosage']}                ${dosage}

JD-TC-GetMRById-3
    [Documentation]   Get Medical Record for a waitlist(online-in).

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id2}  ${CUR_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${pid0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    
    ${ctime}=          db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    
    ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}
    
    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME5}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileName']}              ${pdffile}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileType']}             ${fileType}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['caption']}             ${caption}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['duration']}              ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['frequency']}             ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['instructions']}          ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['medicine_name']}         ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['dosage']}                ${dosage}

JD-TC-GetMRById-4
    [Documentation]   Get Medical Record with consultation mode EMAIL for waitlist.

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id2}  ${CUR_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${pid0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}
    
    ${ctime}=          db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[0]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME6}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileName']}              ${pdffile}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileType']}             ${fileType}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['caption']}             ${caption}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['duration']}              ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['frequency']}             ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['instructions']}          ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['medicine_name']}         ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['dosage']}                ${dosage}


JD-TC-GetMRById-5
    [Documentation]   Get Medical Record with consultation mode PHONE for waitlist.

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${waitlist_id}   ${bookingType[0]}  ${consultationMode[1]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}
    
    # sleep  1s
    ${ctime}=     db.get_time_by_timezone   ${tz}
    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cons_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME7}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${waitlist_id}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[1]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileName']}              ${pdffile}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileType']}             ${fileType}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['caption']}             ${caption}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['duration']}              ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['frequency']}             ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['instructions']}          ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['medicine_name']}         ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['dosage']}                ${dosage}

  
JD-TC-GetMRById-6
    [Documentation]   Get Medical Record with consultation mode VIDEO for waitlist.

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    ${ctime}=          db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[2]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}
    
    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cons_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME8}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${waitlist_id}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[2]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileName']}              ${pdffile}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileType']}             ${fileType}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['caption']}             ${caption}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['duration']}              ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['frequency']}             ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['instructions']}          ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['medicine_name']}         ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['dosage']}                ${dosage}

JD-TC-GetMRById-7
    [Documentation]   Get Medical Record without details.

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${DAY2}=  db.add_timezone_date  ${tz}   2
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${DAY1}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${ctime}=          db.get_time_by_timezone   ${tz}
    ${Pres_notes}=         FakerLibrary.sentence


    ${pre_list}=  Create Dictionary  medicine_name=${EMPTY}  frequency=${EMPTY}  duration=${EMPTY}  instructions=${EMPTY}  dosage=${EMPTY}
    ${prescriptionsList}=  Create List   ${pre_list}
    
    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}
    
    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cons_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME10}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${waitlist_id}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
    # Should Be Equal As Strings  ${resp.json()['clinicalNotes']['symptoms']}            ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['clinicalNotes']['allergies']}           ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['clinicalNotes']['diagnosis']}           ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['clinicalNotes']['complaints']}          ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['clinicalNotes']['misc_notes']}          ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['clinicalNotes']['observations']}        ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['clinicalNotes']['vaccinationHistory']}  ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['duration']}              ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['frequency']}             ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['instructions']}          ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['medicine_name']}         ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['dosage']}                ${EMPTY}

JD-TC-GetMRById-8
    [Documentation]   Get Medical Record with two prescriptions.

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${DAY3}=  db.add_timezone_date  ${tz}  3
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${DAY1}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${ctime}=          db.get_time_by_timezone   ${tz}
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

    ${med_name1}=      FakerLibrary.name
    ${frequency1}=     FakerLibrary.word
    ${duration1}=      FakerLibrary.sentence
    ${instrn1}=        FakerLibrary.sentence
    ${dosage1}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    ${pre_list1}=  Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  duration=${duration1}  instructions=${instrn1}  dosage=${dosage1}
    
    ${prescriptionsList}=  Create List   ${pre_list}    ${pre_list1}
    
    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}

    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cons_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME11}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${waitlist_id}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileName']}              ${pdffile}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileType']}             ${fileType}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['caption']}             ${caption}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['duration']}              ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['frequency']}             ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['instructions']}          ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['medicine_name']}         ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['dosage']}                ${dosage}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][1]['duration']}              ${duration1}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][1]['frequency']}             ${frequency1}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][1]['instructions']}          ${instrn1}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][1]['medicine_name']}         ${med_name1}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][1]['dosage']}                ${dosage1}

JD-TC-GetMRById-9
    [Documentation]   Get Medical Record with inactive status.

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${DAY}=  db.add_timezone_date  ${tz}   1
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${DAY1}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${ctime}=          db.get_time_by_timezone   ${tz}
    # ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY}    ${status[1]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cons_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME12}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${waitlist_id}
    Should Be Equal As Strings  ${resp.json()['state']}                             ${status[0]}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileName']}              ${pdffile}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileType']}             ${fileType}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['caption']}             ${caption}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['duration']}              ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['frequency']}             ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['instructions']}          ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['medicine_name']}         ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['dosage']}                ${dosage}

JD-TC-GetMRById-10
    [Documentation]   Get Medical Record for family member's waitlist(walkin check-in).

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}
       
    ${DAY}=  db.add_timezone_date  ${tz}   1
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${DAY1}  ${ser_id1}  ${cnote}  ${bool[0]}  ${cidfor}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id   ${waitlist_id}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${notes}=         FakerLibrary.sentence
    # ${med_name}=      FakerLibrary.name
    # ${frequency}=     FakerLibrary.word
    # ${duration}=      FakerLibrary.sentence
    # ${instrn}=        FakerLibrary.sentence
    # ${dosage}=        FakerLibrary.sentence

    # ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${waitlist_id}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id1}   ${resp.json()}
    
    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cons_id}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME9}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${waitlist_id}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileName']}              ${pdffile}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['fileType']}             ${fileType}
    Should Be Equal As Strings  ${resp.json()['clinicalNotes'][0]['attachments'][0]['caption']}             ${caption}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['duration']}              ${duration}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['frequency']}             ${frequency}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['instructions']}          ${instrn}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['medicine_name']}         ${med_name}
    Should Be Equal As Strings  ${resp.json()['prescriptions']['prescriptionsList'][0]['dosage']}                ${dosage}


JD-TC-GetMRById-11
    [Documentation]   Create MR and then cancel the waitlist and try to get MR.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}   
    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id2}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${resp}=  Create MR   ${wid3}  ${bookingType[0]}  ${consultationMode[3]}  ${CUR_DAY}  ${status[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id3}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid3}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid3}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}

    ${desc}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Waitlist By Id  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}

    ${resp}=  Get MR By Id  ${mr_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetMRById-UH1
    [Documentation]   Get MR for canceled waitlist.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_customer   ${PUSERNAME_D}

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}   
    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id2}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Waitlist By Id  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}

    ${resp}=  Get MR By Id  ${mr_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MEDICAL_RECORD_NOT_FOUND}"

JD-TC-GetMRById-UH2
    [Documentation]   Get MR  for another provider's MR.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get MR By Id   ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MEDICAL_RECORD_NOT_FOUND}"

JD-TC-GetMRById-UH3
    [Documentation]   Get MR By Id  without login.

    ${resp}=  Get MR By Id    ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetMRById-UH4
    [Documentation]   Get MR By Id  with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get MR By Id    ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetMRById-UH5
    [Documentation]   Get MR By Id  with invalid MR id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get MR By Id    000
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MEDICAL_RECORD_NOT_FOUND}"















